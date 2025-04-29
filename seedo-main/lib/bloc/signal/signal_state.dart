// 4. Mettez à jour le fichier signal_state.dart pour ajouter l'état de lecture audio

import 'dart:io';
import 'package:equatable/equatable.dart';

class SignalementState extends Equatable {
  final String? selectedType;
  final File? photo;
  final String description;
  final String? audioPath;
  final bool isRecording;
  final bool isPlaying; // Nouvel état pour la lecture audio
  final bool isSubmitting;
  final bool isSuccess;
  final String? error;

  const SignalementState({
    this.selectedType,
    this.photo,
    this.description = '',
    this.audioPath,
    this.isRecording = false,
    this.isPlaying = false, // Initialisation du nouvel état
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
  });

  SignalementState copyWith({
    String? selectedType,
    File? photo,
    String? description,
    String? audioPath,
    bool? isRecording,
    bool? isPlaying, // Ajout du paramètre
    bool? isSubmitting,
    bool? isSuccess,
    String? error,
  }) {
    return SignalementState(
      selectedType: selectedType ?? this.selectedType,
      photo: photo ?? this.photo,
      description: description ?? this.description,
      audioPath: audioPath ?? this.audioPath,
      isRecording: isRecording ?? this.isRecording,
      isPlaying: isPlaying ?? this.isPlaying, // Mise à jour de l'état
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    selectedType,
    photo,
    description,
    audioPath,
    isRecording,
    isPlaying, // Ajout à la liste des propriétés
    isSubmitting,
    isSuccess,
    error,
  ];
}
