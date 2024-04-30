# camera\_android\_camerax

The Android implementation of [`camera`][1] built with the [CameraX library][2].

*Note*: If any of [the limitations](#limitations) prevent you from using
using `camera_android_camerax` or if you run into any problems, please report
report these issues under [`flutter/flutter`][5] with `[camerax]` in the title.
You may also opt back into the [`camera_android`][6] implementation if you need.

## Usage

As of `camera: ^0.11.0`, this package is [endorsed][3], which means you can
simply use `camera` normally. This package will be automatically be included
in your app when you do, so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

If using `camera: <0.11.0` and wish to use this plugin instead of [`camera_android`][4],
run

```sh
$ flutter pub add camera_android_camerax
```

from your project's root directory.

## Limitations

### 240p resolution configuration for video recording

240p resolution configuration for video recording is unsupported by CameraX,
and thus, the plugin will fall back to target 480p if configured with a
`ResolutionPreset`.

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
[3]: https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin
[4]: https://pub.dev/packages/camera_android
[5]: https://github.com/flutter/flutter/issues/new/choose
[6]: https://pub.dev/packages/camera_android#usage