// buildAdsList.dart

import 'package:flutter/material.dart';

import '../../../models/publication_model.dart';
import '../../../pages/reservation.dart';
import 'PubWidget.dart';

class AdsHorizontalList extends StatelessWidget {
  final List<Publication> adsList;

  const AdsHorizontalList({super.key, required this.adsList});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(adsList.length, (index) {
          final ad = adsList[index];

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MealDetailPage(publication:  ad ),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.only(
                left: index == 0 ? 10 : 5,
                right: index == adsList.length - 1 ? 10 : 5,
              ),
              width: adsList.length > 1
                  ? MediaQuery.of(context).size.width - 50
                  : MediaQuery.of(context).size.width - 20,
              height: 150,
              child: PubWidget(item: ad),
            ),
          );
        }),
      ),
    );
  }
}
