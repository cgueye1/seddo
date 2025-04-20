import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:solimus_vefa/screens/timeline/transit_timeline_screen.dart';

import '../data/repository.dart';
import '../models/transit/PlaceModel.dart';
import '../utils/HexaColor.dart';
import '../utils/const.dart';
import '../widgets/googleMap/DakarSearchWidget.dart';

class TransportCommun extends StatefulWidget {
  TransportCommun({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<TransportCommun> with WidgetsBindingObserver {
  int tabIndex = 0;
  bool isSwitched = false;
  List tickets = [];

  List gares = [];
  Dio dio = Dio();
  final TextEditingController _id = TextEditingController();
  bool loading = false;
  PlaceModel? origine;

  PlaceModel? destination;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 90,
            left: 16,
            right: 16,
            bottom: 0,
            child: Column(
              children: [
                DakarSearchWidget(
                  icon: Icon(Icons.circle_outlined),
                  label: "Origine",
                  onLocationSelected: (PlaceModel location) {
                    setState(() {
                      loading = true;
                    });
                    Future.delayed(Duration(seconds: 2), () {
                      setState(() {
                        loading = false;
                        origine = location;
                      });
                    });
                  },
                ),
                SizedBox(height: 15),
                DakarSearchWidget(
                  icon: Icon(Icons.location_on_sharp),
                  label: "Destination",
                  onLocationSelected: (PlaceModel location) {
                    setState(() {
                      loading = true;
                    });

                    Future.delayed(Duration(seconds: 2), () {
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
            top: 250,
            left: 0,
            right: 0,
            bottom: 0,
            child:
                loading && (origine != null && destination != null)
                    ? Container(
                      child: Center(child: CircularProgressIndicator()),
                      height: MediaQuery.of(context).size.height / 2,
                    )
                    : (origine != null && destination != null)
                    ? Container(
                      padding: EdgeInsets.only(bottom: 10),
                      child: RouteTimeline(
                        toPlaceDetails: destination,
                        fromPlaceDetails: origine,
                        stopTimeResponse: null,
                      ),
                    )
                    : SizedBox(),
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
              decoration: BoxDecoration(color: HexColor(APIConstants.BLACK)),
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
                          "Transports en commun",
                          style: TextStyle(
                            fontSize: 24,

                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
      ),
    );
  }
}
