// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:seddoapp/bloc/home/home_bloc.dart';
import 'package:seddoapp/bloc/home/home_event.dart';

class SearchBars extends StatefulWidget {
  const SearchBars({super.key});

  @override
  State<SearchBars> createState() => _SearchBarsState();
}

class _SearchBarsState extends State<SearchBars> {
  Timer? _debounceTimer;
  String? _lastSearchedKeyword;

  @override
  void initState() {
    super.initState();
    // Utilise directement le controller du bloc
    final controller = context.read<HomeBloc>().searchController;
    // Configure le listener sur le controller du bloc
    controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    // Ne pas dispose le controller ici car il appartient au bloc
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    final controller = context.read<HomeBloc>().searchController;

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final keyword = controller.text.trim();

      // Ne déclencher la recherche que si le mot-clé a changé
      if (keyword != _lastSearchedKeyword) {
        _lastSearchedKeyword = keyword;

        // Si le mot-clé est vide, rafraîchir toutes les publications
        if (keyword.isEmpty) {
          context.read<HomeBloc>().add(RefreshPublications());
          return;
        }

        _performSearch(context);
      }
    });
  }

  // Dans le fichier SearchBars.dart - Méthode _performSearch
  void _performSearch(BuildContext context) {
    final controller = context.read<HomeBloc>().searchController;
    final keyword = controller.text.trim();

    // Si le mot-clé est vide, demandez un rafraîchissement normal des publications
    if (keyword.isEmpty) {
      context.read<HomeBloc>().add(RefreshPublications());
      return;
    }

    print("Déclenchement de la recherche avec mot-clé: '$keyword'");
    final homeBloc = context.read<HomeBloc>();
    final state = homeBloc.state;

    final latitude = state.currentLatitude ?? 0.0;
    final longitude = state.currentLongitude ?? 0.0;
    final categoryId = state.selectedCategoryId;

    homeBloc.add(
      SearchPublications(
        latitude: latitude,
        longitude: longitude,
        keyword: keyword,
        categoryId: categoryId,
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeBloc>().state;
    final controller = context.read<HomeBloc>().searchController;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/icons/loupe.png',
            width: 23,
            height: 23,
            color: const Color.fromARGB(255, 37, 37, 37),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Rechercher...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              onSubmitted: (value) {
                // Déclencher la recherche lorsque l'utilisateur appuie sur Entrée
                if (state.currentLatitude != null &&
                    state.currentLongitude != null) {
                  if (value.trim().isEmpty) {
                    context.read<HomeBloc>().add(RefreshPublications());
                  } else {
                    context.read<HomeBloc>().add(
                      SearchPublications(
                        latitude: state.currentLatitude!,
                        longitude: state.currentLongitude!,
                        keyword: value,
                        categoryId: state.selectedCategory?.id,
                      ),
                    );
                  }
                }
              },
            ),
          ),
          // Bouton pour effacer la recherche si le texte existe
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                context.read<HomeBloc>().add(RefreshPublications());
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(Icons.clear, size: 18, color: Colors.grey[600]),
              ),
            ),
          GestureDetector(
            onTap: () {
              // Action pour l'icône d'édition - lance la recherche
              final searchText = controller.text.trim();
              if (state.currentLatitude != null &&
                  state.currentLongitude != null) {
                if (searchText.isEmpty) {
                  context.read<HomeBloc>().add(RefreshPublications());
                } else {
                  context.read<HomeBloc>().add(
                    SearchPublications(
                      latitude: state.currentLatitude!,
                      longitude: state.currentLongitude!,
                      keyword: searchText,
                      categoryId: state.selectedCategory?.id,
                    ),
                  );
                }
              }
            },
            child: Image.asset(
              'assets/icons/edit.png',
              width: 23,
              height: 23,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
