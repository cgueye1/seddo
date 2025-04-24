import 'package:dio/dio.dart';
import 'package:seddoapp/models/publication_model.dart';
import 'package:seddoapp/utils/location.dart';

class PublicationService {
  final Dio _dio;

  PublicationService(this._dio);

  Future<List<Publication>> fetchNearbyPublications({
    required double latitude,
    required double longitude,
    double radius = 5000,
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

      if (subcategoryId != null) {
        queryParams['categorieId'] = subcategoryId;
      }

      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
        print(
          "Recherche avec mot-clé: '$keyword' (URL: meals/nearby avec params: $queryParams)",
        );
      }
      print(
        'meals/nearby?latitude=${latitude}&longitude=${longitude}&radius=${radius}&categorieId=${subcategoryId != null ? subcategoryId : ""}&keyword=${keyword != null ? keyword : ""}&page=${page}&size=${size}',
      );

      final response = await _dio.get(
        'meals/nearby?latitude=${latitude}&longitude=${longitude}&radius=${radius}&categorieId=${subcategoryId != null ? subcategoryId : ""}&keyword=${keyword != null ? keyword : ""}&page=${page}&size=${size}',
      );

      // Afficher l'URL complète avec tous les paramètres pour le débogage
      print(
        "URL complète: ${_dio.options.baseUrl}meals/nearby avec params: $queryParams",
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final List<dynamic> content = data['content'];
        print("fuck");
        print(response.data);

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
