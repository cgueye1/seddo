import 'package:flutter/material.dart';

import '../../models/ReservationModel.dart';
import '../../services/PhoneCallService.dart';
import '../../services/WhatsAppService.dart';

class ReservationDetailModal extends StatelessWidget {
  final ReservationModel reservation;

  const ReservationDetailModal({Key? key, required this.reservation})
    : super(key: key);

  // Extraire les initiales du nom
  String get initials {
    final nameParts = "${reservation.user.firstName} ${reservation.user.lastName}".split(' ');
    if (nameParts.length >= 2) {
      return nameParts[0][0] + nameParts[1][0];
    } else if (nameParts.isNotEmpty) {
      return nameParts[0][0];
    }
    return '';
  }
  Color _getStatusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.PENDDING:
        return const Color(0xFFFFA726); // Orange
      case ReservationStatus.ACCEPTED:
        return Colors.green;
      case ReservationStatus.REFUSED:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barre de drag en haut
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Informations de l'utilisateur avec avatar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Row(
              children: [
                // Avatar avec initiales
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0E0E0), // Gris clair
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Color(0xFF757575), // Gris foncé
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Nom et numéro de téléphone
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                       "${reservation.user.firstName} ${reservation.user.lastName}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${reservation.user.phone}",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Boutons d'appel et WhatsApp
                SizedBox(child:Container(
                    padding: EdgeInsets.only(left: 10),
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            WhatsAppService().openWhatsApp(
                              reservation.user.phone.isNotEmpty
                                  ?reservation.user.phone
                                  : reservation.user.phone,
                              message: 'Salut ! Comment ça va ?',
                            );
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  "assets/icons/actions/call.png",
                                ),
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        InkWell(
                          onTap: () {
                            // WhatsAppService().openWhatsApp(
                            //   widget.publication.telephone.isNotEmpty
                            //       ? widget.publication.telephone
                            //       : widget.publication.author!.phone.toString(),
                            //   message: 'Salut ! Comment ça va ?',
                            // );
                          },
                          child: Container(
                            width: 50,
                            height: 50,

                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  "assets/icons/actions/whatsapp.png",
                                ),
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),

                        SizedBox(width: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Détails de la réservation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                // Date de réservation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Date de réservation',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      reservation.formattedCreatedAt,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              /*  const SizedBox(height: 20),

                // Heure de réservation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Heure de réservation',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Nombre de personnes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nombre de personnes',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      numberOfPeople.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),*/

                // Statut
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Statut',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(reservation.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(reservation.status).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        reservation.status.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(reservation.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Boutons Valider/Refuser
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                // Bouton Valider
                if(reservation.status == ReservationStatus.REFUSED ||  reservation.status == ReservationStatus.PENDDING)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Action pour valider la réservation
                      Navigator.pop(context, 1);
                    },
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text(
                      'Valider',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Bouton Refuser

                if(reservation.status == ReservationStatus.ACCEPTED ||  reservation.status == ReservationStatus.PENDDING)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Action pour refuser la réservation
                      Navigator.pop(context, 2);
                    },
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: const Text(
                      'Refuser',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
/*
// Fonction pour afficher le modal
void showReservationDetailModal(
  BuildContext context, {
  required String name,
  required String phoneNumber,
  required String date,
  required String time,
  required int numberOfPeople,
  required String status,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return Padding(b
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ReservationDetailModal(
          name: name,
          phoneNumber: phoneNumber,
          date: date,
          time: time,
          numberOfPeople: numberOfPeople,
          status: status,
        ),
      );
    },
  );
}
*/