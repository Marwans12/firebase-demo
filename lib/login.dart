import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_demo_1/components/components.dart';
import "package:firebase_demo_1/style_consonants.dart";
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
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
    return Scaffold(
      body: Container(
        alignment: Alignment.bottomCenter,
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(StyleConsonants.mainpadding),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Logo(),
                  FormFieldLabel("Login", style: TextStyle(fontSize: 22)),
                  FormFieldLabel(
                    "Login to continue using the app",
                    style: TextStyle(fontSize: 14, color: Colors.black45),
                  ),
                  FormFieldLabel("Email"),
                  StyledTextFormField(
                    hintText: "Enter your Email",
                    controller: emailController,
                  ),
                  FormFieldLabel("Password"),
                  StyledObsecureTextFormField(
                    hintText: "Enter your Password",
                    controller: passwordController,
                  ),
                  Transform.translate(
                    offset: Offset(0, -20),
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushReplacementNamed("/passwordrecovery");
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ),
                  StyledFilledButton(
                    onPressed: () async {
                      assert(_formKey.currentState != null);
                      if (_formKey.currentState!.validate()) {
                        try {
                          await auth.signInWithEmailAndPassword(
                            email: emailController.text,
                            password: passwordController.text,
                          );
                          if (context.mounted) {
                            Navigator.of(
                              context,
                            ).pushReplacementNamed("/homepage");
                          }
                        } on FirebaseAuthException catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(e.code)));
                          }
                        }
                      }
                    },
                    child: Text("Login"),
                  ),
                  SizedBox(height: 30),
                  Text("Or login with"),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MaterialButton(
                        onPressed: () {},
                        child: Image.asset(
                          "assets/meta_logo.png",
                          height: 50,
                          width: 50,
                        ),
                      ),
                      MaterialButton(
                        onPressed: () async {
                          var showSnackBar = ScaffoldMessenger.of(context).showSnackBar;
                          String? errorCode;
                          try {
                          var googleAccount =  await GoogleSignIn.instance.authenticate();
                          var googleAuth = googleAccount.authentication;
                          var googleCredential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);
                          await auth.signInWithCredential(googleCredential);
                          if (context.mounted) {
                            Navigator.of(context).pushReplacementNamed("/homepage");
                          }
                          } on GoogleSignInException catch (e) {
                            errorCode = "google: ${e.description}";
                          } on FirebaseException catch (e) {
                            errorCode = "firebase: ${e.code}";
                          }
                          if (errorCode != null && context.mounted) {
                            showSnackBar(SnackBar(content: Text(errorCode)));
                          }
                        },
                        child: Image.asset(
                          "assets/google_logo.png",
                          height: 50,
                          width: 50,
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {},
                        child: Image.asset(
                          "assets/apple_logo.png",
                          height: 50,
                          width: 50,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      TextButton(
                        style: ButtonStyle(
                          padding: WidgetStatePropertyAll(
                            EdgeInsetsGeometry.all(0),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushReplacementNamed("/register");
                        },
                        child: Text(
                          "Register",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
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


