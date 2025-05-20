import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/bloc/home/home_bloc.dart';
import 'package:seddoapp/bloc/home/home_event.dart';
import 'package:seddoapp/bloc/home/home_state.dart';
import 'package:seddoapp/pages/publie.dart';
import 'package:seddoapp/utils/HexColor.dart';

import 'package:seddoapp/widgets/CustomFloatingButton.dart';
import 'package:seddoapp/widgets/home/SearchBar.dart';
import 'package:seddoapp/widgets/publicationlistSection.dart';

class Publicationslist extends StatefulWidget {
  const Publicationslist({super.key});

  @override
  State<Publicationslist> createState() => _PublicationslistState();
}

class _PublicationslistState extends State<Publicationslist> {
  @override
  void initState() {
    super.initState();
    // Load publications when the screen is initialized
    _loadPublications();
  }

  void _loadPublications() {
    final homeState = context.read<HomeBloc>().state;

    // Check if we have location data available
    if (homeState.currentLatitude != null &&
        homeState.currentLongitude != null) {
      // Dispatch the LoadNearbyPublications event to fetch publications
      context.read<HomeBloc>().add(
        LoadNearbyPublications(
          latitude: homeState.currentLatitude!,
          longitude: homeState.currentLongitude!,
          categoryId: homeState.selectedCategoryId,
          subcategoryId: homeState.selectedSubcategoryId,
        ),
      );
    } else {
      // If location is not available, request it first
      context.read<HomeBloc>().add(const LoadCurrentLocation());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          // Listen for location updates and load publications when location becomes available
          if (state.currentLatitude != null &&
              state.currentLongitude != null &&
              state.publications.isEmpty) {
            context.read<HomeBloc>().add(
              LoadNearbyPublications(
                latitude: state.currentLatitude!,
                longitude: state.currentLongitude!,
                categoryId: state.selectedCategoryId,
                subcategoryId: state.selectedSubcategoryId,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.only(top: 60, left: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Publications',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                const SearchBars(),
                const SizedBox(height: 16),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      // Refresh publications when pulled down
                      _loadPublications();
                    },
                    child: const PublicationListSection(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: CustomFloatingButton(
        imagePath: 'assets/images/plus.svg',
        iconColor: Colors.white,
        onPressed: () {
          final categories = context.read<HomeBloc>().state.categories;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PubliePage(categories: categories),
            ),
          );
        },
        label: '',
        backgroundColor: HexColor("#D95C18"),
        elevation: 4.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
