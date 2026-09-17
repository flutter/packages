---
name: camera-web
description: Set up and use camera_web, the endorsed Web implementation of Flutter's camera plugin, including HTTPS requirements, browser limitations, and displaying captured blob URLs.
---

# Setting Up and Using `camera_web`

[`camera_web`](https://pub.dev/packages/camera_web) is the endorsed Web platform implementation of the Flutter [`camera`](https://pub.dev/packages/camera) plugin, built using standard Web APIs (`MediaDevices.getUserMedia`, `MediaRecorder`, `ImageCapture`, and Blob URLs).

## 1. Installation and `pubspec.yaml` Setup

### Endorsed Usage (Recommended)

Because `camera_web` is endorsed by `camera`, adding `camera` to your `pubspec.yaml` automatically includes web support:

```yaml
dependencies:
  camera: ^0.12.1
```

### Direct Dependency Usage

If you need to import `camera_web` directly or constrain its version explicitly:

```yaml
dependencies:
  camera: ^0.12.1
  camera_web: ^0.3.5
```

## 2. Platform-Specific Configuration and Limitations

### Secure Context Requirement (HTTPS)

Accessing camera devices via `navigator.mediaDevices.getUserMedia` requires a **secure browsing context**:
- Serve your Flutter web application over **HTTPS** in production.
- `http://localhost` is permitted during local development.
- On insecure origins, calling `availableCameras()` throws a `CameraException` with code `permissionDenied`.

### Web Platform Limitations

1. **No `dart:io` Support**: Captured images and videos return an `XFile` whose `.path` is a browser `blob:` URL. Do **not** pass `capturedFile.path` to `dart:io`'s `File()` or `Image.file()`. Use `Image.network(capturedFile.path)` or `await capturedFile.readAsBytes()` with `Image.memory()`.
2. **Unsupported Features**: The following features are not currently supported on Web:
   - Exposure mode, point, and offset
   - Focus mode and point
   - Sensor orientation and image format groups
   - Dart image streaming (`startImageStream`)
3. **Browser-Dependent APIs**:
   - **Flash / Zoom**: Relies on the `ImageCapture` Web API. Browsers lacking support throw `PlatformException` (`torchModeNotSupported` / `zoomLevelNotSupported`).
   - **Video Formats**: Videos record as `video/webm` (Chrome/Firefox) or `video/mp4` (Safari).

## 3. Usage and API Examples

### Displaying a Captured Photo on Web and Mobile

Use `kIsWeb` from `package:flutter/foundation.dart` (or `XFile.readAsBytes()`) to render captured photos across Web and native platforms safely:

```dart
import 'dart:io' show File;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class CapturedImagePreview extends StatelessWidget {
  const CapturedImagePreview({super.key, required this.imageFile});

  final XFile imageFile;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // On Web, XFile.path is a blob: URL accessible via Image.network.
      return Image.network(imageFile.path, fit: BoxFit.cover);
    } else {
      // On Android/iOS/Desktop, XFile.path is a local filesystem path.
      return Image.file(File(imageFile.path), fit: BoxFit.cover);
    }
  }
}
```

### Complete Web Camera Preview and Capture Example

```dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<CameraDescription> cameras = await availableCameras();
  runApp(WebCameraApp(cameras: cameras));
}

class WebCameraApp extends StatefulWidget {
  const WebCameraApp({super.key, required this.cameras});

  final List<CameraDescription> cameras;

  @override
  State<WebCameraApp> createState() => _WebCameraAppState();
}

class _WebCameraAppState extends State<WebCameraApp> {
  CameraController? _controller;
  XFile? _lastCapturedPhoto;

  @override
  void initState() {
    super.initState();
    if (widget.cameras.isNotEmpty) {
      _controller = CameraController(
        widget.cameras.first,
        ResolutionPreset.medium,
      );
      _controller!.initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  Future<void> _capturePhoto() async {
    final CameraController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    final XFile photo = await controller.takePicture();
    setState(() {
      _lastCapturedPhoto = photo;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CameraController? controller = _controller;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Web Camera Example')),
        body: Column(
          children: <Widget>[
            Expanded(
              child: controller != null && controller.value.isInitialized
                  ? CameraPreview(controller)
                  : const Center(child: CircularProgressIndicator()),
            ),
            if (_lastCapturedPhoto != null)
              SizedBox(
                height: 120,
                child: Image.network(_lastCapturedPhoto!.path),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _capturePhoto,
          child: const Icon(Icons.camera_alt),
        ),
      ),
    );
  }
}
```
