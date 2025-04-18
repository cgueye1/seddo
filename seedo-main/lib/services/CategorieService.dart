// ignore_for_file: file_names, avoid_print

import 'package:dio/dio.dart';
import '../services/api_service.dart';

// Service
class CategorieService {
  final Dio _dio = ApiService().dio; // Utilisation de l'instance globale

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      Response response = await _dio.get("categories/no-parent");
      List<Map<String, dynamic>> categories = List<Map<String, dynamic>>.from(
        response.data,
      );

      return categories;
    } catch (e) {
      print("Erreur lors de la récupération des catégories : $e");
      throw Exception("Erreur réseau");
    }
  }

  // Dans CategorieService.dart, vérifiez que cette méthode existe et est correcte
  Future<List<Map<String, dynamic>>> fetchCategoriesByParent(
    int parentId,
  ) async {
    try {
      Response response = await _dio.get("categories/parent/$parentId");
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print("Erreur sous-catégories: $e");
      throw Exception("Erreur réseau");
    }
  }
}
