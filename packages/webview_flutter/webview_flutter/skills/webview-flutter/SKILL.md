---
name: webview-flutter
description: Set up and use the webview_flutter plugin with WebViewController and WebViewWidget to embed system web views on Android, iOS, and macOS, including platform-specific creation parameters.
---

# Setting Up and Using webview_flutter

`webview_flutter` is a Flutter plugin that provides a `WebViewWidget` backed by native system web views (`android.webkit.WebView` on Android and `WKWebView` on iOS and macOS).

## 1. Installation and Setup

Add `webview_flutter` to your `pubspec.yaml`:

```yaml
dependencies:
  webview_flutter: ^4.14.1
```

To access platform-specific creation parameters and controller methods (such as media playback rules, debugging, or hybrid composition), also add the endorsed platform packages:

```yaml
dependencies:
  webview_flutter: ^4.14.1
  webview_flutter_android: ^4.12.0
  webview_flutter_wkwebview: ^3.25.1
```

## 2. Platform-Specific Configuration

### Android

- **Minimum SDK**: Requires Android SDK 24+.
- **Material Components**: To support HTML input elements properly (such as date pickers and dropdowns), ensure your Android application theme inherits from a `Theme.MaterialComponents` or `Theme.Material3` theme in `android/app/src/main/res/values/styles.xml`.
- **Internet Permission**: Ensure `<uses-permission android:name="android.permission.INTERNET" />` is present in `android/app/src/main/AndroidManifest.xml`.

### iOS and macOS

- **Minimum OS**: Requires iOS 13.0+ or macOS 10.15+.
- **App Transport Security (ATS)**: To load non-HTTPS (`http://`) URLs, configure `NSAppTransportSecurity` in `Info.plist`.
- **macOS Network Entitlement**: On macOS, add the outgoing network client entitlement to `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:
  ```xml
  <key>com.apple.security.network.client</key>
  <true/>
  ```

## 3. Usage and API Examples

### Basic Usage (`WebViewController` and `WebViewWidget`)

In `webview_flutter` 4.x+, instantiate a `WebViewController`, configure JavaScript mode and `NavigationDelegate`, load a request, and pass the controller to `WebViewWidget`:

```dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading progress indicator
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://flutter.dev'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter WebView')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
```

### Platform-Specific Creation Parameters and Features

Use `WebViewController.fromPlatformCreationParams` with `WebKitWebViewControllerCreationParams` and `AndroidWebViewControllerCreationParams` to customize platform behavior:

```dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

WebViewController createConfiguredController() {
  late final PlatformWebViewControllerCreationParams params;
  if (WebViewPlatform.instance is WebKitWebViewPlatform) {
    params = WebKitWebViewControllerCreationParams(
      allowsInlineMediaPlayback: true,
      mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
    );
  } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
    params = AndroidWebViewControllerCreationParams();
  } else {
    params = const PlatformWebViewControllerCreationParams();
  }

  final WebViewController controller =
      WebViewController.fromPlatformCreationParams(params);

  // Configure Android-specific controller settings
  if (controller.platform is AndroidWebViewController) {
    AndroidWebViewController.enableDebugging(true);
    (controller.platform as AndroidWebViewController)
        .setMediaPlaybackRequiresUserGesture(false);
  }

  // Configure iOS/macOS-specific controller settings
  if (controller.platform is WebKitWebViewController) {
    (controller.platform as WebKitWebViewController)
        .setAllowsBackForwardNavigationGestures(true);
  }

  return controller;
}
```

### JavaScript Evaluation and Channels

Communicate between Dart and JavaScript using `runJavaScript`, `runJavaScriptReturningResult`, and `addJavaScriptChannel`:

```dart
Future<void> configureJavaScriptInterop(WebViewController controller) async {
  await controller.addJavaScriptChannel(
    'FlutterChannel',
    onMessageReceived: (JavaScriptMessage message) {
      debugPrint('Message from JS: ${message.message}');
    },
  );

  // Execute JavaScript without a return value
  await controller.runJavaScript('console.log("Hello from Flutter!");');

  // Execute JavaScript and parse the returned result
  final Object result = await controller.runJavaScriptReturningResult(
    'document.title',
  );
  debugPrint('Page Title: $result');
}
```
