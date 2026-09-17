---
name: image-picker-macos
description: Set up and use the image_picker_macos plugin, the macOS desktop implementation of image_picker requiring user-selected file entitlements and supporting camera delegates.
---

# Setting Up and Using image_picker_macos

`image_picker_macos` is the endorsed macOS desktop implementation of the [`image_picker`](https://pub.dev/packages/image_picker) plugin, built on top of `file_selector_macos`.

## 1. Installation and Setup

Because `image_picker_macos` is an endorsed implementation, adding `image_picker` to your `pubspec.yaml` automatically includes macOS support:

```yaml
dependencies:
  image_picker: ^1.2.3
```

If you need to depend on `image_picker_macos` or `image_picker_platform_interface` directly (such as for configuring a desktop camera delegate), add them to your `pubspec.yaml`:

```yaml
dependencies:
  image_picker: ^1.2.3
  image_picker_macos: ^0.2.2+1
  image_picker_platform_interface: ^2.11.0
```

## 2. Platform-Specific Configuration & Limitations

### Required macOS App Sandbox Entitlements

Because `image_picker_macos` uses `NSOpenPanel` via `file_selector`, you must grant read-only access to user-selected files in both `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:

```xml
<key>com.apple.security.files.user-selected.read-only</key>
<true/>
```

### macOS Limitations

- **Image Resizing & Compression**: The arguments `maxWidth`, `maxHeight`, and `imageQuality` in `pickImage()` are not currently supported on macOS.
- **Video Options**: The `maxDuration` argument in `pickVideo()` is not supported.
- **Camera Support (`ImageSource.camera`)**: Calling `pickImage(source: ImageSource.camera)` is not supported out of the box and throws a `StateError` unless you register an `ImagePickerCameraDelegate`.

## 3. Usage and API Examples

### Selecting Images and Media on macOS

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MacOSImagePickerWidget extends StatefulWidget {
  const MacOSImagePickerWidget({super.key});

  @override
  State<MacOSImagePickerWidget> createState() => _MacOSImagePickerWidgetState();
}

class _MacOSImagePickerWidgetState extends State<MacOSImagePickerWidget> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ElevatedButton(
          onPressed: _pickFromGallery,
          child: const Text('Choose Image'),
        ),
        if (_selectedImage != null)
          Image.file(File(_selectedImage!.path), height: 250),
      ],
    );
  }
}
```

### Configuring a Custom Camera Delegate on macOS

To enable `ImageSource.camera` on macOS, provide an `ImagePickerCameraDelegate` implementation before calling camera methods:

```dart
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

class MacOSCameraDelegate extends ImagePickerCameraDelegate {
  @override
  Future<XFile?> takePhoto({
    ImagePickerCameraDelegateOptions options = const ImagePickerCameraDelegateOptions(),
  }) async {
    // Capture a photo using a macOS AVFoundation camera package
    // and return the saved XFile.
    return null;
  }

  @override
  Future<XFile?> takeVideo({
    ImagePickerCameraDelegateOptions options = const ImagePickerCameraDelegateOptions(),
  }) async {
    return null;
  }
}

void registerMacOSCameraDelegate() {
  final ImagePickerPlatform instance = ImagePickerPlatform.instance;
  if (instance is CameraDelegatingImagePickerPlatform) {
    instance.cameraDelegate = MacOSCameraDelegate();
  }
}
```
