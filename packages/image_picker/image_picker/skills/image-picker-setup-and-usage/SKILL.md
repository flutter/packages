---
name: image-picker-setup-and-usage
description: Set up and use the image_picker Flutter plugin for selecting images and videos from the gallery or capturing media with the camera across Android, iOS, Web, and Desktop platforms.
---

# Setting Up and Using image_picker

`image_picker` is a Flutter plugin for selecting images and videos from the device media library and capturing new pictures or videos with the camera. It supports Android, iOS, Web, Linux, macOS, and Windows.

## 1. Installation and Setup

Add `image_picker` to your `pubspec.yaml`:

```yaml
dependencies:
  image_picker: ^1.2.3
```

## 2. Platform-Specific Configuration

### iOS (`ios/Runner/Info.plist`)

Add the required usage description keys to your `Info.plist` file:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to let you select images and videos.</string>
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to let you take photos and record videos.</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need access to your microphone to record audio with videos.</string>
```

*Note:* On iOS 14+, `PHPickerViewController` is used for gallery selections. Passing `requestFullMetadata: false` avoids prompting for photo library permission, though Apple still requires `NSPhotoLibraryUsageDescription` in `Info.plist`.

### Android

No manifest permissions are required out of the box, as `image_picker` uses system intents and scoped storage.

- **Android Photo Picker**: Used automatically on Android 13+. To enable the Android Photo Picker on Android 12 and below, configure `ImagePickerAndroid.useAndroidPhotoPicker = true` via `package:image_picker_android`.
- **Activity Lifecycle & `launchMode`**: Do not use `launchMode: singleInstance` on your launching `Activity`, as results cannot be returned across separate tasks (use `singleTask` or default instead).
- **Handling `MainActivity` Destruction**: Under low memory, Android may kill your `MainActivity` while the camera or gallery app is open. Always call `retrieveLostData()` at app startup to recover any pending selection.

### macOS (`macos/Runner/DebugProfile.entitlements` & `Release.entitlements`)

Because the macOS implementation uses `file_selector`, add the read-only user-selected file entitlement:

```xml
<key>com.apple.security.files.user-selected.read-only</key>
<true/>
```

### Windows, macOS, and Linux Camera Support

Desktop platforms support gallery picking via file selection dialogs by default. To support `ImageSource.camera` on desktop, set an `ImagePickerCameraDelegate` on `CameraDelegatingImagePickerPlatform` before calling camera methods.

## 3. Usage and API Examples

### Picking Images, Videos, and Media

All picking methods return `XFile` instances (from `package:cross_file`):

```dart
import 'package:image_picker/image_picker.dart';

class MediaPickerExample {
  final ImagePicker _picker = ImagePicker();

  Future<void> pickSingleImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (image != null) {
      // Use image.path or await image.readAsBytes()
    }
  }

  Future<void> capturePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (photo != null) {
      // Handle captured photo
    }
  }

  Future<void> pickMultipleImages() async {
    final List<XFile> images = await _picker.pickMultiImage(
      imageQuality: 80,
      limit: 5,
    );
    // Process selected images
  }

  Future<void> pickVideo() async {
    final XFile? video = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 60),
    );
    if (video != null) {
      // Handle video file
    }
  }

  Future<void> pickMixedMedia() async {
    // Pick a single image or video
    final XFile? singleMedia = await _picker.pickMedia();

    // Pick multiple images and videos
    final List<XFile> multipleMedia = await _picker.pickMultipleMedia();
  }
}
```

### Recovering Lost Data on Android

Check for lost data during initialization (such as in `initState` of your home screen widget) to handle Android process death:

```dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

Future<void> checkForLostData(ImagePicker picker) async {
  if (kIsWeb || !Platform.isAndroid) {
    return;
  }
  final LostDataResponse response = await picker.retrieveLostData();
  if (response.isEmpty) {
    return;
  }
  final List<XFile>? files = response.files;
  if (files != null) {
    // Process recovered files
  } else {
    final Object? exception = response.exception;
    // Handle error from response.exception
  }
}
```
