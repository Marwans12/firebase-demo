import 'package:flutter/material.dart';

import 'components/circular_images.dart';
import 'components/styled_form_fields.dart';
import 'style_consonants.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});
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
                  FormFieldLabel("Register", style: TextStyle(fontSize: 22)),
                  FormFieldLabel(
                    "Enter your personal information.",
                    style: TextStyle(fontSize: 14, color: Colors.black45),
                  ),
                  FormFieldLabel("Username"),
                  StyledTextFormField(hintText: "Enter your name"),
                  FormFieldLabel("Email"),
                  StyledTextFormField(hintText: "Enter your mail"),
                  FormFieldLabel("Password"),
                  StyledObsecureTextFormField(hintText: "Password"),
                  FormFieldLabel("Confirm password"),
                  StyledObsecureTextFormField(hintText: "Enter your password"),
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
                          Navigator.of(
                            context,
                          ).pushReplacementNamed("Login");
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
