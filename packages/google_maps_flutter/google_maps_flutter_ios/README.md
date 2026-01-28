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

## Swift Package Manager

This package cannot support Swift Package Manager, as Swift Package Manager
does not support automatically selecting the appropriate version of the
Google Maps SDK based on the minimum deployment target. For Swift Package
Manager compatibility, you should use the appropriate
[`google_maps_flutter_ios_sdk*` package][3] instead.


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
