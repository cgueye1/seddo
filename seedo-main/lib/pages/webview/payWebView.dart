// ignore_for_file: unused_field

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayWebView extends StatefulWidget {
  final String url;

  PayWebView({Key? key, required this.url}) : super(key: key);

  @override
  _PayWebViewState createState() => _PayWebViewState();
}

class _PayWebViewState extends State<PayWebView> with WidgetsBindingObserver {
  late Timer _timer;
  bool _loading = true;
  late final WebViewController controller;
  int intersIndex = 0;
  Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  void initState() {
    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                // Update loading bar (if necessary).
              },
              onPageStarted: (String url) {},
              onPageFinished: (String url) {
                setState(() {
                  _loading = false;
                });
              },
              onWebResourceError: (WebResourceError error) {
                // Gérer les erreurs de chargement
                if (error.errorCode == 404) {
                  Navigator.of(
                    context,
                  ).pop(false); // Retourne false si "not found"
                } else {
                  print("Erreur: ${error.description}");
                }
              },
              onNavigationRequest: (NavigationRequest request) async {
                if (request.url == "https://wakana.online:8085/ipn/success") {
                  Navigator.of(context).pop(true); // Paiement réussi
                  return NavigationDecision.prevent;
                } else if (request.url ==
                    "https://wakana.online:8085/ipn/cancel") {
                  Navigator.of(context).pop(false); // Paiement annulé
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.url));

    super.initState();

    _timer = Timer.periodic(Duration(minutes: 30), (timer) {
      // Logique à exécuter périodiquement
    });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // Logique à exécuter lorsque l'application est mise en pause
    } else if (state == AppLifecycleState.resumed) {
      // Logique à exécuter lorsque l'application est reprise
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          10.0,
        ), // Modifier cette valeur selon vos besoins
        child: AppBar(automaticallyImplyLeading: false, elevation: 0),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (_loading) Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
