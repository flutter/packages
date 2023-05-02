# camera\_android\_camerax

An Android implementation of [`camera`][1] that uses the [CameraX library][2].

*Note*: This package is under development.
See [missing implementations and limitations](#missing-features-and-limitations).

## Usage

This package is [unendorsed][3]; the endorsed Android implementation of `camera`
is [`camera_android`][4]. To use this implementation of the plugin, you will need
to specify it in your `pubsepc.yaml` file as a dependency in addition to `camera`:

```yaml
dependencies:
  # ...along with your other dependencies
  camera: ^0.10.4
  camera_android_camerax: ^0.5.0
```

## Contributing


## Missing features and limitations

### Resolution configuration \[[Issue #120462][5]\]

Any specified `ResolutionPreset` is unused in favor of CameraX defaults and
`onCameraResolutionChanged` is unimplemented.

### Locking/Unlocking capture orientation \[[Issue #125915][6]\]

`lockCaptureOrientation` & `unLockCaptureOrientation` are unimplemented.

### Flash mode configuration \[[Issue #120715][7]\]

`setFlashMode` is unimplemented.

### Exposure mode, point, & offset configuration \[[Issue #120468][8]\]

`setExposureMode`, `setExposurePoint`, & `setExposureOffset` are unimplemented.

### Focus mode & point configuration \[[Issue #120467][9]\]

`setFocusMode` & `setFocusPoint` are unimplemented.

### Zoom configuration \[[Issue #125371][9]\]

`setZoomLevel` is unimplemented.

<!-- Links -->

[1]: https://pub.dev/packages/camera
[2]: https://developer.android.com/training/camerax
[3]: https://docs.flutter.dev/packages-and-plugins/developing-packages#non-endorsed-federated-plugin
[4]: https://pub.dev/packages/camera_android
[5]: https://github.com/flutter/flutter/issues/120462
[6]: https://github.com/flutter/flutter/issues/125915
[7]: https://github.com/flutter/flutter/issues/120715
[8]: https://github.com/flutter/flutter/issues/120468
[9]: https://github.com/flutter/flutter/issues/120467
[10]: https://github.com/flutter/flutter/issues/125371
