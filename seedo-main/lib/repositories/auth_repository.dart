import 'package:seddoapp/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/AuthService.dart';
import '../services/SharedPreferencesService.dart';

class AuthRepository {
  final AuthService _authService = AuthService();
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _authService.signIn(email, password);
      // ignore: avoid_print
      print(response);
      return _handleLoginResponse(response);
    } catch (e) {
      throw Exception("Erreur de connexiondsd : ${e.toString()}");
    }
  }

  Future<UserModel> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await _authService.signUp(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception("Erreur d'inscription : ${e.toString()}");
    }
  }

  Future<UserModel> _handleLoginResponse(Map<String, dynamic> response) async {
    if (response.containsKey("token") && response.containsKey("refreshToken")) {
      await _sharedPreferencesService.saveValue(
        APIConstants.AUTH_TOKEN,
        response["token"],
      );
      final userMAp = await _authService.connectedUser();

      return UserModel.fromJson(userMAp);
    } else {
      throw Exception("Réponse invalide : les tokens sont manquants");
    }
  }

  Future<UserModel> currentUser() async {
    final userMAp = await _authService.connectedUser();

    return UserModel.fromJson(userMAp);
  }

  UserModel _handleResponse(Map<String, dynamic> response) {
    if (response['success'] == true) {
      return UserModel.fromJson(response['data']);
    } else {
      throw Exception(response['message'] ?? "Une erreur est survenue");
    }
  }

  // ignore: unused_element
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token); // Sauvegarde du token
  }
}
