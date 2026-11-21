<?code-excerpt path-base="example/lib"?>

# camera\_avfoundation

The iOS implementation of [`camera`][1].

## Usage

This package is [endorsed][2], which means you can simply use `camera`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

## Custom Video Recording Path

You can optionally specify a `videoOutputPath` when calling `startVideoRecording()` to save the recorded video directly to a custom absolute file path on the device.

By default, files saved within the application sandbox are private. If you want the recorded videos to be visible and manageable by the user inside the native iOS **Files app**:

1. Open your `ios/Runner/Info.plist` file.
2. Add the following keys set to `true`:

```xml
<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>
<key>UISupportsDocumentBrowser</key>
<true/>
```

## Responsive Capture

On iOS 17 and later, responsive capture lets a new photo capture start before
the previous photo has finished processing, at the cost of additional memory.
It is disabled by default, requires zero-shutter-lag to be enabled, and only
helps apps that call `CameraPlatform.instance.takePicture` again before the
previous call returns (`CameraController.takePicture` does not allow this).

It is an iOS-specific API, so check that the platform implementation is
`AVFoundationCamera` before calling it:

<?code-excerpt "readme_excerpts.dart (ResponsiveCapture)"?>
```dart
import 'package:camera_avfoundation/camera_avfoundation.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';

Future<void> enableResponsiveCapture(int cameraId) async {
  final CameraPlatform platform = CameraPlatform.instance;
  if (platform is AVFoundationCamera && await platform.isResponsiveCaptureSupported(cameraId)) {
    await platform.setResponsiveCaptureEnabled(cameraId, true);
  }
}
```

[1]: https://pub.dev/packages/camera
[2]: https://flutter.dev/to/endorsed-federated-plugin
