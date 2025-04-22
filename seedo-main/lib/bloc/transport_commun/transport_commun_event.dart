part of 'transport_commun_bloc.dart';



abstract class TransportCommunEvent extends Equatable {
  const TransportCommunEvent();

  @override
  List<Object> get props => [];
}

class TransportCommunInit extends TransportCommunEvent {}

class OriginSelected extends TransportCommunEvent {
  final PlaceModel origin;

  const OriginSelected(this.origin);

  @override
  List<Object> get props => [origin];
}

class DestinationSelected extends TransportCommunEvent {
  final PlaceModel destination;

  const DestinationSelected(this.destination);

  @override
  List<Object> get props => [destination];
}

class SearchLocation extends TransportCommunEvent {
  final String query;

  const SearchLocation(this.query);

  @override
  List<Object> get props => [query];
}

class UseCurrentLocation extends TransportCommunEvent {}