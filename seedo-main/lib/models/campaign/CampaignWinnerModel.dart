
import '../user_model.dart';
import 'CampaignModel.dart';

class CampaignWinnerModel {
  final int id;
  final CampaignModel campaign;
  final UserModel user;
  final int winRank;
  final double amountWon;

  CampaignWinnerModel({
    required this.id,
    required this.campaign,
    required this.user,
    required this.winRank,
    required this.amountWon,
  });

  factory CampaignWinnerModel.fromJson(Map<String, dynamic> json) {
    return CampaignWinnerModel(
      id: json['id'],
      campaign: CampaignModel.fromJson(json['campaign']),
      user: UserModel.fromJson(json['user']),
      winRank: json['winRank'],
      amountWon: (json['amountWon'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaign': campaign.toJson(),
      'user': user.toJson(),
      'winRank': winRank,
      'amountWon': amountWon,
    };
  }
}
