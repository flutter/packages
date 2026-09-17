---
name: webview-flutter-wkwebview-setup-and-usage
description: Set up and use the webview_flutter_wkwebview plugin, the Apple WKWebView implementation of webview_flutter for iOS and macOS with WebKit creation params and gesture settings.
---

# Setting Up and Using webview_flutter_wkwebview

`webview_flutter_wkwebview` is the endorsed iOS and macOS platform implementation of the [`webview_flutter`](https://pub.dev/packages/webview_flutter) plugin, built on Apple's native `WKWebView` control.

## 1. Installation and Setup

Because `webview_flutter_wkwebview` is an endorsed implementation for both iOS and macOS, adding `webview_flutter` to your `pubspec.yaml` automatically includes it. To access WebKit-specific creation parameters (`WebKitWebViewControllerCreationParams`) or controller methods (`WebKitWebViewController`), add it explicitly:

```yaml
dependencies:
  webview_flutter: ^4.14.1
  webview_flutter_wkwebview: ^3.26.1
```

## 2. Platform-Specific Configuration

### iOS and macOS Requirements

- **Minimum OS Versions**: Requires iOS 13.0+ or macOS 10.15+.
- **macOS Network Entitlements**: Sandboxed macOS apps require outgoing network access to load remote URLs. Add the following key to `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:
  ```xml
  <key>com.apple.security.network.client</key>
  <true/>
  ```
- **App Transport Security (`Info.plist`)**: To load insecure HTTP resources or local network servers, configure `NSAppTransportSecurity` in `ios/Runner/Info.plist` or `macos/Runner/Info.plist`.

## 3. Usage and API Examples

### Configuring WebKit Creation Parameters and Controller Settings

Use `WebKitWebViewControllerCreationParams` with `WebViewController.fromPlatformCreationParams` to configure inline media playback, media types requiring user gestures, and WebKit limits:

```dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class AppleWebKitWebView extends StatefulWidget {
  const AppleWebKitWebView({super.key});

  @override
  State<AppleWebKitWebView> createState() => _AppleWebKitWebViewState();
}

class _AppleWebKitWebViewState extends State<AppleWebKitWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
        limitsNavigationsToAppBoundDomains: false,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://flutter.dev'));

    if (_controller.platform is WebKitWebViewController) {
      final WebKitWebViewController wkController =
          _controller.platform as WebKitWebViewController;
      // Enable swipe gestures for back/forward navigation
      wkController.setAllowsBackForwardNavigationGestures(true);
      // Enable Web Inspector debugging on iOS 16.4+ / macOS 13.3+
      wkController.setInspectable(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WKWebView Example')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
```
