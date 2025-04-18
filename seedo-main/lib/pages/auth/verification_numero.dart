// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seddoapp/services/AuthService.dart';
import 'verification.dart';

class PhoneNumberPage extends StatefulWidget {
  const PhoneNumberPage({super.key});

  @override
  State<PhoneNumberPage> createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  final TextEditingController _phoneController = TextEditingController();
  final String _countryCode = '+221'; // Code par défaut pour le Sénégal
  final AuthService _authService =
      AuthService(); // Ajout du service d'authentification
  // ignore: unused_field
  bool _isLoading = false;

  void _addDigit(String digit) {
    _phoneController.text = _phoneController.text + digit;
  }

  void _removeDigit() {
    if (_phoneController.text.isNotEmpty) {
      _phoneController.text = _phoneController.text.substring(
        0,
        _phoneController.text.length - 1,
      );
    }
  }

  void _continueToVerification() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un numéro de téléphone')),
      );
      return;
    }

    // Construire le numéro de téléphone complet
    String fullPhoneNumber = '$_countryCode${_phoneController.text}';

    try {
      setState(() {
        _isLoading = true;
      });

      // Demander l'envoi du code OTP
      await _authService.requestOTP(fullPhoneNumber);

      // Navigation vers la page de vérification en passant le numéro de téléphone
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationPage(phoneNumber: fullPhoneNumber),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la demande OTP : ${e.toString()}'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 30),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Quel est votre numéro\nde téléphone ?",
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Si vous appuyez sur \"Continuer\", un code de confirmation vous sera envoyé pour finaliser votre inscription sur l'application SEDDO.",
                    style: GoogleFonts.inter(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Numéro de téléphone",
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFD95C18),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 90,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1.5,
                              ),
                            ),
                          ),
                          child: Text(
                            _countryCode,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType:
                                TextInputType
                                    .none, // Désactive le clavier par défaut
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              hintText: "7XXXXXXXX",
                              hintStyle: GoogleFonts.inter(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _continueToVerification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD95C18),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Continuer",
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Spacer(),
            // Clavier numérique
            Container(
              width: double.infinity,
              color: const Color.fromARGB(255, 0, 0, 0), // Fond noir
              child: Column(
                children: [
                  // Première Row
                  Container(
                    color: Colors.white, // Fond blanc
                    child: SizedBox(
                      width: double.infinity,
                      height: 60, // Hauteur de la Row
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly, // Espacement égal
                        children: [
                          _buildKeypadButton('1', ''),
                          _buildKeypadButton('2', 'ABC'),
                          _buildKeypadButton('3', 'DEF'),
                        ],
                      ),
                    ),
                  ),

                  // Deuxième Row
                  Container(
                    color: Colors.white,
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildKeypadButton('4', 'GHI'),
                          _buildKeypadButton('5', 'JKL'),
                          _buildKeypadButton('6', 'MNO'),
                        ],
                      ),
                    ),
                  ),

                  // Troisième Row
                  Container(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildKeypadButton('7', 'PQRS'),
                          _buildKeypadButton('8', 'TUV'),
                          _buildKeypadButton('9', 'WXYZ'),
                        ],
                      ),
                    ),
                  ),

                  // Quatrième Row
                  Container(
                    color: Colors.white,
                    child: SizedBox(
                      width: double.infinity,
                      height: 70,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(child: Container()), // Espace vide à gauche
                          _buildKeypadButton('0', ''),
                          Expanded(
                            child: GestureDetector(
                              onTap:
                                  _removeDigit, // Fonction pour supprimer un chiffre
                              child: Container(
                                height: 60,
                                color: Colors.transparent,
                                child: const Center(
                                  child: Icon(
                                    Icons.backspace_outlined,
                                    size: 24,
                                  ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String number, String letters) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _addDigit(number),
        child: Container(
          height: 60,
          color: Colors.transparent,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  number,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (letters.isNotEmpty)
                  Text(
                    letters,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
