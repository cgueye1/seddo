import 'package:dio/dio.dart';
import 'package:seddoapp/models/publication_model.dart';
import 'package:seddoapp/services/publication_service.dart';

class PublicationRepository {
  final PublicationService _publicationService;

  PublicationRepository({required PublicationService publicationService})
    : _publicationService = publicationService;

  // Modified to properly handle category filtering
  Future<List<Publication>> getNearbyPublications({
    required double latitude,
    required double longitude,
    int? categoryId,
    int? subcategoryId,
  }) async {
    try {
      // Retrieve all publications first
      final publications = await _publicationService.fetchNearbyPublications(
        latitude: latitude,
        longitude: longitude,
      );

      // If no filters, return all publications
      if (categoryId == null && subcategoryId == null) {
        return publications;
      }

      // If only a subcategory is specified, filter by that subcategory
      if (subcategoryId != null) {
        return publications
            .where((publication) => publication.categorie.id == subcategoryId)
            .toList();
      }

      // If only a parent category is specified, filter by that parent category
      if (categoryId != null) {
        return publications.where((publication) {
          // Check if the publication's parent category matches the selected category
          if (publication.categorieParent != null) {
            return publication.categorieParent!.id == categoryId;
          }

          // If the publication doesn't have a parent category, check if its direct
          // category is the one we're filtering for (fallback for consistency)
          return publication.categorie.id == categoryId;
        }).toList();
      }

      return publications;
    } catch (e) {
      print('Error fetching publications: $e');
      throw Exception('Network error while loading publications');
    }
  }

  // Search method remains the same, but with improved filtering logic
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
      final publications = await _publicationService.fetchNearbyPublications(
        latitude: latitude,
        longitude: longitude,
        keyword: keyword,
        radius: radius,
        page: page,
        size: size,
      );

      // Apply filtering logic similar to getNearbyPublications
      if (subcategoryId != null) {
        return publications
            .where((publication) => publication.categorie.id == subcategoryId)
            .toList();
      }

      if (categoryId != null) {
        return publications.where((publication) {
          if (publication.categorieParent != null) {
            return publication.categorieParent!.id == categoryId;
          }
          return publication.categorie.id == categoryId;
        }).toList();
      }

      return publications;
    } catch (e) {
      print('Error searching publications: $e');
      throw Exception('Network error during search');
    }
  }

  Future<Response?> postPublication({
    required String titre,
    required String description,
    required int authorId,
    required int categorieId,
    required double latitude,
    required double longitude,
    required List<String> imagePaths,
    required double price,
    required String date,
    required String audio,
    required bool emergency,


    bool available = true,
    bool universel = false,
  }) async {
    try {
      return await _publicationService.postPublication(
        titre: titre,
        description: description,
        authorId: authorId,
        categorieId: categorieId,
        latitude: latitude,
        longitude: longitude,
        imagePaths: imagePaths,
        available: available,
        universel: universel,
        emergency: emergency,
        price: price,
        date: date,
        audio:audio
      );
    } catch (e) {
      print('Erreur lors de la publication : $e');
      rethrow;
    }
  }
}
