import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/bloc/home/home_bloc.dart';
import 'package:seddoapp/bloc/home/home_state.dart';
import 'package:seddoapp/pages/categories/details.dart';
import 'package:seddoapp/widgets/home/publication.dart';

class PublicationsSection extends StatelessWidget {
  const PublicationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        print(
          "Rebuilding PublicationsSection: ${state.publications.length} publications, keyword=${state.lastSearchKeyword}",
        );

        return Column(
          key: const ValueKey('publications'),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.lastSearchKeyword != null &&
                            state.lastSearchKeyword!.isNotEmpty
                        ? 'Résultats de recherche'
                        : 'Plats partagés',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),

                  if (state.lastSearchKeyword == null ||
                      state.lastSearchKeyword!.isEmpty)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => DetailPage(
                                  categoryName: state.currentCategory,
                                ),
                          ),
                        );
                      },
                      child: const Text(
                        'Voir plus',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            _buildPublicationsList(context, state),
          ],
        );
      },
    );
  }

  Widget _buildPublicationsList(BuildContext context, HomeState state) {
    if (state.isLoadingPublications) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.publicationsError != null) {
      return Center(child: Text('Erreur: ${state.publicationsError}'));
    }

    // Si nous sommes en mode recherche et la liste est vide, montrez "Aucun résultat"
    if (state.publications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Icon(Icons.search_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                state.lastSearchKeyword != null &&
                        state.lastSearchKeyword!.isNotEmpty
                    ? "Aucun résultat pour '${state.lastSearchKeyword}'"
                    : "Aucune publication disponible",
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Horizontal scrolling list of publications
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: SizedBox(
        height: 537, // Fixed height for scrolling container
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                state.publications
                    .map(
                      (publication) =>
                          PublicationCard(publication: publication),
                    )
                    .toList(),
          ),
        ),
      ),
    );
  }
}
