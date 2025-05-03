import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/bloc/signal/signal_bloc.dart';
import 'package:seddoapp/bloc/signal/signal_event.dart';
import 'package:seddoapp/bloc/signal/signal_state.dart';

import '../repositories/publication_repository.dart';
import '../services/api_service.dart';
import '../services/publication_service.dart';

class SignalPage extends StatelessWidget {
  const SignalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    final publicationService = PublicationService(apiService.dio);
    final publicationRepository = PublicationRepository(
      publicationService: publicationService,
    );
    return BlocProvider(
      create: (_) => SignalementBloc(publicationRepository),
      child: SignalementView(),
    );
  }
}

class SignalementView extends StatefulWidget {
  const SignalementView({Key? key}) : super(key: key);

  @override
  _SignalementViewState createState() => _SignalementViewState();
}

class _SignalementViewState extends State<SignalementView> {
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_onDescriptionChanged);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _onDescriptionChanged() {
    context.read<SignalementBloc>().add(
      DescriptionChanged(_descriptionController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignalementBloc, SignalementState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        }

        if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signalement envoyé avec succès!')),
          );
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.of(context).pop();
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leadingWidth: 200,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Transform.translate(
                    offset: const Offset(12, 0),
                    child: const Icon(Icons.arrow_back_ios, size: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const Text(
                  'Retour',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            titleSpacing: 0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Une situation à signaler ?',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Écrivez quelques chose....',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    'Photo (optionnel)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      context.read<SignalementBloc>().capturePhoto();
                    },
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          state.photo != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  state.photo!,
                                  fit: BoxFit.cover,
                                ),
                              )
                              : Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      size: 50,
                                      color: Colors.deepOrange[400],
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Prendre une photo',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Audio (optionnel)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  _buildAudioRecordingSection(context, state),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed:
                          state.isSubmitting
                              ? null
                              : () {
                                context.read<SignalementBloc>().add(
                                  SubmitSignalement(authorId: 1),
                                );
                              },
                      child:
                          state.isSubmitting
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'Envoyer',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 5. Mettez à jour le widget _buildAudioRecordingSection dans SignalementView

  Widget _buildAudioRecordingSection(
    BuildContext context,
    SignalementState state,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Afficher le statut de l'enregistrement ou de la lecture
          if (state.isRecording)
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Enregistrement en cours...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (state.isPlaying)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Lecture en cours...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          // Afficher le message si un audio est enregistré
          if (state.audioPath != null && !state.isRecording && !state.isPlaying)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Audio enregistré',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Bouton pour démarrer/arrêter l'enregistrement
              GestureDetector(
                onTap: () {
                  if (state.isRecording) {
                    context.read<SignalementBloc>().add(
                      const StopRecording(null),
                    );
                  } else {
                    context.read<SignalementBloc>().add(StartRecording());
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        state.isRecording ? Colors.red : Colors.deepOrange[400],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    state.isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),

              // Visualisation de l'audio
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  height: 40,
                  child:
                      state.isRecording
                          ? _buildAudioWaveForm()
                          : (state.isPlaying
                              ? _buildPlayingWaveForm()
                              : (state.audioPath != null
                                  ? _buildAudioFileIndicator()
                                  : Center(
                                    child: Text(
                                      'Appuyez sur le microphone pour commencer l\'enregistrement',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ))),
                ),
              ),

              // Bouton pour réécouter l'audio (si disponible)
              if (state.audioPath != null && !state.isRecording)
                GestureDetector(
                  onTap: () {
                    // Déclencher la lecture/pause de l'audio
                    context.read<SignalementBloc>().add(
                      state.isPlaying ? const StopAudio() : const PlayAudio(),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: state.isPlaying ? Colors.red : Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      state.isPlaying ? Icons.stop : Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioWaveForm() {
    // Simuler une forme d'onde pour l'enregistrement audio
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        20,
        (index) => Container(
          width: 3,
          height: 5 + (index % 3) * 10.0,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  // Nouvelle méthode pour afficher une forme d'onde pendant la lecture
  Widget _buildPlayingWaveForm() {
    // Simuler une forme d'onde pour la lecture audio
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        20,
        (index) => Container(
          width: 3,
          height: 5 + (index % 4) * 8.0,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  Widget _buildAudioFileIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.audiotrack, color: Colors.green[700], size: 18),
        const SizedBox(width: 8),
        Text(
          'Audio enregistré',
          style: TextStyle(fontSize: 14, color: Colors.green[700]),
        ),
      ],
    );
  }
}
