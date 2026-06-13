import 'package:firebase_auth/firebase_auth.dart';
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
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (currentUser.emailVerified == false) {
        showDialog(
          // barrierDismissible: false,
          context: context,
          builder: (_) {
            return EmailVerificationDialog();
          },
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("Signed in as ${currentUser.uid}"),
          Text("email: ${currentUser.email}"),
          FilledButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed("/login");
              }
            },
            child: Text("Sign Out"),
          ),
        ],
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
                                  if (context.mounted) Navigator.of(context).pop();
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
