---
name: path-provider-setup-and-usage
description: Locate commonly used filesystem directories in Flutter on Android, iOS, Linux, macOS, and Windows using path_provider. Covers temporary, application support, documents, cache, downloads, external storage directories, and unit testing mocks.
---

# Setting Up and Using path_provider

`path_provider` is a Flutter plugin for finding commonly used locations on the host filesystem across Android, iOS, Linux, macOS, and Windows.

## 1. Installation and Setup

Add `path_provider` to your `pubspec.yaml`:

```yaml
dependencies:
  path_provider: ^2.1.6
```

## 2. Supported Directories by Platform

Not all directory types exist on every platform. Calling an unsupported directory method throws an `UnsupportedError`.

| Directory Function | Android | iOS | Linux | macOS | Windows | Purpose |
| :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| `getTemporaryDirectory()` | Yes | Yes | Yes | Yes | Yes | Transient cache files that the OS may clear at any time |
| `getApplicationSupportDirectory()` | Yes | Yes | Yes | Yes | Yes | Internal app data and config files hidden from the user |
| `getApplicationDocumentsDirectory()` | Yes | Yes | Yes | Yes | Yes | User-generated data or files that cannot be recreated |
| `getApplicationCacheDirectory()` | Yes | Yes | Yes | Yes | Yes | Application-specific cache files |
| `getDownloadsDirectory()` | Yes | Yes | Yes | Yes | Yes | User downloads folder (verify existence before writing) |
| `getLibraryDirectory()` | No | Yes | No | Yes | No | Persistent, backed-up app files on Apple platforms |
| `getExternalStorageDirectory()` | Yes | No | No | No | No | Android top-level external storage (`getExternalFilesDir`) |
| `getExternalCacheDirectories()` | Yes | No | No | No | No | Android external cache directories (e.g., SD cards) |
| `getExternalStorageDirectories()` | Yes | No | No | No | No | Android external storage directories by `StorageDirectory` type |

### Platform-Specific Notes

- **macOS Sandbox**: In sandboxed macOS apps, `getDownloadsDirectory()` accesses the sandbox container's Downloads directory unless the `com.apple.security.files.downloads.read-write` entitlement is added to `macos/Runner/*.entitlements`.
- **Linux**: `getDownloadsDirectory()` relies on `xdg-user-dir` and may return `null` if `xdg-user-dir` is unavailable.

## 3. Usage and API Examples

### Reading and Writing Files in Application Directories

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<File> writeUserNote(String filename, String content) async {
  // Use getApplicationDocumentsDirectory for user-generated data
  final Directory docsDir = await getApplicationDocumentsDirectory();
  final File file = File('${docsDir.path}/$filename');
  return file.writeAsString(content);
}

Future<File> writeAppConfig(String configJson) async {
  // Use getApplicationSupportDirectory for internal app state/databases
  final Directory supportDir = await getApplicationSupportDirectory();
  final File configFile = File('${supportDir.path}/settings.json');
  return configFile.writeAsString(configJson);
}

Future<void> saveToDownloads(String filename, List<int> bytes) async {
  final Directory? downloadsDir = await getDownloadsDirectory();
  if (downloadsDir == null) {
    throw UnsupportedError('Downloads directory is not available');
  }
  if (!downloadsDir.existsSync()) {
    await downloadsDir.create(recursive: true);
  }
  final File output = File('${downloadsDir.path}/$filename');
  await output.writeAsBytes(bytes);
}
```

### Mocking `path_provider` in Unit Tests

Because `path_provider` uses `PathProviderPlatform` rather than a single method channel across all platforms, mock `PathProviderPlatform.instance` in tests instead of mocking `MethodChannel`:

```dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async => Directory.systemTemp.path;

  @override
  Future<String?> getApplicationDocumentsPath() async =>
      Directory.systemTemp.path;

  @override
  Future<String?> getApplicationSupportPath() async =>
      Directory.systemTemp.path;
}

void main() {
  setUp(() {
    PathProviderPlatform.instance = FakePathProviderPlatform();
  });

  test('getApplicationDocumentsDirectory returns mocked path', () async {
    final Directory dir = await getApplicationDocumentsDirectory();
    expect(dir.path, equals(Directory.systemTemp.path));
  });
}
```
