# Camera Linux V4L2 Plugin

The Linux implementation of [`camera`][camera] using Video4Linux2 (V4L2).

*Note*: This plugin is under development.
See [missing features and limitations](#missing-features-and-limitations).

## Usage

### Depend on the package

This package is not an [endorsed][endorsed-federated-plugin]
implementation of the [`camera`][camera] plugin, so in addition to depending
on [`camera`][camera] you'll need to
[add `camera_linux_v4l2` to your pubspec.yaml explicitly][install].
Once you do, you can use the [`camera`][camera] APIs as you normally would.

### Camera access

The plugin opens `/dev/video*` devices directly, so the user running the
application needs read and write access to them. Desktop distributions normally
grant this to the logged-in user or to members of the `video` group. Sandboxed
applications, such as snaps and Flatpaks, also need permission from the sandbox
to access cameras.

## Supported features

- Listing cameras (`availableCameras`). Every `/dev/videoN` device that
  supports streaming capture in a supported pixel format is reported as an
  external camera whose name is its device path.
- Preview (`buildPreview`).
- Image streaming (`onStreamedFrameAvailable`). Frames are delivered as
  `ImageFormatGroup.bgra8888`. When frames arrive faster than they are
  consumed, the intermediate frames are dropped.
- Resolution presets. Each preset requests the size below, and the camera
  selects the closest size that it supports.

  | Preset      | Requested size |
  |-------------|----------------|
  | `low`       | 320x240        |
  | `medium`    | 640x480        |
  | `high`      | 1280x720       |
  | `veryHigh`  | 1920x1080      |
  | `ultraHigh` | 3840x2160      |
  | `max`       | 4096x2160      |

- Camera errors (`onCameraError`), such as the camera being unplugged, or the
  camera being unable to deliver intact frames at the selected resolution.

## Missing features and limitations

- Only cameras that provide uncompressed `YUYV`, `RGB24`, or `BGR24` frames are
  supported. Cameras that only provide other formats, such as `MJPEG` or
  `NV12`, are not listed. Because many USB cameras rely on `MJPEG` for higher
  resolutions, they may only reach low frame rates above 640x480.
- Frame sizes with more pixels than 4096x2160 are not supported.
- Still image capture (`takePicture`).
- Video recording and audio.
- Pausing and resuming the preview.
- Camera controls: flash, zoom, focus, and exposure.

Methods for the missing features throw `UnimplementedError`.

<!-- Links -->

[camera]: https://pub.dev/packages/camera
[endorsed-federated-plugin]: https://flutter.dev/to/endorsed-federated-plugin
[install]: https://pub.dev/packages/camera_linux_v4l2/install
