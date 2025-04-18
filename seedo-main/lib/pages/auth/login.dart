// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seddoapp/bloc/auth/auth_bloc.dart';
import 'package:seddoapp/bloc/auth/auth_event.dart';
import 'package:seddoapp/bloc/auth/auth_state.dart';
import 'package:seddoapp/pages/auth/signup.dart';
import 'package:seddoapp/pages/home.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _loginStatus;
  bool _loginSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleForgotPassword() {
    final email = _emailController.text;
    if (email.isNotEmpty) {
      context.read<AuthBloc>().add(AuthForgotPasswordEvent(email: email));
    } else {
      setState(() {
        _loginStatus = 'Veuillez entrer votre email';
        _loginSuccess = false;
      });
    }
  }

  void _handleLogin() {
    final email = _emailController.text;
    final password = _passwordController.text;

    // Vérifier si les champs sont vides
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _loginStatus = 'Veuillez remplir tous les champs';
        _loginSuccess = false;
      });
      return;
    }

    // Déclencher l'événement de connexion
    context.read<AuthBloc>().add(
      AuthLoginEvent(email: email, password: password),
    );
  }

  void _handleGoogleSignIn() {
    // À implémenter avec un événement spécifique
    debugPrint("Connexion avec Google");
  }

  void _handleFacebookSignIn() {
    // À implémenter avec un événement spécifique
    debugPrint("Connexion avec Facebook");
  }

  void _handleAppleSignIn() {
    // À implémenter avec un événement spécifique
    debugPrint("Connexion avec Apple");
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticatedState) {
            setState(() {
              _loginStatus = state.message;
              _loginSuccess = true;
            });

            // Navigation vers la page d'accueil après un court délai
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.pushReplacement(
                // ignore: use_build_context_synchronously
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            });
          } else if (state is AuthErrorState) {
            setState(() {
              _loginStatus = state.message;
              _loginSuccess = false;
            });
          } else if (state is AuthForgotPasswordSentState) {
            setState(() {
              _loginStatus =
                  'Instructions de récupération envoyées à ${state.email}';
              _loginSuccess = true;
            });
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  Center(
                    child: Text(
                      "Connexion",
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  Text(
                    "Email",
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: "user_admin@gmail.com",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Mot de passe",
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: "*********",
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _handleForgotPassword,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(top: 10),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        "Mot de passe oublié ?",
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          state is AuthLoadingState ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD95C18),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child:
                          state is AuthLoadingState
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : Text(
                                "Connexion",
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      "Ou se connecter avec",
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _socialLoginButton(
                        onPressed: _handleGoogleSignIn,
                        child: Image.asset(
                          'assets/images/googlelogo.png',
                          height: 24,
                        ),
                      ),
                      _socialLoginButton(
                        onPressed: _handleFacebookSignIn,
                        child: Image.asset(
                          'assets/images/facebooklogo.png',
                          height: 24,
                        ),
                      ),
                      _socialLoginButton(
                        onPressed: _handleAppleSignIn,
                        child: Image.asset(
                          'assets/images/applelogo.png',
                          height: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Vous n'avez pas de compte ? ",
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: _navigateToSignUp,
                        child: Text(
                          "S'inscrire",
                          style: GoogleFonts.inter(
                            color: const Color(0xFF4DB6AC),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_loginStatus != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Icon(
                            _loginSuccess ? Icons.check_circle : Icons.error,
                            color: _loginSuccess ? Colors.green : Colors.black,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _loginStatus!,
                              style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _socialLoginButton({
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return SizedBox(
      width: 100,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: const BorderSide(color: Colors.grey, width: 1),
        ),
        child: Center(child: child),
      ),
    );
  }
}
