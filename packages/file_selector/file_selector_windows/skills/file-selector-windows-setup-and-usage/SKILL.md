---
name: file-selector-windows-setup-and-usage
description: Set up and use file_selector_windows, the Windows Win32 COM implementation of Flutter's file_selector plugin supporting file open, save, and directory dialogs.
---

# Setting Up and Using file_selector_windows

`file_selector_windows` is the endorsed Windows platform implementation of the Flutter [`file_selector`](https://pub.dev/packages/file_selector) plugin, built using native Win32 Common Item Dialogs (`IFileOpenDialog` and `IFileSaveDialog`).

## 1. Installation and Setup

Because `file_selector_windows` is endorsed by `file_selector`, adding `file_selector` to your `pubspec.yaml` automatically includes Windows support:

```yaml
dependencies:
  file_selector: ^1.1.0
```

If you import `package:file_selector_windows/file_selector_windows.dart` directly, add it to your `pubspec.yaml`:

```yaml
dependencies:
  file_selector: ^1.1.0
  file_selector_windows: ^0.9.3
```

## 2. Platform Capabilities & Filter Support on Windows

- **Windows Version**: Supports Windows 10 and higher.
- **Supported Operations**:
  - `openFile`: Supported.
  - `openFiles`: Supported.
  - `getSaveLocation`: Supported.
  - `getDirectoryPath` / `getDirectoryPaths`: Supported.
- **CRITICAL: Supported Filter Options (`XTypeGroup`)**:
  - Windows **only** supports `extensions` in `XTypeGroup` (for example, `extensions: <String>['txt', 'json']`).
  - `mimeTypes`, `uniformTypeIdentifiers`, and `webWildCards` are **not** supported on Windows. Passing an `XTypeGroup` on Windows that only defines `mimeTypes` or `uniformTypeIdentifiers` without `extensions` (and is not a wildcard match-all group) will throw an `ArgumentError`.

## 3. Usage and API Examples

### Opening and Saving Files on Windows

```dart
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';

Future<void> openAndSaveWindowsFile() async {
  const XTypeGroup csvGroup = XTypeGroup(
    label: 'CSV Files',
    // REQUIRED on Windows when filtering by type
    extensions: <String>['csv'],
  );

  // Pick a CSV file
  final XFile? pickedFile = await openFile(
    acceptedTypeGroups: <XTypeGroup>[csvGroup],
    confirmButtonText: 'Import CSV',
  );

  // Choose a save location
  final FileSaveLocation? saveResult = await getSaveLocation(
    suggestedName: 'export.csv',
    acceptedTypeGroups: <XTypeGroup>[csvGroup],
    confirmButtonText: 'Save CSV',
  );

  if (saveResult != null) {
    final Uint8List data = Uint8List.fromList('id,name\n1,Alice'.codeUnits);
    final XFile outputFile = XFile.fromData(data, name: 'export.csv');
    await outputFile.saveTo(saveResult.path);
  }
}
```
