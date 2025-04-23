import 'package:flutter/material.dart';

class CustomFloatingButton extends StatelessWidget {
  // Paramètres obligatoires
  final String imagePath; // Chemin vers l'image PNG
  final VoidCallback onPressed;

  // Paramètres optionnels
  final Color backgroundColor;
  final double size;
  final double elevation;
  final String? label;
  final Color labelColor;
  final double imageSize;

  const CustomFloatingButton({
    Key? key,
    required this.imagePath,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.size = 60.0,
    this.elevation = 6.0,
    this.label,
    this.labelColor = Colors.black54,
    this.imageSize = 30.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Si pas de label, on retourne juste le bouton
    if (label == null) {
      return FloatingActionButton(
        onPressed: onPressed,
        elevation: elevation,
        backgroundColor: backgroundColor,
        child: Image.asset(imagePath, width: imageSize, height: imageSize),
      );
    }

    // Si un label est présent, on crée une colonne avec le bouton et le label en dessous
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
            shape: CircleBorder(),
            child: Image.asset(imagePath, width: imageSize, height: imageSize),
          ),
        ),
        const SizedBox(height: 5), // Espace entre le bouton et le label
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
