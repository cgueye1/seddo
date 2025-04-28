import 'dart:io';

import 'package:flutter/material.dart';

class Step2Form extends StatefulWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onPublishPressed;
  final VoidCallback onAddImagesPressed;
  final VoidCallback onCameraPressed;
  final List<String> selectedImages;
  final Function(int) onRemoveImage;

  const Step2Form({
    Key? key,
    required this.onBackPressed,
    required this.onPublishPressed,
    required this.onAddImagesPressed,
    required this.onCameraPressed,
    required this.selectedImages,
    required this.onRemoveImage,
  }) : super(key: key);

  @override
  State<Step2Form> createState() => _Step2FormState();
}

class _Step2FormState extends State<Step2Form> {
  int _selectedImageIndex = 0;

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
          onPressed: widget.onBackPressed,
        ),
        const SizedBox(height: 24),

        // Main image container - Affiche l'image sélectionnée ou l'icône de téléchargement
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              widget.selectedImages.isNotEmpty
                  ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(widget.selectedImages[_selectedImageIndex]),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            widget.onRemoveImage(_selectedImageIndex);
                            setState(() {
                              // Ajuster l'index si on supprime l'image actuellement affichée
                              if (widget.selectedImages.length > 1) {
                                _selectedImageIndex =
                                    _selectedImageIndex >=
                                            widget.selectedImages.length - 1
                                        ? widget.selectedImages.length - 2
                                        : _selectedImageIndex;
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
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

        // Image grid - Affiche toutes les images en miniature
        if (widget.selectedImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.selectedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedImageIndex = index;
                      });
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border:
                                _selectedImageIndex == index
                                    ? Border.all(
                                      color: Colors.deepOrange,
                                      width: 2,
                                    )
                                    : null,
                            image: DecorationImage(
                              image: FileImage(
                                File(widget.selectedImages[index]),
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              // Prévenir la propagation au conteneur parent
                              widget.onRemoveImage(index);
                              setState(() {
                                // Ajuster l'index sélectionné après suppression
                                if (index == _selectedImageIndex) {
                                  _selectedImageIndex =
                                      widget.selectedImages.length > 1 ? 0 : 0;
                                } else if (index < _selectedImageIndex) {
                                  _selectedImageIndex--;
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        if (widget.selectedImages.isNotEmpty) const SizedBox(height: 16),

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
              onPressed: widget.onAddImagesPressed,
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
                onPressed: widget.onCameraPressed,
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
            onPressed: widget.onPublishPressed,
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
