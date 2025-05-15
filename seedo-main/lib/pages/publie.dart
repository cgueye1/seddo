import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:seddoapp/bloc/publie/publie_bloc.dart';
import 'package:seddoapp/bloc/publie/publie_event.dart';
import 'package:seddoapp/bloc/publie/publie_state.dart';
import 'package:seddoapp/models/CategorieModel.dart';
import 'package:seddoapp/models/transit/PlaceModel.dart';
import 'package:seddoapp/pages/webview/payWebView.dart';
import 'package:seddoapp/repositories/categorie_repository.dart';
import 'package:seddoapp/repositories/publication_repository.dart';
import 'package:seddoapp/utils/HexColor.dart';
import 'package:seddoapp/widgets/publieform2.dart';
import 'package:seddoapp/widgets/transit/DakarSearchWidget.dart';

import '../services/api_service.dart';
import '../services/publication_service.dart';

class PubliePage extends StatelessWidget {
  final List<dynamic>? categories;

  const PubliePage({Key? key, this.categories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    final publicationService = PublicationService(apiService.dio);
    final publicationRepository = PublicationRepository(
      publicationService: publicationService,
    );
    return BlocProvider(
      create:
          (context) => PublicationBloc(
            categorieRepository: CategorieRepository(),
            categories: categories,
            publicationRepository: publicationRepository,
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
  PlaceModel? address;
  final ScrollController _scrollController = ScrollController();

  final FocusNode _focusNode = FocusNode();

  bool _validateStep1(PublicationState state) {
    return state.selectedCategory != null &&
        state.selectedSubcategoryModel != null &&
        _titreController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty;
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

  void initState() {
    super.initState();

    // Ajouter les listeners de focus
    _focusNode.addListener(() => _scrollToFocusedField(_focusNode));
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
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PublicationBloc, PublicationState>(
      listener: (context, state) {
        if (state.isSuccess && state.redirectUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Publication soumise avec succès!')),
          );
          Navigator.pop(context);
        }
        if (state.isSuccess && state.redirectUrl != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PayWebView(url: state.redirectUrl!),
            ),
          ).then((value) {
            if (value == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Publication soumise avec succès!'),
                ),
              );
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Paiement annulé')));
              Navigator.pop(context);
            }
          });
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
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: Row(
              children: [
                // Back button
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    if (state.currentStep == 1) {
                      Navigator.of(context).pop();
                    } else {
                      context.read<PublicationBloc>().add(StepChanged(1));
                    }
                  },
                ),
                // Title
                const Text(
                  'Nouvelle Publication',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Step indicator in top right
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    '${state.currentStep} - 2',
                    style: TextStyle(
                      color: HexColor("#D95C18"),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: LinearProgressIndicator(
                value: state.currentStep / 2,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(HexColor("#D95C18")),
                minHeight: 4,
              ),
            ),
          ),
          body: Expanded(
            child:
                state.activeTabIndex == 0
                    ? state.currentStep == 1
                        ? SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: _buildStep1Form(context, state),
                        )
                        : _buildStep2Form(context, state)
                    : const Center(child: Text('Historique des publications')),
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
            borderRadius: BorderRadius.circular(30),
            color: const Color.fromARGB(255, 247, 247, 246),
          ),
          child: DropdownButtonFormField<String>(
            value: state.selectedCategory,
            style: const TextStyle(
              fontSize: 15,
              color: Color.fromARGB(255, 78, 73, 73),
            ),
            decoration: InputDecoration(
              hintText: 'Sélectionnez la catégorie',
              hintStyle: const TextStyle(
                fontSize: 15,
                color: Color.fromARGB(255, 78, 73, 73),
              ),
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
                            fontSize: 15,
                            color: Color.fromARGB(255, 78, 73, 73),
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
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(30),
            color: const Color.fromARGB(255, 247, 247, 246),
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
              fontSize: 15,
              color: Color.fromARGB(255, 78, 73, 73),
              fontWeight: FontWeight.normal,
            ),
            decoration: const InputDecoration(
              hintText: 'Sélectionnez la sous-catégorie',
              hintStyle: TextStyle(
                fontSize: 15,
                color: Color.fromARGB(255, 78, 73, 73),
              ),
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
              color: Color.fromARGB(255, 78, 73, 73),
            ),
            items:
                state.currentSubcategories.map((subCategory) {
                  return DropdownMenuItem<CategorieModel>(
                    value: subCategory,
                    child: Text(
                      subCategory.titre,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color.fromARGB(255, 78, 73, 73),
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
            borderRadius: BorderRadius.circular(30),
            color: const Color.fromARGB(255, 247, 247, 246),
          ),
          child: TextField(
            controller: _titreController,
            decoration: const InputDecoration(
              hintText: 'Entrez le titre de la publication',
              hintStyle: TextStyle(
                fontSize: 15,
                color: Color.fromARGB(255, 78, 73, 73),
              ),
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
          height: 100, // 🔸 Hauteur fixe
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(30),
            color: const Color.fromARGB(255, 247, 247, 246),
          ),
          child: TextField(
            controller: _descriptionController,
            expands: true, // 🔸 Permet au TextField de remplir le conteneur
            maxLines: null, // 🔸 Permet un nombre de lignes illimité (scroll)
            minLines: null,
            decoration: const InputDecoration(
              hintText: 'Ecrivez quelque chose...',
              hintStyle: TextStyle(
                fontSize: 15,
                color: Color.fromARGB(255, 78, 73, 73),
              ),
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
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
          ),
        ),
        const SizedBox(height: 8),
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
                  // widget.availabilityChanged(formattedDateTime);
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
        const SizedBox(height: 24),

        // Next button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: HexColor("#D95C18"),
            borderRadius: BorderRadius.circular(30),
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
      pricingList: state.pricings,
      selectedPricing: state.selectedPricing,
      onPricingChanged: (pricing) {
        context.read<PublicationBloc>().add(PricingSelected(pricing!));
      },
      priceChanged: (value) {
        context.read<PublicationBloc>().add(FormFieldUpdated('price', value));
      },
      onBackPressed: () {
        context.read<PublicationBloc>().add(StepChanged(1));
      },
      onPublishPressed: (address) {
        context.read<PublicationBloc>().add(
          PublicationSubmitted(
            authorId: 1,
            latitude: address != null ? address.latitude : 0,
            longitude: address != null ? address.longitude : 0,
            context: context,
          ),
        );
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
      availabilityChanged: (value) {
        context.read<PublicationBloc>().add(
          FormFieldUpdated(
            'availability',
            value,
          ), // Utilisez 'availability' de manière cohérente
        );
      },
    );
  }
}
