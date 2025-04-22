import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/route_timeline/route_timeline_bloc.dart';
import '../../models/transit/PlaceModel.dart';
import '../../models/transit/StopTimeResponse.dart';
import '../../widgets/transit/timeline_point.dart';
import '../../widgets/transit/timeline_tile.dart';

class RouteTimelinePage extends StatelessWidget {
  final PlaceModel? toPlaceDetails;
  final PlaceModel? fromPlaceDetails;
  final StopTimeResponseModel? stopTimeResponse;

  const RouteTimelinePage({
    Key? key,
    this.toPlaceDetails,
    this.fromPlaceDetails,
    this.stopTimeResponse,
  }) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              RouteTimelineBloc()..add(
                RouteTimelineInitialized(
                  fromPlaceDetails: fromPlaceDetails,
                  toPlaceDetails: toPlaceDetails,
                  stopTimeResponse: stopTimeResponse,
                ),
              ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<RouteTimelineBloc, RouteTimelineState>(
          builder: (context, state) {
            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.status == RouteTimelineStatus.loading || state.departureLoader)
                        Container(
                          child: Center(child: CircularProgressIndicator()),
                          height: MediaQuery.of(context).size.height / 2,
                        )
                      else if (state.departureTransit.isEmpty &&
                          state.status == RouteTimelineStatus.success)
                        _buildNoTransitFound(context, state)
                      else
                        _buildTimeline(context, state),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNoTransitFound(BuildContext context, RouteTimelineState state) {
    return Container(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bus_alert, size: 50, color: Colors.grey),
            SizedBox(height: 20),
            InkWell(
              onTap: () {
                /* UrlLauncher().openMapsNavigation(
                  state.startLat,
                  state.startLon,
                  state.endLat,
                  state.endLon,
                  travelMode: "walk",
                );*/
              },
              child: Container(
                width: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: Colors.grey),
                  color: Colors.white,
                ),
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_walk, color: Colors.grey),
                    SizedBox(width: 12),
                    Text(
                      "Marcher",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  state.errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
      height: MediaQuery.of(context).size.height / 2,
    );
  }

  Widget _buildTimeline(BuildContext context, RouteTimelineState state) {
    return Container(
      margin: EdgeInsets.only(top: 25, left: 16, right: 16,bottom: 100),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.all(0),
        physics: NeverScrollableScrollPhysics(),
        itemCount: state.departureTransit.length>0?state.departureTransit.length+2:state.departureTransit.length,
        itemBuilder: (context, index) {
          if (index == 0) {
            return TimelinePoint(
              label: fromPlaceDetails?.name ?? 'Départ',
              transit: state.departureTransit.first,
              lat: state.startLat,
              lon: state.startLon,
              isStart: true,
              isWalking: true,
            );
          } else if (index == state.departureTransit.length + 1) {
            return TimelinePoint(
              transit: state.departureTransit.last,
              lat: state.endLat,
              lon: state.endLon,
              label: toPlaceDetails?.name ?? 'Arrivée',
              isEnd: true,
              isWalking: true,
              isDestination: false,
            );
          } else {
            final transit = state.departureTransit[index - 1];
            return TimelineTile(
              destination: false,
              transit: transit,
              lat: state.endLat,
              lon: state.endLon,
              isLast: index == state.departureTransit.length,
              nexttransit:
                  index != state.departureTransit.length
                      ? state.departureTransit[index]
                      : transit,
              currentPosition: null, // You can pass current position if needed
            );
          }
        },
      ),
    );
  }
}
