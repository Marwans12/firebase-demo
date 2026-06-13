import 'package:flutter/material.dart';

final _formFieldFillColor = Colors.grey.shade200;
final _formFieldRadius = 25.0;
final _hintStyle = TextStyle(fontSize: 14);

class StyledTextFormField extends StatelessWidget {
  const StyledTextFormField({
    super.key,
    required this.hintText,
    this.isObsecureText = false,
    this.suffixIcon,
    this.validator,
    required this.controller
  });
  final TextEditingController controller;
  final String hintText;
  final bool isObsecureText;
  final Widget? suffixIcon;
  final FormFieldValidator<String?>? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: isObsecureText,
        decoration: InputDecoration(
          hintStyle: _hintStyle,
          filled: true,
          fillColor: _formFieldFillColor,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_formFieldRadius),
            borderSide: BorderSide.none,
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}

class StyledObsecureTextFormField extends StatefulWidget {
  const StyledObsecureTextFormField({
    super.key,
    required this.hintText,
    required this.controller,
    this.validator,

  });
  final TextEditingController controller;
  final String hintText;
  final FormFieldValidator<String?>? validator;

  @override
  State<StyledObsecureTextFormField> createState() =>
      _StyledObsecureTextFormFieldState();
}

class _StyledObsecureTextFormFieldState
    extends State<StyledObsecureTextFormField> {
  var isObsecured = true;
  @override
  Widget build(BuildContext context) {
    return StyledTextFormField(
      controller: widget.controller,
      hintText: widget.hintText,
      isObsecureText: isObsecured,
      validator: widget.validator,
      suffixIcon: IconButton(
        onPressed: () => setState(() {
          isObsecured = !isObsecured;
        }),
        icon: Icon(isObsecured ? Icons.visibility : Icons.visibility_off),
      ),
    );
  }
}

class FormFieldLabel extends StatelessWidget {
  const FormFieldLabel(this.text, {super.key, this.style, this.textAlign});
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      width: double.infinity,
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        child: Text(text, textAlign: textAlign, style: style),
      ),
    );
  }
}
