import 'dart:io';

import 'package:flutter/material.dart';

class Step2Form extends StatelessWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onPublishPressed;
  final VoidCallback onAddImagesPressed;
  final VoidCallback onCameraPressed;
  final List<String> selectedImages;
  final Function(int) onRemoveImage;

  const Step2Form({
    required this.onBackPressed,
    required this.onPublishPressed,
    required this.onAddImagesPressed,
    required this.onCameraPressed,
    required this.selectedImages,
    required this.onRemoveImage,
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

        // Main image container - Affiche la première image ou l'icône de téléchargement
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              selectedImages.isNotEmpty
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(selectedImages.first),
                      fit: BoxFit.cover,
                    ),
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.upload, size: 40),
                      const SizedBox(height: 8),
                      const Text(
                        'Télécharger une image',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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

        // Additional images grid
        if (selectedImages.length > 1)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:
                  selectedImages.length -
                  1, // On affiche à partir de la 2ème image
              itemBuilder: (context, index) {
                final imageIndex = index + 1; // On commence à l'index 1
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(File(selectedImages[imageIndex])),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          // onTap: () => onRemoveImage(imageIndex),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        if (selectedImages.length > 1) const SizedBox(height: 16),

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
