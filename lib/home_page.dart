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
    return Scaffold(
      body: Center(
        child: TextButton(
          child: Text("Sign out and go back"),
          onPressed: () {
            auth.signOut();
            Navigator.of(context).pushReplacementNamed("/login");
          },
        ),
      ),
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
