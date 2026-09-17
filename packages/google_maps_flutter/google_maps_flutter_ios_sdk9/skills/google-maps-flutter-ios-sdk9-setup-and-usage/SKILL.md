---
name: google-maps-flutter-ios-sdk9-setup-and-usage
description: Set up and configure google_maps_flutter_ios_sdk9 to use Google Maps SDK 9.x on iOS 15+ with Swift Package Manager support.
---

# Setting Up and Using google_maps_flutter_ios_sdk9

`google_maps_flutter_ios_sdk9` is an iOS implementation of [`google_maps_flutter`](https://pub.dev/packages/google_maps_flutter) that explicitly targets **Google Maps SDK 9.x**.

Use this package if your application requires **Swift Package Manager (SPM)** support while maintaining compatibility with **iOS 15.0** (whereas SDK 10 requires iOS 16.0+).

## 1. Installation

Because this package is not the default endorsed version, add a direct dependency on `google_maps_flutter_ios_sdk9` alongside `google_maps_flutter` in your application's `pubspec.yaml`. Flutter will automatically use this package in place of the default iOS implementation:

```yaml
dependencies:
  google_maps_flutter: ^2.18.1
  google_maps_flutter_ios_sdk9: ^2.18.14
```

> **Note for Package Authors**: If you are authoring a reusable package, depend only on `google_maps_flutter` so that application developers can choose the iOS SDK package matching their app's minimum deployment target.

## 2. Platform-Specific Configuration

### 1. Minimum Deployment Version (iOS 15+)

Google Maps SDK 9.x requires **iOS 15.0 or higher**. Ensure your Xcode project and `ios/Podfile` specify at least iOS 15.0:

```ruby
platform :ios, '15.0'
```

### 2. Provide Your API Key (`ios/Runner/AppDelegate.swift`)

Enable the **Maps SDK for iOS** in the [Google Cloud Console](https://console.cloud.google.com/) and initialize `GMSServices` with your API key in `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_IOS_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## 3. Usage and API Examples

Once `google_maps_flutter_ios_sdk9` is listed in your `pubspec.yaml` and your API key is registered in `AppDelegate.swift`, use the standard `google_maps_flutter` widget and controller APIs:

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSdk9Screen extends StatelessWidget {
  const MapSdk9Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Maps iOS SDK 9')),
      body: const GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(40.7128, -74.0060),
          zoom: 12.0,
        ),
      ),
    );
  }
}
```
