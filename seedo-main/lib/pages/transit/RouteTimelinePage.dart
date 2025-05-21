import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:seddoapp/utils/HexColor.dart';

import '../../bloc/route_timeline/route_timeline_bloc.dart';
import '../../models/campaign/CampaignWinnerDTOModel.dart';
import '../../models/transit/PlaceModel.dart';
import '../../models/transit/StopTimeResponse.dart';
import '../../models/transit/TransitResponseModel.dart';
import '../../utils/constant.dart';
import '../../widgets/transit/timeline_point.dart';
import '../../widgets/transit/timeline_tile.dart';

class RouteTimelinePage extends StatelessWidget {
  final PlaceModel? toPlaceDetails;
  final PlaceModel? fromPlaceDetails;
  final StopTimeResponseModel? stopTimeResponse;
  final String date;
  final String time;
  final void Function(List<TransitFullResponseModel>, Position?,  List<CampaignWinnerDTOModel> )? onDepartureTransitUpdated;

  const RouteTimelinePage({
    super.key,
    this.toPlaceDetails,
    this.fromPlaceDetails,
    this.stopTimeResponse,
    required this.date,
    required this.time,
    this.onDepartureTransitUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RouteTimelineBloc()
        ..add(RouteTimelineInitialized(
          fromPlaceDetails: fromPlaceDetails,
          toPlaceDetails: toPlaceDetails,
          stopTimeResponse: stopTimeResponse,
          index: 0,
          date: date,
          time: time,
          canShowAd: true
        )),
      child: _RouteTimelineContent(
        onDepartureTransitUpdated: onDepartureTransitUpdated,
        fromPlaceDetails: fromPlaceDetails,
        toPlaceDetails: toPlaceDetails,
        stopTimeResponse: stopTimeResponse,
        date: date,
        time: time,
      ),
    );
  }
}

class _RouteTimelineContent extends StatelessWidget {
  final Function(List<TransitFullResponseModel>, Position?, List<CampaignWinnerDTOModel>)? onDepartureTransitUpdated;
  final PlaceModel? toPlaceDetails;
  final PlaceModel? fromPlaceDetails;
  final StopTimeResponseModel? stopTimeResponse;
  final String date;
  final String time;

  const _RouteTimelineContent({
    Key? key,
    this.onDepartureTransitUpdated,
    this.toPlaceDetails,
    this.fromPlaceDetails,
    this.stopTimeResponse,
    required this.date,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<RouteTimelineBloc, RouteTimelineState>(
      listenWhen: (previous, current) => previous.departureTransit != current.departureTransit,
      listener: (context, state) {
        if (onDepartureTransitUpdated != null && state.departureTransit.isNotEmpty) {
          onDepartureTransitUpdated!(state.departureTransit, state.currentPosition!,state.campaignToWinners);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<RouteTimelineBloc, RouteTimelineState>(
          builder: (context, state) {
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: state.departureTransit.isNotEmpty &&
                        state.departureTransit.first.size > 1
                        ? 30
                        : 0,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.status == RouteTimelineStatus.loading || state.departureLoader || state.departureTransit.isEmpty )
                          SizedBox(
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
                if (state.departureTransit.isNotEmpty &&
                    state.departureTransit.first.size > 1 &&
                    !state.departureLoader)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            state.departureTransit.first.size,
                                (index) => _buildTabItem(context, index, state),
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

  Widget _buildTabItem(BuildContext context, int index, RouteTimelineState state) {
    final labels = ['1er Itinéraire', '2e Itinéraire', '3e Itinéraire'];
    final label = index < labels.length ? labels[index] : 'Itinéraire ${index + 1}';
    final isSelected = state.itineraireIndex == index;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          context.read<RouteTimelineBloc>().add(RouteTimelineInitialized(
            fromPlaceDetails: fromPlaceDetails,
            toPlaceDetails: toPlaceDetails,
            stopTimeResponse: stopTimeResponse,
            index: index,
            date: date,
            time: time,
            canShowAd: false
          ));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: isSelected ?  HexColor(APIConstants.secondaryColorValue ): Colors.grey.shade100,
            boxShadow: isSelected
                ? [
              BoxShadow(
                color:  HexColor(APIConstants.secondaryColorValue ).withOpacity(0.25),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ]
                : [],
          ),
          child: Row(
            children: [
              Icon(
                Icons.directions_bus,
                size: 18,
                color: isSelected ? Colors.white :  HexColor(APIConstants.secondaryColorValue ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoTransitFound(BuildContext context, RouteTimelineState state) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 2,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bus_alert, size: 50, color: Colors.grey),
            const SizedBox(height: 20),
            Container(
              width: 200,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.grey),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.directions_walk, color: Colors.grey),
                  SizedBox(width: 12),
                  Text("Marcher", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
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
      margin: const EdgeInsets.only(top: 25, left: 16, right: 16, bottom: 100),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.departureTransit.length + 2,
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
              label: toPlaceDetails?.name ?? 'Arrivée',
              transit: state.departureTransit.last,
              lat: state.endLat,
              lon: state.endLon,
              isEnd: true,
              isWalking: true,
              isDestination: false,
            );
          } else {
            final transit = state.departureTransit[index - 1];
            final nextTransit = index < state.departureTransit.length
                ? state.departureTransit[index]
                : transit;
            return TimelineTile(
              destination: false,
              transit: transit,
              lat: state.endLat,
              lon: state.endLon,
              isLast: index == state.departureTransit.length,
              nexttransit: nextTransit,
              currentPosition: null,
            );
          }
        },
      ),
    );
  }
}
