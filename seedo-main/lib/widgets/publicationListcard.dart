import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/bloc/home/home_bloc.dart';
import 'package:seddoapp/bloc/home/home_state.dart';
import 'package:seddoapp/models/publication_model.dart';
import 'package:seddoapp/utils/constant.dart';
import 'package:seddoapp/utils/date_formatter.dart';
import 'package:seddoapp/utils/HexColor.dart';
import 'package:intl/intl.dart';

class PublicationListCard extends StatelessWidget {
  const PublicationListCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state.isLoadingPublications) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.publications.isEmpty) {
          return const Center(child: Text('Aucune publication disponible'));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(right: 20),
          itemCount: state.publications.length,
          itemBuilder: (context, index) {
            final publication = state.publications[index];
            return PublicationItem(publication: publication);
          },
        );
      },
    );
  }
}

class PublicationItem extends StatelessWidget {
  final Publication publication;

  const PublicationItem({Key? key, required this.publication})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to publication details
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => MealDetailPage(publication: publication, currentPosition: currentPosition),
        //   ),
        // );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child:
                  publication.picture.isNotEmpty
                      ? Image.network(
                        '${APIConstants.API_BASE_URL_IMG}${publication.picture}',
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 180,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image_not_supported, size: 40),
                            ),
                          );
                        },
                      )
                      : Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 40),
                        ),
                      ),
            ),

            // Category badge
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: HexColor("#F0DCFD"),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Alimentation",
                  style: TextStyle(
                    color: HexColor("#7E30CE"),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Title and Price row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      publication.titre,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          publication.price == 0
                              ? HexColor("#4CAF50")
                              : HexColor("#D95C18"),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      publication.price == 0
                          ? "Gratuit"
                          : "${NumberFormat.decimalPattern().format(publication.price)} FCFA",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Published time
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    "Publié il y a ${getTimeAgo(publication.createdDate)}",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Expiration date
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4, bottom: 16),
              child: Text(
                "Expire le ${getTimeAgo(publication.createdDate)}",
                style: TextStyle(
                  fontSize: 16,
                  color: HexColor("#D95C18"),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
