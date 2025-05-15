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
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (!state.hasLoadedInitialPublications &&
            state.currentLatitude != null &&
            state.currentLongitude != null &&
            state.publications.isEmpty &&
            !state.isLoadingPublications &&
            state.publicationsError == null) {
          // _loadNearbyPublications(context, state);
        }
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          body: Padding(
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
                const Expanded(child: PublicationListSection()),
              ],
            ),
          ),
          floatingActionButton: CustomFloatingButton(
            imagePath: 'assets/images/plus.svg',
            iconColor: Colors.white,
            onPressed: () {
              final categories = context.read<HomeBloc>().state.categories;
              print("Navigating to PubliePage with categories: $categories");

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
      },
    );
  }
}
