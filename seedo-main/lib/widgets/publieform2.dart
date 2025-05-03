import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seddoapp/widgets/transit/DakarSearchWidget.dart';

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

  const Step2Form({
    Key? key,
    required this.onBackPressed,
    required this.onPublishPressed,
    required this.onAddImagesPressed,
    required this.onCameraPressed,
    required this.selectedImages,
    required this.onRemoveImage,
    required this.priceChanged,
    required this.availabilityChanged,
  }) : super(key: key);

  @override
  State<Step2Form> createState() => _Step2FormState();
}

class _Step2FormState extends State<Step2Form> {
  int _selectedImageIndex = 0;
  final TextEditingController _availabilityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  PlaceModel? address;
  final ScrollController _scrollController = ScrollController();

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Ajouter les listeners de focus
    _focusNode.addListener(() => _scrollToFocusedField(_focusNode));
  }

  void _scrollToFocusedField(FocusNode node) {
    if (node.hasFocus) {
      Future.delayed(Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
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
          const Text(
            'Adresse',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          DakarSearchWidget(
            icon: Icon(Icons.location_on_sharp, color: HexColor("#F52D56")),
            focusNode: _focusNode,
            label: "Adresse de récupération",
            initPlace: null,
            onLocationSelected: (PlaceModel location) {
              setState(() {
                address = location;
              });
            },
          ),
          const SizedBox(height: 24),

          // Availability Field
          const Text(
            'Disponibilités',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),

          // Dans la méthode _buildStep1Form, modifiez le code du TextField pour les disponibilités:
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(30),
              color: const Color.fromARGB(255, 247, 247, 246),
            ),
            child: TextField(
              controller: _availabilityController,
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    final DateTime combinedDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                    final formattedDateTime = DateFormat(
                      'dd-MM-yyyy HH:mm',
                    ).format(combinedDateTime);

                    setState(() {
                      _availabilityController.text =
                          formattedDateTime; // Mettez à jour le même contrôleur
                    });
                    widget.availabilityChanged(formattedDateTime);
                  }
                }
              },
              // Utilisez le même contrôleur
              decoration: InputDecoration(
                hintText: 'Entrez vos disponibilités',
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: const Color.fromARGB(255, 78, 73, 73),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
          ),
          const SizedBox(height: 24),

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

          if (widget.selectedImages.isNotEmpty)
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
        ],
      ),
    );
  }
}
