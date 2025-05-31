import 'package:flutter/material.dart';

import '../../services/PushNotificationService.dart';
import '../../services/SharedPreferencesService.dart';

class SplashPage extends StatefulWidget {
  final bool? off;
  const SplashPage({super.key, this.off});

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<SplashPage> {
  final SharedPreferencesService _prefsService = SharedPreferencesService();

  Future<void> init() async {

    final bool? notificationsEnabled = await _prefsService.getBoolValue('notifications');

    if (notificationsEnabled == true) {
      await PushNotificationService().subscribeToTopic("seddo");
    }

  }
  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            bottom: 20,
            top: 20,
            left: 20,
            right: 20,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               widget. off!=null &&    widget.off! ? Center(child: CircularProgressIndicator()):
                Center(child: Image.asset('assets/images/seddo_.png')),
                // Center(
                //   child: Text(
                //     'SEDDO',
                //     style: TextStyle(
                //       fontSize: 100,
                //       fontWeight: FontWeight.w500,
                //       color: HexColor('#D95C18'),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
