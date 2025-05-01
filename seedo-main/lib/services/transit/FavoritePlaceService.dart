import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../models/transit/PlaceModel.dart';


class FavoritePlaceService {
  static const _keys = {
    'home': 'favorite_home',
    'work': 'favorite_work',
    'school': 'favorite_school',
  };

  Future<void> saveFavorite(String type, PlaceModel place) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(place.toJson());
    await prefs.setString(_keys[type]!, jsonString);
  }

  Future<PlaceModel?> getFavorite(String type) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keys[type]!);
    if (jsonString == null) return null;
    final jsonData = jsonDecode(jsonString);
    print(jsonData );
    return PlaceModel.fromJson(jsonData);
  }

  Future<void> removeFavorite(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keys[type]!);
  }
}
