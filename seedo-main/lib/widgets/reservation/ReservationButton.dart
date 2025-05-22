// widgets/reservation/reservation_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/bloc/reservation/reservation_bloc.dart';
import 'package:seddoapp/bloc/reservation/reservation_event.dart';
import 'package:seddoapp/bloc/reservation/reservation_state.dart';
import 'package:seddoapp/models/publication_model.dart';
import 'package:seddoapp/utils/HexColor.dart';

class ReservationButton extends StatefulWidget {
  final Publication publication;
  final int currentUserId;

  const ReservationButton({
    Key? key,
    required this.publication,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _ReservationButtonState createState() => _ReservationButtonState();
}

class _ReservationButtonState extends State<ReservationButton> {
  bool _hasReserved = false;

  @override
  void initState() {
    super.initState();
    _checkIfUserHasReserved();
  }

  void _checkIfUserHasReserved() {
    context.read<ReservationBloc>().add(
      CheckUserReservationEvent(
        userId: widget.currentUserId,
        publicationId: widget.publication.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReservationBloc, ReservationState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _hasReserved = true;
          });
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
        }
        if (state.hasReserved != null) {
          setState(() {
            _hasReserved = state.hasReserved!;
          });
        }
      },
      builder: (context, state) {
        // Ne pas afficher le bouton si c'est la publication de l'utilisateur actuel
        // if (widget.publication.userId == widget.currentUserId) {
        //   return const SizedBox.shrink();
        // }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton(
            onPressed:
                _hasReserved || state.isCreating
                    ? null
                    : () {
                      context.read<ReservationBloc>().add(
                        CreateReservationEvent(
                          userId: widget.currentUserId,
                          publicationId: widget.publication.id,
                        ),
                      );
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: _hasReserved ? Colors.grey : HexColor("#D95C18"),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child:
                state.isCreating
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : Text(
                      _hasReserved ? 'Déjà réservé' : 'Réserver',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        );
      },
    );
  }
}
