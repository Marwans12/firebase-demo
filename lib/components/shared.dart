import 'package:flutter/material.dart';

class CircleAssetImage extends StatelessWidget {
  const CircleAssetImage({
    super.key,
    required this.name,
    this.size,
    this.padding,
    this.backgroundColor,
  });
  final double? size;
  final String name;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Container(
        height: size,
        width: size,
        clipBehavior: Clip.hardEdge,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(180),
          color: backgroundColor,
        ),
        child: Image.asset(name),
      ),
    );
  }
}

class ObsecuredTextFormField extends StatefulWidget {
  const ObsecuredTextFormField({
    super.key,
    required this.inputDecoration,
    required this.passwordController,
    this.validator,
  });
  final String? Function(String?)? validator;
  final InputDecoration inputDecoration;
  final TextEditingController passwordController;

  @override
  State<ObsecuredTextFormField> createState() => _ObsecuredTextFormFieldState();
}

class _ObsecuredTextFormFieldState extends State<ObsecuredTextFormField> {
  var isObsecured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: widget.inputDecoration.copyWith(
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              isObsecured = !isObsecured;
            });
          },
          icon: Icon(isObsecured ? Icons.visibility : Icons.visibility_off),
        ),
      ),
      controller: widget.passwordController,
      validator: widget.validator,
      obscureText: isObsecured,
    );
  }
}

class LoadingOverlay extends OverlayEntry {
  LoadingOverlay(this.context)
    : super(
        builder: (context) {
          return Container(
            color: const Color.fromARGB(108, 0, 0, 0),
            child: Center(child: CircularProgressIndicator()),
          );
        },
      );
  final BuildContext context;
}

class Validators {
  Validators._();

  static String? emailValidator(String? email) {
    {
      if (email == null || email.isEmpty || !email.contains("@")) {
        return "Enter valid email address";
      }
      return null;
    }
  }

  static String? passwordValidator(String? password) {
    {
      if (password == null || password.isEmpty) {
        return "Password can not be empty";
      }
      if (password.length < 5) {
        return "Password must be at least 5 characters long";
      }
      return null;
    }
  }
}
