---
name: camera-avfoundation
description: Set up and use camera_avfoundation, the endorsed iOS implementation of Flutter's camera plugin built on Apple's AVFoundation framework.
---

# Setting Up and Using `camera_avfoundation`

[`camera_avfoundation`](https://pub.dev/packages/camera_avfoundation) is the endorsed iOS platform implementation of the Flutter [`camera`](https://pub.dev/packages/camera) plugin, built using Apple's AVFoundation framework.

## 1. Installation and `pubspec.yaml` Setup

### Endorsed Usage (Recommended)

Because `camera_avfoundation` is endorsed by `camera`, you only need to depend on `camera` in your `pubspec.yaml`. It will be included automatically on iOS:

```yaml
dependencies:
  camera: ^0.12.1
```

### Direct Dependency Usage

If you need to import `camera_avfoundation` directly or pin a specific version in your app, add it explicitly to your `pubspec.yaml`:

```yaml
dependencies:
  camera: ^0.12.1
  camera_avfoundation: ^0.10.3
```

## 2. Platform-Specific Configuration

### iOS `Info.plist` Permissions

You must provide usage descriptions for both camera and microphone access in `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to capture photos and videos.</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need access to your microphone to record audio during video capture.</string>
```

If a user denies permissions on iOS, subsequent initialization attempts throw a `CameraException` with one of the following iOS-specific codes:
- `CameraAccessDeniedWithoutPrompt`: Permission was previously denied; direct the user to **Settings > Privacy > Camera**.
- `CameraAccessRestricted`: Camera access is restricted (e.g., via Screen Time / parental controls).
- `AudioAccessDeniedWithoutPrompt` / `AudioAccessRestricted`: Microphone access was previously denied or is restricted.

The minimum supported deployment target is **iOS 13.0**.

## 3. Usage and API Examples

### Standard Usage via `package:camera`

In most Flutter applications, interact with `camera_avfoundation` through the app-facing `camera` package:

```dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<CameraDescription> cameras = await availableCameras();
  runApp(IosCameraApp(camera: cameras.first));
}

class IosCameraApp extends StatefulWidget {
  const IosCameraApp({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<IosCameraApp> createState() => _IosCameraAppState();
}

class _IosCameraAppState extends State<IosCameraApp> {
  late CameraController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: true,
    );
    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return MaterialApp(
      home: Scaffold(
        body: CameraPreview(_controller),
      ),
    );
  }
}
```

### Direct Registration or Testing

If you are registering or testing the iOS implementation directly against `CameraPlatform`:

```dart
import 'package:camera_avfoundation/camera_avfoundation.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';

void registerIosCamera() {
  AVFoundationCamera.registerWith();
  // Or explicitly set:
  CameraPlatform.instance = AVFoundationCamera();
}
```
