class CampaignModel {
  final int id;
  final String title;
  final String startDate;
  final String endDate;
  final double firstPrize;
  final double secondPrize;
  final double thirdPrize;
  final bool active;

  CampaignModel({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.firstPrize,
    required this.secondPrize,
    required this.thirdPrize,
    required this.active,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: json['id'],
      title: json['title'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      firstPrize: (json['firstPrize'] ?? 0).toDouble(),
      secondPrize: (json['secondPrize'] ?? 0).toDouble(),
      thirdPrize: (json['thirdPrize'] ?? 0).toDouble(),
      active: json['active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate,
      'endDate': endDate,
      'firstPrize': firstPrize,
      'secondPrize': secondPrize,
      'thirdPrize': thirdPrize,
      'active': active,
    };
  }
}
