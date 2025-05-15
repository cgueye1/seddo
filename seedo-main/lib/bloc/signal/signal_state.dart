import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

class SignalementState extends Equatable {
  final String? selectedType;
  final File? photo;
  final String description;
  final String? audioPath;
  final List<String>?
  audioFiles; // Liste pour stocker plusieurs enregistrements audio
  final bool isRecording;
  final bool isPlaying;
  final bool isSubmitting;
  final bool isSuccess;
  final String? error;
  final Position? currentPosition;

  const SignalementState({
    this.selectedType,
    this.photo,
    this.description = '',
    this.audioPath,
    this.audioFiles, // Nouvelle propriété
    this.isRecording = false,
    this.isPlaying = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
    this.currentPosition,
  });

  SignalementState copyWith({
    String? selectedType,
    File? photo,
    String? description,
    String? audioPath,
    List<String>? audioFiles, // Nouvelle propriété
    bool? isRecording,
    bool? isPlaying,
    bool? isSubmitting,
    bool? isSuccess,
    String? error,
    Position? currentPosition,
  }) {
    return SignalementState(
      selectedType: selectedType ?? this.selectedType,
      photo: photo ?? this.photo,
      description: description ?? this.description,
      audioPath: audioPath ?? this.audioPath,
      audioFiles: audioFiles ?? this.audioFiles, // Mise à jour
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
    photo,
    description,
    audioPath,
    audioFiles, // Ajout à la liste des propriétés
    isRecording,
    isPlaying,
    isSubmitting,
    isSuccess,
    error,
    currentPosition,
  ];
}
