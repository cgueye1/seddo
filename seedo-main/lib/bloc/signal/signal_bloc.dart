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

class SignalementBloc extends Bloc<SignalementEvent, SignalementState> {
  final _imagePicker = ImagePicker();
  final _audioRecorder = AudioRecorder();
  final _audioPlayer = AudioPlayer();
  final ApiService _apiService = ApiService();

  SignalementBloc() : super(const SignalementState()) {
    on<TypeSelected>(_onTypeSelected);
    on<PhotoCaptured>(_onPhotoCaptured);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<StartRecording>(_onStartRecording);
    on<StopRecording>(_onStopRecording);
    on<PlayAudio>(_onPlayAudio);
    on<StopAudio>(_onStopAudio);
    on<SubmitSignalement>(_onSubmitSignalement);
    on<ResetSignalement>(_onResetSignalement);
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
    if (state.selectedType == null || state.description.isEmpty) {
      emit(
        state.copyWith(
          error: 'Veuillez sélectionner un type et ajouter une description',
        ),
      );
      return;
    }

    emit(state.copyWith(isSubmitting: true, error: null));

    try {
      // Préparation de FormData pour l'envoi multipart
      FormData formData = FormData.fromMap({
        'type': state.selectedType,
        'description': state.description,
      });

      // Ajouter la photo si disponible
      if (state.photo != null) {
        formData.files.add(
          MapEntry(
            'photo',
            await MultipartFile.fromFile(
              state.photo!.path,
              filename: 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          ),
        );
      }

      // Ajouter l'audio si disponible
      if (state.audioPath != null) {
        formData.files.add(
          MapEntry(
            'audio',
            await MultipartFile.fromFile(
              state.audioPath!,
              filename: 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
            ),
          ),
        );
      }

      // Envoyer la requête
      final response = await _apiService.dio.post(
        '/v1/signalements',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(state.copyWith(isSubmitting: false, isSuccess: true));
      } else {
        emit(
          state.copyWith(
            isSubmitting: false,
            error:
                'Échec de l\'envoi du signalement: ${response.statusMessage}',
          ),
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Erreur réseau';
      if (e.response != null) {
        errorMessage =
            e.response?.data['message'] ??
            'Erreur serveur: ${e.response?.statusCode}';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Délai de connexion dépassé';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Délai de réception dépassé';
      }

      emit(state.copyWith(isSubmitting: false, error: errorMessage));
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          error: 'Erreur lors de l\'envoi: $e',
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
