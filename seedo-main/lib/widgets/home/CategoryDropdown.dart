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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Text(
                'Catégories',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 8),

            // Catégories tabs avec indicateur
            DefaultTabController(
              length: parentCategories.length + 1, // +1 pour "Tout"
              child: Column(
                children: [
                  TabBar(
                    isScrollable: true,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    labelPadding: EdgeInsets.symmetric(horizontal: 16.0),
                    indicatorColor: Color(0xFFD54801),
                    indicatorWeight: 1.0,
                    dividerColor: Colors.grey[300],
                    dividerHeight: 1.0,
                    labelColor: Color(0xFFD54801),
                    unselectedLabelColor: const Color.fromARGB(163, 0, 0, 0),
                    labelStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    tabAlignment: TabAlignment.start, // Alignement à gauche
                    onTap: (index) {
                      if (index == 0) {
                        // "Tout" sélectionné
                        context.read<HomeBloc>().add(
                          const ResetInitialPublicationsFlag(),
                        );
                        context.read<HomeBloc>().add(
                          const CategoryChanged(category: null),
                        );
                      } else {
                        // Catégorie parente sélectionnée
                        context.read<HomeBloc>().add(
                          CategoryChanged(
                            category: parentCategories[index - 1],
                          ),
                        );
                      }
                    },
                    tabs: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text("Tout"),
                        ),
                      ),
                      ...parentCategories
                          .map(
                            (category) => Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                child: Text(category.titre),
                              ),
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ],
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

  Widget _buildSubcategoriesSection(BuildContext context, HomeState state) {
    final selectedCategoryId = state.selectedCategory?.id;
    final subcategories =
        selectedCategoryId != null
            ? state.subcategories[selectedCategoryId] ?? []
            : [];

    if (subcategories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              subcategories.map((subcategory) {
                final isSelected =
                    state.selectedSubcategoryId == subcategory.id;

                return Container(
                  width: 115,
                  margin: const EdgeInsets.only(right: 12.0),
                  child: GestureDetector(
                    onTap: () {
                      context.read<HomeBloc>().add(
                        FilterPublicationsBySubcategory(subcategory.id),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 124,
                          height: 74,
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? const Color.fromARGB(15, 213, 72, 1)
                                    : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                _buildSubcategoryIcon(subcategory),
                                Text(
                                  subcategory.titre,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isSelected
                                            ? const Color.fromARGB(
                                              222,
                                              213,
                                              72,
                                              1,
                                            )
                                            : Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
          width: 30,
          height: 30,
          placeholderBuilder:
              (BuildContext context) => CircularProgressIndicator(
                strokeWidth: 2.0,
                color: Colors.orange.shade700,
              ),
        );
      } else {
        return Image.network(
          iconUrl,
          width: 30,
          height: 30,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.restaurant,
              size: 36,
              color: Colors.orange.shade700,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                  color: Colors.orange.shade700,
                ),
              ),
            );
          },
        );
      }
    } else {
      return Icon(Icons.restaurant, size: 36, color: Colors.orange.shade700);
    }
  }
}
