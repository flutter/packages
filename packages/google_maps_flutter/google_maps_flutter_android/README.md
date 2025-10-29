# google\_maps\_flutter\_android

<?code-excerpt path-base="example/lib"?>

The Android implementation of [`google_maps_flutter`][1].

## Usage

This package is [endorsed][2], which means you can simply use
`google_maps_flutter` normally. This package will be automatically included in
your app when you do, so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

## Display Mode

This plugin supports two different [platform view display modes][3]. The default
display mode is subject to change in the future, and will not be considered a
breaking change, so if you want to ensure a specific mode you can set it
explicitly:

<?code-excerpt "readme_excerpts.dart (DisplayMode)"?>
```dart
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  // Require Hybrid Composition mode on Android.
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    // Force Hybrid Composition mode.
    mapsImplementation.useAndroidViewSurface = true;
  }
  // ···
}
```

### Texture Layer Hybrid Composition

This is the current default mode and corresponds to `useAndroidViewSurface = false`.
This mode is more performant than Hybrid Composition and we recommend that you use this mode.

### Hybrid Composition

This mode is available for backwards compatability and corresponds to `useAndroidViewSurface = true`.
We do not recommend its use as it is less performant than Texture Layer Hybrid Composition and
certain flutter rendering effects are not supported.

If you require this mode for correctness, please file a bug so we can investigate and fix
the issue in the TLHC mode.

## Supported Heatmap Options

| Field                        | Supported |
| ---------------------------- | :-------: |
| Heatmap.dissipating          |     x     |
| Heatmap.maxIntensity         |     ✓     |
| Heatmap.minimumZoomIntensity |     x     |
| Heatmap.maximumZoomIntensity |     x     |
| HeatmapGradient.colorMapSize |     ✓     |

## Warmup

The first time a map is shown, the Google Maps SDK may briefly block 
the main thread, which could cause UI jank. 
If you prefer to control when this happens, you can call
`GoogleMapsFlutterAndroid.warmup()` at some point before showing any maps to
pre-warm the SDK. See this plugin's example code for one way of using this API.

[1]: https://pub.dev/packages/google_maps_flutter
[2]: https://flutter.dev/to/endorsed-federated-plugin
[3]: https://docs.flutter.dev/development/platform-integration/android/platform-views
[4]: https://github.com/flutter/flutter/issues/103686
[5]: https://developers.google.com/maps/documentation/android-sdk/renderer
