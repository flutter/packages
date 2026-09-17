---
name: webview-flutter-platform-interface-setup-and-usage
description: Set up and use the webview_flutter_platform_interface package to build custom platform implementations or mock WebViewPlatform in unit and widget tests.
---

# Setting Up and Using webview_flutter_platform_interface

`webview_flutter_platform_interface` defines the common platform interface for the [`webview_flutter`](https://pub.dev/packages/webview_flutter) plugin. It enables platform-specific implementations (`webview_flutter_android`, `webview_flutter_wkwebview`, `webview_flutter_web`, and custom platforms) and test mocks to support the same interface.

## 1. Installation and Setup

Add `webview_flutter_platform_interface` to your `pubspec.yaml` when implementing a platform plugin or mocking `WebViewPlatform` in tests:

```yaml
dependencies:
  webview_flutter_platform_interface: ^2.15.1
```

## 2. Architecture & Design Guidelines

### Core Platform Classes

A complete platform implementation provides subclasses for four primary platform interface classes:
- `WebViewPlatform`: The factory entry point registered via `WebViewPlatform.instance`.
- `PlatformWebViewController`: Handles loading URLs, JavaScript execution, caching, and settings.
- `PlatformWebViewWidget`: Builds the Flutter `Widget` displaying the platform web view.
- `PlatformNavigationDelegate`: Handles navigation callbacks (`onPageStarted`, `onPageFinished`, `onNavigationRequest`, error handlers).
- `PlatformWebViewCookieManager`: Manages cookies across requests.

### Extending vs Implementing

Always **extend** (`extends`) `WebViewPlatform` and its associated platform classes rather than implementing (`implements`) them. Extending ensures backward compatibility when new methods are added with default implementations.

## 3. Usage and API Examples

### Implementing and Registering a Custom `WebViewPlatform`

To register a custom platform implementation (or a fake implementation for widget testing):

```dart
import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class CustomWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    return CustomPlatformWebViewController(params);
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) {
    return CustomPlatformWebViewWidget(params);
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) {
    return CustomPlatformNavigationDelegate(params);
  }

  @override
  PlatformWebViewCookieManager createPlatformCookieManager(
    PlatformWebViewCookieManagerCreationParams params,
  ) {
    return CustomPlatformCookieManager(params);
  }
}

class CustomPlatformWebViewController extends PlatformWebViewController {
  CustomPlatformWebViewController(super.params) : super.implementation();

  @override
  Future<void> loadRequest(LoadRequestParams params) async {
    // Perform custom platform load logic for params.uri
  }

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {
    // Configure JS mode on custom platform
  }
}

class CustomPlatformWebViewWidget extends PlatformWebViewWidget {
  CustomPlatformWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: Center(child: Text('Custom WebView Implementation')),
    );
  }
}

class CustomPlatformNavigationDelegate extends PlatformNavigationDelegate {
  CustomPlatformNavigationDelegate(super.params) : super.implementation();
}

class CustomPlatformCookieManager extends PlatformWebViewCookieManager {
  CustomPlatformCookieManager(super.params) : super.implementation();
}

void registerCustomWebViewPlatform() {
  WebViewPlatform.instance = CustomWebViewPlatform();
}
```
