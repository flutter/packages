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

[1]: https://pub.dev/packages/camera
[2]: https://flutter.dev/to/endorsed-federated-plugin

## HDR preview

Requesting `PreviewDynamicRange.hlg10` (see `MediaSettings.previewDynamicRange`) is supported on
devices that have a 10-bit format with the HLG BT.2020 color space. The preview is then shown with
an `AVCaptureVideoPreviewLayer` in a platform view. HLG is a setting of the whole capture session,
so while it is active:

* The `max` resolution preset uses the largest HLG format with the same aspect ratio, which can be
  smaller than the largest SDR format. Other presets use HLG only when an HLG format of exactly
  their size exists.
* Video is recorded in HLG (10-bit HEVC).
* Zero-shutter-lag can be unavailable; check `isZeroShutterLagSupported`.
* Image streaming keeps the session in HLG. Frames are narrowed to the requested 8-bit format
  (`yuv420` or `bgra8888`); their values stay HLG BT.2020 encoded and are not tone mapped.

* `setDescriptionWhileRecording` fails for a camera that has no HLG format.

`getPreviewDynamicRange` reports the dynamic range that the camera was created with.
