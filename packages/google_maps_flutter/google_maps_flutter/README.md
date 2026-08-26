# Google Maps for Flutter

<?code-excerpt path-base="example/lib"?>

[![pub package](https://img.shields.io/pub/v/google_maps_flutter.svg)](https://pub.dev/packages/google_maps_flutter)

A Flutter plugin that provides a [Google Maps](https://developers.google.com/maps/) widget.

|             | Android | iOS     | Web                              |
|-------------|---------|---------|----------------------------------|
| **Support** | SDK 24+ | iOS 14+ | Same as [Flutter's][web-support] |

[web-support]: https://docs.flutter.dev/reference/supported-platforms

**Important:** Not all functionality is supported on all platforms.
For details, please read the README files
of the endorsed platform packages:

* [`google_maps_flutter_android` README](https://pub.dev/packages/google_maps_flutter_android)
* [`google_maps_flutter_ios` README](https://pub.dev/packages/google_maps_flutter_ios)
* [`google_maps_flutter_web` README](https://pub.dev/packages/google_maps_flutter_web)

## Getting Started

* Get an API key at <https://cloud.google.com/maps-platform/>.

* Enable Google Map SDK for each platform.
  * Go to [Google Developers Console](https://console.cloud.google.com/).
  * Choose the project that you want to enable Google Maps on.
  * Select the navigation menu and then select "Google Maps".
  * Select "APIs" under the Google Maps menu.
  * To enable Google Maps for Android, select "Maps SDK for Android" in the "Additional APIs" section, then select "ENABLE".
  * To enable Google Maps for iOS, select "Maps SDK for iOS" in the "Additional APIs" section, then select "ENABLE".
  * To enable Google Maps for Web, enable the "Maps JavaScript API".
  * Make sure the APIs you enabled are under the "Enabled APIs" section.

For more details, see [Getting started with Google Maps Platform](https://developers.google.com/maps/gmp-get-started).

### Platform Setup

* **Android**: Please see [the `google_maps_flutter_android` README](https://pub.dev/packages/google_maps_flutter_android#setup).
* **iOS**: Please select an SDK version, and see the relevant README:
  * [8.4 (iOS 14+)](https://pub.dev/packages/google_maps_flutter_ios#setup)
  * [SDK 9.x (iOS 15+)](https://pub.dev/packages/google_maps_flutter_ios_sdk9#setup)
  * [SDK 10.x (iOS 16+)](https://pub.dev/packages/google_maps_flutter_ios_sdk10#setup)
* **Web**: Please see [the `google_maps_flutter_web` README](https://pub.dev/packages/google_maps_flutter_web#setup).

### Advanced Markers

[Advanced Markers](https://developers.google.com/maps/documentation/javascript/advanced-markers/overview) 
are map markers that offer extra customization options. 
[Map ID](https://developers.google.com/maps/documentation/get-map-id) is 
required in order to use Advanced Markers:

<?code-excerpt "readme_sample_advanced_markers.dart (AdvancedMarkersSample)"?>
```dart
body: GoogleMap(
  // Set your Map ID.
  mapId: 'my-map-id',
  // Enable support for Advanced Markers.
  markerType: GoogleMapMarkerType.advancedMarker,
  initialCameraPosition: _kGooglePlex,
),
```

**WARNING:** On iOS, using a PinConfig may result in the marker not showing. For details and updates, see
[this issue](https://issuetracker.google.com/issues/370536110). If this issue has not been fixed in the version of the
Google Maps SDK you are using, consider using an asset or bitmap for customization on iOS.

### Sample Usage

To show a map, add a `GoogleMap` widget to your widget tree. The map view can
be controlled with the `GoogleMapController` that is passed to the `GoogleMap`'s
`onMapCreated` callback.

The `GoogleMap` widget should be used within a widget with a bounded size.
Using it in an unbounded widget will cause the application to throw a Flutter
exception.

<?code-excerpt "readme_sample.dart (MapSample)"?>
```dart
class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

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

See the `example` directory for a complete sample app.
