# camera\_android\_camerax

The Android implementation of [`camera`][1] built with the [CameraX library][2].

*Note*: If any of [the limitations](#limitations) prevent you from using
using `camera_android_camerax` or if you run into any problems, please report
these issues under [`flutter/flutter`][5] with `[camerax]` in the title.
You may also opt back into the [`camera_android`][9] implementation if you need.

## Usage

As of `camera: ^0.11.0`, this package is [endorsed][3], which means you can
simply use `camera` normally. This package will be automatically be included
in your app when you do, so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

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

### `setDescriptionWhileRecording` is unimplemented [Issue #148013][148013]
`setDescriptionWhileRecording`, used to switch cameras while recording video, is currently unimplemented
due to this not currently being supported by CameraX.

### 240p resolution configuration for video recording

240p resolution configuration for video recording is unsupported by CameraX, and thus,
the plugin will fall back to target 480p (`ResolutionPreset.medium`) if configured with
`ResolutionPreset.low`.

### Setting stream options for video capture

Calling `startVideoCapturing` with `VideoCaptureOptions` configured with
`streamOptions` is currently unsupported do to
limitations of the platform interface,
and thus that parameter will silently be ignored.

## What requires Android permissions

### Writing to external storage to save image files

In order to save captured images and videos to files on Android 10 and below, CameraX
requires specifying the `WRITE_EXTERNAL_STORAGE` permission (see [the CameraX documentation][10]).
This is already done in the plugin, so no further action is required on your end.

To understand the privacy impact of specifying the `WRITE_EXTERNAL_STORAGE` permission, see the
[`WRITE_EXTERNAL_STORAGE` documentation][11]. We have seen apps also have the [`READ_EXTERNAL_STORAGE`][13]
permission automatically added to the merged Android manifest; it appears to be implied from
`WRITE_EXTERNAL_STORAGE`. If you do not want the `READ_EXTERNAL_STORAGE` permission to be included
in the merged Android manifest of your app, then take the following steps to remove it:

1. Ensure that your app nor any of the plugins that it depends on require the `READ_EXTERNAL_STORAGE` permission.
2. Add the following to your app's `your_app/android/app/src/main/AndroidManifest.xml`:

```xml
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    tools:node="remove" />
```

### Allowing image streaming in the background

As of Android 14, to allow for background image streaming, you will need to specify the foreground
[`TYPE_CAMERA`][12] foreground service permission in your app's manifest. Specifically, in
`your_app/android/app/src/main/AndroidManifest.xml` add the following:

```xml
<manifest ...>
  <uses-permission android:name="android.permission.FOREGROUND_SERVICE_CAMERA" />
  ...
</manifest>
```

## Contributing

For more information on contributing to this plugin, see [`CONTRIBUTING.md`](CONTRIBUTING.md).

<!-- Links -->

[1]: https://pub.dev/packages/camera
[2]: https://developer.android.com/training/camerax
[3]: https://flutter.dev/to/endorsed-federated-plugin
[4]: https://pub.dev/packages/camera_android
[5]: https://github.com/flutter/flutter/issues/new/choose
[6]: https://developer.android.com/media/camera/camerax/architecture#combine-use-cases
[7]: https://developer.android.com/reference/android/hardware/camera2/CameraMetadata#INFO_SUPPORTED_HARDWARE_LEVEL_3
[8]: https://developer.android.com/reference/android/hardware/camera2/CameraMetadata#INFO_SUPPORTED_HARDWARE_LEVEL_LIMITED
[9]: https://pub.dev/packages/camera_android#usage
[10]: https://developer.android.com/media/camera/camerax/architecture#permissions
[11]: https://developer.android.com/reference/android/Manifest.permission#WRITE_EXTERNAL_STORAGE
[12]: https://developer.android.com/reference/android/Manifest.permission#FOREGROUND_SERVICE_CAMERA
[13]: https://developer.android.com/reference/android/Manifest.permission#READ_EXTERNAL_STORAGE
[148013]: https://github.com/flutter/flutter/issues/148013
