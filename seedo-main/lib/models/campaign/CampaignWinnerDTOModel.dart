class CampaignWinnerDTOModel {
  final String phone;
  final String firstName;
  final int rank;
  final double amount;
  final int points;

  CampaignWinnerDTOModel({
    required this.phone,
    required this.firstName,
    required this.rank,
    required this.amount,
    required this.points,
  });

  factory CampaignWinnerDTOModel.fromJson(Map<String, dynamic> json) {
    return CampaignWinnerDTOModel(
      phone: json['phone'] ?? '',
      firstName: json['firstName'] ?? '',
      rank: json['rank'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      points: json['points'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'firstName': firstName,
      'rank': rank,
      'amount': amount,
      'points': points,
    };
  }

  static List<CampaignWinnerDTOModel> fromJsonList(List<dynamic> list) {
    return list.map((item) => CampaignWinnerDTOModel.fromJson(item)).toList();
  }
}
