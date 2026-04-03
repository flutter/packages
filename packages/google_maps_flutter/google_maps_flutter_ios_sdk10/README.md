# google\_maps\_flutter\_ios\_sdk10

An iOS implementation of [`google_maps_flutter`][1] using
[Google Maps SDK 10.x][2].

## Usage

This package is not the default [endorsed][3] version, so to select this SDK
version for your implementation you must add a dependency on this package in
your application's pubspec.yaml. Once you do, it will automatically replace the
default implementation, then you can use `google_maps_flutter` as normal.

### Package Dependencies

If you are authoring a package, please *do not* depend on one of these specific
implementation packages unless you have a compelling reason to do so. Instead,
just depend on `google_maps_flutter`, so that application developers can
select the appropriate SDK version for their minimum iOS version target.

## Minimum iOS Version

Google Maps SDK 10.x requires iOS 16, so if your application does not already
require iOS 16 you must update your minimum iOS deployment version.

Alternatively, you could use a [different SDK version][4]
with a lower iOS version requirement.

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
