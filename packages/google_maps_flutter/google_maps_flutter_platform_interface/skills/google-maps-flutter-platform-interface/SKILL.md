---
name: google-maps-flutter-platform-interface
description: Use google_maps_flutter_platform_interface to implement custom platform implementations or write platform-level tests for google_maps_flutter.
---

# Setting Up and Using google_maps_flutter_platform_interface

`google_maps_flutter_platform_interface` defines the common platform interface and shared data types (such as `LatLng`, `CameraPosition`, `Marker`, `Polygon`, `Polyline`, and `Heatmap`) for the [`google_maps_flutter`](https://pub.dev/packages/google_maps_flutter) federated plugin.

## 1. Installation

If you are implementing a new platform package for `google_maps_flutter` or writing unit tests that mock the platform layer, add `google_maps_flutter_platform_interface` to your `pubspec.yaml`:

```yaml
dependencies:
  google_maps_flutter_platform_interface: ^2.17.0
```

## 2. Platform-Specific Configuration

This package is a pure Dart/Flutter interface package and requires no native Android, iOS, or Web platform configuration of its own.

When creating a platform implementation, always **extend** `GoogleMapsFlutterPlatform` rather than implementing it (`class MyMapsPlatform extends GoogleMapsFlutterPlatform`). Extending ensures your implementation inherits default method implementations and avoids breaking when new methods are added to the platform interface.

## 3. Usage and API Examples

### Implementing a Custom Platform Implementation

To create and register a custom platform implementation of `google_maps_flutter`:

```dart
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

class CustomGoogleMapsPlatform extends GoogleMapsFlutterPlatform {
  /// Registers this class as the default instance of [GoogleMapsFlutterPlatform].
  static void registerWith() {
    GoogleMapsFlutterPlatform.instance = CustomGoogleMapsPlatform();
  }

  @override
  Future<void> init(int mapId) async {
    // Initialize map instance for mapId.
  }

  @override
  Widget buildViewWithConfiguration(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required MapWidgetConfiguration widgetConfiguration,
    MapObjects mapObjects = const MapObjects(),
    MapConfiguration mapConfiguration = const MapConfiguration(),
  }) {
    // Return the platform-specific widget rendering the map.
    return const SizedBox.expand();
  }
}
```

### Mocking or Inspecting the Platform Instance in Tests

In tests, you can override `GoogleMapsFlutterPlatform.instance` to intercept platform calls made by `GoogleMap` widgets:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

class FakeGoogleMapsPlatform extends GoogleMapsFlutterPlatform {
  @override
  Future<void> init(int mapId) async {}
}

void main() {
  testWidgets('overrides GoogleMapsFlutterPlatform instance',
      (WidgetTester tester) async {
    final FakeGoogleMapsPlatform fakePlatform = FakeGoogleMapsPlatform();
    GoogleMapsFlutterPlatform.instance = fakePlatform;

    expect(GoogleMapsFlutterPlatform.instance, same(fakePlatform));
  });
}
```
