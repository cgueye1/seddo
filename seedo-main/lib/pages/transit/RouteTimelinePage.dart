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
    super.key,
    this.toPlaceDetails,
    this.fromPlaceDetails,
    this.stopTimeResponse,
  });

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
                  index: 0,
                ),
              ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<RouteTimelineBloc, RouteTimelineState>(
          builder: (context, state) {
            return Stack(
              children: [
                // Content body
                Padding(
                  padding: EdgeInsets.only(
                    top:
                        state.departureTransit.isNotEmpty &&
                                state.departureTransit.first.size > 1
                            ? 60
                            : 0,
                  ),
                  // espace pour les tabs
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.status == RouteTimelineStatus.loading ||
                            state.departureLoader)
                          Container(
                            height: MediaQuery.of(context).size.height / 2,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (state.departureTransit.isEmpty &&
                            state.status == RouteTimelineStatus.success)
                          _buildNoTransitFound(context, state)
                        else
                          _buildTimeline(context, state),
                      ],
                    ),
                  ),
                ),

                // Tabs at top using Positioned + Row
                if (state.departureTransit.isNotEmpty &&
                    state.departureTransit.first.size > 1 &&
                    !state.departureLoader)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            state.departureTransit.first.size,
                            (index) {
                              final allLabels = [
                                '1er Itinéraire',
                                '2e Itinéraire',
                                '3e Itinéraire',
                              ];
                              final label =
                                  index < allLabels.length
                                      ? allLabels[index]
                                      : 'Itinéraire ${index + 1}';

                              final isSelected = state.itineraireIndex == index;

                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: GestureDetector(
                                  onTap: () {
                                    context.read<RouteTimelineBloc>().add(
                                      RouteTimelineTabChanged(index),
                                    );
                                    context.read<RouteTimelineBloc>().add(
                                      RouteTimelineInitialized(
                                        fromPlaceDetails: fromPlaceDetails,
                                        toPlaceDetails: toPlaceDetails,
                                        stopTimeResponse: stopTimeResponse,
                                        index: index,
                                      ),
                                    );
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color:
                                          isSelected
                                              ? Colors.blueAccent
                                              : Colors.grey.shade100,
                                      boxShadow:
                                          isSelected
                                              ? [
                                                BoxShadow(
                                                  color: Colors.blueAccent
                                                      .withOpacity(0.25),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ]
                                              : [],
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.directions_bus,
                                          size: 18,
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : Colors.blueAccent,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          label,
                                          style: TextStyle(
                                            color:
                                                isSelected
                                                    ? Colors.white
                                                    : Colors.black87,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
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
    return SizedBox(
      height: MediaQuery.of(context).size.height / 2,
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
    );
  }

  Widget _buildTimeline(BuildContext context, RouteTimelineState state) {
    return Container(
      margin: EdgeInsets.only(top: 25, left: 16, right: 16, bottom: 100),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.all(0),
        physics: NeverScrollableScrollPhysics(),
        itemCount:
            state.departureTransit.isNotEmpty
                ? state.departureTransit.length + 2
                : state.departureTransit.length,
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
