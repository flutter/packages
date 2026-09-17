---
name: google-maps-flutter
description: Set up and use the google_maps_flutter plugin to integrate interactive Google Maps widgets in Android, iOS, and Web applications.
---

# Setting Up and Using google_maps_flutter

`google_maps_flutter` is a Flutter plugin that provides a `GoogleMap` widget for integrating interactive Google Maps across Android, iOS, and Web applications.

## 1. Installation

Add `google_maps_flutter` to your `pubspec.yaml` file:

```yaml
dependencies:
  google_maps_flutter: ^2.18.1
```

Or run:

```bash
flutter pub add google_maps_flutter
```

## 2. Platform-Specific Configuration

Before using the map widget, obtain an API key from the [Google Cloud Console](https://console.cloud.google.com/) and enable the respective SDKs:
- **Android**: Enable "Maps SDK for Android"
- **iOS**: Enable "Maps SDK for iOS"
- **Web**: Enable "Maps JavaScript API"

### Android Setup (`android/app/src/main/AndroidManifest.xml`)

Add your Google Maps API key inside the `<application>` tag of `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
  <application ...>
    <meta-data
      android:name="com.google.android.geo.API_KEY"
      android:value="YOUR_ANDROID_API_KEY"/>
  </application>
</manifest>
```

Ensure your `minSdkVersion` in `android/app/build.gradle` is set to API level 24 or higher.

### iOS Setup (`ios/Runner/AppDelegate.swift`)

Provide your iOS API key in `ios/Runner/AppDelegate.swift` by importing `GoogleMaps` and calling `GMSServices.provideAPIKey`:

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

Ensure your minimum iOS deployment target is at least iOS 14.0 (or use `google_maps_flutter_ios_sdk9` for iOS 15+ or `google_maps_flutter_ios_sdk10` for iOS 16+ and Swift Package Manager support).

### Web Setup (`web/index.html`)

Add the Google Maps JavaScript API script tag to the `<head>` section of `web/index.html`:

```html
<head>
  <!-- Other head tags -->
  <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_WEB_API_KEY&libraries=drawing,marker"></script>
</head>
```

## 3. Usage and API Examples

### Displaying a Basic Map and Controlling the Camera

Place the `GoogleMap` widget inside a widget with bounded size (such as a `Scaffold` body, `SizedBox`, or `Expanded`). Use `GoogleMapController` from `onMapCreated` to programmatically animate or move the camera:

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
    bearing: 192.8334901395799,
    target: LatLng(37.43296265331129, -122.08832357078792),
    tilt: 59.440717697143555,
    zoom: 19.151926040649414,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: const Text('To the lake!'),
        icon: const Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}
```

### Adding Markers and Using Advanced Markers

To use standard markers or [Advanced Markers](https://developers.google.com/maps/documentation/javascript/advanced-markers/overview) (which require a `mapId` configured in the Google Cloud Console):

```dart
GoogleMap(
  mapId: 'YOUR_CLOUD_MAP_ID',
  markerType: GoogleMapMarkerType.advancedMarker,
  initialCameraPosition: const CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 12,
  ),
  markers: <Marker>{
    const Marker(
      markerId: MarkerId('san_francisco'),
      position: LatLng(37.7749, -122.4194),
      infoWindow: InfoWindow(
        title: 'San Francisco',
        snippet: 'California, USA',
      ),
    ),
  },
)
```
