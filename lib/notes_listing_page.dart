import "dart:async";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "components/shared.dart";
import "note_page.dart";
import "models.dart";

class NotesListing extends StatefulWidget {
  const NotesListing({
    super.key,
    required this.category,
    required this.categoryReference,
  });

  final Category category;
  final DocumentReference<Category> categoryReference;
  @override
  State<NotesListing> createState() => _NotesListingState();
}

class _NotesListingState extends State<NotesListing> {
  final auth = FirebaseAuth.instance;
  final currentUser = FirebaseAuth.instance.currentUser as User;
  final noteNameController = TextEditingController();
  late final categoryName = widget.category.name;
  late final notesCollectionReference = widget.categoryReference
      .collection("notes")
      .withConverter(
        fromFirestore: Note.fromFirestore,
        toFirestore: (note, _) => note.toFirestore(),
      );
  late final notesManager = NotesCollectionManager(notesCollectionReference);
  StreamSubscription<QuerySnapshot<Note>>? streamSubscription;
  var isFetching = false;

  @override
  void initState() {
    super.initState();
    () async {
      setState(() {
        isFetching = true;
      });
      //TODO: implement loading from stream
      streamSubscription = notesCollectionReference.snapshots().listen((
        snapshot,
      ) {
        for (var docChange in snapshot.docChanges) {
          var category = docChange.doc.data()!;
          if (docChange.type == DocumentChangeType.added) {
            notesManager.addIncoming(category, docChange.doc.reference);
          } else if (docChange.type == DocumentChangeType.removed) {
            notesManager.deleteIncoming(category);
          } else if (docChange.type == DocumentChangeType.modified) {
            notesManager.updateIncoming(category);
          }
        }
        setState(() {
          // notesManager.docs is updated
        });
      });
      setState(() {
        isFetching = false;
      });
    }();
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    noteNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var navigator = Navigator.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final formKey = GlobalKey<FormState>();
          noteNameController.text = DateTime.now().toString().split(".")[0];
          var isCreated = await showDialog<bool>(
            context: context,
            builder: (context) {
              return _NewNoteDialogue(
                notes: notesManager.docs,
                controller: noteNameController,
                formKey: formKey,
              );
            },
          );
          if (isCreated == true) {
            var note = Note(
              title: noteNameController.text,
              categoryID: widget.category.id!,
            );
            notesManager.add(note);
            navigator.push(
              MaterialPageRoute(
                builder: (_) =>
                    NotePage(note: note, notesManager: notesManager),
              ),
            );
          }
        },
        child: Icon(Icons.add),
      ),
      endDrawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: currentUser.photoURL == null
                  ? null
                  : Image.network(currentUser.photoURL!),
              accountName: Text(currentUser.displayName ?? ""),
              accountEmail: Text(currentUser.email ?? ""),
            ),
            TextButton(
              onPressed: () {
                auth.signOut();
                navigator.pushReplacementNamed("/login");
              },
              child: Text("Sign out"),
            ),
            TextButton(
              onPressed: () async {
                await notesManager.resyncDocs();
                setState(() {
                  // notesManager.resyncDocs() -> notesManager.docs
                });
              },
              child: Text("Debug sync Entries."),
            ),
          ],
        ),
      ),
      body: isFetching
          ? Center(child: CircularProgressIndicator())
          : Scrollbar(
              child: ListView(
                children: List.generate(notesManager.docs.length, (index) {
                  var note = notesManager.docs[index];
                  return ListTile(
                    onTap: () => navigator.push(
                      MaterialPageRoute(
                        builder: (context) =>
                            NotePage(note: note, notesManager: notesManager),
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    leading: Image.asset("assets/note_icon.png"),
                    title: Text(
                      note.title,
                      overflow: .ellipsis,
                      style: TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      note.content,
                      maxLines: 1,
                      overflow: .ellipsis,
                    ),
                    trailing: IconButton(
                      onPressed: () async {
                        var isConfirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return ConfirmDocDeletionDialog(
                              deletedName: note.title,
                            );
                          },
                        );
                        if (isConfirmed == true) {
                          notesManager.delete(note);
                        }
                      },
                      icon: Icon(Icons.delete),
                    ),
                  );
                }),
              ),
            ),
    );
  }
}

class _NewNoteDialogue extends StatelessWidget {
  const _NewNoteDialogue({
    required this.formKey,
    required this.controller,
    required this.notes,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final List<Note> notes;

  @override
  Widget build(BuildContext context) {
    var navigator = Navigator.of(context);
    return AlertDialog(
      title: Text("Create New Note"),
      content: Column(
        mainAxisSize: .min,
        children: [
          Align(alignment: .centerLeft, child: Text("Note title")),
          SizedBox(height: 5, width: .maxFinite),
          Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Title Can't be empty";
                }
                for (var note in notes) {
                  if (value.toLowerCase() == note.title.toLowerCase()) {
                    return "Note already exists";
                  }
                }
                return null;
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              navigator.pop(true);
            }
          },
          child: Text("Create"),
        ),
        TextButton(onPressed: () => navigator.pop(), child: Text("Cancel")),
      ],
    );
  }
}
