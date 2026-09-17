---
name: google-maps-flutter-ios
description: Set up and configure google_maps_flutter_ios, the default iOS platform implementation of google_maps_flutter supporting iOS 14+ via CocoaPods.
---

# Setting Up and Using google_maps_flutter_ios

`google_maps_flutter_ios` is the default endorsed iOS implementation of the [`google_maps_flutter`](https://pub.dev/packages/google_maps_flutter) plugin.

> **Note on SDK Versions and Swift Package Manager**: This package dynamically selects Google Maps SDK 8.4, 9.x, or 10.x via CocoaPods depending on your deployment target to preserve compatibility with iOS 14. It does not support Swift Package Manager and will not receive new feature updates. Unless you must support iOS 14, prefer using [`google_maps_flutter_ios_sdk9`](https://pub.dev/packages/google_maps_flutter_ios_sdk9) (iOS 15+) or [`google_maps_flutter_ios_sdk10`](https://pub.dev/packages/google_maps_flutter_ios_sdk10) (iOS 16+).

## 1. Installation

Because `google_maps_flutter_ios` is the default endorsed iOS implementation, adding `google_maps_flutter` to your `pubspec.yaml` includes it automatically:

```yaml
dependencies:
  google_maps_flutter: ^2.18.1
```

If you import `package:google_maps_flutter_ios/google_maps_flutter_ios.dart` directly in your code, add it explicitly to your `pubspec.yaml`:

```yaml
dependencies:
  google_maps_flutter: ^2.18.1
  google_maps_flutter_ios: ^2.18.6
```

## 2. Platform-Specific Configuration

### Providing the API Key (`ios/Runner/AppDelegate.swift`)

Enable the **Maps SDK for iOS** in the [Google Cloud Console](https://console.cloud.google.com/) and provide your API key inside `application(_:didFinishLaunchingWithOptions:)` in `ios/Runner/AppDelegate.swift`:

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

### Minimum iOS Deployment Target

Ensure your iOS deployment target in `ios/Podfile` and Xcode project settings is set to at least `14.0`:

```ruby
platform :ios, '14.0'
```

## 3. Usage and API Examples

Once configured in `AppDelegate.swift`, use the standard `GoogleMap` widget provided by `google_maps_flutter`:

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class IOSMapExample extends StatelessWidget {
  const IOSMapExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Maps iOS')),
      body: const GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(37.3346, -122.0090),
          zoom: 14.0,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
```
