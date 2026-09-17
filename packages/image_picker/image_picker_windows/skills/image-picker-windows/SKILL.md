---
name: image-picker-windows
description: Set up and use the image_picker_windows plugin, the Windows desktop implementation of image_picker supporting native file open dialogs and custom camera delegates.
---

# Setting Up and Using image_picker_windows

`image_picker_windows` is the endorsed Windows desktop implementation of the [`image_picker`](https://pub.dev/packages/image_picker) plugin, built on top of `file_selector_windows`.

## 1. Installation and Setup

Because `image_picker_windows` is an endorsed implementation, adding `image_picker` to your `pubspec.yaml` automatically includes Windows support:

```yaml
dependencies:
  image_picker: ^1.2.3
```

If you need to depend on `image_picker_windows` or `image_picker_platform_interface` directly (for example, to configure a Windows camera delegate), add them explicitly:

```yaml
dependencies:
  image_picker: ^1.2.3
  image_picker_windows: ^0.2.2
  image_picker_platform_interface: ^2.11.0
```

## 2. Platform-Specific Configuration & Limitations

### Windows Capabilities and Limitations

- **Gallery Selection**: Uses native Win32 file open dialogs filtered to image and video file extensions.
- **Image Resizing & Compression**: The arguments `maxWidth`, `maxHeight`, and `imageQuality` in `pickImage()` are not currently supported on Windows; files are returned unmodified.
- **Video Options**: The `maxDuration` argument in `pickVideo()` is not supported.
- **Camera Support (`ImageSource.camera`)**: Calling `pickImage(source: ImageSource.camera)` throws a `StateError` by default because Windows does not provide a built-in camera capture file dialog. To enable camera capture, assign an `ImagePickerCameraDelegate`.

## 3. Usage and API Examples

### Selecting Images and Videos on Windows

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class WindowsMediaSelector extends StatefulWidget {
  const WindowsMediaSelector({super.key});

  @override
  State<WindowsMediaSelector> createState() => _WindowsMediaSelectorState();
}

class _WindowsMediaSelectorState extends State<WindowsMediaSelector> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedFiles = <XFile>[];

  Future<void> _selectMultipleImages() async {
    final List<XFile> files = await _picker.pickMultiImage();
    if (files.isNotEmpty) {
      setState(() {
        _selectedFiles = files;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ElevatedButton(
          onPressed: _selectMultipleImages,
          child: const Text('Select Images on Windows'),
        ),
        for (final XFile file in _selectedFiles)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.file(File(file.path), height: 150),
          ),
      ],
    );
  }
}
```

### Configuring a Camera Delegate on Windows

To handle `ImageSource.camera` calls on Windows, implement `ImagePickerCameraDelegate` and attach it to `CameraDelegatingImagePickerPlatform`:

```dart
import 'package:flutter/widgets.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

class WindowsCameraDelegate extends ImagePickerCameraDelegate {
  @override
  Future<XFile?> takePhoto({
    ImagePickerCameraDelegateOptions options =
        const ImagePickerCameraDelegateOptions(),
  }) async {
    // Capture a frame using camera_windows or a WinRT MediaCapture UI
    // and return the resulting XFile.
    return null;
  }

  @override
  Future<XFile?> takeVideo({
    ImagePickerCameraDelegateOptions options =
        const ImagePickerCameraDelegateOptions(),
  }) async {
    return null;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final ImagePickerPlatform instance = ImagePickerPlatform.instance;
  if (instance is CameraDelegatingImagePickerPlatform) {
    instance.cameraDelegate = WindowsCameraDelegate();
  }

  runApp(const MyApp());
}
```
