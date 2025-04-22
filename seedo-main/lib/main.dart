import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
// Blocs
import 'package:seddoapp/bloc/auth/auth_bloc.dart';
import 'package:seddoapp/bloc/home/home_bloc.dart';
import 'package:seddoapp/pages/auth/login.dart';

// Pages
import 'package:seddoapp/pages/home.dart';
// import 'package:seddoapp/pages/transit/TransportCommun.dart';

// Repositories & Services
import 'package:seddoapp/repositories/publication_repository.dart';
import 'package:seddoapp/services/AdMobService.dart';
import 'package:seddoapp/services/PushNotificationService.dart';
import 'package:seddoapp/services/api_service.dart';
import 'package:seddoapp/services/publication_service.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // PushNotificationService().initialize();
  await AdService().initialize();

  // Initialisation des formats de date
  try {
    await initializeDateFormatting('fr_FR', null);
  } catch (e) {
    debugPrint("Erreur d'initialisation des formats de date: $e");
  }

  // Initialisation des dépendances
  final apiService = ApiService();
  final publicationRepository = PublicationRepository(
    publicationService: PublicationService(apiService.dio),
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: apiService),
        RepositoryProvider.value(value: publicationRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc()),
          BlocProvider(
            create:
                (context) => HomeBloc(context.read<PublicationRepository>()),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SEDDO APP',
      theme: ThemeData(
        primaryColor: Color(
          0xFFE65100,
        ), // orange foncé (teinte custom, style deep orange 900)
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFE65100),
          brightness: Brightness.light,
        ),
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Poppins'),
          displayMedium: TextStyle(fontFamily: 'Poppins'),
          displaySmall: TextStyle(fontFamily: 'Poppins'),
          headlineLarge: TextStyle(fontFamily: 'Poppins'),
          headlineMedium: TextStyle(fontFamily: 'Poppins'),
          headlineSmall: TextStyle(fontFamily: 'Poppins'),
          titleLarge: TextStyle(fontFamily: 'Poppins'),
          titleMedium: TextStyle(fontFamily: 'Poppins'),
          titleSmall: TextStyle(fontFamily: 'Poppins'),
          bodyLarge: TextStyle(fontFamily: 'Poppins'),
          bodyMedium: TextStyle(fontFamily: 'Poppins'),
          bodySmall: TextStyle(fontFamily: 'Poppins'),
          labelLarge: TextStyle(fontFamily: 'Poppins'),
          labelMedium: TextStyle(fontFamily: 'Poppins'),
          labelSmall: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
      home: //HomePage
          const HomePage(),
    );
  }
}
