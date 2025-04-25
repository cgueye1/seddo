import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:seddoapp/utils/HexColor.dart';

class UpdateRequiredScreen extends StatelessWidget {
  final String androidLink;
  final String iosLink;

  const UpdateRequiredScreen({
    super.key,
    required this.androidLink,
    required this.iosLink,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
              'assets/images/seddo_.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 24),
              const Text(
                "Une mise à jour est requise pour continuer à utiliser l'application.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: Icon(Platform.isAndroid ? Icons.android : Icons.apple),
                label: const Text("Mettre à jour"),
                onPressed: () async {
                  final url = Platform.isAndroid ? androidLink : iosLink;
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Impossible d'ouvrir le lien")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor('#007bff'),
                  foregroundColor: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
