import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/bloc/home/home_bloc.dart';
import 'package:seddoapp/bloc/home/home_state.dart';
import 'package:seddoapp/widgets/publicationListcard.dart';

class PublicationListSection extends StatelessWidget {
  const PublicationListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        print(
          "Rebuilding PublicationListSection: ${state.publications.length} publications, keyword=${state.lastSearchKeyword}",
        );

        return Column(
          key: const ValueKey('publications'),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
              child: SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (state.lastSearchKeyword == null ||
                        state.lastSearchKeyword!.isEmpty)
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          '',
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
            ),
            Expanded(child: _buildPublicationsList(context, state)),
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

    // Changed to use a ListView inside a SingleChildScrollView for proper scrolling
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.publications.length,
          itemBuilder: (context, index) {
            // Display price tag based on publication data
            String priceTag;
            Color priceTagColor;

            // This is a simplified example - you should replace with actual logic to determine price
            if (state.publications[index].titre.contains("Gratuit") ||
                index == 0) {
              // First item is free (Paëla)
              priceTag = "Gratuit";
              priceTagColor = Colors.green;
            } else if (index == 1) {
              // Second item (Thiébou Dieune)
              priceTag = "2 500 FCFA";
              priceTagColor = Colors.deepOrange;
            } else {
              // Third item (C'est bon)
              priceTag = "3500 FCFA";
              priceTagColor = Colors.deepOrange;
            }

            // Get category (in this case, all are "Alimentation")
            String category = "Alimentation";

            // Get expiration date - replace with actual data from your model
            String expirationDate = index == 0 ? "06/05/2025" : "07/05/2025";

            return PublicationListCard(
              publication: state.publications[index],
              item: state.publications[index],
              currentPosition: state.currentPosition!,
              priceTag: priceTag,
              priceTagColor: priceTagColor,
              category: category,
              expirationDate: expirationDate,
            );
          },
        ),
      ),
    );
  }
}
