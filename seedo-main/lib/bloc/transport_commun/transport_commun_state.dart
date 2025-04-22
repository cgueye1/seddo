part of 'transport_commun_bloc.dart';

enum TransportCommunStatus { initial, loading, success, failure }

class TransportCommunState extends Equatable {
  final TransportCommunStatus status;
  final PlaceModel? origin;
  final PlaceModel? destination;
  final List<PlaceModel> searchResults;
  final String? errorMessage;

  const TransportCommunState({
    this.status = TransportCommunStatus.initial,
    this.origin,
    this.destination,
    this.searchResults = const [],
    this.errorMessage,
  });

  TransportCommunState copyWith({
    TransportCommunStatus? status,
    PlaceModel? origin,
    PlaceModel? destination,
    List<PlaceModel>? searchResults,
    String? errorMessage,
  }) {
    return TransportCommunState(
      status: status ?? this.status,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      searchResults: searchResults ?? this.searchResults,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    origin,
    destination,
    searchResults,
    errorMessage,
  ];
}
