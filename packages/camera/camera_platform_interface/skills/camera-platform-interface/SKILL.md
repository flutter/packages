---
name: camera-platform-interface
description: Implement or mock the common platform interface for Flutter's camera plugin using camera_platform_interface and CameraPlatform.
---

# Using and Implementing `camera_platform_interface`

[`camera_platform_interface`](https://pub.dev/packages/camera_platform_interface) defines the common Dart platform interface (`CameraPlatform`) shared by the [`camera`](https://pub.dev/packages/camera) plugin and all platform-specific camera implementations (`camera_android`, `camera_android_camerax`, `camera_avfoundation`, `camera_web`, `camera_windows`).

## 1. Installation and `pubspec.yaml` Setup

To implement a new platform plugin for `camera` or to mock `CameraPlatform` in unit tests, add `camera_platform_interface` to your `pubspec.yaml`:

```yaml
dependencies:
  camera_platform_interface: ^2.13.1
```

For unit testing an app that uses `camera`:

```yaml
dev_dependencies:
  camera_platform_interface: ^2.13.1
  flutter_test:
    sdk: flutter
  plugin_platform_interface: ^2.1.7
```

## 2. Platform-Specific Configuration

`camera_platform_interface` is a pure Dart/Flutter package containing interface definitions, events (`CameraEvent`, `DeviceEvent`), and data types (`CameraDescription`, `MediaSettings`, `ResolutionPreset`, `XFile`). It requires no native platform configuration (`Info.plist`, `AndroidManifest.xml`, or build scripts).

**Design Note on Breaking Changes**: Platform implementations must **extend** (`extends CameraPlatform`) rather than **implement** (`implements CameraPlatform`). Newly added methods on `CameraPlatform` provide default implementations throwing `UnimplementedError` so that adding methods is non-breaking for existing subclasses.

## 3. Usage and API Examples

### Implementing a Custom Platform Plugin

To create a custom platform implementation of `camera`, extend `CameraPlatform` and register it via `CameraPlatform.instance`:

```dart
import 'dart:async';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/widgets.dart';

class MyCustomCameraPlatform extends CameraPlatform {
  /// Registers this class as the default instance of [CameraPlatform].
  static void registerWith() {
    CameraPlatform.instance = MyCustomCameraPlatform();
  }

  @override
  Future<List<CameraDescription>> availableCameras() async {
    return <CameraDescription>[
      const CameraDescription(
        name: 'custom_cam_0',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 90,
      ),
    ];
  }

  @override
  Future<int> createCameraWithSettings(
    CameraDescription cameraDescription,
    MediaSettings? mediaSettings,
  ) async {
    const int cameraId = 1;
    return cameraId;
  }

  @override
  Future<void> initializeCamera(
    int cameraId, {
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) async {
    // Perform native initialization here.
  }

  @override
  Widget buildPreview(int cameraId) {
    return Texture(textureId: cameraId);
  }

  @override
  Future<XFile> takePicture(int cameraId) async {
    return XFile('/path/to/captured_image.jpg');
  }

  @override
  Future<void> dispose(int cameraId) async {
    // Release native camera resources.
  }
}
```

### Mocking `CameraPlatform` in Unit Tests

When writing widget or unit tests for code that uses `package:camera`, replace `CameraPlatform.instance` with a fake or mock subclass that mixes in `MockPlatformInterfaceMixin`:

```dart
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FakeCameraPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements CameraPlatform {
  @override
  Future<List<CameraDescription>> availableCameras() async {
    return <CameraDescription>[
      const CameraDescription(
        name: 'test_camera',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 0,
      ),
    ];
  }

  @override
  Future<int> createCameraWithSettings(
    CameraDescription cameraDescription,
    MediaSettings? mediaSettings,
  ) async => 42;

  @override
  Future<void> initializeCamera(
    int cameraId, {
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) async {}

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) {
    return Stream<CameraInitializedEvent>.value(
      CameraInitializedEvent(
        cameraId,
        1920,
        1080,
        ExposureMode.auto,
        true,
        FocusMode.auto,
        true,
      ),
    );
  }

  @override
  Widget buildPreview(int cameraId) => const SizedBox();

  @override
  Future<void> dispose(int cameraId) async {}
}

void main() {
  test('availableCameras returns fake camera', () async {
    CameraPlatform.instance = FakeCameraPlatform();
    final List<CameraDescription> cameras =
        await CameraPlatform.instance.availableCameras();
    expect(cameras.single.name, 'test_camera');
  });
}
```
