part of 'route_timeline_bloc.dart';

enum RouteTimelineStatus { initial, loading, success, failure }

class RouteTimelineState extends Equatable {
  final RouteTimelineStatus status;
  final List<TransitResponseModel> departureTransit;
  //final Filter? selectedFilter;
  final double startLat;
  final double startLon;
  final double endLat;
  final double endLon;
  final int maxDistanceFrom;
  final int maxDistanceTo;
  final String? errorMessage;
  final bool departureLoader;
  final Position? currentPosition;
  final bool adShown;
  final AppParamModel? appParam;


  const RouteTimelineState({
    this.status = RouteTimelineStatus.initial,
    this.departureTransit = const [],
   // this.selectedFilter,
    this.startLat = 0,
    this.startLon = 0,
    this.endLat = 0,
    this.endLon = 0,
    this.maxDistanceFrom = 500,
    this.maxDistanceTo = 500,
    this.departureLoader = false,
    this.errorMessage,
    this.currentPosition,
    this.adShown = false,
    this.appParam
  });

  RouteTimelineState copyWith({
    RouteTimelineStatus? status,
    List<TransitResponseModel>? departureTransit,
  //  Filter? selectedFilter,
    double? startLat,
    double? startLon,
    bool? departureLoader,
    double? endLat,
    double? endLon,
    int? maxDistanceFrom,
    int? maxDistanceTo,
    String? errorMessage,
    Position? currentPosition,
    bool? adShown,
    AppParamModel? appParam
  }) {
    return RouteTimelineState(
      status: status ?? this.status,
      departureTransit: departureTransit ?? this.departureTransit,
      //selectedFilter: selectedFilter ?? this.selectedFilter,
      startLat: startLat ?? this.startLat,
      startLon: startLon ?? this.startLon,
      endLat: endLat ?? this.endLat,
      endLon: endLon ?? this.endLon,
      maxDistanceFrom: maxDistanceFrom ?? this.maxDistanceFrom,
      maxDistanceTo: maxDistanceTo ?? this.maxDistanceTo,
      errorMessage: errorMessage ?? this.errorMessage,
      departureLoader: departureLoader ?? this.departureLoader,
      currentPosition: currentPosition ?? this.currentPosition,
      adShown: adShown ?? this.adShown,
      appParam:  appParam?? this. appParam,

    );
  }

  @override
  List<Object?> get props => [
    status,
    departureTransit,
  //  selectedFilter,
    startLat,
    startLon,
    endLat,
    endLon,
    maxDistanceFrom,
    maxDistanceTo,
    errorMessage,
    departureLoader,
    currentPosition,
    adShown,
    appParam
  ];
}