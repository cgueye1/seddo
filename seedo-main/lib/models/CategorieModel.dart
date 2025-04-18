// ignore: duplicate_ignore
// ignore: file_names
// ignore_for_file: file_names

class CategorieModel {
  final int id;
  String titre;
  bool isFree;
  String icon;
  String action;
  double price;
  int days;
  CategorieModel? parentCategorie;

  CategorieModel({
    required this.id,
    required this.titre,
    required this.isFree,
    required this.icon,
    required this.action,
    required this.price,
    required this.days,
    this.parentCategorie,
  });

  factory CategorieModel.fromJson(Map<String, dynamic> map) {
    return CategorieModel(
      id: map['id'],
      titre: map['titre'] ?? "",
      isFree: map['isFree'] ?? false,
      icon: map['icon'] ?? "",
      action: map['action'],
      price: (map['price'] ?? 0).toDouble(),
      days: map['days'] ?? 0,
      parentCategorie:
          map['parentCategorie'] != null
              ? CategorieModel.fromJson(map['parentCategorie'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'isFree': isFree,
      'icon': icon,
      'action': action,
      'price': price,
      'days': days,
      'parentCategorie': parentCategorie?.toJson(),
    };
  }

  static List<CategorieModel> fromJsonList(List<dynamic> list) {
    return list.map((item) => CategorieModel.fromJson(item)).toList();
  }
}
