---
name: file-selector-platform-interface-setup-and-usage
description: Implement or mock FileSelectorPlatform for Flutter's file_selector plugin using XFile, XTypeGroup, and FileSaveLocation.
---

# Setting Up and Using file_selector_platform_interface

`file_selector_platform_interface` defines the common platform interface (`FileSelectorPlatform`) and data types (`XFile`, `XTypeGroup`, `FileSaveLocation`, `FileDialogOptions`) for the [`file_selector`](https://pub.dev/packages/file_selector) federated plugin family.

## 1. Installation and Setup

Add `file_selector_platform_interface` to your `pubspec.yaml` when implementing a new platform package or writing unit tests that mock `FileSelectorPlatform.instance`:

```yaml
dependencies:
  file_selector_platform_interface: ^2.7.0
```

## 2. Architecture & Breaking Changes

Platform implementations must extend `FileSelectorPlatform` (which uses `PlatformInterface` verification tokens) rather than implementing it via `implements`. To replace the active implementation in tests or custom platforms, assign `FileSelectorPlatform.instance`.

## 3. Usage and API Examples

### Implementing a Custom or Mock `FileSelectorPlatform` for Tests

```dart
import 'dart:typed_data';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FakeFileSelectorPlatform extends FileSelectorPlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<XFile?> openFile({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    return XFile.fromData(
      Uint8List.fromList('fake file content'.codeUnits),
      name: 'example.txt',
      mimeType: 'text/plain',
    );
  }

  @override
  Future<List<XFile>> openFiles({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final XFile? single = await openFile(
      acceptedTypeGroups: acceptedTypeGroups,
      initialDirectory: initialDirectory,
      confirmButtonText: confirmButtonText,
    );
    return single != null ? <XFile>[single] : <XFile>[];
  }

  @override
  Future<FileSaveLocation?> getSaveLocation({
    List<XTypeGroup>? acceptedTypeGroups,
    SaveDialogOptions options = const SaveDialogOptions(),
  }) async {
    return const FileSaveLocation('/tmp/saved_file.txt');
  }

  @override
  Future<String?> getDirectoryPath({
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    return '/tmp/selected_directory';
  }
}

void setupFakeFileSelectorForTest() {
  FileSelectorPlatform.instance = FakeFileSelectorPlatform();
}
```
