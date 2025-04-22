import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:seddoapp/widgets/transit/WalkingDurationWidget.dart';

import '../../models/transit/TransitResponseModel.dart';

class TimelinePoint extends StatelessWidget {
  final String label;
  final bool isStart;
  final bool isFirstTrajet;
  final bool isEnd;
  final bool isWalking;
  final double lat;
  final double lon;
  final bool? isDestination;

  final TransitResponseModel? transit;

  TimelinePoint({
    required this.label,
    this.isStart = false,
    this.isEnd = false,
    this.isWalking = false,
    this.isFirstTrajet = false,
    this.isDestination,
    required this.transit,
    required this.lat,
    required this.lon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isStart)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trait en pointillés (Dash line)
                  Container(
                    width: 2,
                    height: 55,
                    margin: EdgeInsets.only(left: 10),
                    child: CustomPaint(
                      painter: isWalking ? _DashPainter() : null,
                    ),
                  ),

                  if (isWalking && !isEnd)
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      // Ajustez l'espace ici pour le positionnement
                      child: Row(
                        children: [
                          Icon(Icons.directions_walk, color: Colors.grey),
                          SizedBox(width: 4),
                          // Espace entre l'icône et le texte
                          WalkingDurationWidget(
                            startLat: transit!.stopEnd!.stopLat,
                            startLon: transit!.stopEnd!.stopLon,
                            endLat: lat,
                            endLon: lon,
                          )
                        ],
                      ),
                    ),
                ],
              ),
            Container(
              width: MediaQuery.of(context).size.width - 100,
              child: Row(
                children: [
                  if (isDestination == null || !isDestination!)
                    Icon(
                      isStart
                          ?  Icons.trip_origin_sharp
                          : (isEnd
                          ? Icons.location_on
                          : Icons.trip_origin_sharp),
                      color: isStart
                          ?  Color(0xFFE65100)
                          : (isEnd ? Colors.red : Colors.grey),
                      size: 20,
                    ),
                  SizedBox(width: 8),
                  if (isDestination == null || !isDestination!)
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          overflow: TextOverflow.visible,
                        ),

                        softWrap: true, // Enable text wrapping
                      ),
                    )
                ],
              ),
            ),
            if (!isEnd)
              Row(
                children: [
                  // Trait en pointillés (Dash line)
                  Container(
                    width: 2,
                    height: 55,
                    margin: EdgeInsets.only(left: 10),
                    child: CustomPaint(
                      painter: isWalking
                          ? _DashPainter()
                          : null, // Affichage du trait en pointillé si c'est une marche
                    ),
                  ),

                  // Conteneur pour l'icône de marche et le temps (sur la même ligne)
                  if (isWalking) // Show walking icon and duration if isWalking is true
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      // Ajustez l'espace ici pour le positionnement
                      child: Row(
                        children: [
                          Icon(Icons.directions_walk, color: Colors.grey),
                          SizedBox(width: 4),
                          WalkingDurationWidget(
                            startLat: lat,
                            startLon: lon,
                            endLat: transit!.stopStart!.stopLat,
                            endLon: transit!.stopStart!.stopLon,
                          )
                        ],
                      ),
                    ),
                ],
              )
          ],
        ),
      ],
    );
  }
}

class _DashPainter extends CustomPainter {
  final double dashWidth;
  final double dashSpace;
  final Color color;

  _DashPainter({
    this.dashWidth = 5,
    this.dashSpace = 3,
    this.color = Colors.grey,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double startY = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}