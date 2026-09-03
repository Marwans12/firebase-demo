import "dart:async";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:note_app/components/shared.dart";
import "package:note_app/notes_listing_page.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final auth = FirebaseAuth.instance;
  final currentUser = FirebaseAuth.instance.currentUser as User;
  late final dbHomeReference = FirebaseFirestore.instance.doc(
    "dummyUsers/${currentUser.uid}/",
  );
  late final categoriesReference = dbHomeReference.collection("categories");
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? streamSubscription;
  var categories = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
  final categoryNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!currentUser.emailVerified) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        handleUserVerification(context);
      });
    } else {
      streamSubscription = categoriesReference.snapshots().listen((event) {
        setState(() {
          categories = event.docs;
        });
      });
    }
  }

  Future<void> handleUserVerification(BuildContext context) async {
    bool? dialogueResult;

    dialogueResult = await showDialog<bool>(
      context: context,
      builder: (context) {
        return UserNotVerifiedDialog();
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
      appBar: AppBar(title: Text("Categories")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          categoryNameController.text = DateTime.now().toString();
          final formKey = GlobalKey<FormState>();
          var isCreated = await showDialog<bool>(
            context: context,
            builder: (context) {
              return NewCategoryDialogue(
                formKey: formKey,
                controller: categoryNameController,
                categories: categories,
              );
            },
          );
          if (isCreated == true) {
            categoriesReference.add({
              "name": categoryNameController.text.toLowerCase(),
            });
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
          ],
        ),
      ),
      body: Scrollbar(
        child: ListView(
          children: List.generate(categories.length, (index) {
            var category = categories[index];
            return ListTile(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NotesListing(
                    categorySnapshot: category,
                  ),
                ),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
      
              leading: Image.asset("assets/collection_icon.png"),
              title: Text(
                category.get("name"),
                maxLines: 2,
                overflow: .ellipsis,
              ),
              trailing: IconButton(
                onPressed: () => category.reference.delete(),
                icon: Icon(Icons.delete),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class NewCategoryDialogue extends StatelessWidget {
  const NewCategoryDialogue({
    super.key,
    required this.formKey,
    required this.controller,
    required this.categories,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> categories;

  @override
  Widget build(BuildContext context) {
    var navigator = Navigator.of(context);
    return AlertDialog(
      title: Text("Create New Category"),
      content: Column(
        mainAxisSize: .min,
        children: [
          Align(alignment: .centerLeft, child: Text("Category Name")),
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
                  if (value == category.get("name")) {
                    return "Category already exists";
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

class UserNotVerifiedDialog extends StatelessWidget {
  const UserNotVerifiedDialog({super.key});

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
        TimedTextButton(
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
        TimedTextButton(
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

class TimedTextButton extends StatefulWidget {
  const TimedTextButton({
    super.key,
    required this.buttonText,
    this.onPressed,
    required this.seconds,
  });

  final int seconds;
  final String buttonText;
  final VoidCallback? onPressed;
  @override
  State<TimedTextButton> createState() => _TimedTextButtonState();
}

class _TimedTextButtonState extends State<TimedTextButton> {
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
