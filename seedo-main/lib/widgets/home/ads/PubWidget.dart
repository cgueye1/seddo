// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:seddoapp/utils/HexColor.dart';
import 'package:seddoapp/utils/constant.dart';
import '../../../models/publication_model.dart';
import '../../../pages/reservation.dart';
import '../../../pages/webview/WebViewPage.dart';
import '../../../utils/date_formatter.dart';

class PubWidget extends StatelessWidget {
  final Publication item;

  const PubWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                HexColor(APIConstants.secondaryColorValue).withOpacity(0.3),
                BlendMode.darken,
              ),
              child: Image.network(
                APIConstants.API_BASE_URL_IMG + item.picture,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) =>
                        Container(color: Colors.grey[300], height: 200),
              ),
            ),
          ),

          // Bouton en bas à droite
          Positioned(
            bottom: 12,
            right: 12,
            child: Text(
              item.titre,
              //getTimeAgo(item.createdDate),
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
