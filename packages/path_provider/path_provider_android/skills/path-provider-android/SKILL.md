---
name: path-provider-android
description: Set up and configure path_provider_android, the Android implementation of Flutter's path_provider plugin. Covers endorsed usage, JNI/Android Context directory mappings, external storage queries, and direct registration.
---

# Setting Up and Using path_provider_android

`path_provider_android` is the endorsed Android platform implementation of the Flutter [`path_provider`](https://pub.dev/packages/path_provider) plugin. It uses JNI (`package:jni`) to query Android's `Context` APIs directly without requiring a traditional MethodChannel.

## 1. Installation and Setup

Because `path_provider_android` is an endorsed federated plugin implementation, adding `path_provider` to your `pubspec.yaml` automatically includes it on Android:

```yaml
dependencies:
  path_provider: ^2.1.6
```

If you need to depend on `path_provider_android` directly in your `pubspec.yaml`:

```yaml
dependencies:
  path_provider: ^2.1.6
  path_provider_android: ^2.3.1
```

## 2. Android Directory Mappings and Configuration

`path_provider_android` maps Flutter directory requests to the following Android `Context` and `Environment` APIs:

| Flutter Function | Android API Mapping |
| :--- | :--- |
| `getTemporaryDirectory()` | `Context.getCacheDir()` |
| `getApplicationCacheDirectory()` | `Context.getCacheDir()` |
| `getApplicationSupportDirectory()` | `Context.getFilesDir()` |
| `getApplicationDocumentsDirectory()` | `Context.getDir("flutter", Context.MODE_PRIVATE)` |
| `getDownloadsDirectory()` | `Context.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS)` |
| `getExternalStorageDirectory()` | `Context.getExternalFilesDir(null)` |
| `getExternalCacheDirectories()` | `Context.getExternalCacheDirs()` |
| `getExternalStorageDirectories(type)` | `Context.getExternalFilesDirs(type)` |

### Permissions

All directories returned by `path_provider_android` (including `getExternalStorageDirectory()` and `getExternalStorageDirectories()`) are app-specific directories on internal or external storage. On Android 4.4 (API level 19) and higher, reading and writing to these app-specific external directories **does not require** `READ_EXTERNAL_STORAGE` or `WRITE_EXTERNAL_STORAGE` permissions in `AndroidManifest.xml`.

## 3. Usage and API Examples

### Endorsed Usage with Android External Storage

Use `package:path_provider/path_provider.dart` to access both internal and Android-specific external storage directories:

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> saveMediaToAndroidExternalPictures() async {
  final List<Directory>? dirs = await getExternalStorageDirectories(
    type: StorageDirectory.pictures,
  );
  if (dirs == null || dirs.isEmpty) {
    throw StateError('No external pictures directory available on device');
  }

  final Directory primaryPicturesDir = dirs.first;
  final File imageFile = File('${primaryPicturesDir.path}/sample.png');
  await imageFile.writeAsBytes(<int>[0, 1, 2, 3]);
}
```

### Direct Platform Registration and Usage

To register `PathProviderAndroid` manually or query the platform implementation directly:

```dart
import 'package:path_provider_android/path_provider_android.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

void registerAndroidPathProvider() {
  PathProviderAndroid.registerWith();
}

Future<String?> queryAndroidFilesDirDirectly() async {
  final PathProviderPlatform platform = PathProviderPlatform.instance;
  return platform.getApplicationSupportPath();
}
```
