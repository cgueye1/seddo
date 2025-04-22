// widgets/distance_badge.dart
import 'package:flutter/material.dart';
import 'package:seddoapp/utils/location.dart';

class DistanceBadge extends StatelessWidget {
  final double? distance;

  const DistanceBadge({super.key, required this.distance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 230, 230, 230),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DistanceUtils.formatDistance(distance),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ],
      ),
    );
  }
}
