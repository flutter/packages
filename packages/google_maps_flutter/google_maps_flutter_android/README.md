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

This is the the current default mode and corresponds to `useAndroidViewSurface = false`.
This mode is more performant than Hybrid Composition and we recommend that you use this mode.

### Hybrid Composition

This mode is available for backwards compatability and corresponds to `useAndroidViewSurface = true`.
We do not recommend its use as it is less performant than Texture Layer Hybrid Composition and
certain flutter rendering effects are not supported. 

If you require this mode for correctness, please file a bug so we can investigate and fix
the issue in the TLHC mode.

## Map renderer

This plugin supports the option to request a specific [map renderer][5].

The renderer must be requested before creating GoogleMap instances, as the renderer can be initialized only once per application context.

<?code-excerpt "readme_excerpts.dart (MapRenderer)"?>
```dart
AndroidMapRenderer mapRenderer = AndroidMapRenderer.platformDefault;
// ···
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    mapRenderer = await mapsImplementation
        .initializeWithRenderer(AndroidMapRenderer.latest);
  }
```

`AndroidMapRenderer.platformDefault` corresponds to `AndroidMapRenderer.latest`.

You are not guaranteed to get the requested renderer. For example, on emulators without
Google Play the latest renderer will not be available and the legacy renderer will always be used.

WARNING: `AndroidMapRenderer.legacy` is known to crash apps and is no longer supported by the Google Maps team
and therefore cannot be supported by the Flutter team.

[1]: https://pub.dev/packages/google_maps_flutter
[2]: https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin
[3]: https://docs.flutter.dev/development/platform-integration/android/platform-views
[4]: https://github.com/flutter/flutter/issues/103686
[5]: https://developers.google.com/maps/documentation/android-sdk/renderer
