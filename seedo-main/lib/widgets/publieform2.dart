import 'dart:io';

import 'package:flutter/material.dart';
import 'package:seddoapp/models/PricingModel.dart';

import '../models/transit/PlaceModel.dart';
import '../utils/HexColor.dart';

class Step2Form extends StatefulWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onAddImagesPressed;
  final VoidCallback onCameraPressed;
  final List<String> selectedImages;
  final Function(int) onRemoveImage;
  final Function(String) priceChanged;
  final Function(String) availabilityChanged;
  final Function(PlaceModel?) onPublishPressed;
  final List<PricingModel> pricingList;
  final PricingModel? selectedPricing;
  final Function(PricingModel?) onPricingChanged;

  const Step2Form({
    super.key,
    required this.onBackPressed,
    required this.onPublishPressed,
    required this.onAddImagesPressed,
    required this.onCameraPressed,
    required this.selectedImages,
    required this.onRemoveImage,
    required this.priceChanged,
    required this.availabilityChanged,
    required this.pricingList,
    this.selectedPricing,
    required this.onPricingChanged,
  });

  @override
  State<Step2Form> createState() => _Step2FormState();
}

class _Step2FormState extends State<Step2Form> {
  int _selectedImageIndex = 0;
  final TextEditingController _priceController = TextEditingController();

  PlaceModel? address;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,

      padding: EdgeInsets.only(
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            104, // Ajoute un espace en bas si le clavier est ouvert
        top: 24,
        left: 16,
        right: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Availability Field

          // Price Field with Currency
          const Text(
            'Prix / Tarification',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(30),
                    color: const Color.fromARGB(255, 247, 247, 246),
                  ),
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Entrez le tarif',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: Color.fromARGB(255, 78, 73, 73),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixText: "CFA",
                    ),
                    onChanged: (value) {
                      widget.priceChanged(value);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
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
                                        widget.selectedImages.length > 1
                                            ? 0
                                            : 0;
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

          // Sélection de la tarification
          // Message explicatif
          const SizedBox(height: 24),
          const Text(
            'Sélectionnez une durée de visibilité. La publication sera supprimée après cette période.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                widget.pricingList.map((pricing) {
                  final bool isSelected =
                      widget.selectedPricing?.id == pricing.id;
                  return GestureDetector(
                    onTap: () => widget.onPricingChanged(pricing),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Color(0xFFE65100).withOpacity(.2)
                                : const Color.fromARGB(255, 247, 247, 246),
                        border: Border.all(
                          color:
                              isSelected
                                  ? Color(0xFFE65100)
                                  : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            pricing.libelle,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (pricing.price) == 0
                                ? 'Gratuit'
                                : '${pricing.price} F',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),

          const SizedBox(height: 48),

          // Publish button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: HexColor("#D95C18"),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextButton(
              onPressed: () {
                widget.onPublishPressed(address);
              },
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
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: HexColor("#F1F2F6"),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextButton(
              onPressed: () {
                widget.onPublishPressed(address);
              },
              child: const Text(
                'Précédent',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
