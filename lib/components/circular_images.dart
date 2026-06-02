import 'package:flutter/material.dart';

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

class DefaultCircleAvatar extends StatelessWidget {
  const DefaultCircleAvatar({
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
      foregroundImage: imageUrl != null? NetworkImage(imageUrl!) : null,
      backgroundImage: Image.asset("assets/default_profile_image.png").image,
      backgroundColor: backgroundColor ?? Colors.grey.shade200,
      radius: radius,

    );
  }
}
