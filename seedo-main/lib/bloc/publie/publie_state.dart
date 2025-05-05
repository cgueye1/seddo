// publication_state.dart
import 'package:equatable/equatable.dart';
import 'package:seddoapp/models/user_model.dart';
import 'package:seddoapp/models/CategorieModel.dart';

import '../../models/AppParamModel.dart';
import '../../models/PricingModel.dart';

class PublicationState extends Equatable {
  // Attributs correspondant à ceux de la classe Publication
  final int currentStep;
  final int activeTabIndex;
  final String titre; // au lieu de title
  final String description;
  final UserModel? author;
  final String picture;
  final String telephone;
  final String link;
  final List<String> pictures; // utilisé pour stocker les selectedImages
  final int timestamp;
  final List<dynamic> participants; // corrigé orthographe de paticipants
  final double latitude;
  final double longitude;
  final CategorieModel? categorie; // référence à la catégorie sélectionnée
  final bool available;
  final bool universel;
  final String createdDate;
  final String action;
  final String audio;
  final String date; // remplace dateTime
  final bool emergency;
  final bool ad;
  final double price; // en double au lieu de String

  // Attributs supplémentaires pour l'état du formulaire
  final List<String> categoryTitles;
  final String? selectedCategory;
  final Map<int, List<CategorieModel>> subcategoriesMap;
  final List<CategorieModel> currentSubcategories;
  final CategorieModel? selectedSubcategoryModel;
  final String location; // gardé pour compléter le formulaire
  final String availability; // gardé pour compléter le formulaire
  final String languages; // gardé pour compléter le formulaire
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;
  final bool isFavorite;
  final double? distance;
  final List<PricingModel> pricings;
  final PricingModel? selectedPricing;
  final String? redirectUrl;
  final AppParamModel? appParam;


  const PublicationState({
    this.currentStep = 1,
    this.activeTabIndex = 0,
    this.titre = '',
    this.description = '',
    this.author,
    this.picture = '',
    this.telephone = '',
    this.link = '',
    this.pictures = const [],
    this.timestamp = 0,
    this.participants = const [],
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.categorie,
    this.available = true,
    this.universel = false,
    this.createdDate = '',
    this.action = '',
    this.audio = '',
    this.date = '',
    this.emergency = false,
    this.ad = false,
    this.price = 0.0,
    this.location = '',
    this.availability = '',
    this.languages = '',
    this.categoryTitles = const [],
    this.selectedCategory,
    this.subcategoriesMap = const {},
    this.currentSubcategories = const [],
    this.selectedSubcategoryModel,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
    this.isFavorite = false,
    this.distance,
    this.pricings = const [],
    this.selectedPricing,
    this.redirectUrl,
    this.appParam
  });

  PublicationState copyWith({
    int? currentStep,
    int? activeTabIndex,
    String? titre,
    String? description,
    UserModel? author,
    String? picture,
    String? telephone,
    String? link,
    List<String>? pictures,
    int? timestamp,
    List<dynamic>? participants,
    double? latitude,
    double? longitude,
    CategorieModel? categorie,
    bool? available,
    bool? universel,
    String? createdDate,
    String? action,
    String? audio,
    String? date,
    bool? emergency,
    bool? ad,
    double? price,
    String? location,
    String? availability,
    String? languages,
    List<String>? categoryTitles,
    String? selectedCategory,
    Map<int, List<CategorieModel>>? subcategoriesMap,
    List<CategorieModel>? currentSubcategories,
    CategorieModel? selectedSubcategoryModel,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    bool? isFavorite,
    double? distance,
    List<PricingModel>? pricings,
    PricingModel? selectedPricing,
    String? redirectUrl,
    AppParamModel? appParam
  }) {
    return PublicationState(
      currentStep: currentStep ?? this.currentStep,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      author: author ?? this.author,
      picture: picture ?? this.picture,
      telephone: telephone ?? this.telephone,
      link: link ?? this.link,
      pictures: pictures ?? this.pictures,
      timestamp: timestamp ?? this.timestamp,
      participants: participants ?? this.participants,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      categorie: categorie ?? this.categorie,
      available: available ?? this.available,
      universel: universel ?? this.universel,
      createdDate: createdDate ?? this.createdDate,
      action: action ?? this.action,
      audio: audio ?? this.audio,
      date: date ?? this.date,
      emergency: emergency ?? this.emergency,
      ad: ad ?? this.ad,
      price: price ?? this.price,
      location: location ?? this.location,
      availability: availability ?? this.availability,
      languages: languages ?? this.languages,
      categoryTitles: categoryTitles ?? this.categoryTitles,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      subcategoriesMap: subcategoriesMap ?? this.subcategoriesMap,
      currentSubcategories: currentSubcategories ?? this.currentSubcategories,
      selectedSubcategoryModel:
          selectedSubcategoryModel ?? this.selectedSubcategoryModel,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      isFavorite: isFavorite ?? this.isFavorite,
      distance: distance ?? this.distance,
      pricings: pricings ?? this.pricings,
      selectedPricing: selectedPricing ?? this.selectedPricing,
      redirectUrl: redirectUrl ?? this.redirectUrl,
      appParam:  appParam?? this. appParam,

    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    activeTabIndex,
    titre,
    description,
    author,
    picture,
    telephone,
    link,
    pictures,
    timestamp,
    participants,
    latitude,
    longitude,
    categorie,
    available,
    universel,
    createdDate,
    action,
    audio,
    date,
    emergency,
    ad,
    price,
    location,
    availability,
    languages,
    categoryTitles,
    selectedCategory,
    subcategoriesMap,
    currentSubcategories,
    selectedSubcategoryModel,
    isSubmitting,
    isSuccess,
    errorMessage,
    isFavorite,
    distance,
    pricings,
    selectedPricing,
    redirectUrl,
    appParam
  ];
}
