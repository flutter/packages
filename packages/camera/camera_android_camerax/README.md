# camera\_android\_camerax

An Android implementation of [`camera`][1] that uses the [CameraX library][2].

*Note*: This package is under development, so please note the
[missing features and limitations](#missing-features-and-limitations), but
otherwise feel free to try out the current implementation and provide any
feedback by filing issues under [`flutter/flutter`][5] with `[camerax]` in
the title, which will be actively triaged.

## Usage

This package is [non-endorsed][3]; the endorsed Android implementation of `camera`
is [`camera_android`][4]. To use this implementation of the plugin instead of
`camera_android`, you will need to specify it in your `pubsepc.yaml` file as a
dependency in addition to `camera`:

```yaml
dependencies:
  # ...along with your other dependencies
  camera: ^0.10.4
  camera_android_camerax: ^0.5.0
```

## Missing features and limitations

### Resolution configuration \[[Issue #120462][120462]\]

Any specified `ResolutionPreset` wll go unused in favor of CameraX defaults and
`onCameraResolutionChanged` is unimplemented.

### Locking/Unlocking capture orientation \[[Issue #125915][125915]\]

`lockCaptureOrientation` & `unLockCaptureOrientation` are unimplemented.

### Flash mode configuration \[[Issue #120715][120715]\]

`setFlashMode` is unimplemented.

### Exposure mode, point, & offset configuration \[[Issue #120468][120468]\]

`setExposureMode`, `setExposurePoint`, & `setExposureOffset` are unimplemented.

### Focus mode & point configuration \[[Issue #120467][120467]\]

`setFocusMode` & `setFocusPoint` are unimplemented.

### Zoom configuration \[[Issue #125371][125371]\]

`setZoomLevel` is unimplemented.

### Some video capture functionality \[[Issue #127896][127896], [Issue #126477][126477]\]

`startVideoCapturing` is unimplemented; use `startVideoRecording` instead.
`onVideoRecordedEvent` is also unimplemented.

## Contributing

For more information on contributing to this plugin, see [`CONTRIBUTING.md`](CONTRIBUTING.md).

<!-- Links -->

[1]: https://pub.dev/packages/camera
[2]: https://developer.android.com/training/camerax
[3]: https://docs.flutter.dev/packages-and-plugins/developing-packages#non-endorsed-federated-plugin
[4]: https://pub.dev/packages/camera_android
[5]: https://github.com/flutter/flutter/issues/new/choose
[120462]: https://github.com/flutter/flutter/issues/120462
[125915]: https://github.com/flutter/flutter/issues/125915
[120715]: https://github.com/flutter/flutter/issues/120715
[120468]: https://github.com/flutter/flutter/issues/120468
[120467]: https://github.com/flutter/flutter/issues/120467
[125371]: https://github.com/flutter/flutter/issues/125371
[126477]: https://github.com/flutter/flutter/issues/126477
[127896]: https://github.com/flutter/flutter/issues/127896
