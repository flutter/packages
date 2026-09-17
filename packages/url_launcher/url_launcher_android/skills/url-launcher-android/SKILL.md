---
name: url-launcher-android
description: Set up and configure url_launcher_android, the Android implementation of Flutter's url_launcher plugin. Covers endorsed plugin usage, Android 11+ package visibility queries in AndroidManifest.xml, Custom Tabs support, and direct registration.
---

# Setting Up and Using url_launcher_android

`url_launcher_android` is the endorsed Android platform implementation of the Flutter [`url_launcher`](https://pub.dev/packages/url_launcher) plugin. It handles launching Intents, Chrome Custom Tabs (`inAppBrowserView`), and WebViews (`inAppWebView`) on Android.

## 1. Installation and Setup

Because `url_launcher_android` is an endorsed federated plugin implementation, adding `url_launcher` to your `pubspec.yaml` automatically includes it:

```yaml
dependencies:
  url_launcher: ^6.3.2
```

If you need to depend on `url_launcher_android` directly (for instance, to pin a specific version or register the platform implementation manually in tests):

```yaml
dependencies:
  url_launcher: ^6.3.2
  url_launcher_android: ^6.3.33
```

## 2. Platform-Specific Configuration

### Minimum SDK Requirements

Ensure your Android application meets the minimum SDK version required by `url_launcher_android` (API level 24+ in recent versions) in `android/app/build.gradle`:

```groovy
android {
    defaultConfig {
        minSdkVersion 24
    }
}
```

### Package Visibility Queries (`AndroidManifest.xml`)

Starting on Android 11 (API level 30), Android restricts which packages an application can query. If your app calls `canLaunchUrl` or `supportsLaunchMode(LaunchMode.inAppBrowserView)`, add a `<queries>` element inside the root `<manifest>` tag in `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <queries>
    <!-- Required if your app checks canLaunchUrl for SMS schemes -->
    <intent>
      <action android:name="android.intent.action.VIEW" />
      <data android:scheme="sms" />
    </intent>
    <!-- Required if your app checks canLaunchUrl for phone dialer schemes -->
    <intent>
      <action android:name="android.intent.action.VIEW" />
      <data android:scheme="tel" />
    </intent>
    <!-- Required if your app checks supportsLaunchMode(LaunchMode.inAppBrowserView) -->
    <intent>
      <action android:name="android.support.customtabs.action.CustomTabsService" />
    </intent>
  </queries>

  <application ...>
  </application>
</manifest>
```

Without these declarations, `canLaunchUrl` and `supportsLaunchMode` may return `false` even when a suitable handler app is installed on the device. Note that `launchUrl` itself can often still launch intents without `<queries>`, so calling `launchUrl` directly inside a `try` block or checking its boolean return value is recommended when fallback behavior is available.

## 3. Usage and API Examples

### Endorsed Usage via `url_launcher`

In standard Flutter applications, call the app-facing APIs from `package:url_launcher/url_launcher.dart`. `UrlLauncherAndroid` is automatically registered by the Flutter tool on Android:

```dart
import 'package:url_launcher/url_launcher.dart';

Future<void> openWebPageInCustomTab() async {
  final Uri url = Uri.parse('https://flutter.dev');
  final bool launched = await launchUrl(
    url,
    mode: LaunchMode.inAppBrowserView,
    browserConfiguration: const BrowserConfiguration(showTitle: true),
  );
  if (!launched) {
    throw Exception('Failed to launch $url on Android');
  }
}
```

### Direct Platform Registration and Usage

If you are interacting with the platform interface directly or configuring `UrlLauncherAndroid` manually in an integration test or custom plugin setup:

```dart
import 'package:url_launcher_android/url_launcher_android.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

void registerAndroidLauncher() {
  UrlLauncherAndroid.registerWith();
}

Future<void> launchDirectlyWithPlatform() async {
  final UrlLauncherPlatform launcher = UrlLauncherPlatform.instance;
  final bool canLaunch = await launcher.canLaunch('https://flutter.dev');
  if (canLaunch) {
    await launcher.launchUrl(
      'https://flutter.dev',
      const LaunchOptions(mode: PreferredLaunchMode.inAppBrowserView),
    );
  }
}
```
