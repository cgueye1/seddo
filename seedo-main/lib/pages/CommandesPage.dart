// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:seddoapp/utils/HexColor.dart';

class CommandesPage extends StatefulWidget {
  const CommandesPage({super.key});

  @override
  State<CommandesPage> createState() => _CommandesPageState();
}

class _CommandesPageState extends State<CommandesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.index = 0;

    // Ajouter un écouteur pour mettre à jour l'interface quand l'onglet change
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = HexColor('#D95C18');

    return Scaffold(
      backgroundColor: HexColor('#F1F2F6'),
      appBar: AppBar(
        backgroundColor: HexColor('#F1F2F6'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Mes commandes',
          style: TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 0.5),
            child: TabBar(
              controller: _tabController,
              indicatorColor: primaryColor,
              indicatorWeight: 3,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: [
                _buildTab("En attente", "1", 0),
                _buildTab("Validée", "1", 1),
                _buildTab("Refusée", "1", 2),
              ],
            ),
          ),
          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: En attente
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _buildCommande(),
                ),
                // Tab 2: Validées
                _buildEmptyState(
                  "Validée",
                  "Les publications commandes apparaîtront ici automatiquement.",
                  "assets/images/empty1.png",
                ),
                // Tab 3: Refusées
                _buildEmptyState(
                  "Refusée",
                  "Aucune commande n'a été refusée récemment.",
                  "assets/images/empty2.png", // Image pour refusée (avec l'icône X)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Méthode pour construire un onglet avec style conditionnel
  Widget _buildTab(String text, String count, int index) {
    final bool isSelected = _tabController.index == index;
    Color primaryColor = HexColor('#D95C18');

    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? primaryColor.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              count,
              style: TextStyle(
                color: isSelected ? primaryColor : Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String status, String message, String imagePath) {
    final Color accentColor = HexColor('#D95C18');

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom illustration from assets
            Image.asset(
              imagePath,
              width: 250,
              height: 250,
              // Ne pas définir de couleur pour préserver les couleurs originales
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Aucune commande ${status.toLowerCase()}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommande() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Image.asset(
              'assets/images/payla.jpeg',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // Contenu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                const Text(
                  'Paëla',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 12),

                // Publié il y a 45 mins et distance
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey, size: 20),
                    const SizedBox(width: 5),
                    const Text(
                      'Publié il y a 45 mins',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(width: 20),
                    const Icon(
                      Icons.directions_walk,
                      color: Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      '4.0 km',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Point de départ
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            color: HexColor('#D95C18'),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          height: 40,
                          width: 2,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Rue 47, Pikine Ouest',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Point de départ',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Point d'arrivée
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: HexColor('#D95C18'),
                          width: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Dakar Sacré Cœur',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Point d\'arrivée',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
