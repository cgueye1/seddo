import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:seddoapp/bloc/publie/publie_bloc.dart';
import 'package:seddoapp/bloc/publie/publie_event.dart';
import 'package:seddoapp/bloc/publie/publie_state.dart';
import 'package:seddoapp/models/CategorieModel.dart';
import 'package:seddoapp/repositories/categorie_repository.dart';
import 'package:seddoapp/widgets/publieform2.dart';

class PubliePage extends StatelessWidget {
  final List<dynamic>? categories;

  const PubliePage({Key? key, this.categories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => PublicationBloc(
            categorieRepository: CategorieRepository(),
            categories: categories,
          ),
      child: const PubliePageView(),
    );
  }
}

class PubliePageView extends StatefulWidget {
  const PubliePageView({Key? key}) : super(key: key);

  @override
  State<PubliePageView> createState() => _PubliePageViewState();
}

class _PubliePageViewState extends State<PubliePageView> {
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _availabilityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _languagesController = TextEditingController();
  bool _validateStep1(PublicationState state) {
    return state.selectedCategory != null &&
        state.selectedSubcategoryModel != null &&
        _titreController.text.isNotEmpty;
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _dateTimeController.dispose();
    _availabilityController.dispose();
    _priceController.dispose();
    _languagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PublicationBloc, PublicationState>(
      listener: (context, state) {
        if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Publication soumise avec succès!')),
          );
          Navigator.pop(context);
        }

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${state.errorMessage}')),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Publications',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: Column(
            children: [
              // Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          context.read<PublicationBloc>().add(TabChanged(0));
                        },
                        child: Container(
                          margin: EdgeInsets.all(8.0),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                state.activeTabIndex == 0
                                    ? Colors.black
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Publier',
                              style: TextStyle(
                                color:
                                    state.activeTabIndex == 0
                                        ? Colors.white
                                        : Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          context.read<PublicationBloc>().add(TabChanged(1));
                        },
                        child: Container(
                          margin: EdgeInsets.all(8.0),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                state.activeTabIndex == 1
                                    ? Colors.black
                                    : const Color.fromARGB(251, 255, 255, 255),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Historique',
                              style: TextStyle(
                                color:
                                    state.activeTabIndex == 1
                                        ? Colors.white
                                        : Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Step indicator - Only 2 steps
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    // Step 1 circle
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color:
                            state.currentStep >= 1
                                ? Colors.green
                                : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '1',
                          style: TextStyle(
                            color:
                                state.currentStep >= 1
                                    ? Colors.white
                                    : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Line
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.all(5.0),
                        height: 2,
                        color:
                            state.currentStep >= 2
                                ? Colors.green
                                : Colors.grey[300],
                      ),
                    ),
                    // Step 2 circle
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color:
                            state.currentStep >= 2
                                ? Colors.green
                                : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '2',
                          style: TextStyle(
                            color:
                                state.currentStep >= 2
                                    ? Colors.white
                                    : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Form content - changes based on current step
              Expanded(
                child:
                    state.activeTabIndex == 0
                        ? SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child:
                              state.currentStep == 1
                                  ? _buildStep1Form(context, state)
                                  : _buildStep2Form(context, state),
                        )
                        : const Center(
                          child: Text('Historique des publications'),
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStep1Form(BuildContext context, PublicationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // category Field
        Row(
          children: [
            const Text(
              'Catégorie',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: state.selectedCategory,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            decoration: InputDecoration(
              hintText: 'Sélectionnez la catégorie',
              hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            items:
                state.categoryTitles
                    .map(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                context.read<PublicationBloc>().add(CategorySelected(newValue));
              }
            },
            isExpanded: true,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(15),
            itemHeight: 50,
          ),
        ),
        const SizedBox(height: 24),

        // Sub-category Field
        Row(
          children: [
            const Text(
              'Sous-catégorie',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<CategorieModel>(
            // Only set a value if it's actually in the current list
            value:
                state.selectedSubcategoryModel != null &&
                        state.currentSubcategories.any(
                          (item) =>
                              item.id == state.selectedSubcategoryModel!.id,
                        )
                    ? state.selectedSubcategoryModel
                    : null,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.normal,
            ),
            decoration: const InputDecoration(
              hintText: 'Sélectionnez la sous-catégorie',
              hintStyle: TextStyle(fontSize: 11, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              isDense: true,
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            items:
                state.currentSubcategories.map((subCategory) {
                  return DropdownMenuItem<CategorieModel>(
                    value: subCategory,
                    child: Text(
                      subCategory.titre,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
            onChanged:
                state.currentSubcategories.isEmpty
                    ? null
                    : (CategorieModel? newValue) {
                      if (newValue != null) {
                        context.read<PublicationBloc>().add(
                          SubcategorySelected(newValue),
                        );
                      }
                    },
            isExpanded: true,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(15),
            itemHeight: 50,
          ),
        ),
        const SizedBox(height: 24),

        // Title Field
        Row(
          children: [
            const Text(
              'Titre',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _titreController,
            decoration: const InputDecoration(
              hintText: 'Entrez le titre de la publication',
              hintStyle: TextStyle(fontSize: 10, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              if (value.length < 5) {
                // Afficher une erreur si le titre est trop court
              }
              context.read<PublicationBloc>().add(
                FormFieldUpdated('titre', value),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // Description Field
        const Text(
          'Description',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Ecrivez quelque chose...',
              hintStyle: TextStyle(fontSize: 10, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              context.read<PublicationBloc>().add(
                FormFieldUpdated('description', value),
              );
            },
          ),
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
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _availabilityController, // Utilisez le même contrôleur
            decoration: InputDecoration(
              hintText: 'Entrez vos disponibilités',
              hintStyle: TextStyle(fontSize: 10, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
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
                        'dd/MM/yyyy HH:mm',
                      ).format(combinedDateTime);

                      setState(() {
                        _availabilityController.text =
                            formattedDateTime; // Mettez à jour le même contrôleur
                      });

                      context.read<PublicationBloc>().add(
                        FormFieldUpdated(
                          'availability',
                          formattedDateTime,
                        ), // Utilisez 'availability' de manière cohérente
                      );
                    }
                  }
                },
              ),
            ),
            onChanged: (value) {
              context.read<PublicationBloc>().add(
                FormFieldUpdated('availability', value),
              );
            },
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Entrez le tarif',
                    hintStyle: TextStyle(fontSize: 10, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    context.read<PublicationBloc>().add(
                      FormFieldUpdated('price', value),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 100,
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Fcfa',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Languages Field
        const Text(
          'Langues parlées',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _languagesController,
            decoration: const InputDecoration(
              hintText: 'Entrez la ou les langues parlée(s)',
              hintStyle: TextStyle(fontSize: 10, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: Icon(Icons.keyboard_arrow_down),
            ),
            onChanged: (value) {
              context.read<PublicationBloc>().add(
                FormFieldUpdated('languages', value),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // Next button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.deepOrange,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextButton(
            onPressed: () {
              if (!_validateStep1(state)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Veuillez remplir tous les champs obligatoires (*)',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              context.read<PublicationBloc>().add(StepChanged(2));
            },
            child: const Text(
              'Suivant',
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

  Widget _buildStep2Form(BuildContext context, PublicationState state) {
    return Step2Form(
      onBackPressed: () {
        context.read<PublicationBloc>().add(StepChanged(1));
      },
      onPublishPressed: () {
        context.read<PublicationBloc>().add(PublicationSubmitted());
      },
      onAddImagesPressed: () async {
        try {
          final picker = ImagePicker();
          final List<XFile>? images = await picker.pickMultiImage(
            maxWidth: 1200,
            maxHeight: 1200,
            imageQuality: 85,
          );

          if (images != null && images.isNotEmpty) {
            context.read<PublicationBloc>().add(
              ImagesAdded(images.map((e) => e.path).toList()),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
          }
        }
      },
      onCameraPressed: () async {
        try {
          final status = await Permission.camera.request();
          if (!status.isGranted) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Permission caméra requise')),
              );
            }
            return;
          }

          final picker = ImagePicker();
          final XFile? image = await picker.pickImage(
            source: ImageSource.camera,
            maxWidth: 1200,
            maxHeight: 1200,
            imageQuality: 85,
          );

          if (image != null) {
            context.read<PublicationBloc>().add(ImagesAdded([image.path]));
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur caméra: ${e.toString()}')),
            );
          }
        }
      },
      selectedImages: state.pictures,
      onRemoveImage: (index) {
        context.read<PublicationBloc>().add(ImageRemoved(index));
      },
    );
  }
}
