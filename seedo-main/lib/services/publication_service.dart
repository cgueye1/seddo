import 'package:dio/dio.dart';
import 'package:seddoapp/models/publication_model.dart';
import 'package:seddoapp/utils/location.dart';

class PublicationService {
  final Dio _dio;

  PublicationService(this._dio);

  Future<List<Publication>> fetchNearbyPublications({
    required double latitude,
    required double longitude,
    double radius = 1000,
    int? categorieId,
    int? subcategoryId,
    String? keyword,
    int page = 0,
    int size = 30,
  }) async {
    try {
      Map<String, dynamic> queryParams = {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        'page': page,
        'size': size,
      };

      // Ajouter les paramètres optionnels seulement s'ils ne sont pas null
      /*   if (categorieId != null) {
        queryParams['categorieId'] = categorieId;
      }
 */
      if (subcategoryId != null) {
        queryParams['categorieId'] = subcategoryId;
      }

      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
        print(
          "Recherche avec mot-clé: '$keyword' (URL: meals/nearby avec params: $queryParams)",
        );
      }

      final response = await _dio.get(
        'meals/nearby',
        queryParameters: queryParams,
      );

      // Afficher l'URL complète avec tous les paramètres pour le débogage
      print(
        "URL complète: ${_dio.options.baseUrl}meals/nearby avec params: $queryParams",
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final List<dynamic> content = data['content'];

        final publications =
            content.map((item) {
              final publication = Publication.fromJson(item);
              // Calculer et assigner la distance
              publication.distance = DistanceUtils.calculateDistance(
                latitude,
                longitude,
                publication.latitude,
                publication.longitude,
              );
              return publication;
            }).toList();

        print(
          "Récupéré ${publications.length} publications avec keyword='$keyword'",
        );
        return publications;
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
        "DioException lors de la recherche avec keyword='$keyword': ${e.message}",
      );
      print("Response data: ${e.response?.data}");
      throw Exception('Erreur Dio: ${e.message}');
    } catch (e) {
      print("Exception lors de la recherche avec keyword='$keyword': $e");
      throw Exception('Erreur inattendue: $e');
    }
  }
}
