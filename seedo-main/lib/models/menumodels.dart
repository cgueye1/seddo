class MenuModels {
  final int id;
  final String title;
  final String description;
  final String image;
  final String authorName;
  final String phone;
  final String publishedTime;
  final double latitude;
  final double longitude;
  final String category;
  final bool isAvailable;
  final bool isFavorite;
  final String distance; // Calculé séparément

  const MenuModels({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.authorName,
    required this.phone,
    required this.publishedTime,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.isAvailable,
    this.isFavorite = false,
    this.distance = '',
  });

  factory MenuModels.fromJson(Map<String, dynamic>? json) {
    // Handle null input
    if (json == null) {
      return MenuModels(
        id: 0,
        title: 'Unknown',
        description: '',
        image: '',
        authorName: 'Unknown Author',
        phone: '',
        publishedTime: 'Just now',
        latitude: 0.0,
        longitude: 0.0,
        category: 'Uncategorized',
        isAvailable: false,
      );
    }

    // Safely handle author information
    final author =
        json['author'] is Map<String, dynamic>
            ? json['author'] as Map<String, dynamic>
            : <String, dynamic>{};
    final authorFullName =
        "${author['firstName'] ?? ''} ${author['lastName'] ?? ''}".trim();

    // Safely handle timestamp
    final timestamp = json['timestamp'] is int ? json['timestamp'] as int : 0;
    final publishedDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final difference = DateTime.now().difference(publishedDate);

    String publishedTimeStr;
    if (difference.inDays > 0) {
      publishedTimeStr =
          "il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}";
    } else if (difference.inHours > 0) {
      publishedTimeStr =
          "il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}";
    } else {
      publishedTimeStr =
          "il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}";
    }

    // Safely handle category
    final categorie =
        json['categorie'] is Map<String, dynamic>
            ? json['categorie'] as Map<String, dynamic>
            : <String, dynamic>{};
    final categoryName = categorie['titre']?.toString() ?? 'Uncategorized';

    // Handle image URL
    final String baseImageUrl = "https://votre-api-url.com/images/";
    final picture = json['picture']?.toString();
    final imageUrl =
        picture != null && picture.isNotEmpty ? baseImageUrl + picture : '';

    return MenuModels(
      id: json['id'] is int ? json['id'] as int : 0,
      title: json['titre']?.toString() ?? 'Unknown',
      description: json['description']?.toString() ?? '',
      image: imageUrl,
      authorName: authorFullName.isNotEmpty ? authorFullName : 'Unknown Author',
      phone: json['telephone']?.toString() ?? '',
      publishedTime: publishedTimeStr,
      latitude:
          json['latitude'] is num ? (json['latitude'] as num).toDouble() : 0.0,
      longitude:
          json['longitude'] is num
              ? (json['longitude'] as num).toDouble()
              : 0.0,
      category: categoryName,
      isAvailable:
          json['available'] is bool ? json['available'] as bool : false,
    );
  }
  // Méthode pour calculer la distance (à implémenter avec un package comme geolocator)
  static String calculateDistance(
    double userLat,
    double userLng,
    double menuLat,
    double menuLng,
  ) {
    // Implémentez ici la logique de calcul de distance
    // Exemple simplifié:
    // final distanceInMeters = Geolocator.distanceBetween(userLat, userLng, menuLat, menuLng);
    // return distanceInMeters < 1000
    //     ? "${distanceInMeters.toStringAsFixed(0)} m"
    //     : "${(distanceInMeters / 1000).toStringAsFixed(1)} km";

    return "2.5 km"; // Valeur fictive, à remplacer par le vrai calcul
  }

  // Mettre à jour le modèle avec la distance calculée
  MenuModels withDistance(String calculatedDistance) {
    return copyWith(distance: calculatedDistance);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'authorName': authorName,
      'phone': phone,
      'publishedTime': publishedTime,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'isAvailable': isAvailable,
      'isFavorite': isFavorite,
      'distance': distance,
    };
  }

  // Méthode copyWith mise à jour
  MenuModels copyWith({
    int? id,
    String? title,
    String? description,
    String? image,
    String? authorName,
    String? phone,
    String? publishedTime,
    double? latitude,
    double? longitude,
    String? category,
    bool? isAvailable,
    bool? isFavorite,
    String? distance,
  }) {
    return MenuModels(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      authorName: authorName ?? this.authorName,
      phone: phone ?? this.phone,
      publishedTime: publishedTime ?? this.publishedTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      isFavorite: isFavorite ?? this.isFavorite,
      distance: distance ?? this.distance,
    );
  }

  static List<MenuModels> fromApiList(List<dynamic> list) {
    return list.map((item) => MenuModels.fromJson(item)).toList();
  }

  @override
  String toString() {
    return 'MenuModels(id: $id, title: $title, author: $authorName, category: $category, distance: $distance)';
  }
}
