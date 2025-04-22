import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:seddoapp/widgets/transit/WalkingDurationWidget.dart';
import '../../bloc/route_timeline/route_timeline_bloc.dart';
import '../../models/transit/Stop.dart';
import '../../models/transit/StopTimeResponse.dart';
import '../../models/transit/TransitResponseModel.dart';
import '../../utils/constant.dart';
import '../../utils/url_launcher.dart';

class TimelineTile extends StatelessWidget {
  final TransitResponseModel transit;
  final TransitResponseModel nexttransit;
  final StopModel? nextStop;
  final String? label;
  final StopTimeResponseModel? stopTimeResponse;
  final bool isLast;
  final Position? currentPosition;
  final double? lat;
  final double? lon;
  final bool destination;

  TimelineTile({
    required this.transit,
    this.isLast = false,
    required this.nexttransit,
    this.nextStop,
    this.label,
    this.stopTimeResponse,
    this.currentPosition,
    this.lat,
    this.lon,
    required this.destination,
  });

  String normalizeText(String? input) {
    try {
      return utf8.decode(input!.runes.toList());
    } catch (e) {
      return input!;
    }
  }

  String replaceUnderscores(String text) {
    return text.replaceAll('_', ' ');
  }

  String convertDelayToMinutes(int delayInSeconds) {
    final minutes = delayInSeconds ~/ 60;
    final seconds = delayInSeconds.abs() % 60;

    if (delayInSeconds.isNegative) {
      return minutes.abs() != 0 ? "-${minutes.abs()} min " : "${seconds}s";
    } else {
      return minutes != 0 ? "+${minutes} min" : "${seconds}s";
    }
  }

  String getFormattedTravelDuration(String departure, String arrival) {
    // Convertir les heures en DateTime
    final depParts = departure.split(':').map(int.parse).toList();
    final arrParts = arrival.split(':').map(int.parse).toList();

    final now = DateTime.now();
    final depTime = DateTime(
      now.year,
      now.month,
      now.day,
      depParts[0],
      depParts[1],
      depParts[2],
    );
    var arrTime = DateTime(
      now.year,
      now.month,
      now.day,
      arrParts[0],
      arrParts[1],
      arrParts[2],
    );

    // Si l’arrivée est avant le départ → on suppose que c’est le jour suivant
    if (arrTime.isBefore(depTime)) {
      arrTime = arrTime.add(Duration(days: 1));
    }

    final duration = arrTime.difference(depTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}min';
    } else {
      return '${minutes} min';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                nextStop != null
                    ? SvgPicture.asset(
                      nextStop != null
                          ? "assets/icons/game-icons_subway-train.svg"
                          : "assets/icons/noto_bus-stop.svg",
                    )
                    : Container(
                      height: 25,
                      width: 25,
                      margin: EdgeInsets.only(right: 7),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/transit/arretbus.png"),
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                Expanded(
                  child: Text(
                    nextStop != null
                        ? "  ${label!}"
                        : normalizeText(
                          transit.stopStart?.stopName.toString(),
                        ),
                  ),
                ),
              ],
            ),
            Container(
              width: 2,
              margin: EdgeInsets.only(left: 10),
              height:
                  isLast
                      ? (nextStop != null && stopTimeResponse == null
                          ? 80
                          : 150)
                      : 150,
              color: Colors.grey,
            ),
            Row(
              children: [
                SizedBox(
                  height: 120,
                  width: MediaQuery.of(context).size.width - 32,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: EdgeInsets.only(left: 10),
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 100,
                          child: Row(
                            children: [
                              nextStop != null
                                  ? stopTimeResponse != null
                                      ? SvgPicture.asset(
                                        "assets/transit/game-icons_subway-train.svg",
                                      )
                                      : Icon(
                                        Icons.train_outlined,
                                        color: Colors.grey,
                                      )
                                  : Icon(
                                    Icons.trip_origin_sharp,
                                    color: Color(0xFFE65100),
                                  ),
                              SizedBox(width: 8),
                              Expanded(
                                child: SizedBox(
                                  width: 200,
                                  child: Text(
                                    isLast && nextStop != null
                                        ? stopTimeResponse != null
                                            ? "Gare de ${nextStop!.stop_name}"
                                            : ""
                                        : normalizeText(
                                          transit.stopEnd!.stopName,
                                        ),
                                    style: TextStyle(
                                      overflow: TextOverflow.visible,
                                    ),
                                    softWrap: true, // Enable text wrapping
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (nextStop == null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 2,
                              height: 60,
                              margin: EdgeInsets.only(left: 10),
                              child: CustomPaint(painter: DashPainter()),
                            ),
                            if (nextStop == null &&
                                transit.stopEnd!.stopId !=
                                    nexttransit.stopEnd!.stopId)
                              Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.directions_walk,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 4),
                                    WalkingDurationWidget(
                                      startLat: transit.stopEnd!.stopLat,
                                      startLon: transit.stopEnd!.stopLon,
                                      endLat:
                                          nexttransit.stopStart!.stopLat,
                                      endLon:
                                          nexttransit.stopStart!.stopLon,
                                    ),
                                  ],
                                ),
                              ),

                            if (nextStop == null &&
                                transit.stopEnd!.stopId ==
                                    nexttransit.stopEnd!.stopId &&
                                !destination)
                              Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.directions_walk,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 4),
                                    WalkingDurationWidget(
                                      startLat: transit.stopEnd!.stopLat,
                                      startLon: transit.stopEnd!.stopLon,
                                      endLat: lat!,
                                      endLon: lon!,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(width: 10),
        Positioned(
          left: 30,
          right: 0,
          top: 40,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            margin: EdgeInsets.only(bottom: 20),
            width: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300, width: .4),
            ),
            child:
                nextStop != null
                    ? Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 16),
                              child:
                                  stopTimeResponse == null
                                      ? Image.network(
                                        APIConstants.API_BASE_URL_IMG +
                                            nextStop!.picture,
                                        width: 100,
                                        fit: BoxFit.fill,
                                      )
                                      : Image.asset(
                                        "assets/transit/ter-transit.png",
                                        width: 100,
                                      ),
                            ),

                            Container(
                              margin: EdgeInsets.only(right: 16),
                              child: Text(
                                stopTimeResponse != null
                                    ? stopTimeResponse!.trip.tripShortName
                                    : nextStop!.stop_name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: 16),
                            stopTimeResponse != null
                                ? Text('$label -> ${nextStop!.stop_name}')
                                : Text(
                                  "Laissez vous transporTER",
                                  style: TextStyle(fontSize: 16),
                                ),
                          ],
                        ),

                        SizedBox(height: 10),
                        if (stopTimeResponse != null)
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(width: 16),
                                  Container(
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(
                                        10,
                                      ),
                                    ),
                                    padding: EdgeInsets.only(
                                      left: 5,
                                      right: 5,
                                    ),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/transit/time.svg',
                                          color: Colors.black,
                                          placeholderBuilder:
                                              (
                                                BuildContext context,
                                              ) => Container(
                                                padding:
                                                    const EdgeInsets.all(
                                                      30.0,
                                                    ),
                                                child:
                                                    const CircularProgressIndicator(),
                                              ),
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          stopTimeResponse != null
                                              ? '${stopTimeResponse!.duration} min'
                                              : "",
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Container(
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(
                                        10,
                                      ),
                                    ),
                                    padding: EdgeInsets.only(
                                      left: 5,
                                      right: 5,
                                    ),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/transit/bxs_map-pin.svg',
                                          color: Colors.black,
                                          placeholderBuilder:
                                              (
                                                BuildContext context,
                                              ) => Container(
                                                padding:
                                                    const EdgeInsets.all(
                                                      30.0,
                                                    ),
                                                child:
                                                    const CircularProgressIndicator(),
                                              ),
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          stopTimeResponse != null
                                              ? '${stopTimeResponse!.distance} km'
                                              : "",
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (stopTimeResponse != null)
                                Container(
                                  margin: EdgeInsets.only(right: 16),
                                  child: SvgPicture.asset(
                                    'assets/transit/ri_direction-line.svg',
                                  ),
                                ),
                            ],
                          ),
                      ],
                    )
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        nextStop != null
                            ? Image.asset(
                              "assets/transit/ter-transit.png",
                              width: 60,
                            )
                            : transit.stop.transitType == "BRT"
                            ? Image.asset(
                              "assets/transit/brt.png",
                              width: 60,
                            )
                            : transit.stop.transitType == "DDD"
                            ? Image.asset(
                              "assets/transit/dddk.png",
                              width: 60,
                            )
                            : Image.asset(
                              "assets/transit/aftu.png",
                              width: 60,
                            ),

                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    "Ligne de bus : ",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    replaceUnderscores(
                                      transit.trip!.routeId,
                                    ),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    "Distance : ",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "${(double.parse(transit.destinationStopTime!.shapeDistTraveled) - double.parse(transit.departureStopTime!.shapeDistTraveled)).toStringAsFixed(2)} KM",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    "Durée estimée: ",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "${getFormattedTravelDuration(transit.departureStopTime!.departureTime, transit.destinationStopTime!.arrivalTime)}",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 20),

                              InkWell(
                                onTap: () {
                                  final currentPosition =
                                      context
                                          .read<RouteTimelineBloc>()
                                          .state
                                          .currentPosition;

                                  UrlLauncher().openMapsNavigation(
                                    double.parse(
                                      currentPosition!.latitude.toString(),
                                    ),
                                    double.parse(
                                      currentPosition.longitude.toString(),
                                    ),
                                    transit.stopStart!.stopLat,
                                    transit.stopStart!.stopLon,
                                    travelMode: "walk",
                                  );
                                },
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color(0xFFE65100),
                                      width: .2,
                                    ),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      100,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Itinéraire vers l'arrêt",
                                      style: TextStyle(
                                        color: Color(0xFFE65100),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ],
    );
  }
}

class DashPainter extends CustomPainter {
  final double dashWidth;
  final double dashSpace;
  final Color color;

  DashPainter({
    this.dashWidth = 5,
    this.dashSpace = 3,
    this.color = Colors.grey,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double startY = 0;
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 2;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DashPainter1 extends CustomPainter {
  final double dashWidth;
  final double dashSpacing;
  final Color color;

  DashPainter1({
    required this.dashWidth,
    required this.dashSpacing,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1.0;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpacing;
    }
  }

  @override
  bool shouldRepaint(DashPainter1 oldDelegate) => false;
}
