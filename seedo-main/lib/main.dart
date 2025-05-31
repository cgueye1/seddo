import 'dart:async';
import 'dart:ui';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:seddoapp/bloc/auth/auth_bloc.dart';
import 'package:seddoapp/bloc/home/home_bloc.dart';
import 'package:seddoapp/repositories/publication_repository.dart';
import 'package:seddoapp/services/AdMobService.dart';
import 'package:seddoapp/services/PushNotificationService.dart';
import 'package:seddoapp/services/api_service.dart';
import 'package:seddoapp/services/publication_service.dart';
import 'package:seddoapp/utils/HexColor.dart';
import 'package:seddoapp/utils/constant.dart';
import 'package:seddoapp/widgets/navitems.dart';

import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();


    // Initialisation Firebase
    await _initializeFirebase();

    // Initialisation des services
    await _initializeServices();

    // Initialisation des formats de date
    await _initializeDateFormatting();

    // Lancement de l'application
    runApp(MyApplication());

    // AppTrackingTransparency après le premier frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
     await _initializeAppTracking();
    });

  }, (error, stack) {
    debugPrint('Erreur non capturée: $error');
    debugPrint('Stack trace: $stack');
  });
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Erreur initialisation Firebase: $e');
    rethrow;
  }
}

Future<void> _initializeAppTracking() async {
  try {
    final status = await AppTrackingTransparency.requestTrackingAuthorization();
    debugPrint('Statut tracking: $status');
  } catch (e) {
    debugPrint('Erreur AppTrackingTransparency: $e');
  }
}
Future<void> _initializeServices() async {
  try {
    await PushNotificationService().initialize();
    // Initialize Ads with retry logic
    await _initializeAdsWithRetry();
  } catch (e) {
    debugPrint('Error initializing services: $e');
  }
}

Future<void> _initializeAdsWithRetry({int retries = 3}) async {
  for (var i = 0; i < retries; i++) {
    try {
      await AdService().initialize();
      return;
    } catch (e) {
      debugPrint('Ad initialization attempt ${i + 1} failed: $e');
      if (i < retries - 1) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }
  debugPrint('Failed to initialize ads after $retries attempts');
}
Future<void> _initializeDateFormatting() async {
  try {
    await initializeDateFormatting('fr_FR', null);
  } catch (e) {
    debugPrint("Erreur d'initialisation des formats de date: $e");
  }
}

class MyApplication extends StatelessWidget {
  final ApiService apiService = ApiService();
  late final PublicationRepository publicationRepository;

  MyApplication({super.key}) {
    publicationRepository = PublicationRepository(
      publicationService: PublicationService(apiService.dio),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: apiService),
        RepositoryProvider.value(value: publicationRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc()),
          BlocProvider(
            create: (context) => HomeBloc(context.read<PublicationRepository>()),
          ),
        ],
        child: const MyApp(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'SEDDO APP',
      theme: _buildAppTheme(),
      home: MainScreen(),
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      primaryColor: HexColor(APIConstants.primaryColorValue),
      colorScheme: ColorScheme.fromSeed(
        seedColor: HexColor(APIConstants.secondaryColorValue),
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
    );
  }
}
