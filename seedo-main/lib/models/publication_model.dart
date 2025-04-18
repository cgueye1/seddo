class Publication {
  final int id;
  final String titre;
  final String description;
  final Author? author;
  final String picture;
  final String telephone;
  final String link;
  final List<String> pictures;
  final int timestamp;
  final List<dynamic> paticipants;
  final double latitude;
  final double longitude;
  final Categorie categorie;
  final bool available;
  final bool universel;
  bool isFavorite;
  double? distance; // Nouveau champ pour la distance

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
    this.isFavorite = false,
    this.distance, // Ajout du paramètre optionnel
  });

  factory Publication.fromJson(Map<String, dynamic> json) {
    return Publication(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      author: json['author'] != null ? Author.fromJson(json['author']) : null,
      picture: json['picture'] ?? '',
      telephone: json['telephone'] ?? '',
      link: json['link'] ?? '',
      pictures: List<String>.from(json['pictures'] ?? []),
      timestamp: json['timestamp'],
      paticipants: json['paticipants'] ?? [],
      latitude: json['latitude'],
      longitude: json['longitude'],
      categorie: Categorie.fromJson(json['categorie']),
      available: json['available'] ?? false,
      universel: json['universel'] ?? false,
      distance: json['distance']?.toDouble(), // Lecture optionnelle
    );
  }
}

class Author {
  final int id;
  final String firstName;
  final String lastName;
  final String phone;

  Author({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

class Categorie {
  final int id;
  final String titre;
  final String icon;
  final String action;
  final double price;
  final int days;
  final Categorie? parentCategorie;
  final bool free;

  Categorie({
    required this.id,
    required this.titre,
    required this.icon,
    required this.action,
    required this.price,
    required this.days,
    this.parentCategorie,
    required this.free,
  });

  factory Categorie.fromJson(Map<String, dynamic> json) {
    return Categorie(
      id: json['id'],
      titre: json['titre'],
      icon: json['icon'],
      action: json['action'],
      price: json['price']?.toDouble() ?? 0.0,
      days: json['days'] ?? 0,
      parentCategorie:
          json['parentCategorie'] != null
              ? Categorie.fromJson(json['parentCategorie'])
              : null,
      free: json['free'] ?? true,
    );
  }
}
