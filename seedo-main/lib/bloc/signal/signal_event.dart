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
  List<Object?> get props => [type];
}

class PhotoCaptured extends SignalementEvent {
  final File photo;

  const PhotoCaptured(this.photo);

  @override
  List<Object?> get props => [photo];
}

class DescriptionChanged extends SignalementEvent {
  final String description;

  const DescriptionChanged(this.description);

  @override
  List<Object?> get props => [description];
}

class StartRecording extends SignalementEvent {
  const StartRecording();
}

class StopRecording extends SignalementEvent {
  final String? path;

  const StopRecording(this.path);

  @override
  List<Object?> get props => [path];
}

class PlayAudio extends SignalementEvent {
  const PlayAudio();
}

class StopAudio extends SignalementEvent {
  const StopAudio();
}

class RemovePhoto extends SignalementEvent {
  final int? index; // Ajout d'un index pour identifier quelle photo supprimer

  const RemovePhoto({this.index});

  @override
  List<Object?> get props => [index];
}

class RemoveAudio extends SignalementEvent {
  const RemoveAudio();
}

class ResetSignalement extends SignalementEvent {
  const ResetSignalement();
}

class SubmitSignalement extends SignalementEvent {
  final int authorId;

  const SubmitSignalement({required this.authorId});

  @override
  List<Object?> get props => [authorId];
}

class LoadCurrentPosition extends SignalementEvent {
  const LoadCurrentPosition();
}
