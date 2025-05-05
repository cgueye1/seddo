// ignore_for_file: file_names

class PricingModel {
  final int id;
  double price;
  String libelle;
  int days;

  PricingModel({
    required this.id,
    required this.price,
    required this.libelle,
    required this.days,
  });

  factory PricingModel.fromJson(Map<String, dynamic> map) {
    return PricingModel(
      id: map['id'],
      price: (map['price'] ?? 0.0).toDouble(),
      libelle: map['libelle'] ?? '',
      days: map['days'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'price': price,
      'libelle': libelle,
      'days': days,
    };
  }
}
