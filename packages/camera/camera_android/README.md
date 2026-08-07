# camera\_android

An Android implementation of [`camera`][1] built with the [Camera2 library][4].

## Usage

As of `camera: ^0.11.0`, to use this plugin instead of [`camera_android_camerax`][3],
run

```sh
$ flutter pub add camera_android
```

## Limitation of testing video recording on emulators
`MediaRecorder` does not work properly on emulators, as stated in [the documentation][5]. Specifically,
when recording a video with sound enabled and trying to play it back, the duration won't be correct and
you will only see the first frame.

## Custom Video Recording Path

Although it is possible to use an absolute path like `/storage/emulated/0/Download/video.mp4`, this is a fragile practice and may fail on many devices or Android versions due to **Scoped Storage** restrictions.

- **Best Practice:** Always use the [path_provider](https://pub.dev/packages/path_provider) package to fetch a safe, writable directory.
- **Recommended Directory:** Use `getTemporaryDirectory()` or `getApplicationDocumentsDirectory()`.

```dart
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

final directory = await getTemporaryDirectory();
final videoPath = p.join(directory.path, 'my_video.mp4');

await controller.startVideoRecording(videoOutputPath: videoPath);
```

[1]: https://pub.dev/packages/camera
[2]: https://flutter.dev/to/endorsed-federated-plugin
[3]: https://pub.dev/packages/camera_android_camerax
[4]: https://developer.android.com/media/camera/camera2
[5]: https://developer.android.com/reference/android/media/MediaRecorder
