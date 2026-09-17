---
name: image-picker-android
description: Set up and use the image_picker_android plugin, the Android platform implementation of image_picker featuring Android Photo Picker configuration and lost data recovery.
---

# Setting Up and Using image_picker_android

`image_picker_android` is the endorsed Android platform implementation of the [`image_picker`](https://pub.dev/packages/image_picker) plugin.

## 1. Installation and Setup

Because `image_picker_android` is an endorsed implementation, adding `image_picker` to your `pubspec.yaml` automatically includes it:

```yaml
dependencies:
  image_picker: ^1.2.3
```

If you want to directly configure Android-specific options (such as enabling the Android Photo Picker on older Android versions), add `image_picker_android` and `image_picker_platform_interface` explicitly:

```yaml
dependencies:
  image_picker: ^1.2.3
  image_picker_android: ^0.8.13
  image_picker_platform_interface: ^2.11.0
```

## 2. Platform-Specific Configuration

### Android Photo Picker

- **Android 16+**: Gallery image, video, and mixed-media picks always use the Android Photo Picker.
- **Android 13–15**: The Android Photo Picker is used by default when available, and is required for selection `limit` support.
- **Android 12 and below**: You can opt in to the backported Android Photo Picker by setting `useAndroidPhotoPicker = true` before making any picker calls.

### Activity `launchMode` and Memory Pressure

- **Avoid `singleInstance`**: Launching the image picker from an `Activity` with `launchMode: singleInstance` in `AndroidManifest.xml` will always return `RESULT_CANCELED` because activities cannot return results across tasks. Use `singleTask` or standard launch modes instead.
- **Scoped Storage**: You do not need `android:requestLegacyExternalStorage="true"` in `AndroidManifest.xml`.
- **Temporary Cache**: Camera captures are stored in the application cache directory and should be moved to a permanent directory if long-term storage is required.

## 3. Usage and API Examples

### Enabling the Android Photo Picker on Older Android Versions

Configure `ImagePickerAndroid` during app initialization (e.g., in `main()`):

```dart
import 'package:flutter/widgets.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final ImagePickerPlatform implementation = ImagePickerPlatform.instance;
  if (implementation is ImagePickerAndroid) {
    implementation.useAndroidPhotoPicker = true;
  }

  runApp(const MyApp());
}
```

### Handling MainActivity Destruction (`retrieveLostData`)

On Android, high memory pressure while the camera or gallery intent is active can cause the system to destroy `MainActivity`. When the user returns, the app restarts and the original `pickImage` / `pickVideo` Future will never complete. Call `retrieveLostData()` on startup to recover the files:

```dart
import 'package:image_picker/image_picker.dart';

Future<void> recoverAndroidLostData() async {
  final ImagePicker picker = ImagePicker();
  final LostDataResponse response = await picker.retrieveLostData();

  if (response.isEmpty) {
    return;
  }

  if (response.files != null) {
    for (final XFile file in response.files!) {
      // Handle recovered XFile
    }
  } else if (response.exception != null) {
    // Handle PlatformException or error during capture
  }
}
```
