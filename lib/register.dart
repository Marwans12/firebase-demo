import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'components/circular_images.dart';
import 'components/styled_form_fields.dart';
import 'style_consonants.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();

  String? checkEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return "Should not be empty";
    }
    return null;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordConfirmationController.dispose();
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
                  FormFieldLabel("Register", style: TextStyle(fontSize: 22)),
                  FormFieldLabel(
                    "Enter your personal information.",
                    style: TextStyle(fontSize: 14, color: Colors.black45),
                  ),
                  FormFieldLabel("Username"),
                  StyledTextFormField(
                    hintText: "Enter your name",
                    controller: nameController,
                    validator: checkEmpty,
                  ),
                  FormFieldLabel("Email"),
                  StyledTextFormField(
                    hintText: "Enter your mail",
                    controller: emailController,
                    validator: checkEmpty,
                  ),
                  FormFieldLabel("Password"),
                  StyledObsecureTextFormField(
                    hintText: "Password",
                    controller: passwordController,
                    validator: checkEmpty,
                  ),
                  FormFieldLabel("Confirm password"),
                  StyledObsecureTextFormField(
                    hintText: "Enter your password",
                    controller: passwordConfirmationController,
                    validator: (confPassword) {
                      if (confPassword != passwordController.text) {
                        return "Password not match";
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.blue),
                      ),
                      onPressed: () async {
                        assert(_formKey.currentState != null);
                        if (_formKey.currentState!.validate()) {
                          try {
                            await auth.createUserWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text,
                            );
                            auth.currentUser!.sendEmailVerification();
                            if (context.mounted) {
                              Navigator.of(
                                context,
                              ).pushReplacementNamed("/homepage");
                            }
                          } on FirebaseException catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(e.code)));
                            }
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text("Register"),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                          "login instead.",
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
