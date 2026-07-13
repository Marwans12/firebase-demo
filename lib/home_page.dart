import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_demo_1/components/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser as User;
  final db = FirebaseFirestore.instance;
  late var documentsReference = db.collection(
    "users/${currentUser.uid}/documents/",
  );
  late var trashReference = db.collection("users/${currentUser.uid}/trash/");
  late Stream<QuerySnapshot<Map<String, dynamic>>> documentsSnapshots;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (currentUser.emailVerified == false) {
        showDialog(
          context: context,
          builder: (_) {
            return EmailVerificationDialog();
          },
        );
      }
    });
    documentsSnapshots = documentsReference.snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notes"), backgroundColor: Colors.blue),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var newDocument = documentsReference.doc();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  NotePage(documentReference: newDocument, isNewDoc: true),
            ),
          );
        },
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              accountName: Text(currentUser.displayName ?? "User"),
              accountEmail: Text(currentUser.email ?? ""),
              currentAccountPicture: StyledCircleAvatar(
                imageUrl: currentUser.photoURL,
              ),
            ),
            TextButton(
              child: Text("Sign out"),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed("/login");
                }
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: documentsSnapshots,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text("Error Ocurred: ${snapshot.error}");
          }
          if (snapshot.data == null || snapshot.data!.size == 0) {
            return Text(
              "No notes found. Press the + button to create your first note",
            );
          }
          var notes = snapshot.data!.docs;
          var notesCount = snapshot.data!.size;
          return ListView.builder(
            itemCount: notesCount,
            itemBuilder: (context, index) {
              return NoteListTile(noteSnapshot: notes[index]);
            },
          );
        },
      ),
    );
  }
}

class NoteListTile extends StatelessWidget {
  const NoteListTile({super.key, required this.noteSnapshot});
  final QueryDocumentSnapshot<Map<String, dynamic>> noteSnapshot;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => NotePage(
              documentReference: noteSnapshot.reference,
              isNewDoc: false,
            ),
          ),
        );
      },
      isThreeLine: false,
      leading: Icon(Icons.note),
      title: Text(noteSnapshot.get("title"), maxLines: 1),
      subtitle: Text(noteSnapshot.get("content"), maxLines: 1),
      trailing: IconButton(
        onPressed: () async {
          var user = FirebaseAuth.instance.currentUser as User;
          var scaffoldMessenger = ScaffoldMessenger.of(context);
          var db = FirebaseFirestore.instance;
          var docId = noteSnapshot.id;
          var docData = noteSnapshot.data();
          var trashDocumentReference = db
              .collection("/users/${user.uid}/trash")
              .doc(docId);
          await trashDocumentReference.set(docData);
          await noteSnapshot.reference.delete();
          if (scaffoldMessenger.mounted) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                persist: false,
                content: SizedBox(
                  width: 50,
                  child: Text(noteSnapshot.get("title"), maxLines: 1),
                ),
                action: SnackBarAction(
                  label: "nullDebug",
                  onPressed: () {
                    noteSnapshot.reference.set(docData);
                    trashDocumentReference.delete();
                  },
                ),
              ),
            );
          }
        },
        icon: Icon(Icons.delete),
      ),
    );
  }
}

class NotePage extends StatefulWidget {
  const NotePage({
    super.key,
    required this.documentReference,
    required this.isNewDoc,
  });
  final DocumentReference<Map<String, dynamic>> documentReference;
  final bool isNewDoc;
  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final timeStampTitle = DateTime.now().toString();
  final titleController = TextEditingController();
  final titleFocusNode = FocusNode();
  final contentController = TextEditingController();
  final contentFocusnode = FocusNode();
  final scrollController = ScrollController();
  late final DocumentSnapshot<Map<String, dynamic>> noteSnapshot;
  var initialName = "";
  @override
  void initState() {
    if (widget.isNewDoc) {
      titleController.text = timeStampTitle;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        titleFocusNode.requestFocus();
        titleController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: titleController.text.length,
        );
      });
    } else {
      populateText();
      SchedulerBinding.instance.addPostFrameCallback(
        (_) => contentFocusnode.requestFocus(),
      );
    }

    super.initState();
  }

  Future<void> populateText() async {
    noteSnapshot = await widget.documentReference.get(
      GetOptions(source: Source.cache),
    );
    titleController.text = noteSnapshot.get("title");
    initialName = titleController.text;
    contentController.text = noteSnapshot.get("content");
  }

  @override
  void dispose() {
    titleController.dispose();
    titleFocusNode.dispose();
    contentController.dispose();
    contentFocusnode.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        actions: [
          TextButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Note name is empty")));
                return;
              }
              var data = {
                "title": titleController.text,
                "content": contentController.text,
                if (widget.isNewDoc)
                  "creationTimeStamp": FieldValue.serverTimestamp(),
                "modifiedTimeStamp": FieldValue.serverTimestamp(),
              };
              var documentsReference = widget.documentReference.parent;
              if (titleController.text != initialName) {
                var sameTitleCount = await documentsReference
                    .where("title", isEqualTo: titleController.text)
                    .count()
                    .get();
                if (sameTitleCount.count! > 0) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Document with the same name already exists",
                        ),
                      ),
                    );
                  }
                  return;
                }
              }
              widget.documentReference.set(data);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
        title: TextField(
          controller: titleController,
          focusNode: titleFocusNode,
          decoration: null,
        ),
      ),
      body: SizedBox.expand(
        child: Scrollbar(
          controller: scrollController,
          thumbVisibility: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              scrollController: scrollController,
              focusNode: contentFocusnode,
              controller: contentController,
              decoration: null,
              maxLines: null,
            ),
          ),
        ),
      ),
    );
  }
}

class EmailVerificationDialog extends StatefulWidget {
  const EmailVerificationDialog({super.key});

  @override
  State<EmailVerificationDialog> createState() =>
      _EmailVerificationDialogState();
}

class _EmailVerificationDialogState extends State<EmailVerificationDialog> {
  Timer? timer;
  var count = 0;
  var message =
      "A verification email has been sent. Please follow the instruction and come back once you have verified your email.";
  var currentUser = FirebaseAuth.instance.currentUser as User;

  Future<void> reloadUser() async {
    if (!currentUser.emailVerified) {
      await currentUser.reload();
      currentUser = FirebaseAuth.instance.currentUser as User;
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser.emailVerified) {
      Navigator.of(context).pop();
    }
    return PopScope(
      canPop: false,
      child: SimpleDialog(
        title: Text("Email verification", textAlign: TextAlign.center),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Text(message, textAlign: TextAlign.justify),
                Row(
                  children: [
                    FilledButton(
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                      ),
                      onPressed: () async {
                        await reloadUser();
                        if (currentUser.emailVerified) {
                          if (context.mounted) Navigator.of(context).pop();
                        } else {
                          setState(() {
                            message =
                                "Email not verified. Make sure to visit your email and click verification link.";
                          });
                        }
                      },
                      child: Text("Check verifcation status"),
                    ),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                        ),
                        onPressed: count > 0 || currentUser.emailVerified
                            ? null
                            : () async {
                                await reloadUser();
                                if (currentUser.emailVerified) {
                                  if (context.mounted)
                                    Navigator.of(context).pop();
                                } else {
                                  currentUser.sendEmailVerification();
                                  setState(() {
                                    count = 60;
                                  });
                                  timer = Timer.periodic(Duration(seconds: 1), (
                                    timer,
                                  ) {
                                    setState(() {
                                      count -= 1;
                                    });
                                    if (count == 0) timer.cancel();
                                  });
                                }
                              },
                        child: Text(
                          count > 0 ? count.toString() : "Resend email",
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
