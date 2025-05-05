// 1. Ajoutez d'abord le package just_audio à votre pubspec.yaml:
// dependencies:
//   just_audio: ^0.9.34

// 2. Modifiez votre signal_bloc.dart pour ajouter les fonctionnalités de lecture:

// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:seddoapp/bloc/signal/signal_event.dart';
import 'package:seddoapp/bloc/signal/signal_state.dart';
import 'package:seddoapp/services/api_service.dart';

import '../../repositories/publication_repository.dart';
import '../../services/LocationService.dart';

class SignalementBloc extends Bloc<SignalementEvent, SignalementState> {
  final _imagePicker = ImagePicker();
  final _audioRecorder = AudioRecorder();
  final _audioPlayer = AudioPlayer();
  final ApiService _apiService = ApiService();
  final PublicationRepository _publicationRepository;
  final LocationService locationService = LocationService();

  SignalementBloc(this._publicationRepository)
    : super(const SignalementState()) {
    on<TypeSelected>(_onTypeSelected);
    on<PhotoCaptured>(_onPhotoCaptured);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<StartRecording>(_onStartRecording);
    on<StopRecording>(_onStopRecording);
    on<PlayAudio>(_onPlayAudio);
    on<StopAudio>(_onStopAudio);
    on<SubmitSignalement>(_onSubmitSignalement);
    on<ResetSignalement>(_onResetSignalement);
    on<LoadCurrentPosition>(_onLoadCurrentPosition);
  }

  Future<void> _onLoadCurrentPosition(
    LoadCurrentPosition event,
    Emitter<SignalementState> emit,
  ) async {
    try {
      final position = await locationService.getCurrentLocation();
      emit(state.copyWith(currentPosition: position));
    } catch (e) {
      emit(
        state.copyWith(
          error: 'Erreur lors de la récupération de la position: $e',
        ),
      );
    }
  }

  Future<void> capturePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        add(PhotoCaptured(File(image.path)));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Erreur lors de la capture de photo: $e'));
    }
  }

  void _onTypeSelected(TypeSelected event, Emitter<SignalementState> emit) {
    emit(state.copyWith(selectedType: event.type));
  }

  void _onPhotoCaptured(PhotoCaptured event, Emitter<SignalementState> emit) {
    emit(state.copyWith(photo: event.photo));
  }

  void _onDescriptionChanged(
    DescriptionChanged event,
    Emitter<SignalementState> emit,
  ) {
    emit(state.copyWith(description: event.description));
  }

  Future<void> _onStartRecording(
    StartRecording event,
    Emitter<SignalementState> emit,
  ) async {
    try {
      // Arrêter la lecture audio si elle est en cours
      if (state.isPlaying) {
        await _audioPlayer.stop();
        emit(state.copyWith(isPlaying: false));
      }

      // Vérifier les permissions
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        // Préparer le chemin pour l'enregistrement
        final directory = await getTemporaryDirectory();
        final path =
            '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        // Configurer et démarrer l'enregistrement
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );

        emit(state.copyWith(isRecording: true));
      } else {
        emit(state.copyWith(error: 'Permission d\'enregistrement refusée'));
      }
    } catch (e) {
      emit(
        state.copyWith(
          error: 'Erreur lors du démarrage de l\'enregistrement: $e',
        ),
      );
    }
  }

  Future<void> _onStopRecording(
    StopRecording event,
    Emitter<SignalementState> emit,
  ) async {
    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        emit(state.copyWith(audioPath: path, isRecording: false));
      } else {
        emit(
          state.copyWith(
            isRecording: false,
            error: 'Erreur: Aucun fichier audio enregistré',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isRecording: false,
          error: 'Erreur lors de l\'arrêt de l\'enregistrement: $e',
        ),
      );
    }
  }

  Future<void> _onPlayAudio(
    PlayAudio event,
    Emitter<SignalementState> emit,
  ) async {
    if (state.audioPath == null) {
      emit(state.copyWith(error: 'Aucun audio à écouter'));
      return;
    }

    try {
      // Si une lecture est déjà en cours, l'arrêter d'abord
      if (state.isPlaying) {
        await _audioPlayer.stop();
        emit(state.copyWith(isPlaying: false));
      } else {
        // Configurer le lecteur audio
        await _audioPlayer.setFilePath(state.audioPath!);
        emit(state.copyWith(isPlaying: true));

        // Démarrer la lecture
        await _audioPlayer.play();

        // À la fin de la lecture, mettre à jour l'état
        _audioPlayer.playerStateStream.listen((playerState) {
          if (playerState.processingState == ProcessingState.completed) {
            add(StopAudio());
          }
        });
      }
    } catch (e) {
      emit(state.copyWith(error: 'Erreur lors de la lecture de l\'audio: $e'));
    }
  }

  Future<void> _onStopAudio(
    StopAudio event,
    Emitter<SignalementState> emit,
  ) async {
    try {
      await _audioPlayer.stop();
      emit(state.copyWith(isPlaying: false));
    } catch (e) {
      emit(state.copyWith(error: 'Erreur lors de l\'arrêt de l\'audio: $e'));
    }
  }

  Future<void> _onSubmitSignalement(
    SubmitSignalement event,
    Emitter<SignalementState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, isSuccess: false, error: null));

    try {
      // 1. Charger la position si elle est nulle
      var currentPosition = state.currentPosition;
      if (currentPosition == null) {
        try {
          currentPosition = await locationService.getCurrentLocation();
          emit(state.copyWith(currentPosition: currentPosition));
        } catch (e) {
          emit(
            state.copyWith(
              isSubmitting: false,
              error: "Impossible d'obtenir la position actuelle : $e",
            ),
          );
          return;
        }
      }

      final latitude = currentPosition!.latitude;
      final longitude = currentPosition!.longitude;

      // Vérifie si les coordonnées sont valides
      if (latitude == 0 || longitude == 0) {
        emit(
          state.copyWith(
            isSubmitting: false,
            error: "La position actuelle est invalide",
          ),
        );
        return;
      }

      final titre = "";
      final description = state.description;
      final authorId = event.authorId;
      List<String> pictures = state.photo != null ? [state.photo!.path] : [];
      final available = true;
      final universel = false;
      final date = "";
      final price = 0.0;
      final audio = state.audioPath;

      final response = await _publicationRepository.postPublication(
        titre: titre,
        description: description,
        authorId: authorId,
        categorieId: 1,
        latitude: latitude,
        longitude: longitude,
        price: price,
        date: date,
        imagePaths: pictures,
        available: available,
        universel: universel,
        audio: audio ?? '',
        emergency: true,
        days: 1,
        pricingId: 1,
      );

      print(response);
      emit(state.copyWith(isSubmitting: false, isSuccess: true));
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          isSuccess: false,
          error: "Erreur lors de l'envoi du signalement : $e",
        ),
      );
    }
  }

  void _onResetSignalement(
    ResetSignalement event,
    Emitter<SignalementState> emit,
  ) {
    emit(const SignalementState());
  }

  @override
  Future<void> close() async {
    await _audioPlayer.dispose();
    return super.close();
  }
}
