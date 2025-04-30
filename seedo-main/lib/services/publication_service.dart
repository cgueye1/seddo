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

      // Ajouter des paramètres optionnels uniquement s'ils sont fournis
      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
      }

      // Construire l'URL correctement avec les paramètres
      String url = 'meals/nearby?';
      queryParams.forEach((key, value) {
        url += '$key=$value&';
      });
      url = url.substring(0, url.length - 1); // Enlever le dernier '&'

      print("URL de requête: $_dio.options.baseUrl$url");

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final List<dynamic> content = data['content'];

        final publications =
            content.map((item) {
              final publication = Publication.fromJson(item);
              publication.distance = DistanceUtils.calculateDistance(
                latitude,
                longitude,
                publication.latitude,
                publication.longitude,
              );
              return publication;
            }).toList();

        print("Récupéré ${publications.length} publications");
        return publications;
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print("DioException lors de la requête: ${e.message}");
      print("Response data: ${e.response?.data}");
      throw Exception('Erreur Dio: ${e.message}');
    } catch (e) {
      print("Exception lors de la requête: $e");
      throw Exception('Erreur inattendue: $e');
    }
  }
}
