// ignore_for_file: must_be_immutable

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:seddoapp/models/AppParamModel.dart';
import 'package:seddoapp/utils/HexColor.dart';
import '../../models/transit/PlaceModel.dart';
import '../../services/AdMobService.dart';
import '../../widgets/transit/DakarSearchWidget.dart';
import '../../widgets/transit/FavoritePlacesWidget.dart';
import '../../widgets/transit/PlaceSearchWidget.dart';
import 'RouteTimelinePage.dart';

class TransportCommun extends StatefulWidget {
  AppParamModel? appParam;

  TransportCommun({super.key, this.appParam});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<TransportCommun> with WidgetsBindingObserver {
  int tabIndex = 0;
  bool isSwitched = false;
  List tickets = [];

  List gares = [];
  Dio dio = Dio();
  bool loading = false;
  PlaceModel? origine;

  PlaceModel? destination;
  bool _isBannerAdReady = false;

  @override
  void initState() {
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
            // bottom: 0,
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
                  // height: 100,
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
                      ),
                    )
                    : FavoritePlacesWidget(
                      onFavoritePlaceSelected: (PlaceModel place) {
                        setState(() {
                          destination = place;
                        });
                      },
                    ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            // bottom: 0,
            child: Container(
              height: 80,
              padding: EdgeInsets.only(left: 16, top: 16),
              alignment: Alignment.center,
              //  decoration: BoxDecoration(color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
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
