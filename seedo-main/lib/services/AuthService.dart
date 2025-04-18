// ignore_for_file: file_names

import 'package:dio/dio.dart';
import '../services/api_service.dart';

class AuthService {
  final Dio _dio = ApiService().dio;

  // Méthode existante de connexion
  Future<dynamic> signIn(String email, String password) async {
    try {
      Response response = await _dio.post(
        "v1/auth/signin",
        data: {"email": email, "password": password},
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e, "Échec de la connexion");
    }
  }

  // Nouvelle méthode pour l'inscription complète
  Future<dynamic> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      Response response = await _dio.post(
        "v1/auth/signup",
        data: {
          "firstName": firstName,
          "lastName": lastName,
          "email": email,
          "password": password,
          "role": "USER",
          "activated": true,
          "profil": "USER",
          "phone": phone,
        },
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e, "Échec de la création de compte");
    }
  }

  // Nouvelle méthode pour demander l'OTP
  Future<dynamic> requestOTP(String phoneNumber) async {
    try {
      Response response = await _dio.post(
        "otp/generate",
        data: {"phoneNumber": phoneNumber},
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e, "Impossible d'envoyer le code OTP");
    }
  }

  // Nouvelle méthode pour valider l'OTP
  Future<dynamic> verifyOTP({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      Response response = await _dio.post(
        "otp/validate",
        data: {"phoneNumber": phoneNumber, "otp": otp},
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e, "Échec de la vérification OTP");
    }
  }

  // Méthode existante pour récupérer l'utilisateur connecté
  Future<dynamic> connectedUser() async {
    try {
      Response response = await _dio.get("v1/user/me");
      return response.data;
    } on DioException catch (e) {
      _handleError(e, "Impossible de récupérer les informations utilisateur");
    }
  }

  // Méthode privée de gestion des erreurs
  dynamic _handleError(DioException e, String defaultMessage) {
    if (e.response != null) {
      switch (e.response!.statusCode) {
        case 400:
          throw Exception("Données invalides");
        case 401:
          throw Exception("Non autorisé");
        case 403:
          throw Exception("Accès refusé");
        case 404:
          throw Exception("Ressource non trouvée");
        case 409:
          throw Exception("Conflit : Un compte existe déjà");
        case 500:
          throw Exception("Erreur serveur");
        default:
          throw Exception("$defaultMessage : ${e.response!.statusCode}");
      }
    } else {
      throw Exception("$defaultMessage. Vérifiez votre connexion internet.");
    }
  }
}
