import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({Key? key, required this.url}) : super(key: key);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;


  @override
  void initState() {
    super.initState();
    _controller =
    WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        width:100,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.4),
          borderRadius: BorderRadius.circular(50)
        ),
        padding: EdgeInsets.all(5),
        child: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Center(child:Row(
              crossAxisAlignment: CrossAxisAlignment.center,
                children: [

              Icon(Icons.arrow_back_ios_outlined),
              SizedBox(width: 5,),
              Text("Retour",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),)
            ]))

        ),

      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
