import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/bloc/home/home_bloc.dart';
import 'package:seddoapp/bloc/home/home_event.dart';
import 'package:seddoapp/bloc/home/home_state.dart';
import 'package:seddoapp/models/publication_model.dart';
import 'package:seddoapp/pages/details.dart';
import 'package:seddoapp/pages/publie.dart';
import 'package:seddoapp/utils/HexColor.dart';
import 'package:seddoapp/utils/constant.dart';
import 'package:seddoapp/utils/date_formatter.dart';
import 'package:seddoapp/widgets/CustomFloatingButton.dart';
import 'package:seddoapp/widgets/home/SearchBar.dart';
import 'package:intl/intl.dart';

class Publicationslist extends StatefulWidget {
  final int authorId; // Ajoutez l'ID de l'auteur

  const Publicationslist({super.key, required this.authorId});

  @override
  State<Publicationslist> createState() => _PublicationslistState();
}

class _PublicationslistState extends State<Publicationslist> {
  @override
  void initState() {
    super.initState();
    // Charger les publications de l'auteur
    _loadAuthorPublications();
  }

  void _loadAuthorPublications() {
    context.read<HomeBloc>().add(
      LoadAuthorPublications(authorId: widget.authorId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.only(top: 50, left: 10, right: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mes Publications',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
               // const SizedBox(height: 16),
                // Optionnel: gardez la barre de recherche si vous voulez filtrer
             //   const SearchBars(),
                // const SizedBox(height: 16),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      _loadAuthorPublications();
                    },
                    child: _buildAuthorPublicationsList(state),
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
        onPressed: () async{
          final categories = context.read<HomeBloc>().state.categories;
          final user = context.read<HomeBloc>().state.currentUser;
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PubliePage(
                categories: categories,
                idUser: user!.id,
              ),
            ),
          );

          // Rafraîchir les publications au retour
          _loadAuthorPublications();
        },
        label: '',
        backgroundColor: HexColor("#D95C18"),
        elevation: 4.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildAuthorPublicationsList(HomeState state) {
    if (state.isLoadingAuthorPublications) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.authorPublications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucune publication trouvée',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Commencez par publier votre première annonce',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: state.authorPublications.length,
      itemBuilder: (context, index) {
        final publication = state.authorPublications[index];

        return Dismissible(
          key: Key(publication.id.toString()), // Assure-toi que `id` est unique
          direction: DismissDirection.endToStart, // Slide vers la gauche
          background: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerRight,
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            // Optionnel : demander confirmation
            return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Confirmation"),
                content: const Text("Voulez-vous vraiment supprimer cette publication ?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("Annuler"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) {
            // 🔥 Ajouter ici l’appel pour supprimer la publication
            context.read<HomeBloc>().add(DeletePublication(publication.id));
            // Afficher feedback visuel
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Publication supprimée.")),
            );
          },
          child: AuthorPublicationItem(publication: publication),
        );
      },
    );

  }
}

// Widget spécialisé pour les publications de l'auteur avec des options supplémentaires
class AuthorPublicationItem extends StatelessWidget {
  final Publication publication;

  const AuthorPublicationItem({Key? key, required this.publication})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10, right: 5),
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
      child: Column(
        children: [
          // Contenu principal de la publication avec le même design que PublicationItem
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailPage(publication: publication),
                ),
              );
            },
            child: _buildPublicationContent(),
          ),

          // Barre d'actions pour l'auteur
          // _buildAuthorActions(context),
        ],
      ),
    );
  }

  Widget _buildPublicationContent() {
    // Format price display - même logique que PublicationItem
    String priceText =
        publication.price == 0
            ? "Gratuit"
            : "${NumberFormat.decimalPattern().format(publication.price)} FCFA";

    // Determine price badge color - même logique que PublicationItem
    Color priceBadgeColor =
        publication.price == 0
            ? HexColor("#4CAF50") // Green for free
            : HexColor("#D95C18"); // Orange for paid

    return Container(
      height: 165, // Fixed height pour correspondre à PublicationItem
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image - même design que PublicationItem
          ClipRRect(
            child: Container(
              margin: EdgeInsets.only(left: 10, bottom: 10, top: 10),
              width: 130, // Fixed width pour correspondre à PublicationItem
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
                                            loadingProgress.expectedTotalBytes!
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

          // Content section - même design que PublicationItem
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Category badge at the top - même design que PublicationItem
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

                  // Title - même design que PublicationItem
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

                  // Publication time - même design que PublicationItem
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

                  // Expiration date - même design que PublicationItem
                  Text(
                    "Expire le ${DateFormat('dd/MM/yyyy').format(DateTime.parse(publication.createdDate).add(Duration(days: publication.days)))}",
                    style: TextStyle(
                      fontSize: 11,
                      color: HexColor("#D95C18"),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // Price badge at the bottom right - même design que PublicationItem
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
    );
  }

  Widget _buildAuthorActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.edit,
            label: 'Modifier',
            onTap: () {
              // Implémenter la modification
              _editPublication(context);
            },
          ),
          _buildActionButton(
            icon:
                publication.available ? Icons.visibility_off : Icons.visibility,
            label: publication.available ? 'Masquer' : 'Publier',
            onTap: () {
              // Implémenter le toggle de visibilité
              _toggleVisibility(context);
            },
          ),
          _buildActionButton(
            icon: Icons.delete,
            label: 'Supprimer',
            color: Colors.red,
            onTap: () {
              // Implémenter la suppression
              _deletePublication(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color ?? Colors.grey[700]),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color ?? Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  void _editPublication(BuildContext context) {
    // Naviguer vers la page d'édition
    // Vous devrez créer une page d'édition ou réutiliser PubliePage en mode édition
    print('Modifier publication: ${publication.id}');
  }

  void _toggleVisibility(BuildContext context) {
    // Implémenter le toggle de visibilité
    print('Toggle visibilité: ${publication.id}');
  }

  void _deletePublication(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer la publication'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer cette publication ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Implémenter la suppression
                print('Supprimer publication: ${publication.id}');
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}
