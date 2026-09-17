---
name: webview-flutter-web
description: Set up and use the webview_flutter_web plugin to render HTML content and external URLs using WebViewController and WebViewWidget on Flutter Web.
---

# Setting Up and Using webview_flutter_web

`webview_flutter_web` is the Web platform implementation of the [`webview_flutter`](https://pub.dev/packages/webview_flutter) plugin, rendering web content inside an HTML `<iframe>`.

## 1. Installation and Setup

Because `webview_flutter_web` is **not** an endorsed default implementation of `webview_flutter` yet, you **must** add both `webview_flutter` and `webview_flutter_web` explicitly to your `pubspec.yaml`:

```yaml
dependencies:
  webview_flutter: ^4.14.1
  webview_flutter_web: ^0.2.3+4
```

## 2. Platform-Specific Configuration & Limitations

### Web Capabilities and Limitations

`webview_flutter_web` uses an HTML `<iframe>` element under the hood and currently supports a subset of the `webview_flutter` API:
- **Supported**:
  - `WebViewController.loadRequest` (loads a URL into the iframe)
  - `WebViewController.loadHtmlString` (renders raw HTML content without `baseUrl` support)
- **Unsupported**:
  - JavaScript execution (`runJavaScript`, `runJavaScriptReturningResult`) and `JavaScriptChannel`s
  - Navigation interception (`NavigationDelegate` callbacks such as `onNavigationRequest`, `onPageStarted`, `onPageFinished`)
  - Cookie management (`WebViewCookieManager`) and cache clearing
- **Cross-Origin Restrictions (`X-Frame-Options` / CSP)**: Websites that send `X-Frame-Options: DENY` or `SAMEORIGIN` headers (or restrictive `frame-ancestors` Content Security Policies) will refuse to load inside an `<iframe>` on the web.

## 3. Usage and API Examples

### Loading a URL or HTML String on Flutter Web

Once `webview_flutter_web` is listed in `pubspec.yaml`, Flutter automatically registers `WebWebViewPlatform` on web builds. Use `WebViewController` and `WebViewWidget` from `package:webview_flutter`:

```dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebIframeExample extends StatefulWidget {
  const WebIframeExample({super.key});

  @override
  State<WebIframeExample> createState() => _WebIframeExampleState();
}

class _WebIframeExampleState extends State<WebIframeExample> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..loadRequest(Uri.parse('https://flutter.dev'));
  }

  Future<void> _loadInlineHtml() async {
    await _controller.loadHtmlString('''
      <!DOCTYPE html>
      <html>
        <head><title>Embedded HTML</title></head>
        <body style="font-family: sans-serif; padding: 20px;">
          <h1>Hello from webview_flutter_web!</h1>
        </body>
      </html>
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Web WebView'),
        actions: <Widget>[
          TextButton(
            onPressed: _loadInlineHtml,
            child: const Text('Load HTML'),
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
```
