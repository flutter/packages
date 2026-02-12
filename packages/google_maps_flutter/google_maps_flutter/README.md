# Google Maps for Flutter

<?code-excerpt path-base="example/lib"?>

[![pub package](https://img.shields.io/pub/v/google_maps_flutter.svg)](https://pub.dev/packages/google_maps_flutter)

A Flutter plugin that provides a [Google Maps](https://developers.google.com/maps/) widget.

|             | Android | iOS     | Web                              |
|-------------|---------|---------|----------------------------------|
| **Support** | SDK 24+ | iOS 14+ | Same as [Flutter's][web-support] |

[web-support]: https://docs.flutter.dev/reference/supported-platforms

**Important:** Not all functionality is supported on all platforms.
To check details, please read the README files
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

### Android

1. Specify your API key in the application manifest `android/app/src/main/AndroidManifest.xml`:

   ```xml
   <manifest ...
     <application ...
       <meta-data android:name="com.google.android.geo.API_KEY"
                  android:value="YOUR KEY HERE"/>
   ```

2. Read about Android-specific features and limitations in the
   [`google_maps_flutter_android` README](https://pub.dev/packages/google_maps_flutter_android).

### iOS

1. Specify your API key in the application delegate `ios/Runner/AppDelegate.swift`:

   ```swift
   import UIKit
   import Flutter
   import GoogleMaps

   @UIApplicationMain
   @objc class AppDelegate: FlutterAppDelegate {
     override func application(
       _ application: UIApplication,
       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
     ) -> Bool {
       GMSServices.provideAPIKey("YOUR KEY HERE")
       GeneratedPluginRegistrant.register(with: self)
       return super.application(application, didFinishLaunchingWithOptions: launchOptions)
     }
   }
   ```

2. Select an SDK version. The Google Maps SDK for iOS usually releases a new
   major version once per year, dropping support for an older version of iOS
   with each major release; see
   [the SDK release notes](https://developers.google.com/maps/documentation/ios-sdk/releases)
   for details of the minimum supported iOS version for each release. There is a
   pub package for each SDK release.
   - By default, this plugin uses [`google_maps_flutter_ios`](https://pub.dev/packages/google_maps_flutter_ios),
     which will automatically select the latest SDK release that is compatible
     with your project's minimum iOS version, up to version 10.x. This
     functionality relies on CocoaPods, so this implementation is not compatible
     with [Swift Package Manager](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers).
     Because the Google Maps SDK [will not be releasing future versions via
     CocoaPods](https://developers.google.com/maps/documentation/ios-sdk/release-notes#August_18_2025)
     this implementation will not support SDK releases past 10.x.
   - To use a specific SDK release, add a dependency on the corresponding
     package to your `pubspec.yaml` file. All of the SDK-specific packages
     support Swift Package Manager. In general, you should use the latest SDK
     release that is compatible with your project's minimum iOS version:
     - [`google_maps_flutter_ios_sdk9`](https://pub.dev/packages/google_maps_flutter_ios_sdk9)
       requires iOS 15.0 or higher.
     - [`google_maps_flutter_ios_sdk10`](https://pub.dev/packages/google_maps_flutter_ios_sdk10)
       requires iOS 16.0 or higher.
     - Future major SDK versions will be available as new packages.

   **Important:** Package authors depending on `google_maps_flutter`
   **should not** depend on a specific implementation package, as that will
   prevent application developers from selecting the appropriate SDK version for
   their project. Instead, just depend on `google_maps_flutter` as usual, and
   leave the choice of SDK version to application developers.

3. Read about iOS-specific features and limitations in the README for the
   package you selected in step 2.

### Web

1. Add the following to the `<head>` section of `web/index.html`:

   ```html
   <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY"></script>
   ```

2. Read about web-specific features and limitations in the
   [`google_maps_flutter_web` README](https://pub.dev/packages/google_maps_flutter_web).

### All

You can now add a `GoogleMap` widget to your widget tree.

The map view can be controlled with the `GoogleMapController` that is passed to
the `GoogleMap`'s `onMapCreated` callback.

The `GoogleMap` widget should be used within a widget with a bounded size. Using it
in an unbounded widget will cause the application to throw a Flutter exception.

### Sample Usage

<?code-excerpt "readme_sample.dart (MapSample)"?>
```dart
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

See the `example` directory for a complete sample app.
