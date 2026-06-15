import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'style_consonants.dart';
import "components/components.dart";

class PasswordRecoveryPage extends StatefulWidget {
  const PasswordRecoveryPage({super.key});

  @override
  State<PasswordRecoveryPage> createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  final controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(StyleConsonants.mainpadding),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FormFieldLabel(
                "Account Recovery",
                style: TextStyle(fontSize: 22),
              ),
              FormFieldLabel(
                "Enter the email associated with your account to send password reset link.",
                style: TextStyle(fontSize: 14, color: Colors.black45),
              ),
              StyledTextFormField(hintText: "Email", controller: controller),
              StyledFilledButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() == true) {
                    var showSnackBar = ScaffoldMessenger.of(context).showSnackBar;
                    try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: controller.text,
                    );
                    if (context.mounted) {
                      showSnackBar(SnackBar(content: Text("A password recovery email has been sent")));
                      Navigator.of(context).pushReplacementNamed("/login");
                    }

                    } on FirebaseAuthException catch (e) {
                      showSnackBar(SnackBar(content: Text(e.code)));
                    }
                  }
                },
                child: Text("Submit"),
              ),
              TextButton(
                    style: ButtonStyle(
                      padding: WidgetStatePropertyAll(
                        EdgeInsetsGeometry.all(0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed("/login");
                    },
                    child: Text(
                      "Go back to login",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
            ],
          ),
        ),
      ),
    );
  }
}
