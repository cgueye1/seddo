import 'package:seddoapp/models/user_model.dart';
import 'CategorieModel.dart';

class Publication {
  final int id;
  final String titre;
  final String description;
  final UserModel? author;
  final String picture;
  final String telephone;
  final String link;
  final List<String> pictures;
  final int timestamp;
  final List<dynamic> paticipants;
  final double latitude;
  final double longitude;
  final CategorieModel categorie;
  final bool available;
  final bool universel;
  final String createdDate;
  final String action;
  final String audio;
  final String date;
  final bool emergency;
  final bool ad;
  bool isFavorite;
  double? distance;
  final double price;

  Publication({
    required this.id,
    required this.titre,
    required this.description,
    this.author,
    required this.picture,
    required this.telephone,
    required this.link,
    required this.pictures,
    required this.timestamp,
    required this.paticipants,
    required this.latitude,
    required this.longitude,
    required this.categorie,
    required this.available,
    required this.universel,
    required this.createdDate,
    required this.action,
    required this.audio,
    required this.date,
    required this.emergency,
    required this.ad,
    required this.price,
    this.isFavorite = false,
    this.distance,
  });

  factory Publication.fromJson(Map<String, dynamic> json) {
    return Publication(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      author: json['author'] != null ? UserModel.fromJson(json['author']) : null,
      picture: json['picture'] ?? '',
      telephone: json['telephone'] ?? '',
      audio: json['audio'] ?? '',
      date: json['date'] ?? '',
      link: json['link'] ?? '',
      pictures: List<String>.from(json['pictures'] ?? []),
      timestamp: json['timestamp'],
      paticipants: json['paticipants'] ?? [],
      latitude: json['latitude'],
      longitude: json['longitude'],
      price: json['price']??0,
      createdDate: json['createdDate'].toString(),
      categorie:   CategorieModel.fromJson(json['categorie']),
      available: json['available'] ?? false,
      universel: json['universel'] ?? false,
      emergency: json['emergency'] ?? false,
      ad: json['ad'] ?? false,
      distance: json['distance']?.toDouble(),
      action: json['action'] ?? '',
    );
  }

  static List<Publication> fromJsonList(List<dynamic> list) {
    return list.map((item) => Publication.fromJson(item)).toList();
  }
}
