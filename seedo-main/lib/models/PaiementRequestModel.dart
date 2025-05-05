class PaiementRequestModel {
  final String ref;
  final String price;
  final String itemName;
  final String commandeName;
  final int id;

  PaiementRequestModel({
    required this.ref,
    required this.price,
    required this.itemName,
    required this.commandeName,
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'ref': ref,
      'price': price,
      'itemName': itemName,
      'commandeName': commandeName,
      'id': id,
    };
  }
}
