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
    required this.controller,
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

class StyledFilledButton extends StatelessWidget {
  const StyledFilledButton({super.key, this.onPressed, this.child});
  final VoidCallback? onPressed;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.blue),
        ),
        onPressed: onPressed,
        child: Padding(padding: const EdgeInsets.all(16.0), child: child),
      ),
    );
  }
}

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return CircularImage(imagePath: "assets/logo.png");
  }
}

class CircularImage extends StatelessWidget {
  const CircularImage({
    super.key,
    this.height = 100,
    this.width = 100,
    this.color,
    required this.imagePath,
  });

  final double height;
  final double width;
  final Color? color;
  final String imagePath;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(150),
        color: color ?? Colors.grey.shade100,
      ),
      child: Image.asset(imagePath),
    );
  }
}

class StyledCircleAvatar extends StatelessWidget {
  const StyledCircleAvatar({
    super.key,
    this.imageUrl,
    this.radius,
    this.backgroundColor,
  });
  final String? imageUrl;
  final Color? backgroundColor;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      foregroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      backgroundImage: Image.asset("assets/default_profile_image.png").image,
      backgroundColor: backgroundColor ?? Colors.grey.shade200,
      radius: radius,
    );
  }
}
