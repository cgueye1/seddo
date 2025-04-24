// 2. Now, let's create the BLoC state
import 'package:equatable/equatable.dart';
import 'package:seddoapp/models/CategorieModel.dart';

class PublicationState extends Equatable {
  final int currentStep;
  final int activeTabIndex;
  final String title;
  final String description;
  final String location;
  final String dateTime;
  final String availability;
  final String price;
  final String languages;
  final List<String> selectedImages;
  final List<String> categoryTitles;
  final String? selectedCategory;
  final Map<int, List<CategorieModel>> subcategoriesMap;
  final List<CategorieModel> currentSubcategories;
  final CategorieModel? selectedSubcategoryModel;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  const PublicationState({
    this.currentStep = 1,
    this.activeTabIndex = 0,
    this.title = '',
    this.description = '',
    this.location = '',
    this.dateTime = '',
    this.availability = '',
    this.price = '',
    this.languages = '',
    this.selectedImages = const [],
    this.categoryTitles = const [],
    this.selectedCategory,
    this.subcategoriesMap = const {},
    this.currentSubcategories = const [],
    this.selectedSubcategoryModel,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  PublicationState copyWith({
    int? currentStep,
    int? activeTabIndex,
    String? title,
    String? description,
    String? location,
    String? dateTime,
    String? availability,
    String? price,
    String? languages,
    List<String>? selectedImages,
    List<String>? categoryTitles,
    String? selectedCategory,
    Map<int, List<CategorieModel>>? subcategoriesMap,
    List<CategorieModel>? currentSubcategories,
    CategorieModel? selectedSubcategoryModel,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return PublicationState(
      currentStep: currentStep ?? this.currentStep,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      dateTime: dateTime ?? this.dateTime,
      availability: availability ?? this.availability,
      price: price ?? this.price,
      languages: languages ?? this.languages,
      selectedImages: selectedImages ?? this.selectedImages,
      categoryTitles: categoryTitles ?? this.categoryTitles,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      subcategoriesMap: subcategoriesMap ?? this.subcategoriesMap,
      currentSubcategories: currentSubcategories ?? this.currentSubcategories,
      selectedSubcategoryModel:
          selectedSubcategoryModel ?? this.selectedSubcategoryModel,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    activeTabIndex,
    title,
    description,
    location,
    dateTime,
    availability,
    price,
    languages,
    selectedImages,
    categoryTitles,
    selectedCategory,
    subcategoriesMap,
    currentSubcategories,
    selectedSubcategoryModel,
    isSubmitting,
    isSuccess,
    errorMessage,
  ];
}
