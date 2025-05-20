import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomFloatingButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final double size;
  final double elevation;
  final String? label;
  final Color labelColor;
  final double imageSize;
  final Color? iconColor; // 🔸 nouvelle propriété

  const CustomFloatingButton({
    super.key,
    required this.imagePath,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.size = 60.0,
    this.elevation = 6.0,
    this.label,
    this.labelColor = Colors.black54,
    this.imageSize = 30.0,
    this.iconColor, // 🔸 ajout au constructeur
  });

  Widget _buildImage() {
    String extension = imagePath.toLowerCase();

    if (extension.endsWith('.svg')) {
      return SvgPicture.asset(
        imagePath,
        width: imageSize,
        height: imageSize,
        fit: BoxFit.contain,
        color: iconColor, // 🔸 couleur du SVG
      );
    } else {
      return Image.asset(
        imagePath,
        width: imageSize,
        height: imageSize,
        fit: BoxFit.contain,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return FloatingActionButton(
        onPressed: onPressed,
        elevation: elevation,
        backgroundColor: backgroundColor,
        child: _buildImage(),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: FloatingActionButton(
            onPressed: onPressed,
            elevation: elevation,
            backgroundColor: backgroundColor,
            shape: const CircleBorder(),
            child: _buildImage(),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label!,
          style: TextStyle(
            fontSize: 12,
            color: labelColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
