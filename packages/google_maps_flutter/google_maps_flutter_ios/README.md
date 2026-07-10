# google\_maps\_flutter\_ios

The default iOS implementation of [`google_maps_flutter`][1].

This package will use Google Maps SDK 8.4, 9.x, or 10.x, depending on your
application's minimum deployment target.

## Usage

This package is [endorsed][2], which means you can simply use
`google_maps_flutter` normally. This package will be automatically included in
your app when you do, so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

### Alternate Implementations

This package is the default implementation only to preserve compatibility with
previous versions of the plugin. Unless you need to support iOS 14, you should
use one of the SDK-specific packages instead:

* [`google_maps_flutter_ios_sdk9`](https://pub.dev/packages/google_maps_flutter_ios_sdk9)
  for iOS 15+.
* [`google_maps_flutter_ios_sdk10`](https://pub.dev/packages/google_maps_flutter_ios_sdk10)
  for iOS 16+.

Using an SDK-specific package will allow you to [use Swift Package
Manager](#swift-package-manager) instead of CocoaPods, and will allow using
future major SDK releases beyond 10.x.

## Setup

Specify your API key in the application delegate `ios/Runner/AppDelegate.swift`:

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

## Swift Package Manager

This package cannot support [Swift Package Manager][4], as Swift Package Manager
does not support automatically selecting the appropriate version of the
Google Maps SDK based on the minimum deployment target. For Swift Package
Manager compatibility, you should use the appropriate
[`google_maps_flutter_ios_sdk*` package][3] instead.

Because the Google Maps SDK [will not be releasing versions beyond 10.x via
CocoaPods](https://developers.google.com/maps/documentation/ios-sdk/release-notes#August_18_2025),
this package will not add support for newer SDKs in the future, as it had
historically done.

## Supported Heatmap Options

| Field                        | Supported |
| ---------------------------- | :-------: |
| Heatmap.dissipating          |     x     |
| Heatmap.maxIntensity         |     x     |
| Heatmap.minimumZoomIntensity |     ✓     |
| Heatmap.maximumZoomIntensity |     ✓     |
| HeatmapGradient.colorMapSize |     ✓     |

[1]: https://pub.dev/packages/google_maps_flutter
[2]: https://flutter.dev/to/endorsed-federated-plugin
[3]: https://pub.dev/packages?q=implements-federated-plugin%3Agoogle_maps_flutter+platform%3Aios
[4]: https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers
