import 'dart:async';
import 'package:flutter/material.dart';
import 'package:seddoapp/utils/HexColor.dart';
import 'package:seddoapp/utils/constant.dart';
import '../../models/campaign/CampaignWinnerDTOModel.dart';

class CampaignWinnersWidget extends StatefulWidget {
  final List<CampaignWinnerDTOModel> winners;
  final String title;

  const CampaignWinnersWidget({
    Key? key,
    required this.winners,
    this.title = "Top 3",
  }) : super(key: key);

  @override
  State<CampaignWinnersWidget> createState() => _CampaignWinnersWidgetState();
}

class _CampaignWinnersWidgetState extends State<CampaignWinnersWidget> {
  late Timer _timer;
  String _remaining = "";

  @override
  void initState() {
    super.initState();
    _updateRemainingTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemainingTime();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateRemainingTime() {
    final now = DateTime.now();
    final endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));
    final remaining = endOfMonth.difference(now);

    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    setState(() {
      _remaining = "${days}j ${hours}h ${minutes}min ${seconds}s";
    });
  }

  @override
  Widget build(BuildContext context) {
    final winners = widget.winners;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          Row(
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: HexColor(APIConstants.secondaryColorValue),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "(Dans $_remaining)",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(winners.length, (index) {
            final winner = winners[index];
            final colors = _getRankColors(winner.rank);
            final badge = _getBadge(winner.rank);
            final maskedPhone = _maskPhone(winner.phone);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: colors['bg'],
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 20,
                      color: colors['fg'],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  winner.firstName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(maskedPhone, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      "Recherches : ${winner.points}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Gain", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      "${winner.amount.toStringAsFixed(0)} FCFA",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Map<String, Color> _getRankColors(int rank) {
    switch (rank) {
      case 1:
        return {'bg': Colors.amber, 'fg': Colors.black};
      case 2:
        return {'bg': Colors.grey.shade400, 'fg': Colors.black};
      case 3:
        return {'bg': Colors.brown.shade400, 'fg': Colors.white};
      default:
        return {'bg': Colors.blue, 'fg': Colors.white};
    }
  }

  String _getBadge(int rank) {
    switch (rank) {
      case 1:
        return "🥇";
      case 2:
        return "🥈";
      case 3:
        return "🥉";
      default:
        return "🎖️";
    }
  }

  String _maskPhone(String phone) {
    if (phone.length < 2) return "**";
    final lastDigits = phone.substring(phone.length - 2);
    return "******$lastDigits";
  }
}
