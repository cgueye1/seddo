// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seddoapp/pages/auth/login.dart';
import 'package:seddoapp/services/AuthService.dart';

class VerificationPage extends StatefulWidget {
  final String
  phoneNumber; // Nouveau paramètre pour recevoir le numéro de téléphone

  // ignore: use_super_parameters
  const VerificationPage({Key? key, required this.phoneNumber})
    : super(key: key);

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final List<String> _codeDigits = ['', '', '', ''];
  int _currentIndex = 0;
  final AuthService _authService = AuthService();
  // ignore: unused_field
  bool _isLoading = false;

  void _addDigit(String digit) {
    if (_currentIndex < 4) {
      setState(() {
        _codeDigits[_currentIndex] = digit;
        _currentIndex++;
      });
    }
  }

  void _removeDigit() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _codeDigits[_currentIndex] = '';
      });
    }
  }

  void _resendCode() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await _authService.requestOTP(widget.phoneNumber);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Code renvoyé avec succès')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du renvoi : ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _continueAfterVerification() async {
    // Vérifier que tous les chiffres sont saisis
    if (_codeDigits.every((digit) => digit.isNotEmpty)) {
      // Combiner les digits en un seul code OTP
      String otpCode = _codeDigits.join();

      try {
        setState(() {
          _isLoading = true;
        });

        // Vérifier le code OTP
        final result = await _authService.verifyOTP(
          phoneNumber: widget.phoneNumber,
          otp: otpCode,
        );

        // Redirection vers la page de connexion
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LogIn()),
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Vérification réussie')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de vérification : ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez compléter le code')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Envoyer automatiquement le code OTP lors de l'initialisation
    _resendCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Content with padding
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
                  const SizedBox(height: 20),
                  Text(
                    "Vérifier votre numéro\nde téléphone",
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Pour confirmer automatiquement votre numéro, nous allons envoyer un code par SMS. Il sera détecté automatiquement pour simplifier le processus.",
                    style: GoogleFonts.inter(
                      color: Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      4,
                      (index) => Container(
                        width: 80,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            _codeDigits[index],
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF4DB6AC),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Si le code ne s'affiche pas automatiquement, entrez-le manuellement.",
                          style: GoogleFonts.inter(
                            color: const Color.fromARGB(189, 0, 0, 0),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Text(
                        "Vous n'avez pas reçu de code ? ",
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: _resendCode,
                        child: Text(
                          "Renvoyer",
                          style: GoogleFonts.inter(
                            color: const Color(0xFF4DB6AC),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _continueAfterVerification,
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

            // Spacer to push the keypad to the bottom
            const Spacer(),

            // Keypad without padding (full width)
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
          height: 70,
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
