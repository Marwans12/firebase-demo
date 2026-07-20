import "dart:async";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:google_sign_in/google_sign_in.dart";
import "components/shared.dart";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = FirebaseAuth.instance;
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 20,
                children: [
                  CircleAssetImage(
                    size: 100,
                    name: "assets/logo.png",
                    padding: EdgeInsets.all(5),
                    backgroundColor: const Color.fromARGB(255, 231, 231, 231),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("Login", style: theme.textTheme.titleLarge),
                      Text(
                        "Login To Continue Using This App",
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("Email", style: theme.textTheme.labelMedium),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: "Enter your email",
                        ),
                        controller: emailController,
                        validator: Validators.emailValidator,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("Password", style: theme.textTheme.labelMedium),
                      SizedBox(height: 10),
                      ObsecuredTextFormField(
                        inputDecoration: InputDecoration(
                          hintText: "Enter your password",
                        ),
                        passwordController: passwordController,
                        validator: Validators.passwordValidator,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return PasswordResetDialog();
                              },
                            );
                          },
                          child: Text("Forgot Password?"),
                        ),
                      ),
                    ],
                  ),
                  FilledButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }
                      var loadingOverlay = LoadingOverlay(context);
                      var overlayInsert = Overlay.of(context).insert;
                      var pushReplacementNamed = Navigator.of(
                        context,
                      ).pushReplacementNamed;
                      var showSnackBar = ScaffoldMessenger.of(
                        context,
                      ).showSnackBar;
                      try {
                        overlayInsert(loadingOverlay);
                        await auth.signInWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                        loadingOverlay.remove();
                        loadingOverlay.dispose();
                      } on FirebaseAuthException catch (e) {
                        showSnackBar(
                          SnackBar(content: Text("Error: ${e.code}")),
                        );
                        loadingOverlay.remove();
                        loadingOverlay.dispose();
                        return;
                      }
                      if (auth.currentUser!.emailVerified) {
                        pushReplacementNamed("/home");
                        return;
                      }
                      var isUserVerified = await showDialog<bool>(
                        // ignore: use_build_context_synchronously
                        context: context,
                        builder: (context) {
                          return UserNotVerifiedDialog();
                        },
                      );
                      if (isUserVerified == true) {
                        pushReplacementNamed("/home");
                        return;
                      }
                      auth.signOut();
                    },
                    child: Text("Login"),
                  ),
                  Center(
                    child: Column(
                      children: [
                        Text("Or login with"),
                        Center(
                          child: IconButton(
                            onPressed: () async {
                              var errorMessage = "";
                              var loadingOverlay = LoadingOverlay(context);
                              var showSnackBar = ScaffoldMessenger.of(
                                context,
                              ).showSnackBar;
                              var pushReplacementNamed = Navigator.of(
                                context,
                              ).pushReplacementNamed;
                              try {
                                Overlay.of(context).insert(loadingOverlay);
                                var googleUser = await GoogleSignIn.instance
                                    .authenticate();
                                await auth.signInWithCredential(
                                  GoogleAuthProvider.credential(
                                    idToken: googleUser.authentication.idToken,
                                  ),
                                );
                                loadingOverlay.remove();
                                loadingOverlay.dispose();
                                pushReplacementNamed("/home");
                                return;
                              } on FirebaseAuthException catch (e) {
                                errorMessage += e.code;
                              } on GoogleSignInException catch (e) {
                                errorMessage += e.code.toString();
                              }
                              loadingOverlay.remove();
                              loadingOverlay.dispose();
                              showSnackBar(
                                SnackBar(content: Text(errorMessage)),
                              );
                            },
                            icon: CircleAssetImage(
                              name: "assets/google.png",
                              size: 26,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account?"),
                            TextButton(
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).pushReplacementNamed("/register");
                              },
                              child: Text("Sign Up"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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

              Timer.periodic(Duration(seconds: 1), (timer) {
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

class PasswordResetDialog extends StatefulWidget {
  const PasswordResetDialog({super.key});

  @override
  State<PasswordResetDialog> createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<PasswordResetDialog> {
  final controller = TextEditingController();
  final auth = FirebaseAuth.instance;
  final formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return AlertDialog(
      // backgroundColor: Colors.white,
      title: Text("Password Recovery"),
      content: Form(
        key: formKey,
        child: TextFormField(
          decoration: InputDecoration(hintText: "Enter your email"),
          controller: controller,
          validator: Validators.emailValidator,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            var showSnackBar = ScaffoldMessenger.of(context).showSnackBar;
            Navigator.of(context).pop();
            try {
              await auth.sendPasswordResetEmail(email: controller.text);
            } on FirebaseAuthException catch (e) {
              showSnackBar(SnackBar(content: Text("Error: ${e.code}")));
              return;
            }
            showSnackBar(
              SnackBar(
                content: Text("Reset link has been sent to your email."),
              ),
            );
          },
          child: Text("Send Reset Email"),
        ),
      ],
    );
  }
}
