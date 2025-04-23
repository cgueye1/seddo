import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/bloc/signal/signal_bloc.dart';
import 'package:seddoapp/bloc/signal/signal_event.dart';
import 'package:seddoapp/bloc/signal/signal_state.dart';

class SignalPage extends StatelessWidget {
  const SignalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SignalementBloc(),
      child: const SignalementView(),
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

  final List<String> _typeOptions = [
    'Problème de voirie',
    'Déchet/Dépôt sauvage',
    'Graffiti',
    'Éclairage défectueux',
    'Mobilier urbain endommagé',
    'Autre',
  ];

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
              mainAxisSize:
                  MainAxisSize.min, // ← Important pour éviter l'espace inutile
              children: [
                IconButton(
                  icon: Transform.translate(
                    offset: const Offset(
                      12,
                      0,
                    ), // ← Déplace légèrement l'icône vers la droite
                    child: const Icon(Icons.arrow_back_ios, size: 20),
                  ), // ← Taille réduite si besoin
                  onPressed: () => Navigator.pop(context),
                  padding:
                      EdgeInsets
                          .zero, // ← Supprime le padding interne du bouton
                  constraints:
                      const BoxConstraints(), // ← Désactive les contraintes par défaut
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
            titleSpacing: 0, // ← Supprime l'espace réservé au titre
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
                    'Type de signalement',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('Selectionnez un type'),
                        ),
                        value: state.selectedType,
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.black),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            context.read<SignalementBloc>().add(
                              TypeSelected(newValue),
                            );
                          }
                        },
                        items:
                            _typeOptions.map<DropdownMenuItem<String>>((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Text(value),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            state.isRecording ? Icons.stop : Icons.mic,
                            color:
                                state.isRecording ? Colors.red : Colors.black,
                          ),
                          onPressed: () {
                            if (state.isRecording) {
                              // Ne pas fournir de chemin - le BLoC récupérera le vrai chemin
                              context.read<SignalementBloc>().add(
                                const StopRecording(null),
                              );
                            } else {
                              context.read<SignalementBloc>().add(
                                StartRecording(),
                              );
                            }
                          },
                        ),
                        Expanded(
                          child: Slider(
                            value:
                                0, // Devrait être remplacé par la position actuelle
                            min: 0,
                            max: 100,
                            onChanged:
                                state.audioPath == null
                                    ? null
                                    : (value) {
                                      // Implémenter la logique de position audio
                                    },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              state.isRecording ? Icons.stop : Icons.mic,
                              color:
                                  state.isRecording ? Colors.red : Colors.black,
                            ),
                            onPressed: () {
                              if (state.isRecording) {
                                // Pour simplifier, nous utilisons un chemin vide pour le StopRecording
                                // Le vrai chemin sera fourni par le Record package
                                context.read<SignalementBloc>().add(
                                  StopRecording(''),
                                );
                              } else {
                                context.read<SignalementBloc>().add(
                                  StartRecording(),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
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
                                  SubmitSignalement(),
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
}
