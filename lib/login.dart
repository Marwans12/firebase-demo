import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_demo_1/components/logo.dart';
import 'package:firebase_demo_1/components/styled_form_fields.dart';
import "package:firebase_demo_1/style_consonants.dart";
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final _formKey = GlobalKey<FormState>();

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
                  FormFieldLabel("Login", style: TextStyle(fontSize: 22),),
                  FormFieldLabel("Login to continue using the app", style: TextStyle(fontSize: 14, color: Colors.black45),),
                  FormFieldLabel("Email"),
                  StyledTextFormField(hintText: "Enter your Email"),
                  FormFieldLabel("Password"),
                  StyledObsecureTextFormField(hintText: "Enter your Password"),
                  Transform.translate(
                    offset: Offset(0, -20),
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushReplacementNamed("Recovery");
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w900),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.blue),
                      ),
                      onPressed: () {
                        assert(_formKey.currentState != null);
                        if (_formKey.currentState!.validate()) {
                          Navigator.of(
                            context,
                          ).pushReplacementNamed("HomePage");
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text("Login"),
                      ),
                    ),
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
                        onPressed: () {},
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
                  SizedBox(height: 28,),
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
                          ).pushReplacementNamed("Register");
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
