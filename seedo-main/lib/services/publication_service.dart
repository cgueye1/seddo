import 'package:dio/dio.dart';
import 'package:seddoapp/models/PricingModel.dart';
import 'package:seddoapp/models/publication_model.dart';
import 'package:seddoapp/utils/location.dart';

import '../models/PaiementRequestModel.dart';
import '../models/PaymentResponseModel.dart';

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

  Future<Response?> postPublication({
    required String titre,
    required String description,
    required int authorId,
    required int categorieId,
    required double latitude,
    required double longitude,
    required double price,
    required String date,
    required String audio,
    required List<String> imagePaths,
    bool available = true,
    bool universel = false,
    bool emergency = false,
    required int days,
    required int pricingId,

  }) async {
    try {
      FormData formData = FormData();

      // Ajouter les images
      for (var path in imagePaths) {
        String fileName = path.split('/').last;
        formData.files.add(
          MapEntry(
            "pictures",
            await MultipartFile.fromFile(path, filename: fileName),
          ),
        );
      }

      // Ajouter la première image en tant que "picture" principale
      if (imagePaths.isNotEmpty) {
        String fileName = imagePaths[0].split('/').last;
        formData.files.add(
          MapEntry(
            "picture",
            await MultipartFile.fromFile(imagePaths[0], filename: fileName),
          ),
        );
      }

      if (audio.isNotEmpty) {
        String fileName = audio.split('/').last;
        formData.files.add(
          MapEntry(
            'audioFile',
            await MultipartFile.fromFile(audio, filename: fileName),
          ),
        );
      }

      // Ajouter les champs
      formData.fields.addAll([
        MapEntry("titre", titre),
        MapEntry("description", description),
        MapEntry("authorId", authorId.toString()),
        MapEntry("categorieId", categorieId.toString()),
        MapEntry("available", available.toString()),
        MapEntry("universel", universel.toString()),
        MapEntry("latitude", latitude.toString()),
        MapEntry("longitude", longitude.toString()),
        MapEntry("price", price.toString()),
        MapEntry("date", date.toString()),
        MapEntry("emergency", emergency.toString()),
        MapEntry("days", days.toString()),
        MapEntry("pricingId", pricingId.toString()),
      ]);

      final response = await _dio.post("meals/add", data: formData);
      return response;
    } on DioException catch (e) {
      print("Erreur Dio : ${e.message}");
      print("Réponse : ${e.response?.data}");
      rethrow;
    } catch (e) {
      print("Erreur inattendue : $e");
      rethrow;
    }
  }

  Future<List<PricingModel>> getPricings() async {
    try {
      String url = 'pricing';

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data as List;

        return data.map((item) => PricingModel.fromJson(item)).toList();
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


  Future<PaymentResponseModel> payMeal(PaiementRequestModel paiementRequest) async {
    try {
      final response = await _dio.post(
        'peytech/meal',
        data: paiementRequest.toJson(),
      );

      if (response.statusCode == 200) {
        return PaymentResponseModel.fromJson(response.data);
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } on DioException catch (e) {

      throw Exception('Erreur de paiement : ${e.message}');
    } catch (e) {
      print("Erreur inattendue : $e");
      throw Exception('Erreur inattendue : $e');
    }
  }


}
