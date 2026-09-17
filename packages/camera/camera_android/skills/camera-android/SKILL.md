---
name: camera-android
description: Set up and use camera_android, the Android Camera2 implementation of Flutter's camera plugin, including switching from CameraX and handling emulator limitations.
---

# Setting Up and Using `camera_android`

[`camera_android`](https://pub.dev/packages/camera_android) is an Android platform implementation of the Flutter [`camera`](https://pub.dev/packages/camera) plugin built with Android's [Camera2 API](https://developer.android.com/media/camera/camera2).

## 1. Installation and `pubspec.yaml` Setup

Since `camera: ^0.11.0`, the default endorsed Android implementation of `camera` is `camera_android_camerax` (built with Jetpack CameraX).

To opt into using `camera_android` (Camera2) instead of `camera_android_camerax`, explicitly add both `camera` and `camera_android` to your `pubspec.yaml`:

```yaml
dependencies:
  camera: ^0.12.1
  camera_android: ^0.10.11
```

Or run:

```sh
flutter pub add camera_android
```

## 2. Platform-Specific Configuration

### Android Configuration (`android/app/build.gradle`)

Ensure your Android project specifies `minSdkVersion 24` or higher:

```groovy
android {
    defaultConfig {
        minSdkVersion 24
        compileSdkVersion 35
    }
}
```

### Android Permissions (`AndroidManifest.xml`)

The plugin automatically declares required hardware features and permissions in its merged `AndroidManifest.xml`:
- `android.permission.CAMERA`
- `android.permission.RECORD_AUDIO` (requested when `enableAudio: true` is configured on `CameraController`)

### Emulator Limitations

`MediaRecorder` does not work properly on Android emulators when recording video with sound enabled: playback duration may be inaccurate and only the first video frame may be displayed. Always test video recording with audio on physical Android devices.

## 3. Usage and API Examples

### Standard App Usage via `package:camera`

Once `camera_android` is added to your `pubspec.yaml`, Flutter automatically registers `AndroidCamera` as the platform implementation on Android. Use the standard `camera` APIs in your application code:

```dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<CameraDescription> cameras = await availableCameras();
  runApp(CameraPreviewApp(camera: cameras.first));
}

class CameraPreviewApp extends StatefulWidget {
  const CameraPreviewApp({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<CameraPreviewApp> createState() => _CameraPreviewAppState();
}

class _CameraPreviewAppState extends State<CameraPreviewApp> {
  late CameraController _controller;
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: true,
    );
    _initFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder<void>(
          future: _initFuture,
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(_controller);
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
```

### Direct Platform Registration (Advanced)

If you need to manually switch to `camera_android` at runtime or in tests, assign `AndroidCamera` to `CameraPlatform.instance`:

```dart
import 'package:camera_android/camera_android.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';

void useCamera2Implementation() {
  CameraPlatform.instance = AndroidCamera();
}
```
