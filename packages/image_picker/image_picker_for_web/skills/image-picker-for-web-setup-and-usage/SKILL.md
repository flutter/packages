---
name: image-picker-for-web-setup-and-usage
description: Set up and use the image_picker_for_web plugin, the Web platform implementation of image_picker supporting HTML file inputs, media capture, and XFile Blob URLs.
---

# Setting Up and Using image_picker_for_web

`image_picker_for_web` is the endorsed Web platform implementation of the [`image_picker`](https://pub.dev/packages/image_picker) plugin.

## 1. Installation and Setup

Because `image_picker_for_web` is an endorsed implementation, adding `image_picker` to your `pubspec.yaml` automatically includes web support:

```yaml
dependencies:
  image_picker: ^1.2.3
```

If you import `package:image_picker_for_web` directly (for example, in custom platform tests or advanced web integrations), add it explicitly:

```yaml
dependencies:
  image_picker_for_web: ^3.1.0
```

## 2. Platform-Specific Configuration & Limitations

### Web Browser Limitations

- **File `accept` Attribute**: The plugin uses `<input type="file" accept="...">` to filter images and videos. Because users can override this filter in their browser dialog, always validate the MIME type or file contents in your application or backend.
- **Camera Capture (`capture` Attribute)**: On mobile browsers, `ImageSource.camera` sets the HTML `capture` attribute to launch the camera directly. On desktop browsers where `capture` is unsupported, it falls back to the standard file picker dialog.
- **Image Resizing and Quality (`ImagePickerOptions`)**:
  - `maxWidth`, `maxHeight`, and `imageQuality` are **not** supported for `gif` images.
  - `imageQuality` only affects `jpg` and `webp` images.
- **Video Options**: The `maxDuration` parameter in `pickVideo()` is not supported on the web.

## 3. Usage and API Examples

### Picking and Displaying Images on the Web

On the web, `XFile.path` contains a browser-accessible `Blob` URL (`blob:https://...`) rather than a local file system path. Do **not** pass `XFile.path` to `dart:io`'s `File` class on web. Instead, use `Image.network(pickedFile.path)` or `Image.memory(await pickedFile.readAsBytes())`:

```dart
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class WebCompatibleImagePicker extends StatefulWidget {
  const WebCompatibleImagePicker({super.key});

  @override
  State<WebCompatibleImagePicker> createState() => _WebCompatibleImagePickerState();
}

class _WebCompatibleImagePickerState extends State<WebCompatibleImagePicker> {
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedFile;

  Future<void> _selectImage() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (file != null) {
      setState(() {
        _pickedFile = file;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ElevatedButton(
          onPressed: _selectImage,
          child: const Text('Pick Image'),
        ),
        if (_pickedFile != null)
          kIsWeb
              ? Image.network(_pickedFile!.path)
              : Image.file(File(_pickedFile!.path)),
      ],
    );
  }
}
```

### Cross-Platform Byte Reading

To process file data identically across Web, Mobile, and Desktop without platform branches, read the bytes directly from `XFile`:

```dart
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

Future<Widget?> buildImageFromBytes(ImagePicker picker) async {
  final XFile? file = await picker.pickImage(source: ImageSource.gallery);
  if (file == null) {
    return null;
  }
  final Uint8List bytes = await file.readAsBytes();
  return Image.memory(bytes);
}
```
