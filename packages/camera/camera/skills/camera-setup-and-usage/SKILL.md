---
name: camera-setup-and-usage
description: Set up and use the Flutter camera plugin to display live camera previews, capture photos, record videos, and stream image frames across Android, iOS, and Web.
---

# Setting Up and Using the Flutter Camera Plugin

The [`camera`](https://pub.dev/packages/camera) package provides cross-platform access to device cameras on Android, iOS, and Web (and Windows when adding `camera_windows`), supporting live camera previews, photo capture, video recording, and Dart image streaming.

## 1. Installation and `pubspec.yaml` Setup

Add `camera` to your project's `pubspec.yaml`:

```yaml
dependencies:
  camera: ^0.12.1
```

Or run:

```sh
flutter pub add camera
```

## 2. Platform-Specific Configuration

### Android Configuration

1. **Minimum SDK Version**: Set `minSdkVersion` to `24` or higher in `android/app/build.gradle` (or `build.gradle.kts`):

```groovy
android {
    defaultConfig {
        minSdkVersion 24
        compileSdkVersion 35
    }
}
```

2. **Permissions**: Camera and audio permissions (`android.permission.CAMERA` and `android.permission.RECORD_AUDIO`) are automatically included by the plugin manifest.
3. **Endorsed Implementation**: By default, `camera` uses `camera_android_camerax` (Jetpack CameraX). If you need the legacy Camera2 implementation instead, add `camera_android` to your `pubspec.yaml`.

### iOS Configuration

Add camera and microphone usage descriptions to your `ios/Runner/Info.plist` file:

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to take photos and record video.</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access to record audio with videos.</string>
```

The minimum supported iOS version is iOS 13.0+.

### Web Configuration

Accessing camera devices on Web requires a **secure browsing context** (`https://` or `localhost`). Insecure contexts will throw a `CameraException` with code `permissionDenied`.

## 3. Usage and API Examples

### Initializing Cameras and Handling Lifecycle States

As of version 0.5.0+, the application must manage camera lifecycle changes manually using `WidgetsBindingObserver.didChangeAppLifecycleState`.

```dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(const CameraApp());
}

class CameraApp extends StatefulWidget {
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_cameras.isNotEmpty) {
      _initializeCameraController(_cameras.first);
    }
  }

  Future<void> _initializeCameraController(
    CameraDescription description,
  ) async {
    final CameraController cameraController = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: true,
    );

    _controller = cameraController;

    try {
      await cameraController.initialize();
      if (!mounted) {
        return;
      }
      setState(() {
        _isCameraInitialized = true;
      });
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
        case 'CameraAccessDeniedWithoutPrompt':
        case 'CameraAccessRestricted':
        case 'AudioAccessDenied':
        case 'AudioAccessDeniedWithoutPrompt':
        case 'AudioAccessRestricted':
          debugPrint('Permission error: ${e.description}');
          break;
        default:
          debugPrint('Camera error (${e.code}): ${e.description}');
          break;
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(cameraController.description);
    }
  }

  Future<void> _takePicture() async {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (cameraController.value.isTakingPicture) {
      return;
    }

    try {
      final XFile picture = await cameraController.takePicture();
      debugPrint('Picture saved to ${picture.path}');
    } on CameraException catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  Future<void> _toggleVideoRecording() async {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    try {
      if (cameraController.value.isRecordingVideo) {
        final XFile video = await cameraController.stopVideoRecording();
        debugPrint('Video saved to ${video.path}');
      } else {
        await cameraController.startVideoRecording();
      }
      setState(() {});
    } on CameraException catch (e) {
      debugPrint('Error recording video: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Camera Example')),
        body: _isCameraInitialized && _controller != null
            ? CameraPreview(_controller!)
            : const Center(child: CircularProgressIndicator()),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FloatingActionButton(
              heroTag: 'photo',
              onPressed: _takePicture,
              child: const Icon(Icons.camera_alt),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: 'video',
              onPressed: _toggleVideoRecording,
              child: Icon(
                (_controller?.value.isRecordingVideo ?? false)
                    ? Icons.stop
                    : Icons.videocam,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```
