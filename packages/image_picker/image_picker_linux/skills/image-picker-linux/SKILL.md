---
name: image-picker-linux
description: Set up and use the image_picker_linux plugin, the Linux desktop implementation of image_picker supporting native file dialogs and custom camera delegates.
---

# Setting Up and Using image_picker_linux

`image_picker_linux` is the endorsed Linux desktop implementation of the [`image_picker`](https://pub.dev/packages/image_picker) plugin, built on top of `file_selector_linux`.

## 1. Installation and Setup

Because `image_picker_linux` is an endorsed implementation, adding `image_picker` to your `pubspec.yaml` automatically includes Linux support:

```yaml
dependencies:
  image_picker: ^1.2.3
```

If you need to depend on `image_picker_linux` or `image_picker_platform_interface` directly (for example, to configure a custom camera delegate), add them explicitly:

```yaml
dependencies:
  image_picker: ^1.2.3
  image_picker_linux: ^0.2.2
  image_picker_platform_interface: ^2.11.0
```

## 2. Platform-Specific Configuration & Limitations

### Linux Capabilities and Limitations

- **Gallery Selection**: Opens the native GTK file chooser dialog filtered to image and video MIME types.
- **Image Modification Options**: Arguments `maxWidth`, `maxHeight`, and `imageQuality` in `pickImage()` are not currently supported on Linux; images are returned in their original resolution and quality.
- **Video Options**: The `maxDuration` argument in `pickVideo()` is not supported.
- **Camera Support (`ImageSource.camera`)**: Because Linux desktop environments do not provide a standard system intent for camera capture, calling `pickImage(source: ImageSource.camera)` throws a `StateError` unless a custom `cameraDelegate` is configured.

## 3. Usage and API Examples

### Picking Images and Videos from the Linux File Dialog

```dart
import 'package:image_picker/image_picker.dart';

Future<void> pickLinuxMedia() async {
  final ImagePicker picker = ImagePicker();

  // Select a single image via GTK file dialog
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);

  // Select multiple images
  final List<XFile> images = await picker.pickMultiImage();

  // Select a video
  final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
}
```

### Setting Up a Custom Camera Delegate on Linux

To enable `ImageSource.camera` on Linux, implement `ImagePickerCameraDelegate` and assign it to `CameraDelegatingImagePickerPlatform.cameraDelegate` in `main()`:

```dart
import 'package:flutter/widgets.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

class LinuxCameraDelegate extends ImagePickerCameraDelegate {
  @override
  Future<XFile?> takePhoto({
    ImagePickerCameraDelegateOptions options = const ImagePickerCameraDelegateOptions(),
  }) async {
    // Integrate with a Linux camera package or V4L2 capture utility
    // and return the captured XFile.
    return null;
  }

  @override
  Future<XFile?> takeVideo({
    ImagePickerCameraDelegateOptions options = const ImagePickerCameraDelegateOptions(),
  }) async {
    return null;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final ImagePickerPlatform instance = ImagePickerPlatform.instance;
  if (instance is CameraDelegatingImagePickerPlatform) {
    instance.cameraDelegate = LinuxCameraDelegate();
  }

  runApp(const MyApp());
}
```
