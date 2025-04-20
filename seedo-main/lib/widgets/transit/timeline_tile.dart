import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:seddoapp/widgets/transit/WalkingDurationWidget.dart';

import '../../models/transit/Stop.dart';
import '../../models/transit/StopTimeResponse.dart';
import '../../models/transit/TransitResponseModel.dart';
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

  const TimelineTile({
    Key? key,
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
  }) : super(key: key);

  String _normalizeText(String? input) {
    try {
      return input?.replaceAll('_', ' ') ?? '';
    } catch (e) {
      return input ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    nextStop != null
                        ? SvgPicture.asset(nextStop != null
                        ? "assets/icons/game-icons_subway-train.svg"
                        : "assets/icons/noto_bus-stop.svg")
                        : Container(
                      height: 25,
                      width: 25,
                      margin: EdgeInsets.only(right: 7),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/arretbus.png")),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    Expanded(
                      child: Text(nextStop != null
                          ? "  ${label!}"
                          : _normalizeText(transit.stopStart?.stopName)),
                    )
                  ],
                ),
                Container(
                  width: 2,
                  margin: EdgeInsets.only(left: 10),
                  height: isLast
                      ? (nextStop != null && stopTimeResponse == null ? 80 : 120)
                      : 150,
                  color: Colors.grey,
                ),
                Row(
                  children: [
                    Container(
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
                              child: Container(
                                height: 100,
                                child: Row(
                                  children: [
                                    nextStop != null
                                        ? stopTimeResponse != null
                                        ? SvgPicture.asset(
                                        "assets/icons/game-icons_subway-train.svg")
                                        : Icon(Icons.train_outlined,
                                        color: Colors.grey)
                                        : Icon(Icons.trip_origin_sharp,
                                        color: Colors.orange),
                                    SizedBox(width: 8),
                                    Expanded(
                                        child: Container(
                                          width: 200,
                                          child: Text(
                                            isLast && nextStop != null
                                                ? stopTimeResponse != null
                                                ? "Gare de ${nextStop!.stop_name}"
                                                : ""
                                                : _normalizeText(transit.stopEnd!.stopName),
                                            style: TextStyle(
                                              overflow: TextOverflow.visible,
                                            ),
                                            softWrap: true,
                                          ),
                                        )),
                                  ],
                                ),
                              )),
                          if (nextStop == null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 2,
                                  height: 60,
                                  margin: EdgeInsets.only(left: 10),
                                  child: CustomPaint(
                                    painter: _DashPainter(),
                                  ),
                                ),
                                if (nextStop == null &&
                                    transit.stopEnd!.stopId !=
                                        nexttransit.stopEnd!.stopId)
                                  Padding(
                                    padding: EdgeInsets.only(left: 20),
                                    child: Row(
                                      children: [
                                        Icon(Icons.directions_walk,
                                            color: Colors.grey),
                                        SizedBox(width: 4),
                                        WalkingDurationWidget(
                                          startLat: transit.stopEnd!.stopLat,
                                          startLon: transit.stopEnd!.stopLon,
                                          endLat: nexttransit.stopStart!.stopLat,
                                          endLon: nexttransit.stopStart!.stopLon,
                                        )
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
                                          Icon(Icons.directions_walk,
                                              color: Colors.grey),
                                          SizedBox(width: 4),
                                          WalkingDurationWidget(
                                            startLat: transit.stopEnd!.stopLat,
                                            startLon: transit.stopEnd!.stopLon,
                                            endLat: lat!,
                                            endLon: lon!,
                                          )
                                        ],
                                      )),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          Positioned(
            left: 30,
            right: 0,
            top: 40,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              margin: EdgeInsets.only(bottom: 20),
              width: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: nextStop != null
                  ? Container(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            margin: EdgeInsets.only(left: 16),
                            child: stopTimeResponse == null
                                ? Image.network(
                              "${APIConstants.API_BASE_URL_IMG}${nextStop!.picture}",
                              width: 100,
                              fit: BoxFit.fill,
                            )
                                : Image.asset(
                              "assets/ter-transit.png",
                              width: 100,
                            )),
                        Container(
                            margin: EdgeInsets.only(right: 16),
                            child: Text(
                              stopTimeResponse != null
                                  ? stopTimeResponse!.trip.tripShortName
                                  : nextStop!.stop_name,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 16),
                        stopTimeResponse != null
                            ? Text("${label} -> ${nextStop!.stop_name}")
                            : Text("Laissez vous transporTER",
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    SizedBox(height: 10),
                    if (stopTimeResponse != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 16),
                              Container(
                                height: 26,
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(.1),
                                    borderRadius:
                                    BorderRadius.circular(10)),
                                padding: EdgeInsets.only(left: 5, right: 5),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/time.svg',
                                      color: Colors.black,
                                    ),
                                    SizedBox(width: 5),
                                    Text('${stopTimeResponse!.duration} min')
                                  ],
                                ),
                              ),
                              SizedBox(width: 5),
                              Container(
                                height: 26,
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(.1),
                                    borderRadius:
                                    BorderRadius.circular(10)),
                                padding: EdgeInsets.only(left: 5, right: 5),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/bxs_map-pin.svg',
                                      color: Colors.black,
                                    ),
                                    SizedBox(width: 5),
                                    Text('${stopTimeResponse!.distance} km')
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 16),
                            child: InkWell(
                              onTap: ()async {
                                if (currentPosition != null) {
                                  try {
                                    await UrlLauncher().openMapsNavigation(
                                      currentPosition!.latitude,
                                      currentPosition!.longitude,
                                      transit.stopStart!.stopLat,
                                      transit.stopStart!.stopLon,
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Impossible d\'ouvrir la navigation: ${e.toString()}')),
                                    );
                                  }
                                }
                              },
                              child: SvgPicture.asset(
                                'assets/icons/ri_direction-line.svg',
                              ),
                            ),
                          )
                        ],
                      ),
                  ],
                ),
              )
                  : ListTile(
                onTap: () {
                  if (currentPosition != null)
                    UrlLauncher().openMapsNavigation(
                        currentPosition!.latitude,
                        currentPosition!.longitude,
                        transit.stopStart!.stopLat,
                        transit.stopStart!.stopLon);
                },
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
                title: Text(
                  _normalizeText(transit.trip!.routeId),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                leading: nextStop != null
                    ? Image.asset("assets/ter-transit.png")
                    : transit.stop.transitType == "BRT"
                    ? Image.asset("assets/brt.png")
                    : transit.stop.transitType == "DDD"
                    ? Image.asset("assets/dddk.png", width: 80)
                    : Image.asset("assets/icons/aftu.png"),
                trailing: Icon(Icons.gps_fixed),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.0;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + 5, 0),
        paint,
      );
      startX += 8;
    }
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) => false;
}