import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({Key? key}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late InAppWebViewController _webViewController;
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebView - localhost:3000'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri("http://localhost:3000"),
            ),
            initialSettings: InAppWebViewSettings(
              useShouldOverrideUrlLoading: true,
              mediaPlaybackRequiresUserGesture: false,
              javaScriptEnabled: true,
              // iOS specific settings for localhost
              allowsInlineMediaPlayback: true,
              // Android specific settings for localhost
              mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
              domStorageEnabled: true,
              databaseEnabled: true,
              clearSessionCache: true,
              clearCache: true,
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onLoadStart: (controller, url) {
              print("Started loading: $url");
            },
            onLoadStop: (controller, url) async {
              print("Finished loading: $url");
            },
            onProgressChanged: (controller, progress) {
              setState(() {
                this.progress = progress / 100;
              });
            },
            onReceivedError: (controller, request, error) {
              print("Error: ${error.description}");
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to load: ${error.description}'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            onConsoleMessage: (controller, consoleMessage) {
              print("Console message: ${consoleMessage.message}");
            },
          ),
          progress < 1.0
              ? LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                )
              : Container(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _webViewController.reload();
        },
        child: const Icon(Icons.refresh),
        tooltip: 'Reload',
      ),
    );
  }
}