import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/bloc/signal/signal_bloc.dart';
import 'package:seddoapp/bloc/signal/signal_event.dart';
import 'package:seddoapp/bloc/signal/signal_state.dart';
import 'package:seddoapp/utils/HexColor.dart';

import '../repositories/publication_repository.dart';
import '../services/api_service.dart';
import '../services/publication_service.dart';

// Fonction pour afficher la modal de signalement
Future<void> showSignalModal(BuildContext context) {
  final apiService = ApiService();
  final publicationService = PublicationService(apiService.dio);
  final publicationRepository = PublicationRepository(
    publicationService: publicationService,
  );

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => BlocProvider(
          create: (_) => SignalementBloc(publicationRepository),
          child: SignalModalContent(),
        ),
  );
}

class SignalModalContent extends StatefulWidget {
  const SignalModalContent({Key? key}) : super(key: key);

  @override
  _SignalModalContentState createState() => _SignalModalContentState();
}

class _SignalModalContentState extends State<SignalModalContent> {
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
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Barre de drag en haut
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(top: 15, bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              // Zone de fermeture
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 30),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
              // Contenu
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Une situation à signaler ?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _descriptionController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Décrivez la situation en détail...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'Médias (optionnel)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 15),
                        // Options de médias
                        Row(
                          children: [
                            // Option Photo/Video
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  context
                                      .read<SignalementBloc>()
                                      .capturePhoto();
                                },
                                child: Container(
                                  height: 140,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        size: 36,
                                        color: Colors.deepOrange[400],
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Photo/Video',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            // Option Audio
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (state.isRecording) {
                                    context.read<SignalementBloc>().add(
                                      const StopRecording(null),
                                    );
                                  } else {
                                    context.read<SignalementBloc>().add(
                                      StartRecording(),
                                    );
                                  }
                                },
                                child: Container(
                                  height: 140,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.mic,
                                        size: 36,
                                        color: Colors.deepOrange[400],
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Enregistrement audio',
                                        style: TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Afficher les photos sélectionnées
                        if (state.photo != null)
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    state.photo!,
                                    height: 150,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 5,
                                  top: 5,
                                  child: GestureDetector(
                                    onTap: () {
                                      // Ajouter une méthode pour supprimer la photo
                                      context.read<SignalementBloc>().add(
                                        const RemovePhoto(),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Indicateur d'audio enregistré
                        if (state.audioPath != null)
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 15,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.mic, color: Colors.deepOrange[400]),
                                const SizedBox(width: 10),
                                const Text("Enregistrement audio"),
                                const Spacer(),
                                IconButton(
                                  icon: Icon(
                                    state.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    context.read<SignalementBloc>().add(
                                      state.isPlaying
                                          ? const StopAudio()
                                          : const PlayAudio(),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    // Ajouter une méthode pour supprimer l'audio
                                    context.read<SignalementBloc>().add(
                                      const RemoveAudio(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 30),
                        Container(
                          width: double.infinity,
                          height: 50,
                          margin: const EdgeInsets.only(bottom: 30),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: HexColor('#D95C18'),
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
                                      'Envoyer le signalement',
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
              ),
            ],
          ),
        );
      },
    );
  }
}
