import 'package:flutter/material.dart';

class Step2Form extends StatelessWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onPublishPressed;
  final VoidCallback onAddImagesPressed;
  final VoidCallback onCameraPressed;

  const Step2Form({
    super.key,
    required this.onBackPressed,
    required this.onPublishPressed,
    required this.onAddImagesPressed,
    required this.onCameraPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button
        TextButton.icon(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          label: const Text(
            'Retour',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          onPressed: onBackPressed,
        ),
        const SizedBox(height: 24),

        // Image upload area
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.upload, size: 40),
              const SizedBox(height: 8),
              const Text(
                'Télécharger une image',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '(vous pouvez télécharger plus d\'images en',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const Text(
                'appuyant sur l\'icone plus)',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Add more images button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              icon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.grey),
              ),
              label: const Text(
                'Ajouter plus d\'images',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              onPressed: onAddImagesPressed,
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: onCameraPressed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),

        // Publish button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.deepOrange,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextButton(
            onPressed: onPublishPressed,
            child: const Text(
              'Publier',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
