---
name: path-provider-foundation
description: Set up and configure path_provider_foundation, the iOS and macOS implementation of Flutter's path_provider plugin. Covers endorsed usage, Foundation NSSearchPathDirectory mappings, macOS sandbox entitlements, and iOS App Group container paths.
---

# Setting Up and Using path_provider_foundation

`path_provider_foundation` is the endorsed iOS and macOS implementation of the Flutter [`path_provider`](https://pub.dev/packages/path_provider) plugin. It uses Dart FFI (`package:objective_c`) to call Apple's `Foundation` framework (`NSFileManager` and `NSSearchPathForDirectoriesInDomains`) directly.

## 1. Installation and Setup

Because `path_provider_foundation` is an endorsed federated plugin implementation, adding `path_provider` to your `pubspec.yaml` automatically includes it on iOS and macOS:

```yaml
dependencies:
  path_provider: ^2.1.6
```

If you need to call iOS-specific APIs such as `getContainerPath` for App Groups, add `path_provider_foundation` directly to your `pubspec.yaml`:

```yaml
dependencies:
  path_provider: ^2.1.6
  path_provider_foundation: ^2.6.0
```

## 2. Apple Directory Mappings and Configuration

### Foundation Directory Mappings

| Flutter Function | Apple Foundation API (`NSSearchPathDirectory`) |
| :--- | :--- |
| `getTemporaryDirectory()` | `NSCachesDirectory` |
| `getApplicationCacheDirectory()` | `NSCachesDirectory` (appends bundle ID on macOS) |
| `getApplicationSupportDirectory()` | `NSApplicationSupportDirectory` (appends bundle ID on macOS) |
| `getLibraryDirectory()` | `NSLibraryDirectory` |
| `getApplicationDocumentsDirectory()` | `NSDocumentDirectory` |
| `getDownloadsDirectory()` | `NSDownloadsDirectory` |

Note that `getExternalStorageDirectory()`, `getExternalCacheDirectories()`, and `getExternalStorageDirectories()` throw an `UnsupportedError` on iOS and macOS.

### macOS Sandbox Entitlements (`macos/Runner/*.entitlements`)

In sandboxed macOS applications, `getDownloadsDirectory()` points to the app's sandbox container Downloads directory by default. To read and write directly to the user's primary `~/Downloads` folder on macOS, add the downloads entitlement to `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:

```xml
<key>com.apple.security.files.downloads.read-write</key>
<true/>
```

### iOS App Groups Configuration

To share files between your main iOS app and an app extension (e.g., a WidgetKit extension or Share extension) using `getContainerPath`, enable the **App Groups** capability in Xcode for both targets and add the shared group identifier (e.g., `group.com.example.mysharedgroup`) to their entitlements.

## 3. Usage and API Examples

### Endorsed Usage via `path_provider`

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<Directory> getAppleLibraryDirectory() async {
  // Available on iOS and macOS for persistent files hidden from the user
  return getLibraryDirectory();
}
```

### Direct Usage: Accessing iOS App Group Container Paths

When sharing files with an iOS App Extension, instantiate `PathProviderFoundation` directly and call `getContainerPath`:

```dart
import 'dart:io';
import 'package:path_provider_foundation/path_provider_foundation.dart';

Future<Directory?> getSharedAppGroupDirectory(String appGroupId) async {
  final PathProviderFoundation provider = PathProviderFoundation();
  final String? containerPath = await provider.getContainerPath(
    appGroupIdentifier: appGroupId,
  );
  if (containerPath == null) {
    return null;
  }
  return Directory(containerPath);
}
```
