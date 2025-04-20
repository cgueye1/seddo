import 'package:flutter/material.dart';

import 'dart:math';

class WalkingDurationWidget extends StatelessWidget {
  final double startLat;
  final double startLon;
  final double endLat;
  final double endLon;

  WalkingDurationWidget({
    required this.startLat,
    required this.startLon,
    required this.endLat,
    required this.endLon,
  });

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371.0;
    final lat1Rad = _degToRad(lat1);
    final lon1Rad = _degToRad(lon1);
    final lat2Rad = _degToRad(lat2);
    final lon2Rad = _degToRad(lon2);

    final deltaLat = lat2Rad - lat1Rad;
    final deltaLon = lon2Rad - lon1Rad;

    final a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLon / 2) * sin(deltaLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degToRad(double deg) {
    return deg * (pi / 180.0);
  }

  String getWalkingDuration(double startLat, double startLon, double endLat, double endLon) {
    double distanceKm = calculateDistance(startLat, startLon, endLat, endLon);

    const walkingSpeedKmPerHour = 5.0;
    double estimatedHours = distanceKm / walkingSpeedKmPerHour;
    double estimatedMinutes = estimatedHours * 60;

    if (estimatedMinutes > 60) {
      return "🕗";
    } else {
      return "${estimatedMinutes.round()} min";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(getWalkingDuration(startLat, startLon, endLat, endLon));
  }
}
