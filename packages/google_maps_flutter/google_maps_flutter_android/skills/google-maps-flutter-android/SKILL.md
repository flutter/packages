---
name: google-maps-flutter-android
description: Set up and configure google_maps_flutter_android, the Android platform implementation of google_maps_flutter, including API key setup, display modes, and SDK warmup.
---

# Setting Up and Using google_maps_flutter_android

`google_maps_flutter_android` is the endorsed Android implementation of the [`google_maps_flutter`](https://pub.dev/packages/google_maps_flutter) plugin.

## 1. Installation

Because this package is endorsed, simply adding `google_maps_flutter` to your `pubspec.yaml` automatically includes `google_maps_flutter_android`.

However, if you import `package:google_maps_flutter_android/google_maps_flutter_android.dart` directly (for example, to configure Android display modes or call `warmup()`), add it explicitly to your `pubspec.yaml`:

```yaml
dependencies:
  google_maps_flutter: ^2.18.1
  google_maps_flutter_android: ^2.19.13
  google_maps_flutter_platform_interface: ^2.17.0
```

## 2. Platform-Specific Configuration

### Android Manifest API Key (`android/app/src/main/AndroidManifest.xml`)

Enable the **Maps SDK for Android** in the [Google Cloud Console](https://console.cloud.google.com/) and specify your API key inside the `<application>` element in `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
  <application ...>
    <meta-data
      android:name="com.google.android.geo.API_KEY"
      android:value="YOUR_ANDROID_API_KEY"/>
  </application>
</manifest>
```

### Minimum SDK Version

Ensure that `minSdkVersion` in `android/app/build.gradle` meets the plugin requirement (SDK 24+):

```groovy
android {
    defaultConfig {
        minSdkVersion 24
    }
}
```

## 3. Usage and Android-Specific Configuration

### Configuring Platform View Display Mode

The Android plugin supports two display modes:
1. **Texture Layer Hybrid Composition** (`useAndroidViewSurface = false`): The default, recommended, and most performant mode.
2. **Hybrid Composition** (`useAndroidViewSurface = true`): Available for backwards compatibility if required for specific rendering scenarios.

To explicitly configure the display mode before rendering any `GoogleMap` widget:

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    // Set to false for Texture Layer Hybrid Composition (default/recommended),
    // or true for Hybrid Composition mode.
    mapsImplementation.useAndroidViewSurface = false;
  }

  runApp(const MyApp());
}
```

### Pre-Warming the Google Maps SDK

The first time a `GoogleMap` widget is displayed, the Google Maps Android SDK initializes on the main thread, which can briefly cause UI jank. You can pre-warm the SDK ahead of time during app startup or on a splash screen using `warmup()`:

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

Future<void> prewarmGoogleMaps() async {
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    await mapsImplementation.warmup();
  }
}
```
