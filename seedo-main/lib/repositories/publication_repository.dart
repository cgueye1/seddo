import 'package:seddoapp/models/publication_model.dart';
import 'package:seddoapp/services/publication_service.dart';

class PublicationRepository {
  final PublicationService _publicationService;

  PublicationRepository({required PublicationService publicationService})
    : _publicationService = publicationService;

  Future<List<Publication>> getNearbyPublications({
    required double latitude,
    required double longitude,
    int? categoryId,
    int? subcategoryId,
  }) async {
    try {
      // Utiliser le service correctement avec les bons paramètres
      return await _publicationService.fetchNearbyPublications(
        latitude: latitude,
        longitude: longitude,
        categorieId:
            categoryId, // Ce paramètre doit correspondre à ce qui est attendu par le service
        subcategoryId: subcategoryId,
      );
    } catch (e) {
      print('Erreur lors de la récupération des publications: $e');
      throw Exception('Erreur réseau lors du chargement des publications');
    }
  }

  // Ajout d'une méthode de recherche dans PublicationRepository
  Future<List<Publication>> searchPublications({
    required double latitude,
    required double longitude,
    String? keyword,
    int? categoryId,
    int? subcategoryId,
    double radius = 5000,
    int page = 0,
    int size = 30,
  }) async {
    try {
      return await _publicationService.fetchNearbyPublications(
        latitude: latitude,
        longitude: longitude,
        categorieId: categoryId,
        subcategoryId: subcategoryId,
        keyword: keyword,
        radius: radius,
        page: page,
        size: size,
      );
    } catch (e) {
      print('Erreur lors de la recherche de publications: $e');
      throw Exception('Erreur réseau lors de la recherche');
    }
  }
}
