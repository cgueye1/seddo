import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

class SignalementState extends Equatable {
  final String? selectedType;
  final List<File>? photos; // Changé de File unique à List<File>
  final String description;
  final String? audioPath;
  final List<String>? audioFiles;
  final bool isRecording;
  final bool isPlaying;
  final bool isSubmitting;
  final bool isSuccess;
  final String? error;
  final Position? currentPosition;

  const SignalementState({
    this.selectedType,
    this.photos, // Changé de photo à photos
    this.description = '',
    this.audioPath,
    this.audioFiles,
    this.isRecording = false,
    this.isPlaying = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
    this.currentPosition,
  });

  SignalementState copyWith({
    String? selectedType,
    List<File>? photos, // Changé de File à List<File>
    String? description,
    String? audioPath,
    List<String>? audioFiles,
    bool? isRecording,
    bool? isPlaying,
    bool? isSubmitting,
    bool? isSuccess,
    String? error,
    Position? currentPosition,
  }) {
    return SignalementState(
      selectedType: selectedType ?? this.selectedType,
      photos: photos ?? this.photos, // Mise à jour
      description: description ?? this.description,
      audioPath: audioPath ?? this.audioPath,
      audioFiles: audioFiles ?? this.audioFiles,
      isRecording: isRecording ?? this.isRecording,
      isPlaying: isPlaying ?? this.isPlaying,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
      currentPosition: currentPosition ?? this.currentPosition,
    );
  }

  @override
  List<Object?> get props => [
    selectedType,
    photos, // Mise à jour
    description,
    audioPath,
    audioFiles,
    isRecording,
    isPlaying,
    isSubmitting,
    isSuccess,
    error,
    currentPosition,
  ];
}
