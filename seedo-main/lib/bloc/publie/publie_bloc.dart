// 3. Now, let's create the BLoC
// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seddoapp/bloc/publie/publie_event.dart';
import 'package:seddoapp/bloc/publie/publie_state.dart';
import 'package:seddoapp/models/CategorieModel.dart';
import 'package:seddoapp/repositories/categorie_repository.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/AppParamModel.dart';
import '../../models/PaiementRequestModel.dart';
import '../../repositories/defaultRepository.dart';
import '../../repositories/publication_repository.dart';
import '../../services/AdMobService.dart'; // Ajoutez cette ligne

class PublicationBloc extends Bloc<PublicationEvent, PublicationState> {
  final CategorieRepository categorieRepository;
  final List<dynamic> allCategories; // Store categories here
  final PublicationRepository _publicationRepository;
  final AdService adService = AdService();
  final DefaultRepository repository = DefaultRepository();

  PublicationBloc({
    required this.categorieRepository,
    required List<dynamic>? categories,
    required PublicationRepository publicationRepository,
  }) : _publicationRepository = publicationRepository,
       allCategories = categories ?? [],
       super(
         PublicationState(categoryTitles: _extractCategoryTitles(categories)),
       ) {
    on<TabChanged>(_onTabChanged);
    on<StepChanged>(_onStepChanged);
    on<CategorySelected>(_onCategorySelected);
    on<SubcategorySelected>(_onSubcategorySelected);
    on<FormFieldUpdated>(_onFormFieldUpdated);
    on<ImagesAdded>(_onImagesAdded);
    on<PublicationSubmitted>(_onPublicationSubmitted);
    on<ImageRemoved>(_onImageRemoved); // Ajoutez cette ligne
    on<LoadInitialPricing>(_onLoadInitialPricing);

    on<LoadAppParam>(_onLoadAppParam);

    on<PricingSelected>((event, emit) {
      emit(state.copyWith(selectedPricing: event.selectedPricing));
    });
    // Déclenche l'événement pour charger les prix dès le démarrage
    add(LoadInitialPricing());
    add(LoadAppParam());
  }

  static List<String> _extractCategoryTitles(List<dynamic>? categories) {
    if (categories != null && categories.isNotEmpty) {
      try {
        return categories
            .map<String>((category) => category.titre as String)
            .toList();
      } catch (e) {
        print("Erreur d'extraction des titres: $e");
        return ['catégorie 1', 'catégorie 2', 'catégorie 3'];
      }
    } else {
      return ['catégorie 1', 'catégorie 2', 'catégorie 3'];
    }
  }

  void _onTabChanged(TabChanged event, Emitter<PublicationState> emit) {
    emit(state.copyWith(activeTabIndex: event.tabIndex));
  }

  void _onStepChanged(StepChanged event, Emitter<PublicationState> emit) {
    emit(state.copyWith(currentStep: event.stepIndex));
  }

  Future<void> _onCategorySelected(
    CategorySelected event,
    Emitter<PublicationState> emit,
  ) async {
    // Find the category
    CategorieModel? foundCategory;
    for (var category in allCategories) {
      if (category.titre == event.category) {
        foundCategory = category;
        break;
      }
    }

    // Always clear the subcategory selection
    emit(
      state.copyWith(
        selectedCategory: event.category,
        categorie: foundCategory,
        selectedSubcategoryModel: null, // Make sure this is null
        currentSubcategories: [], // Clear the list while loading
      ),
    );

    // Then load subcategories
    await _loadSubcategories(event.category, emit);
  }

  void _onSubcategorySelected(
    SubcategorySelected event,
    Emitter<PublicationState> emit,
  ) {
    emit(state.copyWith(selectedSubcategoryModel: event.subcategory));
  }

  void _onFormFieldUpdated(
    FormFieldUpdated event,
    Emitter<PublicationState> emit,
  ) {
    switch (event.field) {
      case 'titre':
        emit(state.copyWith(titre: event.value));
        break;
      case 'description':
        emit(state.copyWith(description: event.value));
        break;
      case 'location':
        emit(state.copyWith(location: event.value));
        break;
      case 'date':
        emit(state.copyWith(date: event.value));
        break;
      case 'availability':
        emit(state.copyWith(availability: event.value));
        break;
      case 'price':
        // Convertir le prix en double ou utiliser 0.0 si la conversion échoue
        final priceValue = double.tryParse(event.value) ?? 0.0;
        emit(state.copyWith(price: priceValue));
        break;
      case 'call':
        emit(state.copyWith(telephone: event.value));
        break;
      case 'languages':
        emit(state.copyWith(languages: event.value));
        break;
      case 'link':
        emit(state.copyWith(link: event.value));
        break;
      case 'audio':
        emit(state.copyWith(audio: event.value));
        break;
      case 'action':
        emit(state.copyWith(action: event.value));
        break;
      // Gérer les booléens
      case 'available':
        emit(state.copyWith(available: event.value.toLowerCase() == 'true'));
        break;
      case 'universel':
        emit(state.copyWith(universel: event.value.toLowerCase() == 'true'));
        break;
      case 'emergency':
        emit(state.copyWith(emergency: event.value.toLowerCase() == 'true'));
        break;
      case 'ad':
        emit(state.copyWith(ad: event.value.toLowerCase() == 'true'));
        break;
    }
  }

  Future<void> _onPublicationSubmitted(
    PublicationSubmitted event,
    Emitter<PublicationState> emit,
  ) async {
    emit(
      state.copyWith(isSubmitting: true, isSuccess: false, errorMessage: null),
    );

    try {
      final titre = state.titre;
      final description = state.description;
      final authorId = event.authorId;
      final latitude = event.latitude;
      final longitude = event.longitude;
      final pictures = state.pictures;
      final available = state.available;
      final universel = state.universel;
      final date = state.availability;
      final price = state.price;
      final pricing = state.selectedPricing;
      final call = state.telephone;


      if (latitude == 0 || longitude == 0) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: "L'adresse est obligatoire",
          ),
        );
        return;
      }

      if (pictures.isEmpty) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: "Veuillez sélectionner au moins une image",
          ),
        );
        return;
      }

      final selectedCategory =
          state.selectedSubcategoryModel ?? state.categorie;
      if (selectedCategory == null) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: "Veuillez sélectionner une catégorie.",
          ),
        );
        return;
      }

      if (pricing!.price == 0.0 && !state.appParam!.hideAds) {
        final rewardedWatched = await adService.showRewardedAd(
          onRewarded: () {},
        );

        if (!rewardedWatched) {
          emit(
            state.copyWith(
              isSubmitting: false,
              errorMessage:
                  "Vous devez regarder la vidéo pour valider la publication.",
            ),
          );
          return;
        }
      }

      final response = await _publicationRepository.postPublication(
        titre: titre,
        description: description,
        authorId: authorId,
        categorieId: selectedCategory.id,
        latitude: latitude,
        longitude: longitude,
        price: price,
        date: date,
        imagePaths: pictures,
        available: available,
        universel: universel,
        audio: '',
        emergency: false,
        days: pricing.days,
        pricingId: pricing.id,
        call:call
      );

      if (pricing.price != 0.0 && response != null) {
        final paiementRequest = PaiementRequestModel(
          ref: '$titre-${response.data["id"]}',
          price: pricing.price.toString(),
          itemName: titre,
          commandeName: titre,
          id: response.data["id"],
        );

        final paymentResponse = await _publicationRepository.payMeal(
          paiementRequest,
        );

        emit(
          state.copyWith(
            isSubmitting: false,
            isSuccess: true,
            redirectUrl: paymentResponse.redirectUrl,
          ),
        );
      } else {
        emit(state.copyWith(isSubmitting: false, isSuccess: true));
      }
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          isSuccess: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _loadSubcategories(
    String? categoryTitle,
    Emitter<PublicationState> emit,
  ) async {
    if (categoryTitle == null) {
      emit(state.copyWith(currentSubcategories: []));
      return;
    }

    try {
      // Find the selected category from the stored categories
      CategorieModel? selectedCategory;
      for (var category in allCategories) {
        if (category.titre == categoryTitle) {
          selectedCategory = category;
          break;
        }
      }

      if (selectedCategory != null) {
        int categoryId = selectedCategory.id;

        // Check if subcategories are already loaded
        if (state.subcategoriesMap.containsKey(categoryId)) {
          emit(
            state.copyWith(
              currentSubcategories: state.subcategoriesMap[categoryId] ?? [],
            ),
          );
        } else {
          // Load subcategories with null check
          final subcategories = await categorieRepository.fetchSubcategories(
            categoryId,
          ); // Provide empty list if null is returned

          Map<int, List<CategorieModel>> updatedMap = Map.from(
            state.subcategoriesMap,
          );
          updatedMap[categoryId] = subcategories;

          emit(
            state.copyWith(
              subcategoriesMap: updatedMap,
              currentSubcategories: subcategories,
            ),
          );
        }
      } else {
        emit(state.copyWith(currentSubcategories: []));
      }
    } catch (e) {
      print("Erreur lors du chargement des sous-catégories: $e");
      emit(
        state.copyWith(currentSubcategories: [], errorMessage: e.toString()),
      );
    }
  }

  Future<void> onCameraPressed(BuildContext context) async {
    try {
      // Vérification plus robuste des permissions
      var cameraStatus = await Permission.camera.status;
      var storageStatus = await Permission.storage.status;

      print("Status caméra: $cameraStatus");
      print("Status stockage: $storageStatus");

      // Demander les permissions si nécessaire
      if (!cameraStatus.isGranted) {
        cameraStatus = await Permission.camera.request();
        if (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Permission caméra requise pour prendre des photos',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      // Vérifier la permission de stockage pour Android
      if (!storageStatus.isGranted) {
        storageStatus = await Permission.storage.request();
      }

      final picker = ImagePicker();

      // Prendre la photo avec des paramètres plus conservateurs
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        // Réduire la qualité pour éviter les problèmes de mémoire
        maxWidth: 1024,
        // Réduire la taille maximale
        maxHeight: 1024,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null && context.mounted) {
        print("Photo prise avec succès: ${image.path}");

        // Vérifier que le fichier existe
        final file = File(image.path);
        if (await file.exists()) {
          // Ajouter l'image via le BLoC
          context.read<PublicationBloc>().add(ImagesAdded([image.path]));

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo ajoutée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception("Le fichier image n'a pas été créé");
        }
      }
    } catch (e) {
      print("Erreur lors de la prise de photo: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur caméra: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onImagesAdded(ImagesAdded event, Emitter<PublicationState> emit) {
    try {
      final currentPictures = List<String>.from(state.pictures);
      final newPictures = [...currentPictures, ...event.images];

      // Limiter le nombre d'images pour éviter les problèmes de mémoire
      if (newPictures.length > 10) {
        emit(state.copyWith(errorMessage: "Maximum 10 images autorisées"));
        return;
      }

      emit(state.copyWith(pictures: newPictures, errorMessage: null));
    } catch (e) {
      emit(
        state.copyWith(errorMessage: "Erreur lors de l'ajout des images: $e"),
      );
    }
  }

  void _onImageRemoved(ImageRemoved event, Emitter<PublicationState> emit) {
    final newImages = List<String>.from(state.pictures);
    newImages.removeAt(event.index);
    emit(state.copyWith(pictures: newImages));
  }

  Future<void> _onLoadInitialPricing(
    LoadInitialPricing event,
    Emitter<PublicationState> emit,
  ) async {
    try {
      final pricings = await _publicationRepository.fetchPricings();

      final selected = pricings.firstWhere(
        (p) => p.price == 0,
        orElse:
            () =>
                pricings.isNotEmpty
                    ? pricings.first
                    : throw Exception('Aucun pricing'),
      );

      emit(state.copyWith(pricings: pricings, selectedPricing: selected));
    } catch (e) {
      emit(state.copyWith(errorMessage: "Erreur chargement des tarifs"));
    }
  }

  Future<void> _onLoadAppParam(
    LoadAppParam event,
    Emitter<PublicationState> emit,
  ) async {
    final appParam = await _getAppParam();
    emit(state.copyWith(appParam: appParam));
  }

  Future<AppParamModel> _getAppParam() async {
    try {
      final response = await repository.getData("/appparam");

      if (response.data != null) {
        return AppParamModel.fromJson(response.data);
      } else {
        return AppParamModel(
          id: 0,
          hideAds: false,
          hideTransit: false,
          appVersion: "",
          androidLink:
              "https://apps.apple.com/us/app/seddo/id6737347803?l=fr-FR",
          iosLink:
              "https://play.google.com/store/apps/details?id=com.wakana.seddo&hl=ln",
          apiKey: "",
          useGoogleSearch: false,
          appVersionList: [],
        );
      }
    } catch (e) {
      return AppParamModel(
        id: 0,
        hideAds: false,
        hideTransit: false,
        appVersion: "",
        androidLink: "https://apps.apple.com/us/app/seddo/id6737347803?l=fr-FR",
        iosLink:
            "https://play.google.com/store/apps/details?id=com.wakana.seddo&hl=ln",
        apiKey: "",
        useGoogleSearch: false,
        appVersionList: [],
      );
    }
  }
}
