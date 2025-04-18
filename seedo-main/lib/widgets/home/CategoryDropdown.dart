// ignore_for_file: deprecated_member_use, unnecessary_to_list_in_spreads, file_names
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/utils/constant.dart';
import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_event.dart';
import '../../bloc/home/home_state.dart';

class CategoryDropdown extends StatelessWidget {
  const CategoryDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen:
          (previous, current) =>
              previous.categories != current.categories ||
              previous.selectedCategory != current.selectedCategory ||
              previous.subcategories != current.subcategories ||
              previous.selectedSubcategory != current.selectedSubcategory,
      builder: (context, state) {
        if (state.categories.isEmpty) {
          return const SizedBox.shrink();
        }

        final parentCategories =
            state.categories
                .where((category) => category.parentCategorie == null)
                .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Catégories parentes (horizontales)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    // Bouton "Tout"
                    _buildCategoryItem(
                      context: context,
                      label: "Tout",
                      isSelected: state.selectedCategory == null,
                      onTap: () {
                        context.read<HomeBloc>().add(
                          const CategoryChanged(category: null),
                        );
                      },
                    ),
                    // Catégories parentes
                    ...parentCategories.map((category) {
                      return _buildCategoryItem(
                        context: context,
                        label: category.titre,
                        isSelected: state.selectedCategory?.id == category.id,
                        onTap: () {
                          context.read<HomeBloc>().add(
                            CategoryChanged(category: category),
                          );
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            // Sous-catégories (si une catégorie est sélectionnée)
            if (state.selectedCategory != null)
              _buildSubcategoriesSection(context, state),
          ],
        );
      },
    );
  }

  Widget _buildCategoryItem({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? const Color.fromARGB(222, 213, 72, 1)
                    : const Color.fromARGB(255, 233, 233, 233),
            borderRadius: BorderRadius.circular(8),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubcategoriesSection(BuildContext context, HomeState state) {
    final selectedCategoryId = state.selectedCategory?.id;
    final subcategories =
        selectedCategoryId != null
            ? state.subcategories[selectedCategoryId] ?? []
            : [];
    final selectedSubcategory = state.selectedSubcategory;

    if (subcategories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              subcategories.map((subcategory) {
                final isSelected = selectedSubcategory?.id == subcategory.id;

                return Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 10.0),
                  child: GestureDetector(
                    onTap: () {
                      final isCurrentlySelected =
                          selectedSubcategory?.id == subcategory.id;

                      // Envoyer l'événement de filtrage par sous-catégorie
                      context.read<HomeBloc>().add(
                        FilterPublicationsBySubcategory(
                          isCurrentlySelected ? null : subcategory.id,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Modifier le conteneur pour utiliser un fond orange lorsqu'il est sélectionné
                          Container(
                            width: 65,
                            height: 69,
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? const Color.fromARGB(
                                        222,
                                        213,
                                        72,
                                        1,
                                      ) // Fond orange pour les sous-catégories sélectionnées
                                      : Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: _buildSubcategoryIcon(subcategory),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 80,
                            child: Text(
                              subcategory.titre,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color:
                                    isSelected
                                        ? const Color.fromARGB(222, 213, 72, 1)
                                        : Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildSubcategoryIcon(dynamic subcategory) {
    if (subcategory.icon != null && subcategory.icon.isNotEmpty) {
      final String iconUrl = APIConstants.API_BASE_URL_IMG + subcategory.icon;
      final String extension = iconUrl.split('.').last.toLowerCase();

      if (extension == 'svg') {
        return SvgPicture.network(
          iconUrl,
          width: 40,
          height: 40,
          placeholderBuilder:
              (BuildContext context) =>
                  CircularProgressIndicator(color: Colors.orange.shade700),
        );
      } else {
        return Image.network(
          iconUrl,
          width: 40,
          height: 40,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.category,
              size: 36,
              color: Colors.orange.shade700,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return CircularProgressIndicator(
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
              color: Colors.orange.shade700,
            );
          },
        );
      }
    } else {
      return Icon(Icons.category, size: 36, color: Colors.orange.shade700);
    }
  }
}
