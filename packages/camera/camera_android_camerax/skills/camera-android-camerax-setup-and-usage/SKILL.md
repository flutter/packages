---
name: camera-android-camerax-setup-and-usage
description: Set up and use the camera_android_camerax plugin, the Android implementation of Flutter's camera plugin built on Jetpack CameraX.
---

# Setting Up and Using camera_android_camerax

`camera_android_camerax` is the endorsed Android platform implementation of the Flutter [`camera`](https://pub.dev/packages/camera) plugin, built using Android's Jetpack CameraX library.

## 1. Installation and Setup

Because `camera_android_camerax` is the endorsed Android implementation of `camera`, adding `camera` to your `pubspec.yaml` automatically includes it:

```yaml
dependencies:
  camera: ^0.11.0
```

If you need to depend on `camera_android_camerax` directly (for example, to pin a specific version or access Android CameraX-specific APIs):

```yaml
dependencies:
  camera: ^0.11.0
  camera_android_camerax: ^0.7.0
```

### Android Requirements (`android/app/build.gradle`)
Ensure your Android project meets the minimum SDK requirements required by Jetpack CameraX:

```groovy
android {
    defaultConfig {
        minSdkVersion 21 // CameraX requires API level 21 or higher
        compileSdkVersion 35
    }
}
```

### Android Permissions (`AndroidManifest.xml`)
Camera permissions are declared automatically by the plugin's manifest, including `android.permission.CAMERA` and `android.permission.RECORD_AUDIO` (when `enableAudio: true` is passed to `CameraController`).

## 2. Usage via the App-Facing `camera` Package

In standard Flutter apps, interact with `camera_android_camerax` through the app-facing `camera` API:

```dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<CameraDescription> cameras = await availableCameras();
  runApp(MyApp(camera: cameras.first));
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, required this.camera});
  final CameraDescription camera;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: true,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return CameraPreview(_controller);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
```

## 3. Direct Platform Registration (Advanced)

If you are swapping between `camera_android` (Camera2) and `camera_android_camerax` (CameraX) or testing the platform implementation directly:

```dart
import 'package:camera_android_camerax/camera_android_camerax.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';

void useCameraXImplementation() {
  CameraPlatform.instance = AndroidCameraCameraX();
}
```
