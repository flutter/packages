---
name: camera-windows
description: Set up and use camera_windows, the Windows platform implementation of Flutter's camera plugin, including explicit pubspec setup, error handling, and Windows API limitations.
---

# Setting Up and Using `camera_windows`

[`camera_windows`](https://pub.dev/packages/camera_windows) is the Windows desktop implementation of the Flutter [`camera`](https://pub.dev/packages/camera) plugin.

## 1. Installation and `pubspec.yaml` Setup

**Important**: `camera_windows` is **not** currently an endorsed implementation in `camera`. To enable camera support on Windows, you **must** add both `camera` and `camera_windows` explicitly to your `pubspec.yaml`:

```yaml
dependencies:
  camera: ^0.12.1
  camera_windows: ^0.2.6
```

Or run:

```sh
flutter pub add camera camera_windows
```

Once both packages are listed in `pubspec.yaml`, Flutter automatically registers `CameraWindows` on Windows, and you can use the standard `package:camera` APIs.

## 2. Platform-Specific Configuration and Limitations

### Windows Camera Permissions

Windows desktop applications automatically prompt the user for webcam/microphone permissions managed by Windows Privacy Settings (**Settings > Privacy & security > Camera / Microphone**). Ensure camera access for desktop apps is enabled in Windows Settings.

### Unsupported Features and Limitations on Windows

Due to current Windows API and plugin limitations, the following features are **not supported** on Windows:
- **Pause and Resume Video Recording**: Not supported by Windows Media Foundation capture APIs.
- **Image Streaming (`startImageStream`)**: Not yet implemented on Windows.
- **Flash Mode, Focus Mode/Point, and Exposure Mode/Point/Offset**: Not yet implemented or unsupported by Windows camera APIs.
- **Device Orientation Detection**: Not yet implemented on Windows.

## 3. Usage and API Examples

### Listening to Windows Camera Errors and Managing Camera State

On Windows, hardware disconnects or media capture failures are reported through `CameraPlatform.instance.onCameraError(cameraId)`. When an unrecoverable error occurs, disposing and re-initializing the `CameraController` is required to reset the camera session.

```dart
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<CameraDescription> cameras = await availableCameras();
  runApp(WindowsCameraApp(cameras: cameras));
}

class WindowsCameraApp extends StatefulWidget {
  const WindowsCameraApp({super.key, required this.cameras});

  final List<CameraDescription> cameras;

  @override
  State<WindowsCameraApp> createState() => _WindowsCameraAppState();
}

class _WindowsCameraAppState extends State<WindowsCameraApp> {
  CameraController? _controller;
  StreamSubscription<CameraErrorEvent>? _errorSubscription;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    if (widget.cameras.isNotEmpty) {
      _initCamera(widget.cameras.first);
    } else {
      _statusMessage = 'No cameras found on this Windows device.';
    }
  }

  Future<void> _initCamera(CameraDescription description) async {
    await _disposeCamera();

    final CameraController controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: true,
    );
    _controller = controller;

    try {
      await controller.initialize();
      _errorSubscription = CameraPlatform.instance
          .onCameraError(controller.cameraId)
          .listen((CameraErrorEvent event) {
        debugPrint('Windows Camera Error: ${event.description}');
        // Dispose camera on fatal hardware/stream errors to reset state.
        _disposeCamera();
      });
      if (mounted) {
        setState(() {
          _statusMessage = null;
        });
      }
    } on CameraException catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Failed to initialize camera: ${e.description}';
        });
      }
    }
  }

  Future<void> _disposeCamera() async {
    await _errorSubscription?.cancel();
    _errorSubscription = null;
    final CameraController? controller = _controller;
    _controller = null;
    if (controller != null) {
      await controller.dispose();
    }
  }

  @override
  void dispose() {
    _disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CameraController? controller = _controller;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Windows Camera Example')),
        body: Center(
          child: _statusMessage != null
              ? Text(_statusMessage!)
              : (controller != null && controller.value.isInitialized)
                  ? CameraPreview(controller)
                  : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
```
