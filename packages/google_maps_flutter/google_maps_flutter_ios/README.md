# google\_maps\_flutter\_ios

The iOS implementation of [`google_maps_flutter`][1].

## Usage

This package is [endorsed][2], which means you can simply use
`google_maps_flutter` normally. This package will be automatically included in
your app when you do, so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

## Supported Heatmap Options

| Field                        | Supported |
| ---------------------------- | :-------: |
| Heatmap.dissipating          |     x     |
| Heatmap.maxIntensity         |     x     |
| Heatmap.minimumZoomIntensity |     ✓     |
| Heatmap.maximumZoomIntensity |     ✓     |
| HeatmapGradient.colorMapSize |     ✓     |

## Swift Package Manager Support

This package supports Swift Package Manager for projects targeting iOS 15 or above. For projects targeting iOS 14, you need to disable Swift Package Manager. For more information on how to disable Swift Package Manager for a single project, refer to [this document][3].

[1]: https://pub.dev/packages/google_maps_flutter
[2]: https://flutter.dev/to/endorsed-federated-plugin
[3]: https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers#turn-off-for-a-single-project
