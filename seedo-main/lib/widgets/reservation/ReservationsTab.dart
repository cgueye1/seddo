import 'package:flutter/material.dart';
import 'package:seddoapp/models/publication_model.dart';
import 'package:seddoapp/utils/HexColor.dart';
import 'package:seddoapp/widgets/reservation/ApprovedReservationsTab.dart';
import 'package:seddoapp/widgets/reservation/PendingReservationsTab.dart';
import 'package:seddoapp/widgets/reservation/RejectedReservationsTab.dart';

class ReservationsTab extends StatefulWidget {
  final Publication publication;

  const ReservationsTab({Key? key, required this.publication})
    : super(key: key);

  @override
  _ReservationsTabState createState() => _ReservationsTabState();
}

class _ReservationsTabState extends State<ReservationsTab> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              _buildPillTab('En attente', 0, 3),
              const SizedBox(width: 10),
              _buildPillTab('Validées', 1, 0),
              const SizedBox(width: 10),
              _buildPillTab('Refusées', 2, 0),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tab content
        IndexedStack(
          index: _selectedTabIndex,
          children: [
            PendingReservationsTab(publication: widget.publication),
            ApprovedReservationsTab(publication: widget.publication),
            RejectedReservationsTab(publication: widget.publication),
          ],
        ),
      ],
    );
  }

  Widget _buildPillTab(String title, int index, int count) {
    final isSelected = _selectedTabIndex == index;

    Color backgroundColor;
    Color textColor;
    Color countBgColor;
    Color countTextColor;

    if (isSelected) {
      if (index == 0) {
        backgroundColor = HexColor("#FCE9DE");
        textColor = HexColor("#D95C18");
        countBgColor = HexColor("#D95C18");
        countTextColor = Colors.white;
      } else if (index == 1) {
        backgroundColor = HexColor("#FCE9DE");
        textColor = HexColor("#D95C18");
        countBgColor = HexColor("#D95C18");
        countTextColor = Colors.white;
      } else {
        backgroundColor = HexColor("#FCE9DE");
        textColor = HexColor("#D95C18");
        countBgColor = HexColor("#D95C18");
        countTextColor = Colors.white;
      }
    } else {
      backgroundColor = HexColor('#F5F5F5');
      textColor = HexColor('#777777');
      countBgColor = HexColor('#777777');
      countTextColor = HexColor('#F5F5F5');
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: countBgColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: countTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
