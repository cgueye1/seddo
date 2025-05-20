import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<SplashPage> {
  @override
  void initState() {
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
