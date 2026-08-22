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

```dart
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

final directory = await getApplicationDocumentsDirectory();
final videoPath = p.join(directory.path, 'my_video.mp4');

await controller.startVideoRecording(videoOutputPath: videoPath);
```

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
