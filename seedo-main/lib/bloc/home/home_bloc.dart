// Dans homeBloc.dart
// ignore_for_file: avoid_init_to_null, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/bloc/home/publicationState.dart';
import 'package:seddoapp/models/CategorieModel.dart';
import 'package:seddoapp/models/menumodels.dart';
import 'package:seddoapp/models/publication_model.dart';
import 'package:seddoapp/repositories/auth_repository.dart';
import 'package:seddoapp/repositories/categorie_repository.dart';
import 'package:seddoapp/repositories/publication_repository.dart';
import 'package:seddoapp/services/LocationService.dart';
import 'package:seddoapp/services/menu_service.dart';
import 'home_state.dart';
import 'home_event.dart';

// Ajoutez un nouvel événement
class LocationUpdated extends HomeEvent {
  final String locationName;
  const LocationUpdated({required this.locationName});
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final MenuService _menuService = MenuService();
  final AuthRepository _authRepository = AuthRepository();
  final CategorieRepository _categorieRepository = CategorieRepository();
  final LocationService _locationService = LocationService();
  final PublicationRepository _publicationRepository;
  final TextEditingController searchController = TextEditingController();
  final SearchManager searchManager = SearchManager();

  HomeBloc(this._publicationRepository) : super(HomeState.initial()) {
    on<InitializeHomeEvent>(_onInitializeHome);
    on<LoadCurrentUser>(_onLoadCurrentUser);
    on<TabChanged>(_onChangeTab);
    on<NavigationIndexChanged>(_onChangeNavigation);

    on<LoadCategories>(_onLoadCategories);
    on<SelectCategory>(_onSelectCategory);
    on<CategoryChanged>(_onCategoryChanged);
    on<LoadSubcategories>(_onLoadSubcategories);
    on<SubcategoryChanged>(_onSubcategoryChanged);

    on<TypesFilterChanged>(_onTypesFilterChanged);
    on<ResetFilters>(_onResetFilters);
    on<ToggleFavorite>(_onToggleFavorite);
    on<LoadCurrentLocation>(_onLoadCurrentLocation);
    on<UpdateCurrentLocation>(_onUpdateCurrentLocation);
    on<LoadNearbyPublications>(_onLoadNearbyPublications);
    on<RefreshPublications>(_onRefreshPublications);
    on<FilterPublicationsByCategory>(_onFilterPublicationsByCategory);
    on<ToggleFavoritePublication>(_onToggleFavoritePublication);
    on<FilterPublicationsBySubcategory>(_onFilterPublicationsBySubcategory);
    on<SearchPublications>(_onSearchPublications);

    // Initialize data when bloc is created
    add(const InitializeHomeEvent());
  }
  Future<void> _onInitializeHome(
    InitializeHomeEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      // Load menu data
      final categoryPublications = await _menuService.loadMenuData();

      // Load categories
      final categories = await _categorieRepository.fetchCategoriesNoParent();

      // Ne sélectionne aucune catégorie au démarrage
      CategorieModel? initialCategory = null;

      // Get first menu category if available
      final firstCategory =
          categoryPublications.keys.isNotEmpty
              ? categoryPublications.keys.first
              : "Petit'dej\n";

      emit(
        state.copyWith(
          categoryPublications: categoryPublications,
          currentCategory: firstCategory,
          categories: categories,
          selectedCategory: initialCategory,
        ),
      );

      // Préchargement de toutes les sous-catégories pour éviter les délais
      for (var category in categories) {
        try {
          final subcategories = await _categorieRepository.fetchSubcategories(
            category.id,
          );

          emit(
            state.copyWith(
              subcategories: {
                ...state.subcategories,
                category.id: subcategories,
              },
            ),
          );
        } catch (e) {
          // Continuez avec la prochaine catégorie même en cas d'erreur
        }
      }
    } catch (e) {
      emit(state.copyWith(error: 'Error: ${e.toString()}'));
    }
  }

  Future<void> _onLoadCurrentUser(
    LoadCurrentUser event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final user = await _authRepository.currentUser();
      emit(state.copyWith(currentUser: user));
    } catch (e) {
      emit(
        state.copyWith(
          error: 'Erreur de chargement utilisateur: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onLoadNearbyPublications(
    LoadNearbyPublications event,
    Emitter<HomeState> emit,
  ) async {
    // Ne pas bloquer les chargements normaux lorsque la recherche est désactivée
    if (searchManager.blockAutoRefresh &&
        searchManager.isSearchActive &&
        state.lastSearchKeyword != null &&
        state.lastSearchKeyword!.isNotEmpty) {
      print("LoadNearbyPublications ignoré car la recherche est active");
      return;
    }

    emit(state.copyWith(isLoadingPublications: true, publicationsError: null));

    try {
      final publications = await _publicationRepository.getNearbyPublications(
        latitude: event.latitude,
        longitude: event.longitude,
        categoryId: event.categoryId,
        subcategoryId: event.subcategoryId,
      );

      emit(
        state.copyWith(
          publications: publications,
          isLoadingPublications: false,
          selectedCategory: state.selectedCategory, // Ajoutez cette ligne
          selectedCategoryId: event.categoryId ?? state.selectedCategoryId,
          selectedSubcategory: state.selectedSubcategory, // Ajoutez cette ligne
          selectedSubcategoryId:
              event.subcategoryId ?? state.selectedSubcategoryId,
          lastSearchKeyword:
              searchManager.isSearchActive ? state.lastSearchKeyword : null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingPublications: false,
          publicationsError: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSearchPublications(
    SearchPublications event,
    Emitter<HomeState> emit,
  ) async {
    print("_onSearchPublications: keyword=${event.keyword}");
    searchManager.beginSearch(event.keyword);

    // Gardez l'ancien mot-clé pour comparaison
    final previousKeyword = state.lastSearchKeyword;

    emit(
      state.copyWith(
        isLoadingPublications: true,
        publicationsError: null,
        isSearching: true,
        lastSearchKeyword: event.keyword,
        // Préserver explicitement ces valeurs
        selectedCategory: state.selectedCategory,
        selectedCategoryId: state.selectedCategoryId,
        selectedSubcategory: state.selectedSubcategory,
        selectedSubcategoryId: state.selectedSubcategoryId,
      ),
    );

    try {
      // Récupérer toutes les publications sans filtrage par mot-clé au niveau de l'API
      final allPublications = await _publicationRepository
          .getNearbyPublications(
            latitude: event.latitude,
            longitude: event.longitude,
            categoryId: event.categoryId,
          );

      // Filtrer les publications localement
      List<Publication> filteredPublications = allPublications;
      if (event.keyword != null && event.keyword!.isNotEmpty) {
        final String normalizedKeyword = event.keyword!.toLowerCase();
        filteredPublications =
            allPublications.where((publication) {
              return publication.titre.toLowerCase().startsWith(
                normalizedKeyword,
              );
            }).toList();
      }

      print(
        "Recherche terminée. Nombre de résultats: ${filteredPublications.length}",
      );

      emit(
        state.copyWith(
          publications: filteredPublications,
          isLoadingPublications: false,
          isSearching: false,
          lastSearchKeyword: event.keyword,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingPublications: false,
          publicationsError: e.toString(),
          isSearching: false,
          lastSearchKeyword: event.keyword,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    searchController.dispose(); // Important: dispose controller
    return super.close();
  }

  Future<void> _onRefreshPublications(
    RefreshPublications event,
    Emitter<HomeState> emit,
  ) async {
    // Réinitialiser le gestionnaire de recherche
    searchManager.cancelSearch();

    emit(
      state.copyWith(
        publications: [],
        hasReachedMax: false,
        lastSearchKeyword:
            null, // Important : réinitialiser le mot-clé de recherche
        isSearching: false, // Réinitialiser l'état de recherche
      ),
    );

    // Si nous avons des coordonnées de localisation, charger les publications à proximité
    if (state.currentLatitude != null && state.currentLongitude != null) {
      add(
        LoadNearbyPublications(
          latitude: state.currentLatitude!,
          longitude: state.currentLongitude!,
          categoryId: state.selectedCategoryId,
        ),
      );
    }
  }

  Future<void> _onFilterPublicationsBySubcategory(
    FilterPublicationsBySubcategory event,
    Emitter<HomeState> emit,
  ) async {
    // Conservez la catégorie parent actuellement sélectionnée
    final currentCategory = state.selectedCategory;
    final currentCategoryId = state.selectedCategoryId;

    // Vérifier si nous cliquons sur la même sous-catégorie (pour désélectionner)
    final int? newSubcategoryId =
        (state.selectedSubcategoryId == event.subcategoryId)
            ? null
            : event.subcategoryId;

    // Rechercher la sous-catégorie pour l'affichage
    CategorieModel? selectedSubcategory;
    if (newSubcategoryId != null && currentCategoryId != null) {
      final subcategories = state.subcategories[currentCategoryId] ?? [];
      for (var subcat in subcategories) {
        if (subcat.id == newSubcategoryId) {
          selectedSubcategory = subcat;
          break;
        }
      }
    }

    // Mettre à jour l'état en CONSERVANT la catégorie parent
    emit(
      state.copyWith(
        selectedCategory: currentCategory,
        selectedCategoryId: currentCategoryId,
        selectedSubcategoryId: newSubcategoryId,
        selectedSubcategory: selectedSubcategory,
        publications: [], // Réinitialiser les publications
        hasReachedMax: false,
        isLoadingPublications: true,
      ),
    );

    if (state.currentLatitude != null && state.currentLongitude != null) {
      try {
        print(
          "Chargement des publications avec: categoryId=$currentCategoryId, subcategoryId=$newSubcategoryId",
        );
        final publications = await _publicationRepository.getNearbyPublications(
          latitude: state.currentLatitude!,
          longitude: state.currentLongitude!,
          categoryId: currentCategoryId,
          subcategoryId: newSubcategoryId,
        );

        // Vérifier que les publications ont été correctement filtrées
        print("Publications chargées: ${publications.length}");

        emit(
          state.copyWith(
            publications: publications,
            isLoadingPublications: false,
            selectedCategory: currentCategory,
            selectedCategoryId: currentCategoryId,
            selectedSubcategory: selectedSubcategory,
            selectedSubcategoryId: newSubcategoryId,
          ),
        );
      } catch (e) {
        print("Erreur de chargement des publications: $e");
        emit(
          state.copyWith(
            isLoadingPublications: false,
            publicationsError: e.toString(),
            selectedCategory: currentCategory,
            selectedCategoryId: currentCategoryId,
            selectedSubcategory: selectedSubcategory,
            selectedSubcategoryId: newSubcategoryId,
          ),
        );
      }
    }
  }

  Future<void> _onFilterPublicationsByCategory(
    FilterPublicationsByCategory event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedCategoryId: event.categoryId,
        publications: [],
        hasReachedMax: false,
        selectedSubcategoryId: null,
      ),
    );

    if (state.currentLatitude != null && state.currentLongitude != null) {
      add(
        LoadNearbyPublications(
          latitude: state.currentLatitude!,
          longitude: state.currentLongitude!,
          categoryId: event.categoryId,
          subcategoryId: null,
        ),
      );
    }
  }

  void _onChangeTab(TabChanged event, Emitter<HomeState> emit) {
    emit(state.copyWith(selectedTabIndex: event.tabIndex));
  }

  void _onChangeNavigation(
    NavigationIndexChanged event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(currentNavigationIndex: event.navigationIndex));
  }

  void _onSubcategoryChanged(
    SubcategoryChanged event,
    Emitter<HomeState> emit,
  ) {
    final newSubcategory =
        (event.subcategory?.id == state.selectedSubcategory?.id)
            ? null
            : event.subcategory;

    emit(
      state.copyWith(
        selectedSubcategory: newSubcategory,
        selectedSubcategoryId: newSubcategory?.id, // Ajouter cette ligne
        isFiltered: newSubcategory != null,
        // Ne pas changer la catégorie sélectionnée
      ),
    );

    // Ne pas déclencher LoadNearbyPublications ici, car FilterPublicationsBySubcategory s'en charge
  }

  void _onSelectCategory(SelectCategory event, Emitter<HomeState> emit) {
    emit(state.copyWith(selectedCategory: event.category));
  }

  void _onCategoryChanged(CategoryChanged event, Emitter<HomeState> emit) {
    // Cas 1: Désélection complète (category == null)
    if (event.category == null) {
      emit(state.copyWith(selectedCategory: null, selectedSubcategory: null));
      return;
    }

    // Cas 2: Nouvelle catégorie différente
    if (state.selectedCategory?.id != event.category?.id) {
      emit(
        state.copyWith(
          selectedCategory: event.category,
          selectedSubcategory:
              null, // Réinitialise seulement si catégorie change
        ),
      );
    }
    // Cas 3: Même catégorie recliquée
    else {
      emit(
        state.copyWith(
          selectedCategory: event.category, // Maintient la sélection
          // Ne change pas selectedSubcategory intentionnellement
        ),
      );
    }
  }

  void _onTypesFilterChanged(
    TypesFilterChanged event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(selectedTypes: event.selectedTypes));
  }

  void _onResetFilters(ResetFilters event, Emitter<HomeState> emit) {
    emit(
      state.copyWith(
        selectedTypes: [],
        selectedCategory: null,
        isFiltered: false,
        filteredPublications: {},
      ),
    );
  }

  void _onToggleFavorite(ToggleFavorite event, Emitter<HomeState> emit) {
    try {
      // Create a deep copy of categoryPublications with correct type
      final Map<String, List<MenuModels>> updatedPublications = {};

      // Properly copy the map with the correct types
      state.categoryPublications.forEach((category, menuList) {
        updatedPublications[category] = List<MenuModels>.from(menuList);
      });

      // Update the favorite status for all matching menu items across categories
      for (final category in updatedPublications.keys) {
        final menuList = updatedPublications[category]!;

        for (int i = 0; i < menuList.length; i++) {
          final menu = menuList[i];
          if (menu.title == event.menuId) {
            menuList[i] = menu.copyWith(isFavorite: !menu.isFavorite);
          }
        }
      }

      // If filtering is active, also update the filtered publications
      Map<String, List<MenuModels>>? updatedFilteredPublications;
      if (state.isFiltered) {
        updatedFilteredPublications = {};

        // Properly copy the filtered map with correct types
        state.filteredPublications.forEach((category, menuList) {
          updatedFilteredPublications![category] = List<MenuModels>.from(
            menuList,
          );
        });

        for (final category in updatedFilteredPublications.keys) {
          final menuList = updatedFilteredPublications[category]!;

          for (int i = 0; i < menuList.length; i++) {
            final menu = menuList[i];
            if (menu.title == event.menuId) {
              menuList[i] = menu.copyWith(isFavorite: !menu.isFavorite);
            }
          }
        }
      }

      emit(
        state.copyWith(
          categoryPublications: updatedPublications,
          filteredPublications: updatedFilteredPublications,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: 'Error toggling favorite: ${e.toString()}'));
    }
  }

  Future<void> _onLoadSubcategories(
    LoadSubcategories event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final subcategories = await _categorieRepository.fetchSubcategories(
        event.parentId,
      );

      final updatedSubcategories = Map<int, List<CategorieModel>>.from(
        state.subcategories,
      );
      updatedSubcategories[event.parentId] = subcategories;

      emit(
        state.copyWith(
          subcategories: updatedSubcategories,
          selectedCategory: state.selectedCategory,
        ),
      );
    } catch (e) {
      emit(state);
    }
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final categories = await _categorieRepository.fetchCategoriesNoParent();
      emit(state.copyWith(categories: categories));
    } catch (e) {
      emit(state.copyWith(error: 'Erreur de chargement des catégories: $e'));
    }
  }

  Future<void> _onLoadCurrentLocation(
    LoadCurrentLocation event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        // Update to await the asynchronous method call
        final String address = await _locationService.getAddressFromCoordinates(
          position,
        );
        emit(
          state.copyWith(
            currentLocation: address,
            currentLatitude: position.latitude,
            currentLongitude: position.longitude,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(currentLocation: "Localisation non disponible"));
    }
  }

  Future<void> _onToggleFavoritePublication(
    ToggleFavoritePublication event,
    Emitter<HomeState> emit,
  ) async {
    try {
      // Créer une copie de la liste de publications pour pouvoir la modifier
      final List<Publication> updatedPublications = List<Publication>.from(
        state.publications,
      );

      // Mettre à jour le statut favori pour la publication spécifique
      for (int i = 0; i < updatedPublications.length; i++) {
        if (updatedPublications[i].id == event.publicationId) {
          // Créer une copie de la publication avec la valeur isFavorite inversée
          final publication = updatedPublications[i];
          publication.isFavorite = !publication.isFavorite;
          break;
        }
      }

      // Émettre le nouvel état avec les publications mises à jour
      emit(state.copyWith(publications: updatedPublications));

      // Vous pourriez également ajouter ici une logique pour sauvegarder le statut favori
      // via une API ou en local storage si nécessaire
      // await _publicationRepository.toggleFavorite(event.publicationId);
    } catch (e) {
      emit(
        state.copyWith(
          error: 'Erreur lors de la mise à jour des favoris: ${e.toString()}',
        ),
      );
    }
  }

  void _onUpdateCurrentLocation(
    UpdateCurrentLocation event,
    Emitter<HomeState> emit,
  ) {
    emit(
      state.copyWith(
        currentLocation: event.location,
        currentLatitude: event.latitude,
        currentLongitude: event.longitude,
      ),
    );
  }
}
