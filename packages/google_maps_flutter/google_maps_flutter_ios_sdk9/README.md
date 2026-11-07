# google\_maps\_flutter\_ios\_sdk9

An iOS implementation of [`google_maps_flutter`][1] using
[Google Maps SDK 9.x][2].

## Usage

This package is [endorsed][2], which means you can simply use
`google_maps_flutter` normally. This package will be automatically included in
your app when you do, so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

### Package Dependencies

If you are authoring a package, please *do not* depend on one of these specific
implementation packages unless you have a compelling reason to do so. Instead,
just depend on `google_maps_flutter`, so that application developers can
select the appropriate SDK version for their minimum iOS version target.

### Alternate Implementations

This package is the default implementation because it is compatible with iOS 15.
If you do not need to support iOS 15, you can use
[a newer `google_maps_flutter_ios_sdk*` package][4] instead.

## Setup

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

## Supported Heatmap Options

| Field                        | Supported |
| ---------------------------- | :-------: |
| Heatmap.dissipating          |     x     |
| Heatmap.maxIntensity         |     x     |
| Heatmap.minimumZoomIntensity |     ✓     |
| Heatmap.maximumZoomIntensity |     ✓     |
| HeatmapGradient.colorMapSize |     ✓     |

[1]: https://pub.dev/packages/google_maps_flutter
[2]: https://developers.google.com/maps/documentation/ios-sdk/release-notes
[3]: https://flutter.dev/to/endorsed-federated-plugin
[4]: https://pub.dev/packages?q=implements-federated-plugin%3Agoogle_maps_flutter+platform%3Aios
