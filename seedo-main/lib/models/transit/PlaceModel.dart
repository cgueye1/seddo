class PlaceModel {
  final double latitude;
  final double longitude;
  final String name;
  final String address;

  PlaceModel({
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.address,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> item) {
    final displayName = item['display_name'] ?? '';
    final name = displayName.split(",").isNotEmpty ? displayName.split(",")[0] : displayName;

    return PlaceModel(
      latitude: double.parse(item['lat'].toString()),
      longitude: double.parse(item['lon'].toString()),
      name: name,
      address:_formatAddress(item['address']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
      'address': address,
    };
  }

  static List<PlaceModel> fromJsonList(List<dynamic> list) {
    return list.map((item) => PlaceModel.fromJson(item)).toList();
  }

  static String _formatAddress(Map<String, dynamic>? address) {
    if (address == null) return '';

    final parts = [
      address['road'],
      address['neighbourhood'],
      address['suburb'],
      address['city_district'],
      address['city'],
      address['country'],
    ].where((part) => part != null).toList();

    return parts.join(', ');
  }

}
