---
name: google-maps-flutter-ios-sdk10-setup-and-usage
description: Set up and configure google_maps_flutter_ios_sdk10 to use Google Maps SDK 10.x on iOS 16+ with Swift Package Manager support.
---

# Setting Up and Using google_maps_flutter_ios_sdk10

`google_maps_flutter_ios_sdk10` is an iOS implementation of [`google_maps_flutter`](https://pub.dev/packages/google_maps_flutter) that explicitly targets **Google Maps SDK 10.x**.

Unlike the default `google_maps_flutter_ios` package, depending on `google_maps_flutter_ios_sdk10` enables **Swift Package Manager (SPM)** support and ensures your app uses Google Maps SDK 10.x features.

## 1. Installation

Because this package is not the default endorsed version, you must add it alongside `google_maps_flutter` in your application's `pubspec.yaml`. Once added, Flutter automatically replaces the default iOS implementation with this SDK 10 implementation:

```yaml
dependencies:
  google_maps_flutter: ^2.18.1
  google_maps_flutter_ios_sdk10: ^2.18.13
```

> **Note for Package Authors**: If you are publishing a reusable Flutter package or plugin, depend only on `google_maps_flutter` rather than a specific `google_maps_flutter_ios_sdk*` package so application developers can select the appropriate SDK version for their target iOS deployment version.

## 2. Platform-Specific Configuration

### 1. Minimum Deployment Version (iOS 16+)

Google Maps SDK 10.x requires **iOS 16.0 or higher**. Update your minimum iOS deployment target in Xcode and in your `ios/Podfile` (if using CocoaPods):

```ruby
platform :ios, '16.0'
```

### 2. Provide Your API Key (`ios/Runner/AppDelegate.swift`)

Enable the **Maps SDK for iOS** in the [Google Cloud Console](https://console.cloud.google.com/) and register your API key in `ios/Runner/AppDelegate.swift`:

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

After adding `google_maps_flutter_ios_sdk10` to `pubspec.yaml` and configuring `AppDelegate.swift`, use the standard `google_maps_flutter` APIs as normal:

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSdk10Screen extends StatelessWidget {
  const MapSdk10Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Maps iOS SDK 10')),
      body: GoogleMap(
        mapId: 'YOUR_MAP_ID',
        markerType: GoogleMapMarkerType.advancedMarker,
        initialCameraPosition: const CameraPosition(
          target: LatLng(37.4220, -122.0841),
          zoom: 15,
        ),
        markers: <Marker>{
          AdvancedMarker(
            markerId: const MarkerId('hq'),
            position: const LatLng(37.4220, -122.0841),
            infoWindow: const InfoWindow(title: 'Googleplex'),
          ),
        },
      ),
    );
  }
}
```
