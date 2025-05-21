// ignore_for_file: must_be_immutable

import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:seddoapp/models/AppParamModel.dart';
import 'package:seddoapp/utils/HexColor.dart';
import '../../models/campaign/CampaignWinnerDTOModel.dart';
import '../../models/transit/PlaceModel.dart';
import '../../models/transit/TransitResponseModel.dart';
import '../../models/transit/TransitStopModel.dart';
import '../../services/AdMobService.dart';
import '../../utils/url_launcher.dart';
import '../../widgets/campaign/CampaignWinnersWidget.dart';
import '../../widgets/transit/DakarSearchWidget.dart';
import '../../widgets/transit/FavoritePlacesWidget.dart';
import '../../widgets/transit/PlaceSearchWidget.dart';
import 'RouteTimelinePage.dart';

class TransportCommun extends StatefulWidget {
  AppParamModel? appParam;
  final List<CampaignWinnerDTOModel> winners;

  TransportCommun({super.key, this.appParam, required this.winners});

  @override
  _TransportCommunState createState() => _TransportCommunState();
}

class _TransportCommunState extends State<TransportCommun>
    with WidgetsBindingObserver {
  List<CampaignWinnerDTOModel> topWinners = [];
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  int tabIndex = 0;
  bool isSwitched = false;
  List tickets = [];
  List gares = [];
  Dio dio = Dio();
  bool loading = false;
  PlaceModel? origine;
  PlaceModel? destination;
  bool _isBannerAdReady = false;
  List<TransitFullResponseModel> _transitData = [];
  Position? _currentPosition;
  TransitStopModel? _nearbyStop;

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000; // en mètres
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  void _updateNearbyStop(
    List<TransitFullResponseModel> transitData,
    Position? currentPosition,
  ) {
    if (currentPosition == null || transitData.isEmpty) {
      setState(() {
        _nearbyStop = null;
      });
      return;
    }

    TransitStopModel? closestStop;
    double? minDistance;

    for (final transit in transitData) {
      final stopStart = transit.mainTripInfo?.stopStart;
      if (stopStart != null) {
        final distance = _calculateDistance(
          origine!.latitude,
          origine!.longitude,
          stopStart.stopLat,
          stopStart.stopLon,
        );

        if (minDistance == null || distance < minDistance) {
          minDistance = distance;
          closestStop = stopStart;
        }
      }
    }

    setState(() {
      _nearbyStop = closestStop;
    });
  }

  @override
  void initState() {
    setState(() {
      topWinners = widget.winners;
    });
    _initBannerAd();
    super.initState();
  }

  Future<void> _initBannerAd() async {
    await AdService().initialize(); // Initialiser le service
    await AdService().loadBannerAd(AdSize.banner);
    setState(() {
      _isBannerAdReady = true;
    });
  }

  @override
  void dispose() {
    AdService().bannerDispos();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 90,
            left: 16,
            right: 16,
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 20,
                    bottom: 20,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      widget.appParam!.useGoogleSearch
                          ? PlaceSearchWidget(
                            key: ValueKey("${origine?.name}-1"),
                            apiKey: widget.appParam!.apiKey,
                            initPlace: origine,
                            icon: Icon(
                              Icons.trip_origin_outlined,
                              color: HexColor("#D9D9D9"),
                            ),
                            label: "Origine",
                            onLocationSelected: (PlaceModel location) {
                              setState(() {
                                loading = true;
                              });
                              Future.delayed(Duration(seconds: 1), () {
                                setState(() {
                                  loading = false;
                                  origine = location;
                                });
                              });
                            },
                          )
                          : DakarSearchWidget(
                            key: ValueKey("${origine?.name}-1"),
                            initPlace: origine,
                            icon: Icon(
                              Icons.trip_origin_outlined,
                              color: HexColor("#D9D9D9"),
                            ),
                            label: "Origine",
                            onLocationSelected: (PlaceModel location) {
                              setState(() {
                                loading = true;
                              });
                              Future.delayed(Duration(seconds: 1), () {
                                setState(() {
                                  loading = false;
                                  origine = location;
                                });
                              });
                            },
                          ),
                      SizedBox(height: 15),
                      widget.appParam!.useGoogleSearch
                          ? PlaceSearchWidget(
                            apiKey: widget.appParam!.apiKey,
                            key: ValueKey(destination?.name),
                            icon: Icon(
                              Icons.location_on_sharp,
                              color: HexColor("#F52D56"),
                            ),
                            label: "Destination",
                            initPlace: destination,
                            onLocationSelected: (PlaceModel location) {
                              setState(() {
                                loading = true;
                              });

                              Future.delayed(Duration(seconds: 1), () {
                                setState(() {
                                  loading = false;
                                  destination = location;
                                });
                              });
                            },
                          )
                          : DakarSearchWidget(
                            key: ValueKey(destination?.name),
                            icon: Icon(
                              Icons.location_on_sharp,
                              color: HexColor("#F52D56"),
                            ),
                            label: "Destination",
                            initPlace: destination,
                            onLocationSelected: (PlaceModel location) {
                              setState(() {
                                loading = true;
                              });

                              Future.delayed(Duration(seconds: 1), () {
                                setState(() {
                                  loading = false;
                                  destination = location;
                                });
                              });
                            },
                          ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 35,
                  child: InkWell(
                    onTap: () {
                      if (origine != null && destination != null) {
                        PlaceModel backup = origine!;
                        setState(() {
                          loading = true;
                          origine = destination;
                          destination = backup;
                        });
                        Future.delayed(Duration(seconds: 1), () {
                          setState(() {
                            loading = false;
                          });
                        });
                      }
                    },
                    child: SvgPicture.asset("assets/transit/switch.svg"),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 250,
            left: 0,
            right: 0,
            bottom: 0,
            child:
                loading && (origine != null && destination != null)
                    ? SizedBox(
                      height: MediaQuery.of(context).size.height / 2,
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : (origine != null && destination != null)
                    ? Container(
                      color: Colors.white,
                      padding: EdgeInsets.only(bottom: 10),
                      child: RouteTimelinePage(
                        toPlaceDetails: destination,
                        fromPlaceDetails: origine,
                        stopTimeResponse: null,
                        date: _dateController.text,
                        time: _timeController.text,
                        onDepartureTransitUpdated: (
                          List<TransitFullResponseModel> transitData,
                          Position? currentPosition,
                          List<CampaignWinnerDTOModel> winners,
                        ) {
                          setState(() {
                            _transitData = transitData;
                            _currentPosition = currentPosition;
                            topWinners = winners;
                          });
                          _updateNearbyStop(transitData, currentPosition);
                        },
                      ),
                    )
                    : SingleChildScrollView(
                      child: Column(
                        children: [
                          FavoritePlacesWidget(
                            onFavoritePlaceSelected: (PlaceModel place) {
                              setState(() {
                                destination = place;
                              });
                            },
                          ),
                          if (topWinners.isNotEmpty)
                            CampaignWinnersWidget(winners: topWinners),
                        ],
                      ),
                    ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              padding: EdgeInsets.only(left: 16, top: 16, right: 16),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      children: [
                        Text(
                          "Où allons-nous ?",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SpeedDial(
                    elevation: 0,
                    direction: SpeedDialDirection.down,
                    icon: Icons.tune,
                    activeIcon: Icons.close,
                    iconTheme: IconThemeData(color: Colors.black, size: 24),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.white,
                    overlayColor: Colors.black.withOpacity(0.3),
                    spacing: 10,
                    spaceBetweenChildren: 8,
                    children: [
                      SpeedDialChild(
                        child: Icon(Icons.directions_walk, color: Colors.black),
                        label: "Marcher vers l'arrêt de départ",
                        onTap: () {
                          if (_transitData.isNotEmpty && _nearbyStop != null) {
                            UrlLauncher().openMapsNavigation(
                              origine!.latitude,
                              origine!.longitude,
                              _nearbyStop!.stopLat,
                              _nearbyStop!.stopLon,
                            );
                          }
                        },
                      ),
                      SpeedDialChild(
                        child: Icon(Icons.calendar_month, color: Colors.black),
                        label:
                            _dateTimeController.text.isEmpty
                                ? "Date et heure de voyage"
                                : _dateTimeController.text,
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(DateTime.now().year, 12, 31),
                          );
                          if (pickedDate != null) {
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              final DateTime combinedDateTime = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                              final formattedDateTime = DateFormat(
                                'dd-MM-yyyy HH:mm',
                              ).format(combinedDateTime);
                              final formattedDate = DateFormat(
                                'yyyMMdd',
                              ).format(combinedDateTime);
                              final formattedTime = DateFormat(
                                'HH:mm:ss',
                              ).format(combinedDateTime);
                              setState(() {
                                _dateTimeController.text = formattedDateTime;
                                _dateController.text = formattedDate;
                                _timeController.text = formattedTime;
                              });

                              PlaceModel backup = origine!;
                              setState(() {
                                loading = true;
                                origine = null;
                              });
                              Future.delayed(Duration(milliseconds: 500), () {
                                setState(() {
                                  loading = false;
                                  origine = backup;
                                });
                              });
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isBannerAdReady &&
              widget.appParam != null &&
              !widget.appParam!.hideAds)
            Positioned(
              bottom: 2,
              left: 0,
              right: 0,
              child: AdService().getBannerAd(),
            ),
        ],
      ),
    );
  }
}
