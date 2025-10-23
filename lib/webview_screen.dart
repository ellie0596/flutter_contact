import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({Key? key}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  double progress = 0;
  String? errorMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initMobileAds();
    _initWebView();
  }

  Future<void> _initMobileAds() async {
    await MobileAds.instance.initialize();
  }

  Future<void> _initWebView() async {
    _controller = WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted);

    // 2. Enable third-party cookies for Android.
    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewCookieManager cookieManager = AndroidWebViewCookieManager(const PlatformWebViewCookieManagerCreationParams());
      await cookieManager.setAcceptThirdPartyCookies(_controller.platform as AndroidWebViewController, true);
    }

    // Register WebView with MobileAds for ad integration
    await MobileAds.instance.registerWebView(_controller);

    // Load the URL
    await _controller.loadRequest(Uri.parse("https://google.github.io/webview-ads/test/"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebView - localhost'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () async {
              if (await _controller.canGoBack()) {
                _controller.goBack();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () async {
              if (await _controller.canGoForward()) {
                _controller.goForward();
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading && progress < 1.0)
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          if (errorMessage != null)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load page',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        _controller.reload();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller.reload();
        },
        tooltip: 'Reload',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
