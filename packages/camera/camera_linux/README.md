# Camera Linux Plugin

The Linux implementation of [`camera`][camera].

*Note*: This plugin is under development.
See [missing implementations and limitations](#missing-features-on-the-linux-platform).

## Usage

### Depend on the package

This package is not an [endorsed][endorsed-federated-plugin]
implementation of the [`camera`][camera] plugin, so in addition to depending
on [`camera`][camera] you'll need to
[add `camera_linux` to your pubspec.yaml explicitly][install].
Once you do, you can use the [`camera`][camera] APIs as you normally would.

### Build requirements

The native part is a single C file that uses the kernel's V4L2 API and is
compiled by a [build hook][hooks] when the app is built. Besides a C compiler
and the kernel headers that come with every distribution's toolchain, nothing
needs to be installed, and the resulting `libcamera_linux.so` depends on libc
only. Flutter bundles it through the native-assets install step in the
app's `linux/CMakeLists.txt`, which `flutter create` has generated since
Flutter 3.24; older runners need that block added.

At run time the user needs access to the `/dev/video*` node, which desktop
distributions grant through the `video` group or logind. In a Flatpak that
means `--device=all` or the camera portal.

## How frames are produced

Frames are captured with memory-mapped streaming and reach Dart as JPEG:

- MJPEG cameras are passed through. UVC cameras often omit the Huffman tables
  from their MJPEG frames, which makes decoders reject them, so the standard
  tables are inserted when missing.
- YUYV, UYVY, YVYU, VYUY, NV12, NV21, YU12, YV12, RGB24, BGR24 and GREY
  frames are converted and encoded with the public-domain
  [stb_image_write](https://github.com/nothings/stb) encoder in
  `src/third_party/stb`.

Uncompressed formats are preferred when a camera offers both, so that the
JPEG an app sees is the same for every camera.

`availableCameras` names cameras by device node (`/dev/video0`), skipping
nodes that cannot stream video such as UVC metadata nodes. `ResolutionPreset`
maps to a requested size (`low` 320x240, `medium` 640x480, `high` 1280x720,
`veryHigh` 1920x1080, `ultraHigh` 3840x2160, `max` the largest the driver
offers); the driver picks the nearest size it supports and the actual size is
reported by `CameraInitializedEvent`.

`takePicture` writes the next frame to a JPEG file in the system temporary
directory. Image streaming (`onStreamedFrameAvailable`) delivers each frame
as a single `ImageFormatGroup.jpeg` plane, which avoids the file round trip.

## Missing features on the Linux platform

### Preview

There is no texture-based preview. `buildPreview` shows the frames as they
arrive, which is adequate for viewfinders and scanners at webcam frame rates
but costs a JPEG decode per frame.

### Video recording

Video recording is not supported; the recording methods throw
`UnsupportedError`.

### Flash, zoom, focus and exposure

V4L2 controls are not exposed yet. The setters throw `UnsupportedError`, and
the getters return the neutral values the app-facing package expects.

### Device orientation

Desktops do not rotate; `onDeviceOrientationChanged` reports landscape, as the
Windows implementation does.

## Error handling

Camera errors, such as the camera being unplugged, are reported through
`onCameraError`, after which the camera must be disposed.

## Development

```sh
flutter test                       # builds the hook, runs the unit tests
cd example && flutter run -d linux
```

The unit tests cover the pixel-format conversions, the encoder and the MJPEG
repair without hardware, and the platform implementation against a fake
capture session. One test streams from a real camera and is skipped when
none is attached. To exercise it without a webcam, load `v4l2loopback` and
feed it frames with `tool/v4l2loopback_feed.dart`:

```sh
sudo modprobe v4l2loopback video_nr=42 card_label=test exclusive_caps=1
dart run tool/v4l2loopback_feed.dart /dev/video42 --format yuyv --text hello &
CAMERA_LINUX_DEVICE=/dev/video42 flutter test
```

`--format mjpeg --strip-dht` reproduces cameras whose MJPEG frames lack
Huffman tables. `dart run tool/probe.dart` reports the format, size, latency
and throughput of the default device.

<!-- Links -->

[camera]: https://pub.dev/packages/camera
[endorsed-federated-plugin]: https://flutter.dev/to/endorsed-federated-plugin
[install]: https://pub.dev/packages/camera_linux/install
[hooks]: https://dart.dev/tools/hooks
