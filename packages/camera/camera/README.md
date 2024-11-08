# Camera Plugin

<?code-excerpt path-base="example/lib"?>

[![pub package](https://img.shields.io/pub/v/camera.svg)](https://pub.dev/packages/camera)

A Flutter plugin for iOS, Android and Web allowing access to the device cameras.

|                | Android | iOS       | Web                    |
|----------------|---------|-----------|------------------------|
| **Support**    | SDK 21+ | iOS 12.0+ | [See `camera_web `][1] |

## Features

* Display live camera preview in a widget.
* Snapshots can be captured and saved to a file.
* Record video.
* Add access to the image stream from Dart.

## Setup

### iOS

Add two rows to the `ios/Runner/Info.plist`:

* one with the key `Privacy - Camera Usage Description` and a usage description.
* and one with the key `Privacy - Microphone Usage Description` and a usage description.

If editing `Info.plist` as text, add:

```xml
<key>NSCameraUsageDescription</key>
<string>your usage description here</string>
<key>NSMicrophoneUsageDescription</key>
<string>your usage description here</string>
```

### Android

Change the minimum Android sdk version to 21 (or higher) in your `android/app/build.gradle` file.

```groovy
minSdkVersion 21
```

The endorsed [`camera_android_camerax`][2] implementation of the camera plugin built with CameraX has
better support for more devices than `camera_android`, but has some limitations; please see [this list][3]
for more details. If you wish to use the [`camera_android`][4] implementation of the camera plugin
built with Camera2 that lacks these limitations, please follow [these instructions][5].

If you wish to allow image streaming while your app is in the background, there are additional steps required;
please see [these instructions][6] for more details.

### Web integration

For web integration details, see the
[`camera_web` package](https://pub.dev/packages/camera_web).

### Handling Lifecycle states

As of version [0.5.0](https://github.com/flutter/packages/blob/main/packages/camera/CHANGELOG.md#050) of the camera plugin, lifecycle changes are no longer handled by the plugin. This means developers are now responsible to control camera resources when the lifecycle state is updated. Failure to do so might lead to unexpected behavior (for example as described in issue [#39109](https://github.com/flutter/flutter/issues/39109)). Handling lifecycle changes can be done by overriding the `didChangeAppLifecycleState` method like so:

<?code-excerpt "main.dart (AppLifecycle)"?>
```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  final CameraController? cameraController = controller;

  // App state changed before we got the chance to initialize.
  if (cameraController == null || !cameraController.value.isInitialized) {
    return;
  }

  if (state == AppLifecycleState.inactive) {
    cameraController.dispose();
  } else if (state == AppLifecycleState.resumed) {
    _initializeCameraController(cameraController.description);
  }
}
```

### Handling camera access permissions

Permission errors may be thrown when initializing the camera controller, and you are expected to handle them properly.

Here is a list of all permission error codes that can be thrown:

- `CameraAccessDenied`: Thrown when user denies the camera access permission.

- `CameraAccessDeniedWithoutPrompt`: iOS only for now. Thrown when user has previously denied the permission. iOS does not allow prompting alert dialog a second time. Users will have to go to Settings > Privacy > Camera in order to enable camera access.

- `CameraAccessRestricted`: iOS only for now. Thrown when camera access is restricted and users cannot grant permission (parental control).

- `AudioAccessDenied`: Thrown when user denies the audio access permission.

- `AudioAccessDeniedWithoutPrompt`: iOS only for now. Thrown when user has previously denied the permission. iOS does not allow prompting alert dialog a second time. Users will have to go to Settings > Privacy > Microphone in order to enable audio access.

- `AudioAccessRestricted`: iOS only for now. Thrown when audio access is restricted and users cannot grant permission (parental control).

### Example

Here is a small example flutter app displaying a full screen camera preview.

<?code-excerpt "readme_full_example.dart (FullAppExample)"?>
```dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(const CameraApp());
}

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(_cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: CameraPreview(controller),
    );
  }
}
```

For a more elaborate usage example see [here](https://github.com/flutter/packages/tree/main/packages/camera/camera/example).

[1]: https://pub.dev/packages/camera_web#limitations-on-the-web-platform
[2]: https://pub.dev/packages/camera_android_camerax
[3]: https://pub.dev/packages/camera_android_camerax#limitations
[4]: https://pub.dev/packages/camera_android
[5]: https://pub.dev/packages/camera_android#usage
[6]: https://pub.dev/packages/camera_android_camerax#allowing-image-streaming-in-the-background
