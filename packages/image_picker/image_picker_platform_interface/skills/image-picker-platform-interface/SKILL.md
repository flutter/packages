---
name: image-picker-platform-interface
description: Set up and use the image_picker_platform_interface package to implement custom platform implementations, mock image_picker in tests, or configure desktop camera delegates.
---

# Setting Up and Using image_picker_platform_interface

`image_picker_platform_interface` defines the common platform interface for the [`image_picker`](https://pub.dev/packages/image_picker) plugin. It enables platform-specific implementations (`image_picker_android`, `image_picker_ios`, desktop implementations, and custom platforms) as well as unit testing mocks to share a consistent contract.

## 1. Installation and Setup

Add `image_picker_platform_interface` to your `pubspec.yaml` when writing a platform implementation, configuring desktop `ImagePickerCameraDelegate`s, or mocking `ImagePickerPlatform` in tests:

```yaml
dependencies:
  image_picker_platform_interface: ^2.11.1
```

## 2. Architecture & Platform Configuration

### Extending `ImagePickerPlatform` vs Implementing

Always **extend** (`extends ImagePickerPlatform`) rather than implement (`implements ImagePickerPlatform`). `ImagePickerPlatform` uses `plugin_platform_interface` verification and provides default fallback implementations so that adding new methods to the interface is non-breaking for existing subclasses.

### Desktop Camera Delegation (`CameraDelegatingImagePickerPlatform`)

Desktop implementations (`image_picker_windows`, `image_picker_macos`, `image_picker_linux`) extend `CameraDelegatingImagePickerPlatform`. This base class routes `ImageSource.camera` requests to a configurable `ImagePickerCameraDelegate` instance.

## 3. Usage and API Examples

### Implementing a Custom Platform or Test Mock

To create a custom platform implementation or mock `image_picker` behavior in widget tests, extend `ImagePickerPlatform` and set `ImagePickerPlatform.instance`:

```dart
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FakeImagePickerPlatform extends ImagePickerPlatform
    with MockPlatformInterfaceMixin {
  XFile? nextPickedFile;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    return nextPickedFile;
  }

  @override
  Future<List<XFile>> getMultiImageWithOptions({
    MultiImagePickerOptions options = const MultiImagePickerOptions(),
  }) async {
    return nextPickedFile != null ? <XFile>[nextPickedFile!] : <XFile>[];
  }
}

void setUpMockImagePicker() {
  final FakeImagePickerPlatform fakePlatform = FakeImagePickerPlatform()
    ..nextPickedFile = XFile('/path/to/mock_image.jpg');
  ImagePickerPlatform.instance = fakePlatform;
}
```

### Implementing `ImagePickerCameraDelegate` for Desktop Platforms

To supply camera capture UI on desktop platforms that inherit from `CameraDelegatingImagePickerPlatform`:

```dart
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

class CustomDesktopCameraDelegate extends ImagePickerCameraDelegate {
  @override
  Future<XFile?> takePhoto({
    ImagePickerCameraDelegateOptions options =
        const ImagePickerCameraDelegateOptions(),
  }) async {
    // Launch custom camera dialog using options.preferredCameraDevice
    // and return the captured XFile.
    return XFile('/tmp/captured_photo.jpg');
  }

  @override
  Future<XFile?> takeVideo({
    ImagePickerCameraDelegateOptions options =
        const ImagePickerCameraDelegateOptions(),
  }) async {
    // Record video using options.maxVideoDuration and return XFile.
    return XFile('/tmp/captured_video.mp4');
  }
}

void registerDesktopCamera() {
  final ImagePickerPlatform platform = ImagePickerPlatform.instance;
  if (platform is CameraDelegatingImagePickerPlatform) {
    platform.cameraDelegate = CustomDesktopCameraDelegate();
  }
}
```
