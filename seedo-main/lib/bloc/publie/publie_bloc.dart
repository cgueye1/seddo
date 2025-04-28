// 3. Now, let's create the BLoC
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seddoapp/bloc/publie/publie_event.dart';
import 'package:seddoapp/bloc/publie/publie_state.dart';
import 'package:seddoapp/models/CategorieModel.dart';
import 'package:seddoapp/repositories/categorie_repository.dart';
import 'package:permission_handler/permission_handler.dart'; // Ajoutez cette ligne

class PublicationBloc extends Bloc<PublicationEvent, PublicationState> {
  final CategorieRepository categorieRepository;
  final List<dynamic> allCategories; // Store categories here

  PublicationBloc({
    required this.categorieRepository,
    required List<dynamic>? categories,
  }) : allCategories = categories ?? [],
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
      case 'telephone':
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
    emit(state.copyWith(isSubmitting: true));

    try {
      // Here you would typically call an API to submit the publication
      // await publicationRepository.submitPublication(...);

      // For now, we'll just simulate a successful submission
      await Future.delayed(const Duration(seconds: 1));

      emit(state.copyWith(isSubmitting: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
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
    // Vérifiez d'abord si vous avez la permission
    var status = await Permission.camera.status;

    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (!status.isGranted) {
        // Si la permission est refusée, montrez un message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission caméra requise')),
        );
        return;
      }
    }

    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null && context.mounted) {
        // Traitez l'image ici
        // Par exemple avec un Bloc :
        // context.read<PublicationBloc>().add(ImagesAdded([image.path]));

        // Ou avec un StatefulWidget :
        // setState(() {
        //   _selectedImages.add(File(image.path));
        // });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
      }
    }
  }

  void _onImagesAdded(ImagesAdded event, Emitter<PublicationState> emit) {
    emit(state.copyWith(pictures: [...state.pictures, ...event.images]));
  }

  void _onImageRemoved(ImageRemoved event, Emitter<PublicationState> emit) {
    final newImages = List<String>.from(state.pictures);
    newImages.removeAt(event.index);
    emit(state.copyWith(pictures: newImages));
  }
}
