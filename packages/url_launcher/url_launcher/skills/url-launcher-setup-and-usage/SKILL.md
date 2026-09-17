---
name: url-launcher-setup-and-usage
description: Launch web URLs, emails, phone calls, SMS messages, and files in Flutter across Android, iOS, Web, Linux, macOS, and Windows. Covers pubspec setup, AndroidManifest queries, Info.plist LSApplicationQueriesSchemes, LaunchMode options, and query parameter encoding.
---

# Setting Up and Using url_launcher

`url_launcher` is a Flutter plugin for launching URLs across Android, iOS, Linux, macOS, Web, and Windows. It supports web (`http`, `https`), email (`mailto`), phone (`tel`), SMS (`sms`), and desktop file (`file`) schemes.

## 1. Installation and Setup

Add `url_launcher` to your `pubspec.yaml`:

```yaml
dependencies:
  url_launcher: ^6.3.2
```

## 2. Platform-Specific Configuration

### Android (`android/app/src/main/AndroidManifest.xml`)

Starting on Android 11 (API level 30), package visibility restrictions require you to declare `<queries>` entries in your `AndroidManifest.xml` as a child of the root `<manifest>` element if you call `canLaunchUrl` or check `supportsLaunchMode(LaunchMode.inAppBrowserView)`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <!-- Provide required visibility configuration for API level 30 and above -->
  <queries>
    <!-- If your app checks for SMS support -->
    <intent>
      <action android:name="android.intent.action.VIEW" />
      <data android:scheme="sms" />
    </intent>
    <!-- If your app checks for call support -->
    <intent>
      <action android:name="android.intent.action.VIEW" />
      <data android:scheme="tel" />
    </intent>
    <!-- If your application checks for inAppBrowserView launch mode support -->
    <intent>
      <action android:name="android.support.customtabs.action.CustomTabsService" />
    </intent>
  </queries>

  <application ...>
  </application>
</manifest>
```

### iOS (`ios/Runner/Info.plist`)

Add any URL schemes passed to `canLaunchUrl` as `LSApplicationQueriesSchemes` entries in your `Info.plist` file; otherwise `canLaunchUrl` will return `false`:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>sms</string>
  <string>tel</string>
  <string>mailto</string>
</array>
```

### macOS Entitlements

If your macOS application opens `file:` URLs outside of its application sandbox, configure appropriate file access entitlements in `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`. For network requests (e.g., in-app web views), ensure `com.apple.security.network.client` is enabled.

### Web Limitations

Web browsers block opening new tabs or windows (`_blank`) unless triggered directly by a synchronous user interaction (such as a button tap). If awaiting asynchronous operations before calling `launchUrl`, pass `webOnlyWindowName: '_self'` to open in the current tab or prepare the `Uri` ahead of time.

## 3. Usage and API Examples

### Launching a Web URL

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri _flutterUrl = Uri.parse('https://flutter.dev');

Future<void> launchFlutterHomepage() async {
  if (!await launchUrl(_flutterUrl)) {
    throw Exception('Could not launch $_flutterUrl');
  }
}
```

### Specifying Launch Modes (Browser vs. In-App View)

Control whether a web URL opens in the default external browser, an in-app browser tab (Chrome Custom Tabs / SFSafariViewController), or an embedded WebView using `LaunchMode`:

```dart
import 'package:url_launcher/url_launcher.dart';

Future<void> launchInExternalBrowser(Uri url) async {
  if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  )) {
    throw Exception('Could not launch $url');
  }
}

Future<void> launchInAppBrowserView(Uri url) async {
  final bool supported = await supportsLaunchMode(LaunchMode.inAppBrowserView);
  final LaunchMode mode = supported
      ? LaunchMode.inAppBrowserView
      : LaunchMode.platformDefault;

  await launchUrl(url, mode: mode);
}
```

### Encoding Query Parameters for Non-HTTP Schemes (`mailto`, `sms`, `tel`)

For schemes other than `http` or `https`, do not use `Uri(queryParameters: ...)` because it encodes spaces as `+` instead of `%20`. Use a custom query encoder with `Uri.encodeComponent`:

```dart
import 'package:url_launcher/url_launcher.dart';

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map(
        (MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
      )
      .join('&');
}

Future<void> sendFeedbackEmail() async {
  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: 'support@example.com',
    query: encodeQueryParameters(<String, String>{
      'subject': 'App Feedback & Support',
      'body': 'Hello team, I would like to report...',
    }),
  );

  if (!await launchUrl(emailLaunchUri)) {
    throw Exception('Could not launch email client');
  }
}
```

### Launching Desktop Files (`file:` scheme)

On desktop platforms (Windows, macOS, Linux), check that the file exists before launching:

```dart
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

Future<void> openLocalFile(String filePath) async {
  final File file = File(filePath);
  if (!file.existsSync()) {
    throw Exception('File does not exist: $filePath');
  }

  final Uri fileUri = Uri.file(file.absolute.path);
  if (!await launchUrl(fileUri)) {
    throw Exception('Could not open file $fileUri');
  }
}
```
