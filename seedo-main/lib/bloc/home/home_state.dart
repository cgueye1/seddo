import 'package:equatable/equatable.dart';
import 'package:seddoapp/models/menumodels.dart';
import 'package:seddoapp/models/publication_model.dart';
import '../../models/CategorieModel.dart';
import '../../models/user_model.dart';

class HomeState extends Equatable {
  final int selectedTabIndex;
  final int currentNavigationIndex;
  final String currentCategory;
  final Map<String, List<MenuModels>> categoryPublications;
  final Map<String, List<MenuModels>> filteredPublications;
  final List<String> selectedTypes;
  final bool isLoading;
  final bool isFiltered;
  final String error;
  final UserModel? currentUser;
  final CategorieModel?
  selectedCategory; // CategorieModel pour la catégorie sélectionnée
  final List<CategorieModel> categories; // Liste des catégories
  final String currentLocation;
  final List<Publication> publications;
  final bool isLoadingPublications;
  final String? publicationsError;
  final Map<int, List<CategorieModel>> subcategories;
  final CategorieModel? selectedSubcategory;
  final int? selectedCategoryId; // Pour le filtre de catégorie
  final bool hasReachedMax;
  final double? currentLatitude;
  final double? currentLongitude;
  final int? selectedSubcategoryId;
  final String? lastSearchKeyword;
  final bool isSearching;

  const HomeState({
    this.selectedTabIndex = 0,
    this.currentNavigationIndex = 0,
    this.currentCategory = 'All',
    this.categoryPublications = const {},
    this.filteredPublications = const {},
    this.selectedTypes = const [],
    this.isLoading = false,
    this.isFiltered = false,
    this.error = '',
    this.currentUser,
    this.categories = const [],
    this.currentLocation = 'Localisation',
    this.subcategories = const {},
    this.selectedCategory, // Pas de required, nullable
    this.selectedSubcategory,
    this.publications = const [],
    this.isLoadingPublications = false,
    this.publicationsError,
    this.selectedCategoryId,
    this.hasReachedMax = false,
    this.currentLatitude,
    this.currentLongitude,
    this.selectedSubcategoryId,
    this.lastSearchKeyword,
    this.isSearching = false,
  });

  factory HomeState.initial() {
    return HomeState(
      selectedTabIndex: 0,
      currentNavigationIndex: 0,
      currentCategory: "Petit'dej\n",
      categoryPublications: {},
      filteredPublications: {},
      selectedTypes: [],
      isLoading: false,
      isFiltered: false,
      error: '',
      currentUser: null,
      categories: [],
      currentLocation: 'Localisation',
      subcategories: {},
      selectedCategory: null,
      selectedSubcategory: null,
      publications: const [],
      isLoadingPublications: false,
      publicationsError: null,
      selectedCategoryId: null,
      hasReachedMax: false,
      lastSearchKeyword: '',
      isSearching: false,
    );
  }

  HomeState copyWith({
    int? selectedTabIndex,
    int? currentNavigationIndex,
    String? currentCategory,
    Map<String, List<MenuModels>>? categoryPublications,
    Map<String, List<MenuModels>>? filteredPublications,
    List<String>? selectedTypes,
    CategorieModel? selectedCategory,
    bool? isLoading,
    bool? isFiltered,
    String? error,
    UserModel? currentUser,
    List<CategorieModel>? categories,
    String? currentLocation,
    Map<int, List<CategorieModel>>? subcategories,
    CategorieModel? selectedSubcategory,
    List<Publication>? publications,
    bool? isLoadingPublications,
    String? publicationsError,
    int? selectedCategoryId,
    bool? hasReachedMax,
    double? currentLatitude,
    double? currentLongitude,
    int? selectedSubcategoryId,
    String? lastSearchKeyword,
    bool? isSearching,
  }) {
    return HomeState(
      currentUser: currentUser ?? this.currentUser,
      currentCategory: currentCategory ?? this.currentCategory,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      currentNavigationIndex:
          currentNavigationIndex ?? this.currentNavigationIndex,
      categoryPublications: categoryPublications ?? this.categoryPublications,
      filteredPublications: filteredPublications ?? this.filteredPublications,
      isFiltered: isFiltered ?? this.isFiltered,
      error: error ?? this.error,
      selectedCategory: selectedCategory,
      selectedSubcategory: selectedSubcategory,
      categories: categories ?? this.categories,
      subcategories: subcategories ?? this.subcategories,
      selectedTypes: selectedTypes ?? this.selectedTypes,
      currentLocation: currentLocation ?? this.currentLocation,
      publications: publications ?? this.publications,
      isLoadingPublications:
          isLoadingPublications ?? this.isLoadingPublications,
      publicationsError: publicationsError ?? this.publicationsError,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      selectedSubcategoryId:
          selectedSubcategoryId ?? this.selectedSubcategoryId,
      lastSearchKeyword: lastSearchKeyword ?? this.lastSearchKeyword,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object?> get props => [
    selectedTabIndex,
    currentNavigationIndex,
    currentCategory,
    categoryPublications,
    filteredPublications,
    selectedTypes,
    selectedCategory,
    isLoading,
    isFiltered,
    error,
    currentUser,
    categories,
    subcategories,
    selectedSubcategory,
    publications,
    isLoadingPublications,
    publicationsError,
    selectedCategoryId,
    hasReachedMax,
    currentLatitude,
    currentLongitude,
    selectedSubcategoryId,
    lastSearchKeyword,
    isSearching,
  ];
}
