import "dart:async";

import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:note_app/components/shared.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final auth = FirebaseAuth.instance;
  final currentUser = FirebaseAuth.instance.currentUser as User;
  final scrollController = ScrollController();
  @override
  void initState() {
    if (!currentUser.emailVerified) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        handleUserVerification(context);
      });
    }
    super.initState();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    var list = [
      "adsf",
      "adfag",
      "adsfk",
      "adsf",
      "adfag",
      "adsfk",
      "adsf",
      "adfag",
      "adsfk",
    ];
    double height = 220;
    return Scaffold(
      appBar: AppBar(title: Text("Home Directory")),
      drawer: Drawer(
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
          controller: scrollController,
          children: [
            // SizedBox(
            //   height: height,
            //   child: GridView.count(
            //     mainAxisSpacing: 10,
            //     childAspectRatio: 0.75,
            //     crossAxisCount: 2,
            //     scrollDirection: .horizontal,
            //     children: [
            //       ...list.map((elem) {
            //         return CollectionCard(text: elem);
            //       }),
            //     ],
            //   ),
            // ),
            SizedBox(
              height: height,
              child: Scrollbar(
                thumbVisibility: true,
                scrollbarOrientation: .left,
                child: ListView(
                  controller: scrollController,
                  children: [
                    ...list.map((elem) {
                      return CollectionListTile(text: elem);
                    }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Divider(height: 4,),
            )
            ,
            ...list.map((elem) {
              return ListTile(title: Text(elem));
            }),
          ],
        ),
      ),
    );
  }
}

class CollectionCard extends StatelessWidget {
  const CollectionCard({super.key, required this.text});
  final String text;
  final double size = 30;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Column(
        children: [
          SizedBox(
            height: size,
            width: size,
            child: Image.asset("assets/collection_icon.png"),
          ),
          SingleChildScrollView(
            child: Text(
              "adsfsf afsd 32r2r 323fadsfsf afsd 32r2r 323f ",
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class CollectionListTile extends StatelessWidget {
  const CollectionListTile({super.key, required this.text});
  final String text;
  final double size = 40;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: SizedBox(
            height: size,
            width: size,
            child: Image.asset("assets/collection_icon.png"),
          ),
          title: Text("adsfsf afsd 32r2r 323fadsfsf afsd 32r2r 323f "),
        ),
        // SingleChildScrollView(
        //   child: Text("adsfsf afsd 32r2r 323fadsfsf afsd 32r2r 323f ",maxLines: 2,),
        // ),
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
