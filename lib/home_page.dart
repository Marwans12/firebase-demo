import "dart:async";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "components/shared.dart";
import "models.dart";
import "notes_listing_page.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final auth = FirebaseAuth.instance;
  final currentUser = FirebaseAuth.instance.currentUser as User;
  final categoryNameController = TextEditingController();
  late final userIDDocReference = FirebaseFirestore.instance.doc(
    "dummyUsers/${currentUser.uid}/",
  );
  late final categoriesCollectionReference = userIDDocReference
      .collection("folders")
      .withConverter(
        fromFirestore: Category.fromFirestore,
        toFirestore: (category, _) => category.toFirestore(),
      );
  late final categoryManager = CategoryCollectionManager(
    categoriesCollectionReference,
  );
  StreamSubscription<QuerySnapshot<Category>>? streamSubscription;
  var isFetching = false;

  @override
  void initState() {
    super.initState();
    if (!currentUser.emailVerified) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        handleUserVerification(context);
      });
    } else {
      () async {
        setState(() {
          isFetching = true;
        });
        if ((await userIDDocReference.get()).exists == false) {
          var batch = FirebaseFirestore.instance.batch();
          var defaultCategoryRef = categoriesCollectionReference.doc();
          var defaultNoteRef = defaultCategoryRef
              .collection("notes")
              .withConverter(
                fromFirestore: Note.fromFirestore,
                toFirestore: (note, _) => note.toFirestore(),
              )
              .doc();
          batch.set(userIDDocReference, {
            "id": userIDDocReference.id,
            "uid": currentUser.uid,
            "email": currentUser.email,
          });
          batch.set<Category>(
            defaultCategoryRef,
            Category(
              id: defaultCategoryRef.id,
              name: "My Notes",
              creationTime: DateTime.now(),
              lastEditedTime: DateTime.now(),
            ),
          );
          batch.set<Note>(
            defaultNoteRef,
            Note(
              id: defaultNoteRef.id,
              title: "Welcome",
              content: "Welcome to your personal app for taking notes...",
              categoryID: defaultCategoryRef.id,
              creationTime: DateTime.now(),
              lastEditedTime: DateTime.now(),
            ),
          );
          await batch.commit();
        }
        //TODO: Implement loading from stream
        streamSubscription = categoriesCollectionReference.snapshots().listen((
          snapshot,
        ) {
          for (var docChange in snapshot.docChanges) {
            var category = docChange.doc.data()!;
            if (docChange.type == DocumentChangeType.added) {
              categoryManager.addIncoming(category, docChange.doc.reference);
            } else if (docChange.type == DocumentChangeType.removed) {
              categoryManager.deleteIncoming(category);
            } else if (docChange.type == DocumentChangeType.modified) {
              categoryManager.updateIncoming(category);
            }
          }
          setState(() {
            //categoryManager
          });
        });
        setState(() {
          isFetching = false;
        });
      }();
    }
  }

  Future<void> handleUserVerification(BuildContext context) async {
    bool? dialogueResult;

    dialogueResult = await showDialog<bool>(
      context: context,
      builder: (context) {
        return _UserNotVerifiedDialog();
      },
    );
    if (dialogueResult != true) {
      auth.signOut();
      if (context.mounted) Navigator.of(context).pushReplacementNamed("/login");
      return;
    }
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    categoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Folders")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          categoryNameController.text = DateTime.now().toString().split(".")[0];
          final formKey = GlobalKey<FormState>();
          var isCreated = await showDialog<bool>(
            context: context,
            builder: (context) {
              return _NewCategoryDialogue(
                formKey: formKey,
                controller: categoryNameController,
                categories: categoryManager.docs,
              );
            },
          );
          if (isCreated == true) {
            var category = Category(name: categoryNameController.text);
            categoryManager.add(category);
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
                Navigator.of(context).pushReplacementNamed("/login");
              },
              child: Text("Sign out"),
            ),
            TextButton(
              onPressed: () async {
                await categoryManager.resyncDocs();
                setState(() {//categoryManager
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
                children: List.generate(categoryManager.docs.length, (index) {
                  var category = categoryManager.docs[index];
                  var categoryReference =
                      categoryManager.docsReferences[category]!;
                  return ListTile(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => NotesListing(
                          category: category,
                          categoryReference: categoryReference,
                        ),
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),

                    leading: Image.asset("assets/collection_icon.png"),
                    title: Text(
                      category.name,
                      maxLines: 2,
                      overflow: .ellipsis,
                    ),
                    trailing: IconButton(
                      onPressed: () => categoryManager.delete(category),
                      icon: Icon(Icons.delete),
                    ),
                  );
                }),
              ),
            ),
    );
  }
}

class _NewCategoryDialogue extends StatelessWidget {
  const _NewCategoryDialogue({
    required this.formKey,
    required this.controller,
    required this.categories,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    var navigator = Navigator.of(context);
    return AlertDialog(
      title: Text("Create New Folder"),
      content: Column(
        mainAxisSize: .min,
        children: [
          Align(alignment: .centerLeft, child: Text("Folder Name")),
          SizedBox(height: 5, width: .maxFinite),
          Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Name Can't be empty";
                }
                for (var category in categories) {
                  if (value.toLowerCase() == category.name.toLowerCase()) {
                    return "Folder already exists";
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

class _UserNotVerifiedDialog extends StatelessWidget {
  const _UserNotVerifiedDialog();

  @override
  Widget build(BuildContext context) {
    var navigator = Navigator.of(context);
    var currentUser = FirebaseAuth.instance.currentUser as User;
    var showSnackBar = ScaffoldMessenger.of(context).showSnackBar;
    return AlertDialog(
      title: Text("Email Verification"),
      content: Text(
        "Your email is not verified. Head to your email and click the verifcation link.",
      ),
      actions: [
        _TimedTextButton(
          onPressed: () async {
            var loadingOverlay = LoadingOverlay(context);
            try {
              Overlay.of(context).insert(loadingOverlay);
              await currentUser.reload();
              loadingOverlay.remove();
              loadingOverlay.dispose();
            } on FirebaseAuthException catch (e) {
              showSnackBar(SnackBar(content: Text("Error: ${e.code}")));
              loadingOverlay.remove();
              loadingOverlay.dispose();
              return;
            }
            if (currentUser.emailVerified) {
              showSnackBar(SnackBar(content: Text("User is verified")));
              navigator.pop(true);
            } else {
              showSnackBar(SnackBar(content: Text("User is not yet verified")));
            }
          },
          seconds: 5,
          buttonText: "Check Status",
        ),
        _TimedTextButton(
          onPressed: () async {
            try {
              await FirebaseAuth.instance.currentUser!.sendEmailVerification();
            } on FirebaseAuthException catch (e) {
              showSnackBar(SnackBar(content: Text("Error: ${e.code}")));
              return;
            }
            showSnackBar(
              SnackBar(content: Text("Verification Email has been sent")),
            );
          },
          seconds: 60,
          buttonText: "Send Verification Email",
        ),
        TextButton(
          onPressed: () {
            navigator.pop();
          },
          child: Text("Cancel"),
        ),
      ],
    );
  }
}

class _TimedTextButton extends StatefulWidget {
  const _TimedTextButton({
    required this.buttonText,
    this.onPressed,
    required this.seconds,
  });

  final int seconds;
  final String buttonText;
  final VoidCallback? onPressed;
  @override
  State<_TimedTextButton> createState() => _TimedTextButtonState();
}

class _TimedTextButtonState extends State<_TimedTextButton> {
  late var buttonText = widget.buttonText;
  late var isEnabled = widget.onPressed == null ? false : true;
  late var count = widget.seconds;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isEnabled
          ? () {
              setState(() {
                isEnabled = false;
              });

              timer = Timer.periodic(Duration(seconds: 1), (timer) {
                setState(() {
                  count -= 1;
                });
                if (count <= 0) {
                  timer.cancel();
                  isEnabled = true;
                  count = widget.seconds;
                }
              });

              widget.onPressed?.call();
            }
          : null,
      child: Text(
        isEnabled ? widget.buttonText : "${widget.buttonText} ($count)",
      ),
    );
  }
}
