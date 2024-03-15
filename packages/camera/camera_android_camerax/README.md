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
`camera_android`, you will need to specify it in your `pubspec.yaml` file as a
dependency in addition to `camera`:

```yaml
dependencies:
  # ...along with your other dependencies
  camera: ^0.10.4
  camera_android_camerax: ^0.5.0
```

## Missing features and limitations

### 240p resolution configuration for video recording

240p resolution configuration for video recording is unsupported by CameraX,
and thus, the plugin will fall back to 480p if configured with a
`ResolutionPreset`.

### Focus mode configuration \[[Issue #120467][120467]\]

`setFocusMode` is unimplemented.

### Setting maximum duration and stream options for video capture

Calling `startVideoCapturing` with `VideoCaptureOptions` configured with
`maxVideoDuration` and `streamOptions` is currently unsupported do to the
limitations of the CameraX library and the platform interface, respectively,
and thus, those parameters will silently be ignored.

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
