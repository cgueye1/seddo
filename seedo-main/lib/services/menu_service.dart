import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:seddoapp/models/menumodels.dart';

class MenuService {
  // Load the menu data from the assets JSON file
  Future<Map<String, List<MenuModels>>> loadMenuData() async {
    try {
      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString(
        'assets/data/menu_data.json',
      );

      // Parse the JSON
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Extract the categories map
      final Map<String, dynamic> categoriesMap = jsonData['categories'];

      // Convert the dynamic map to the required type
      final Map<String, List<MenuModels>> result = {};

      categoriesMap.forEach((key, value) {
        if (value is List) {
          result[key] =
              value
                  .map((item) => MenuModels.fromJson(item))
                  .cast<MenuModels>()
                  .toList();
        }
      });

      return result;
    } catch (e) {
      // ignore: avoid_print
      print('Error loading menu data: $e');
      // Return empty map in case of error
      return {};
    }
  }
}
