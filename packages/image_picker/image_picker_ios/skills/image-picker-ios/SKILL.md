---
name: image-picker-ios
description: Set up and use the image_picker_ios plugin, the iOS platform implementation of image_picker supporting PHPickerViewController, camera capture, and Info.plist permissions.
---

# Setting Up and Using image_picker_ios

`image_picker_ios` is the endorsed iOS platform implementation of the [`image_picker`](https://pub.dev/packages/image_picker) plugin.

## 1. Installation and Setup

Because `image_picker_ios` is an endorsed implementation, adding `image_picker` to your `pubspec.yaml` automatically includes iOS support:

```yaml
dependencies:
  image_picker: ^1.2.3
```

If you need to depend on `image_picker_ios` directly (for example, to pin a version or reference `ImagePickerIOS` directly), add it to your `pubspec.yaml`:

```yaml
dependencies:
  image_picker: ^1.2.3
  image_picker_ios: ^0.8.13
```

## 2. Platform-Specific Configuration

### Required `Info.plist` Permissions

Add the following permission keys to `<project root>/ios/Runner/Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Describe why your app needs permission for the photo library.</string>
<key>NSCameraUsageDescription</key>
<string>Describe why your app needs access to the camera.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Describe why your app needs access to the microphone when recording videos.</string>
```

### Metadata & Permission Behavior (`requestFullMetadata`)

- **iOS 14+ PHPicker**: Gallery image and video selection uses Apple's `PHPickerViewController`, which runs out-of-process and provides built-in privacy.
- **Avoiding Photo Library Permission Prompts**: When picking images with `requestFullMetadata: false` (available via `ImagePickerOptions`), iOS will not prompt the user for photo library permission. However, App Store review policy still requires `NSPhotoLibraryUsageDescription` to be present in `Info.plist`.
- **iOS Simulator HEIC Note**: Due to a known Apple simulator issue with `PHPickerViewController`, picking default HEIC images on the iOS Simulator may fail. Test HEIC images on a physical iOS device or test with JPEG/PNG images on the simulator.

## 3. Usage and API Examples

### Picking Images with iOS Metadata Options

Use `image_picker` as normal, or pass `requestFullMetadata` via `pickImage` / `pickMultiImage`:

```dart
import 'package:image_picker/image_picker.dart';

class IosImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Picks an image without requesting full EXIF/location metadata,
  /// avoiding the iOS Photo Library permission prompt.
  Future<XFile?> pickImageWithoutPermissionPrompt() async {
    return _picker.pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
      maxWidth: 1600,
      imageQuality: 85,
    );
  }

  /// Captures a new photo using the front camera.
  Future<XFile?> captureSelfie() async {
    return _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
  }

  /// Picks multiple images from PHPickerViewController.
  Future<List<XFile>> pickMultipleGalleryImages() async {
    return _picker.pickMultiImage(
      requestFullMetadata: true,
      limit: 10,
    );
  }
}
```
