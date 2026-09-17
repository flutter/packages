---
name: url-launcher-ios
description: Set up and configure url_launcher_ios, the iOS implementation of Flutter's url_launcher plugin. Covers endorsed usage, Info.plist LSApplicationQueriesSchemes configuration, SFSafariViewController vs universal links, and direct registration.
---

# Setting Up and Using url_launcher_ios

`url_launcher_ios` is the endorsed iOS platform implementation of the Flutter [`url_launcher`](https://pub.dev/packages/url_launcher) plugin. It uses `UIApplication.shared.open`, `SFSafariViewController`, and `UIApplication.shared.canOpenURL` to handle URLs on iOS.

## 1. Installation and Setup

Because `url_launcher_ios` is an endorsed federated plugin implementation, adding `url_launcher` to your `pubspec.yaml` automatically includes it:

```yaml
dependencies:
  url_launcher: ^6.3.2
```

If you need to depend on `url_launcher_ios` directly (for example, to pin a specific version or interact with `UrlLauncherIOS` directly):

```yaml
dependencies:
  url_launcher: ^6.3.2
  url_launcher_ios: ^6.4.2
```

## 2. Platform-Specific Configuration

### iOS Info.plist Configuration (`LSApplicationQueriesSchemes`)

On iOS, any URL scheme passed to `canLaunchUrl` must be explicitly declared under the `LSApplicationQueriesSchemes` key in `ios/Runner/Info.plist`. If a scheme is omitted from `Info.plist`, `canLaunchUrl` will always return `false` for that scheme:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>sms</string>
  <string>tel</string>
  <string>mailto</string>
</array>
```

### Simulator Limitations

iOS Simulators do not include default Phone (`tel:`) or Mail (`mailto:`) applications. Attempting to open `tel:` or `mailto:` links on an iOS Simulator will fail; always test these schemes on a physical iOS device.

## 3. Usage and API Examples

### Endorsed Usage via `url_launcher`

Use the standard `package:url_launcher/url_launcher.dart` APIs. On iOS:
- `LaunchMode.inAppBrowserView` (and `LaunchMode.inAppWebView`) opens web URLs inside an in-app `SFSafariViewController`.
- `LaunchMode.externalApplication` opens URLs in the default external browser (Safari) or app.
- `LaunchMode.externalNonBrowserApplication` opens universal links in a registered native app if installed, failing if only a browser can handle the URL.

```dart
import 'package:url_launcher/url_launcher.dart';

Future<void> openInSafariViewController() async {
  final Uri url = Uri.parse('https://flutter.dev');
  if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
    throw Exception('Could not launch $url in SFSafariViewController');
  }
}

Future<void> closeInAppSafariViewController() async {
  await closeInAppWebView();
}
```

### Direct Platform Registration and Usage

To explicitly register `UrlLauncherIOS` or call methods on the platform interface directly:

```dart
import 'package:url_launcher_ios/url_launcher_ios.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

void registerIOSLauncher() {
  UrlLauncherIOS.registerWith();
}

Future<void> launchViaPlatformInterface() async {
  final UrlLauncherPlatform launcher = UrlLauncherPlatform.instance;
  final bool launched = await launcher.launchUrl(
    'https://flutter.dev',
    const LaunchOptions(mode: PreferredLaunchMode.inAppBrowserView),
  );
  if (!launched) {
    throw Exception('Failed to launch URL on iOS');
  }
}
```
