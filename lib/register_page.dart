import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "components/shared.dart";

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();
  final auth = FirebaseAuth.instance;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      body: Padding(
        padding: const .symmetric(horizontal: 20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: .stretch,
                spacing: 20,
                children: [
                  CircleAssetImage(
                    size: 100,
                    name: "assets/logo.png",
                    padding: .all(5),
                    backgroundColor: const Color.fromARGB(255, 231, 231, 231),
                  ),
                  Column(
                    crossAxisAlignment: .stretch,
                    children: [
                      Text("Sign Up", style: theme.textTheme.titleLarge),
                      Text(
                        "Sign Up to start your note collection",
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: .stretch,
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
                    crossAxisAlignment: .stretch,
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
                    ],
                  ),
                  Column(
                    crossAxisAlignment: .stretch,
                    children: [
                      Text("Confirm Password", style: theme.textTheme.labelMedium),
                      SizedBox(height: 10),
                      ObsecuredTextFormField(
                        inputDecoration: InputDecoration(
                          hintText: "Re-enter your password",
                        ),
                        passwordController: passwordConfirmationController,
                        validator: (value) {
                          if(passwordController.text != passwordConfirmationController.text) {
                            return "Password doesn't match";
                          }
                          return null;
                        },
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
                        await auth.createUserWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                        loadingOverlay.remove();
                        loadingOverlay.dispose();
                        pushReplacementNamed("/home");
                      } on FirebaseAuthException catch (e) {
                        showSnackBar(
                          SnackBar(content: Text("Error: ${e.code}")),
                        );
                        loadingOverlay.remove();
                        loadingOverlay.dispose();
                      }
                      // if (auth.currentUser!.emailVerified) {
                      //   pushReplacementNamed("/home");
                      //   return;
                      // }
                      // var isUserVerified = await showDialog<bool>(
                      //   // ignore: use_build_context_synchronously
                      //   context: context,
                      //   builder: (context) {
                      //     return UserNotVerifiedDialog();
                      //   },
                      // );
                      // if (isUserVerified == true) {
                      //   pushReplacementNamed("/home");
                      //   return;
                      // }
                      // auth.signOut();
                    },
                    child: Text("Sign Up"),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: .center,
                      children: [
                        Text("Already have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pushReplacementNamed("/login");
                          },
                          child: Text("Sign in"),
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
