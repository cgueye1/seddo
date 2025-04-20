import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../../data/repository.dart';
import '../../models/PlaceDetails.dart';
import '../../models/Stop.dart';
import '../../models/StopTimeResponse.dart';
import '../../models/transit/PlaceModel.dart';
import '../../models/transit/TransitResponseModel.dart';
import '../../services/route_finder.dart';
import '../../utils/HexaColor.dart';
import '../../utils/const.dart';
import '../../utils/urlLuncher.dart';
import 'WalkingDurationWidget.dart';

class RouteTimeline extends StatefulWidget {

  final  PlaceModel ? toPlaceDetails;
  final  PlaceModel?  fromPlaceDetails;
  StopTimeResponseModel? stopTimeResponse;

  RouteTimeline({
    Key? key,
    this.toPlaceDetails,
    this.fromPlaceDetails,
    required this.stopTimeResponse,
  }) : super(key: key);

  @override
  _RouteTimelineState createState() => _RouteTimelineState();
}

class _RouteTimelineState extends State<RouteTimeline> {
  final Repository repository = GetIt.instance<Repository>();
 // final LocationService _locationService = LocationService();

  final TextEditingController _origine = TextEditingController();
  final TextEditingController _arrivee = TextEditingController();
  List<TransitResponseModel> departureTransit = [];
  //List<TransitResponseModel> arrivalTransit = [];

  Filter? selectedFilter;
  List<Filter> filters = [
    Filter(id: 2, name: "DDD", icon: "assets/icons/ddd.svg"),
    Filter(id: 3, name: "AFTU", icon: "assets/icons/tata.svg"),
  ];
  int maxDistanceFrom = 1000;
  int maxDistanceTo = 1000;

  int arrivalmaxDistanceFrom = 500;
  int arrivalmaxDistanceTo = 500;

  int maxDistanceFrom1 = 1000;
  int maxDistanceTo1 = 1000;

  int arrivalmaxDistanceFrom1 = 1000;
  int arrivalmaxDistanceTo1 = 1000;

  int maxDistanceToIncrementCount = 0;
  int maxDistanceFromIncrementCount = 0;

  int maxDistanceToIncrementCount1 = 0;
  int maxDistanceFromIncrementCount1 = 0;

  double startLat = 0;
  double startLon = 0;

  double stopLat = 0;
  double stopLon = 0;

  double endLat = 0;
  double endLon = 0;
  Position? _currentPosition;

  bool departureLoader = false;
  bool arrivalLoader = false;



  intData() async {
    if (widget.fromPlaceDetails != null) {
      _origine.text = widget.fromPlaceDetails!.name;
      setState(() {
        startLat = widget.fromPlaceDetails!.latitude;
        startLon = widget.fromPlaceDetails!.longitude;
      });
    } else {
    }

    if (widget.toPlaceDetails != null) {
      _arrivee.text = widget.toPlaceDetails!.name;
      setState(() {
        endLat =widget.toPlaceDetails!.latitude;
        endLon = widget.toPlaceDetails!.longitude;
      });
    } else {}

    callFunction();

  }

  Future<String?> getWalkingDuration(
      double startLat, double startLon, double endLat, double endLon) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/foot/$startLon,$startLat;$endLon,$endLat?overview=false',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['code'] == 'Ok' && data['routes'].isNotEmpty) {
        final durationInSeconds = data['routes'][0]['duration'];
        final durationInMinutes = (durationInSeconds / 60).round();
        return '$durationInMinutes min';
      } else {
        return null;
      }
    } else {
      print("Erreur OSRM : ${response.statusCode}");
      return null;
    }
  }




  @override
  void initState() {
    super.initState();
    intData();
  }

  callFunction() async {
    if (calculateDistance(
            startLat,
            startLon,
            endLat,
           endLon) >=
        .5) {
      await getDepartureData();

      while (departureTransit.isEmpty) {
        await getDepartureData();

        if (departureTransit.isNotEmpty) {
          setState(() {
            maxDistanceFrom = 500;
            maxDistanceTo = 500;
          });
          break;
        }

        if (maxDistanceToIncrementCount < 5) {
          setState(() {
            maxDistanceTo += 500;
          });
          maxDistanceToIncrementCount++;
        } else if (maxDistanceFromIncrementCount < 5) {
          setState(() {
            maxDistanceFrom += 500;
          });
          maxDistanceFromIncrementCount++;
          maxDistanceToIncrementCount = 0;
        } else {
          setState(() {
            departureLoader = false;
          });

          break;
        }
      }
    }
  }


  bool checkForDuplicateStopId(
      List<TransitResponseModel> data, TransitResponseModel tr) {
    return !data.any((item) => item.stopEnd!.stopId == tr.stopEnd!.stopId);
  }

  Future<void> getDepartureData() async {
    print("PPPP");

    var firstDistanceDepartureToStop = 0.0;
    var distanceDepartureToStop = 0.0;
    setState(() {
      departureLoader = true;
    });
    TransitResponseModel? data = await findTrips(
        startLat,
        startLon,
        widget.toPlaceDetails!.latitude,
        widget.toPlaceDetails!.longitude,
        false,
        maxDistanceFrom,
        maxDistanceTo);
    print("PPPP");

    if (data != null) {
      firstDistanceDepartureToStop = data.distanceToDestination!;
      distanceDepartureToStop = data.distanceDepartureToStop!;

      setState(() {
        departureTransit.add(data!);
      });

      if (distanceDepartureToStop > 1000) {
        setState(() {
          maxDistanceTo = 1000;
          maxDistanceFrom = 1000;
        });
        TransitResponseModel? stepData = await findTrips(
            startLat,
            startLon,
            data.stopStart!.stopLat,
            data.stopStart!.stopLon,
            true,
            maxDistanceFrom,
            maxDistanceTo);

        if (stepData != null) {
          if (stepData.distanceToDestination! <= 1000 &&
              firstDistanceDepartureToStop >
                  stepData.distanceDepartureToStop! &&
              stepData.distanceToDestination! < data.distanceToDestination!) {
            setState(() {
             // departureTransit.insert(0, stepData);
            });
          }
        }
      }

      int iterationCount = 0;
      setState(() {
        maxDistanceTo = 500;
        maxDistanceFrom = 500;
      });
      while (data!.distanceToDestination! > 1000 && iterationCount < 20) {
        print("karang");
        if (data!.distanceToDestination! <= 1000) {


          setState(() {
            departureLoader = false;
          });
          break;
        }
        setState(() {
          maxDistanceTo += 100;
          maxDistanceFrom += 100;
        });

        iterationCount++;
        print( data.stopEnd!.stopLat);
        print( data.stopEnd!.stopLon);
        print( "___oklm__");
        print( widget.toPlaceDetails!.longitude);
        print(   widget.toPlaceDetails!.longitude);

        print( "___///__");
        print( startLat);
        print(   startLon);
        TransitResponseModel? stepDataEnd = await findTrips(
            data.stopEnd!.stopLat,
            data.stopEnd!.stopLon,
            widget.toPlaceDetails!.latitude,
            widget.toPlaceDetails!.longitude,
            false,
            maxDistanceFrom,
            maxDistanceTo);

        if (stepDataEnd != null &&
            checkForDuplicateStopId(departureTransit, stepDataEnd) &&
            stepDataEnd.distanceToDestination! <=
                data.distanceToDestination! / 2 &&
            (stepDataEnd.distanceDepartureToStop! +
                    stepDataEnd.distanceToDestination!) <
                data.distanceToDestination!) {
          if (stepDataEnd.distanceToDestination != data.distanceToDestination ||
              stepDataEnd.distanceToDestination == data.distanceToDestination) {
            if (stepDataEnd.trip!.tripId.trim() == data.trip!.tripId.trim() ||
                stepDataEnd.stopEnd!.stopId == data.stopEnd!.stopId) {
              setState(() {
                if (departureTransit.isNotEmpty &&
                    departureTransit.last.stopEnd != stepDataEnd.stopEnd) {
                  departureTransit[departureTransit.length - 1] = stepDataEnd;
                } else if (departureTransit.isEmpty ||
                    departureTransit.last.stopEnd == stepDataEnd.stopEnd) {
                  departureTransit.add(stepDataEnd);
                }
              });

              data = stepDataEnd;
            } else {
              if (stepDataEnd.distanceDepartureToStop! < 2000)
                setState(() {
                  departureTransit.add(stepDataEnd);
                  maxDistanceTo = 500;
                  maxDistanceFrom = 500;
                });
              data = stepDataEnd;
            }
          } else {}
        } else {}
      }
    }

    setState(() {
      departureLoader = false;
    });
  }


  String formatText(String input) {
    return input.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '');
  }

  Future<TransitResponseModel?> findTrips(dlat, dlon, alat, alon, orderByFrom,
      maxDistanceFrom, maxDistanceTo) async {
    Map<String, dynamic> body = {
      "departureLat": dlat,
      "departureLon": dlon,
      "destinationLat": alat,
      "destinationLon": alon,
      "maxDistanceFrom": maxDistanceFrom,
      "maxDistanceTo": maxDistanceTo,
      "type": selectedFilter?.name ?? "",
      "orderByFrom": orderByFrom
    };

    Response? response;
    await repository
        .saveBodyFree(body, "transit/stops/findTrips")
        .then((value) => response = value);

    if (response != null && response!.data != null) {
      if (response!.data is Map<String, dynamic>) {
        return TransitResponseModel.fromJson(response!.data);
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              departureTransit.isEmpty && departureLoader
                  ? Container(
                      child: Center(child: CircularProgressIndicator()),
                      height: MediaQuery.of(context).size.height / 2,
                    )
                  : departureTransit.isEmpty && !departureLoader
                      ? Container(
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bus_alert,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                InkWell(
                                    onTap: () {
                                      UrlLauncher().openMapsNavigation(
                                          startLat,
                                          startLon,
                                          endLat,
                                          endLon,
                                          travelMode: "walk");
                                    },
                                    child: Container(
                                      width: 200,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          border:
                                              Border.all(color: Colors.grey),
                                          color: Colors.white),
                                      height: 50,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.directions_walk,
                                              color: Colors.grey),
                                          SizedBox(
                                            width: 12,
                                          ),
                                          Text(
                                            "Marcher",
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey),
                                          )
                                        ],
                                      ),
                                    ))
                              ],
                            ),
                          ),
                          height: MediaQuery.of(context).size.height / 2,
                        )
                      : Container(
                          margin: EdgeInsets.only(top: 25, left: 16, right: 16),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.all(0),
                            // Allows ListView to take minimum space
                            physics: NeverScrollableScrollPhysics(),
                            // Disable inner scrolling
                            itemCount: departureTransit.length + 2,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                final transit = departureTransit[index];
                                return TimelinePoint(
                                  label: widget.fromPlaceDetails!.name,
                                  transit: transit,
                                  lat: startLat,
                                  lon: startLon,
                                  isStart: true,
                                  isWalking:
                                      true, // Adding walking indicator for the first point
                                );
                              } else if (index == departureTransit.length + 1) {
                                final transit = departureTransit[
                                    departureTransit.length - 1];
                                return TimelinePoint(
                                  transit: transit,
                                  lat: endLat,
                                  lon: endLon,
                                  label: "${_arrivee.text}",
                                  isEnd: true,
                                  isWalking: true,
                                  // Adding walking indicator for the last point
                                  isDestination: false,
                                );
                              } else {
                                final transit = departureTransit[index - 1];
                                return TimelineTile(
                                  destination: false,
                                  transit: transit,
                                  lat: endLat,
                                  lon: endLon,
                                  isLast: index == departureTransit.length,
                                  nexttransit: index != departureTransit.length
                                      ? departureTransit[index]
                                      : transit,
                                  currentPosition: _currentPosition,
                                );
                              }
                            },
                          ),
                        ),

            ],
          ),
        ),
      ],
    ));
  }
}

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
                      painter: isWalking ? DashPainter() : null,
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
                          ? Icons.trip_origin
                          : (isEnd
                              ? Icons.location_on
                              : Icons.radio_button_unchecked),
                      color: isStart
                          ? Colors.blue
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
                          ? DashPainter()
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


  TimelineTile(
      {required this.transit,
      this.isLast = false,
      required this.nexttransit,
      this.nextStop,
      this.label,
      this.stopTimeResponse,
      this.currentPosition,
      this.lat,
      this.lon,
      required this.destination});

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
                    nextStop != null?
                    SvgPicture.asset(nextStop != null
                        ? "assets/icons/game-icons_subway-train.svg"
                        : "assets/icons/noto_bus-stop.svg"):
                        Container(
                          height: 25,
                          width: 25,
                          margin: EdgeInsets.only(right: 7),
                          decoration: BoxDecoration(
                            image: DecorationImage(image: AssetImage("assets/arretbus.png")),
                            borderRadius: BorderRadius.circular(3)
                          ),
                          
                        )
                        ,
                    Expanded(
                      child: Text(nextStop != null
                          ? "  ${label!}"
                          : normalizeText(
                                  transit.stopStart?.stopName.toString()) ??
                              "Stop"),
                    )
                  ],
                ),
                Container(
                  width: 2,
                  margin: EdgeInsets.only(left: 10),
                  height: isLast ?( nextStop != null && stopTimeResponse==null? 80:120)  : 150,
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
                                    ?
                                stopTimeResponse!=null?
                                SvgPicture.asset(
                                        "assets/icons/game-icons_subway-train.svg"):Icon(Icons.train_outlined,color: Colors.grey)


                                    : Icon(Icons.trip_origin_sharp,
                                        color: Colors.orange),
                                SizedBox(width: 8),
                                Expanded(
                                    child: Container(
                                  width: 200,
                                  child: Text(
                                    isLast && nextStop != null
                                        ? stopTimeResponse!=null? "Gare de ${nextStop!.stop_name}":""
                                        : normalizeText(
                                            transit.stopEnd!.stopName),
                                    style: TextStyle(
                                      overflow: TextOverflow.visible,
                                    ),
                                    softWrap: true, // Enable text wrapping
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
                                    painter: DashPainter(),
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
                                          endLat:
                                              nexttransit.stopStart!.stopLat,
                                          endLon:
                                              nexttransit.stopStart!.stopLon,
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
                                  child:       stopTimeResponse==null?
                                  Image.network(
                                    APIConstants.API_BASE_URL_IMG+nextStop!.picture,
                                    width: 100,
                                    fit: BoxFit.fill,

                                  )

                                  :Image.asset(
                                    "assets/ter-transit.png",
                                    width: 100,
                                  )),


                              Container(
                                  margin: EdgeInsets.only(right: 16),
                                  child: Text(
                                    stopTimeResponse!=null?stopTimeResponse!.trip.tripShortName:nextStop!.stop_name,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 16,
                              ),
                              stopTimeResponse!=null?
                              Text("${label} -> ${nextStop!.stop_name}"):
                              Text("Laissez vous transporTER",style: TextStyle(fontSize: 16),),
                            ],
                          ),

                          SizedBox(
                            height: 10,
                          ),
                          if(stopTimeResponse!=null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Container(
                                    height: 26,
                                    decoration: BoxDecoration(
                                        color: HexColor(
                                                APIConstants.PRIMARY_COLOR_DARK)
                                            .withOpacity(.1),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    padding: EdgeInsets.only(left: 5, right: 5),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/time.svg',
                                          color: Colors.black,
                                          placeholderBuilder:
                                              (BuildContext context) =>
                                                  Container(
                                            padding: const EdgeInsets.all(30.0),
                                            child:
                                                const CircularProgressIndicator(),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                            stopTimeResponse!=null?    '${stopTimeResponse!.duration} min':"")
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    height: 26,
                                    decoration: BoxDecoration(
                                        color: HexColor(
                                                APIConstants.PRIMARY_COLOR_DARK)
                                            .withOpacity(.1),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    padding: EdgeInsets.only(left: 5, right: 5),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/bxs_map-pin.svg',
                                          color: Colors.black,
                                          placeholderBuilder:
                                              (BuildContext context) =>
                                                  Container(
                                            padding: const EdgeInsets.all(30.0),
                                            child:
                                                const CircularProgressIndicator(),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(stopTimeResponse!=null?'${stopTimeResponse!.distance} km':"")
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if( stopTimeResponse!=null)
                              Container(
                                margin: EdgeInsets.only(right: 16),
                                child: SvgPicture.asset(
                                  'assets/icons/ri_direction-line.svg',
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
                              double.parse(
                                  currentPosition!.latitude.toString()),
                              double.parse(
                                  currentPosition!.longitude.toString()),
                              transit.stopStart!.stopLat,
                              transit.stopStart!.stopLon);
                      },
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      title: Text(
                        replaceUnderscores(transit.trip!.routeId),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      /* subtitle: Text(
                        normalizeText(transit.stopStart?.stopName.toString()) ??
                            "Stop"),*/
                      leading: nextStop != null
                          ? Image.asset("assets/ter-transit.png")
                          : transit.stop.transitType == "BRT"
                              ? Image.asset("assets/brt.png")
                              : transit.stop.transitType == "DDD"
                                  ? Image.asset("assets/dddk.png",width: 80,)
                                  : Image.asset("assets/icons/aftu.png"),
                /*
                  SvgPicture.asset(
                                      "assets/icons/oncoming-bus.svg",
                                    ),
                 */


                      trailing: Icon(Icons.gps_fixed),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class Filter {
  final int id;
  final String name;
  final String icon;

  Filter({required this.id, required this.name, required this.icon});
}

class DashPainter extends CustomPainter {
  final double dashWidth;
  final double dashSpace;
  final Color color;

  DashPainter(
      {this.dashWidth = 5, this.dashSpace = 3, this.color = Colors.grey});

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
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpacing;
    }
  }

  @override
  bool shouldRepaint(DashPainter1 oldDelegate) => false;
}
