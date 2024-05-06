# camera\_android\_camerax

An Android implementation of [`camera`][1] that uses the [CameraX library][2].

*Note*: This implementation will become the default implementation of `camera`
on Android by May 2024, so **we strongly encourage you to opt into it**
by using [the instructions](#usage) below. If any of [the limitations](#limitations)
prevent you from using `camera_android_camerax` or if you run into any problems,
please report these issues under [`flutter/flutter`][5] with `[camerax]` in
the title.

## Usage

To use this plugin instead of [`camera_android`][4], run

```sh
$ flutter pub add camera_android_camerax
```

from your project's root directory.

## Limitations

### Concurrent preview display, video recording, image capture, and image streaming

The CameraX plugin only supports the concurrent camera use cases supported by Camerax; see
[their documentation][6] for more information. To avoid the usage of unsupported concurrent
use cases, the plugin behaves according to the following:

* If the preview is paused (via `pausePreview`), concurrent video recording and image capture
  and/or image streaming (via `startVideoCapturing(cameraId, VideoCaptureOptions(streamCallback:...))`)
  is supported.
* If the preview is not paused
  * **and** the camera device is at least supported hardware [`LIMITED`][8], then concurrent
    image capture and video recording is supported.
  * **and** the camera device is at least supported hardware [`LEVEL_3`][7], then concurrent
    video recording and image streaming is supported, but concurrent video recording, image
    streaming, and image capture is not supported.

### 240p resolution configuration for video recording

240p resolution configuration for video recording is unsupported by CameraX,
and thus, the plugin will fall back to 480p if configured with a
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
[3]: https://docs.flutter.dev/packages-and-plugins/developing-packages#non-endorsed-federated-plugin
[4]: https://pub.dev/packages/camera_android
[5]: https://github.com/flutter/flutter/issues/new/choose
[6]: https://developer.android.com/media/camera/camerax/architecture#combine-use-cases
[7]: https://developer.android.com/reference/android/hardware/camera2/CameraMetadata#INFO_SUPPORTED_HARDWARE_LEVEL_3
[8]: https://developer.android.com/reference/android/hardware/camera2/CameraMetadata#INFO_SUPPORTED_HARDWARE_LEVEL_LIMITED
[120462]: https://github.com/flutter/flutter/issues/120462
[125915]: https://github.com/flutter/flutter/issues/125915
[120715]: https://github.com/flutter/flutter/issues/120715
[120468]: https://github.com/flutter/flutter/issues/120468
[120467]: https://github.com/flutter/flutter/issues/120467
[125371]: https://github.com/flutter/flutter/issues/125371
[126477]: https://github.com/flutter/flutter/issues/126477
[127896]: https://github.com/flutter/flutter/issues/127896
