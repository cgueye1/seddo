// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/bloc/home/home_bloc.dart';
import 'package:seddoapp/bloc/home/home_state.dart';
import 'package:seddoapp/models/publication_model.dart';
import 'package:seddoapp/pages/details.dart';
import 'package:seddoapp/utils/constant.dart';
import 'package:seddoapp/utils/date_formatter.dart';
import 'package:seddoapp/utils/HexColor.dart';
import 'package:intl/intl.dart';

class PublicationListSection extends StatelessWidget {
  const PublicationListSection({Key? key}) : super(key: key);

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
          padding: const EdgeInsets.symmetric(vertical: 16),
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
    // Format price display
    String priceText =
        publication.price == 0
            ? "Gratuit"
            : "${NumberFormat.decimalPattern().format(publication.price)} FCFA";

    // Determine price badge color
    Color priceBadgeColor =
        publication.price == 0
            ? HexColor("#4CAF50") // Green for free
            : HexColor("#D95C18"); // Orange for paid

    return GestureDetector(
      onTap: () {
        // Navigation vers la page de détails avec la publication sélectionnée
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(publication: publication),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, right: 5),
        height: 165, // Fixed height for consistent cards
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image on the left
            ClipRRect(
              child: Container(
                margin: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                width: 130, // Fixed width for the image
                height: double.infinity,
                child:
                    publication.picture.isNotEmpty
                        ? Image.network(
                          '${APIConstants.API_BASE_URL_IMG}${publication.picture}',
                          width: double.infinity,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print("Error loading image: $error");
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 32,
                                color: Colors.grey,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                        )
                        : Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 32,
                              color: Colors.grey,
                            ),
                          ),
                        ),
              ),
            ),

            // Content section on the right
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Category badge at the top
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: HexColor("#F0DCFD"),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        publication.categorie.titre,
                        style: TextStyle(
                          color: HexColor("#7E30CE"),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        publication.titre,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Publication time
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 13,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          getTimeAgo(publication.createdDate),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Expiration date
                    Text(
                      "Expire le ${DateFormat('dd/MM/yyyy').format(DateTime.parse(publication.createdDate))}",
                      style: TextStyle(
                        fontSize: 11,
                        color: HexColor("#D95C18"),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // Price badge at the bottom right
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: priceBadgeColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          priceText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
