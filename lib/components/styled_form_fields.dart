import 'package:flutter/material.dart';

final _formFieldFillColor = Colors.grey.shade200;
final _formFieldRadius = 25.0;
final _hintStyle = TextStyle(fontSize: 14);

class StyledTextFormField extends StatelessWidget {
  const StyledTextFormField({super.key, required this.hintText});
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 18),
      child: TextFormField(
        decoration: InputDecoration(
          hintStyle: _hintStyle,
          filled: true,
          fillColor: _formFieldFillColor,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_formFieldRadius),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class StyledObsecureTextFormField extends StatefulWidget {
  const StyledObsecureTextFormField({super.key, required this.hintText, this.validator = null});
  final String hintText;
  final String? Function(String?)? validator;

  @override
  State<StyledObsecureTextFormField> createState() =>
      _StyledObsecureTextFormFieldState();
}

class _StyledObsecureTextFormFieldState
    extends State<StyledObsecureTextFormField> {
  var isVisible = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 18),
      child: TextFormField(
        obscureText: !isVisible,
        decoration: InputDecoration(
          hintStyle: _hintStyle,
          filled: true,
          fillColor: _formFieldFillColor,
          hintText: widget.hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_formFieldRadius),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(onPressed: () => setState(() {
            isVisible = !isVisible;
          }),icon: Icon(
            isVisible? Icons.visibility_off : Icons.visibility)
            ,),
        ),
      ),
    );
  }
}

class FormFieldLabel extends StatelessWidget {
  const FormFieldLabel(this.text ,{
    super.key, this.style, this.textAlign,

  });
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      width: double.infinity,
      child: DefaultTextStyle.merge(style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),child: Text(text, textAlign: textAlign, style: style,)),
    );
  }
}