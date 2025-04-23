// file: signal_event.dart
import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class SignalementEvent extends Equatable {
  const SignalementEvent();

  @override
  List<Object?> get props => [];
}

class TypeSelected extends SignalementEvent {
  final String type;

  const TypeSelected(this.type);

  @override
  List<Object> get props => [type];
}

class PhotoCaptured extends SignalementEvent {
  final File photo;

  const PhotoCaptured(this.photo);

  @override
  List<Object> get props => [photo];
}

class DescriptionChanged extends SignalementEvent {
  final String description;

  const DescriptionChanged(this.description);

  @override
  List<Object> get props => [description];
}

class StartRecording extends SignalementEvent {}

class StopRecording extends SignalementEvent {
  final String? path;

  const StopRecording(this.path);

  @override
  List<Object?> get props => [path];
}

class SubmitSignalement extends SignalementEvent {}

class ResetSignalement extends SignalementEvent {}
