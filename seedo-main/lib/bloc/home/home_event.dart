import 'package:equatable/equatable.dart';
import '../../models/CategorieModel.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => []; // Changed to Object? to handle nulls
}

class InitializeHomeEvent extends HomeEvent {
  const InitializeHomeEvent();
}

class TabChanged extends HomeEvent {
  final int tabIndex;

  const TabChanged({required this.tabIndex});

  @override
  List<Object> get props => [tabIndex];
}

class ToggleFavorite extends HomeEvent {
  final String menuId; // Unique identifier for the menu item

  const ToggleFavorite({required this.menuId});

  @override
  List<Object> get props => [menuId];
}

class NavigationIndexChanged extends HomeEvent {
  final int navigationIndex;

  const NavigationIndexChanged({required this.navigationIndex});

  @override
  List<Object> get props => [navigationIndex];
}

class TypesFilterChanged extends HomeEvent {
  final List<String> selectedTypes;

  const TypesFilterChanged({required this.selectedTypes});

  @override
  List<Object> get props => [selectedTypes];
}

class ApplyFilters extends HomeEvent {
  const ApplyFilters();
}

class ResetFilters extends HomeEvent {
  const ResetFilters();
}

class LoadCurrentUser extends HomeEvent {}

// Categorie events
class LoadCategories extends HomeEvent {}

class SelectCategory extends HomeEvent {
  final CategorieModel category;

  const SelectCategory(this.category);

  @override
  List<Object> get props => [category];
}

// Ajoutez cette classe à votre fichier home_event.dart
class LoadNearbyLocation extends HomeEvent {
  final double latitude;
  final double longitude;

  const LoadNearbyLocation({required this.latitude, required this.longitude});

  @override
  List<Object> get props => [latitude, longitude];
}

class LoadSubcategories extends HomeEvent {
  final int parentId;

  const LoadSubcategories({required this.parentId});

  @override
  List<Object> get props => [parentId];
}

class CategoryChanged extends HomeEvent {
  final CategorieModel? category; // Made nullable

  const CategoryChanged({this.category}); // Removed required

  @override
  List<Object?> get props => [category];
}

class SubcategoryChanged extends HomeEvent {
  final CategorieModel? subcategory; // Made nullable

  const SubcategoryChanged({this.subcategory}); // Removed required

  @override
  List<Object?> get props => [subcategory];
}

class LoadPublications extends HomeEvent {}

class LoadCurrentLocation extends HomeEvent {
  const LoadCurrentLocation();

  @override
  List<Object> get props => [];
}

// Événement pour mettre à jour la localisation
class UpdateCurrentLocation extends HomeEvent {
  final String location;
  final double? latitude;
  final double? longitude;

  const UpdateCurrentLocation({
    required this.location,
    this.latitude,
    this.longitude,
  });
}

class LoadNearbyPublications extends HomeEvent {
  final double latitude;
  final double longitude;
  final int? categoryId;
  final int? subcategoryId;
  final bool
  isResetRequest; // Nouvel attribut pour indiquer une réinitialisation intentionnelle

  const LoadNearbyPublications({
    required this.latitude,
    required this.longitude,
    this.categoryId,
    this.subcategoryId,
    this.isResetRequest =
        false, // Par défaut, ce n'est pas une réinitialisation explicite
  });

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    categoryId,
    subcategoryId,
    isResetRequest,
  ];
}

class RefreshPublications extends HomeEvent {
  final bool
  clearFilters; // Nouvel attribut pour indiquer si on doit effacer les filtres

  const RefreshPublications({this.clearFilters = false});

  @override
  List<Object?> get props => [clearFilters];
}

class FilterPublicationsByCategory extends HomeEvent {
  final int? categoryId;

  const FilterPublicationsByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class FilterPublicationsBySubcategory extends HomeEvent {
  final int? subcategoryId;

  const FilterPublicationsBySubcategory(this.subcategoryId);

  @override
  List<Object?> get props => [subcategoryId];
}

// Nouvel événement pour gérer les favoris des publications
class ToggleFavoritePublication extends HomeEvent {
  final int publicationId;

  const ToggleFavoritePublication({required this.publicationId});

  @override
  List<Object> get props => [publicationId];
}

class SearchPublications extends HomeEvent {
  final double latitude;
  final double longitude;
  final String? keyword;
  final int? categoryId;

  const SearchPublications({
    required this.latitude,
    required this.longitude,
    this.keyword,
    this.categoryId,
  });

  @override
  List<Object> get props => [
    latitude,
    longitude,
    if (keyword != null) keyword!,
    if (categoryId != null) categoryId!,
  ];
}
