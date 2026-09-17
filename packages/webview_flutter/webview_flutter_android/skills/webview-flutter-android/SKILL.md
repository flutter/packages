---
name: webview-flutter-android
description: Set up and use the webview_flutter_android plugin to configure Android WebView features including Hybrid Composition, geolocation, fullscreen video, WebAuthn, and Payment Request APIs.
---

# Setting Up and Using webview_flutter_android

`webview_flutter_android` is the endorsed Android platform implementation of the [`webview_flutter`](https://pub.dev/packages/webview_flutter) plugin.

## 1. Installation and Setup

Because `webview_flutter_android` is an endorsed implementation, adding `webview_flutter` to your `pubspec.yaml` automatically includes it. However, to access Android-specific classes (`AndroidWebViewController`, `AndroidWebViewWidgetCreationParams`, geolocation prompts, fullscreen callbacks, etc.), add it explicitly:

```yaml
dependencies:
  webview_flutter: ^4.14.1
  webview_flutter_android: ^4.14.1
```

## 2. Platform-Specific Configuration

### Display Modes: Texture Layer vs Hybrid Composition

By default, `webview_flutter_android` uses **Texture Layer Hybrid Composition**, which is performant across Flutter 3.0+. If you encounter rendering or input edge cases with `SurfaceTexture`, switch explicitly to **Hybrid Composition** via `AndroidWebViewWidgetCreationParams(displayWithHybridComposition: true)`.

### Payment Request API (`AndroidManifest.xml`)

To discover and invoke Android payment apps when enabling Payment Request APIs in WebView, add the Chromium payment intent queries to `android/app/src/main/AndroidManifest.xml`:

```xml
<queries>
  <intent>
    <action android:name="org.chromium.intent.action.PAY"/>
  </intent>
  <intent>
    <action android:name="org.chromium.intent.action.IS_READY_TO_PAY"/>
  </intent>
  <intent>
    <action android:name="org.chromium.intent.action.UPDATE_PAYMENT_DETAILS"/>
  </intent>
</queries>
```

## 3. Usage and API Examples

### Enabling Debugging, Media Playback, and Hybrid Composition

Use `AndroidWebViewController` and `AndroidWebViewWidgetCreationParams` with the modern `WebViewController` and `WebViewWidget` APIs:

```dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class AndroidConfiguredWebView extends StatefulWidget {
  const AndroidConfiguredWebView({super.key});

  @override
  State<AndroidConfiguredWebView> createState() =>
      _AndroidConfiguredWebViewState();
}

class _AndroidConfiguredWebViewState extends State<AndroidConfiguredWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    final PlatformWebViewControllerCreationParams params =
        WebViewPlatform.instance is AndroidWebViewPlatform
            ? AndroidWebViewControllerCreationParams()
            : const PlatformWebViewControllerCreationParams();

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://flutter.dev'));

    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      final AndroidWebViewController androidController =
          _controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    PlatformWebViewWidgetCreationParams widgetParams =
        PlatformWebViewWidgetCreationParams(controller: _controller.platform);

    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      widgetParams = AndroidWebViewWidgetCreationParams
          .fromPlatformWebViewWidgetCreationParams(
        widgetParams,
        displayWithHybridComposition: true,
      );
    }

    return WebViewWidget.fromPlatformCreationParams(params: widgetParams);
  }
}
```

### Handling Geolocation Prompts, Fullscreen Video, WebAuthn, and Payment Requests

Configure advanced Android WebView features directly on `AndroidWebViewController`:

```dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

Future<void> configureAdvancedAndroidFeatures(
  BuildContext context,
  WebViewController controller,
) async {
  if (controller.platform is! AndroidWebViewController) {
    return;
  }
  final AndroidWebViewController androidController =
      controller.platform as AndroidWebViewController;

  // 1. Handle Fullscreen Video
  androidController.setCustomWidgetCallbacks(
    onShowCustomWidget: (Widget widget, OnHideCustomWidgetCallback callback) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => widget,
          fullscreenDialog: true,
        ),
      );
    },
    onHideCustomWidget: () {
      Navigator.of(context).pop();
    },
  );

  // 2. Handle Geolocation Permission Prompts (ensure Android OS location permission is granted first)
  await androidController.setGeolocationPermissionsPromptCallbacks(
    onShowPrompt: (GeolocationPermissionsRequestParams request) async {
      return const GeolocationPermissionsResponse(allow: true, retain: true);
    },
  );

  // 3. Enable Payment Request API if supported by the device WebView
  final bool paymentSupported = await androidController.isWebViewFeatureSupported(
    WebViewFeatureType.paymentRequest,
  );
  if (paymentSupported) {
    await androidController.setPaymentRequestEnabled(true);
  }

  // 4. Enable Web Authentication (WebAuthn) if supported
  final bool webAuthnSupported = await androidController.isWebViewFeatureSupported(
    WebViewFeatureType.webAuthentication,
  );
  if (webAuthnSupported) {
    await androidController.setWebAuthenticationSupport(
      WebAuthenticationSupport.forApp,
    );
  }
}
```
