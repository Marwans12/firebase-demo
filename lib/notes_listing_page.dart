import "dart:async";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:note_app/note_page.dart";


class NotesListing extends StatefulWidget {
  const NotesListing({super.key, required this.categorySnapshot});

  final QueryDocumentSnapshot<Map<String, dynamic>> categorySnapshot;
  @override
  State<NotesListing> createState() => _NotesListingState();
}

class _NotesListingState extends State<NotesListing> {
  final auth = FirebaseAuth.instance;
  final currentUser = FirebaseAuth.instance.currentUser as User;
  late final categoryName = widget.categorySnapshot.get("name");
  late final docsReference = widget.categorySnapshot.reference.collection(
    "docs",
  );
  late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
  streamSubscription;
  var notes = <QueryDocumentSnapshot<Map<String, dynamic>>>[];

  @override
  void initState() {
    super.initState();
    streamSubscription = docsReference.snapshots().listen((event) {
      setState(() {
        notes = event.docs;
      });
    });
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var navigator = Navigator.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showDialog<bool>(
            context: context,
            builder: (context) {
              return NewNoteDialogue(
                notes: notes,
                category: widget.categorySnapshot,
              );
            },
          );
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
          ],
        ),
      ),
      body: Scrollbar(
        child: ListView(
          children: List.generate(notes.length, (index) {
            var note = notes[index];
            return ListTile(
              onTap: () => navigator.push(
                MaterialPageRoute(builder: (context) => NotePage(note: note)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
              leading: Image.asset("assets/note_icon.png"),
              title: Text(note.get("name"),  overflow: .ellipsis, style: TextStyle(fontSize: 14)),
              subtitle: Text(note.get("content"), maxLines: 1,overflow: .fade,),
              trailing: IconButton(
                onPressed: () async {
                  var isConfirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return ConfirmNoteDeletionDialog(note: note);
                    },
                  );
                  if (isConfirmed == true) {
                    note.reference.delete();
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

class NewNoteDialogue extends StatefulWidget {
  const NewNoteDialogue({
    super.key,
    required this.notes,
    required this.category,
  });

  final QueryDocumentSnapshot<Map<String, dynamic>> category;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> notes;

  @override
  State<NewNoteDialogue> createState() => _NewNoteDialogueState();
}

class _NewNoteDialogueState extends State<NewNoteDialogue> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController controller = TextEditingController();
  late final categoryName = widget.category.get("name");
  late final CollectionReference<Map<String, dynamic>> docsReference =
      widget.category.reference.collection("docs");

  @override
  void initState() {
    controller.text = DateTime.now().toString().split(".")[0];
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var navigator = Navigator.of(context);
    return AlertDialog(
      title: Text("Create New Note"),
      content: Column(
        mainAxisSize: .min,
        children: [
          Align(alignment: .centerLeft, child: Text("Note Name")),
          SizedBox(height: 5, width: .maxFinite),
          Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Name Can't be empty";
                }
                for (var note in widget.notes) {
                  if (value == note.get("name")) {
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
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              var note = await (await docsReference.add({
                "name": controller.text.toLowerCase(),
                "category": categoryName,
                "content": "",
              })).get();
              if (context.mounted) {
                navigator.pushReplacement(
                  MaterialPageRoute(builder: (context) => NotePage(note: note)),
                );
              }
            }
          },
          child: Text("Create"),
        ),
        TextButton(onPressed: () => navigator.pop(), child: Text("Cancel")),
      ],
    );
  }
}
