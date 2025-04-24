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
    emit(
      state.copyWith(
        selectedCategory: event.category,
        selectedSubcategoryModel: null,
        currentSubcategories: [],
      ),
    );

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
      case 'title':
        emit(state.copyWith(title: event.value));
        break;
      case 'description':
        emit(state.copyWith(description: event.value));
        break;
      case 'location':
        emit(state.copyWith(location: event.value));
        break;
      case 'dateTime':
        emit(state.copyWith(dateTime: event.value));
        break;
      case 'availability':
        emit(state.copyWith(availability: event.value));
        break;
      case 'price':
        emit(state.copyWith(price: event.value));
        break;
      case 'languages':
        emit(state.copyWith(languages: event.value));
        break;
    }
  }

  void _onImagesAdded(ImagesAdded event, Emitter<PublicationState> emit) {
    emit(
      state.copyWith(
        selectedImages: [...state.selectedImages, ...event.images],
      ),
    );
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

  void _onImageRemoved(ImageRemoved event, Emitter<PublicationState> emit) {
    final newImages = List<String>.from(state.selectedImages);
    newImages.removeAt(event.index);
    emit(state.copyWith(selectedImages: newImages));
  }
}
