---
name: file-selector
description: Set up and use the file_selector plugin for opening files, saving files, and selecting directories using native file dialogs across Flutter platforms.
---

# Setting Up and Using file_selector

`file_selector` allows Flutter applications to interact with native file and directory selection dialogs across Android, iOS, Linux, macOS, Web, and Windows.

## 1. Installation and Setup

Add `file_selector` to your `pubspec.yaml`:

```yaml
dependencies:
  file_selector: ^1.1.0
```

## 2. Platform-Specific Configuration

### macOS Entitlements

On macOS, sandboxed apps must declare file access entitlements in both `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`.

For read-only file selection (`openFile`, `openFiles`):
```xml
<key>com.apple.security.files.user-selected.read-only</key>
<true/>
```

For read/write file selection or saving files (`getSaveLocation`, `getDirectoryPath`):
```xml
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
```

### Platform Feature & Filter Support Matrix

Not all operations or `XTypeGroup` filters are supported on every platform:
- **`openFile` / `openFiles`**: Supported on Android, iOS, Linux, macOS, Windows, and Web.
- **`getSaveLocation`**: Supported on Linux, macOS, and Windows (not supported on Android, iOS, or Web).
- **`getDirectoryPath`**: Supported on Android, Linux, macOS, and Windows (not supported on iOS or Web).
- **Filtering (`XTypeGroup`)**:
  - `extensions`: Supported on Android, Linux, macOS, Web, and Windows (not iOS).
  - `uniformTypeIdentifiers`: Supported on iOS and macOS.
  - `mimeTypes`: Supported on Android, Linux, macOS 11+, and Web.
  - `webWildCards`: Supported on Web.

Always provide both `extensions` and `uniformTypeIdentifiers` (or `mimeTypes`) in `XTypeGroup` definitions when targeting both mobile/desktop and Apple platforms to avoid `ArgumentError`s.

## 3. Usage and API Examples

### Opening a Single File

```dart
import 'package:file_selector/file_selector.dart';

Future<void> pickSingleImage() async {
  const XTypeGroup imageTypeGroup = XTypeGroup(
    label: 'Images',
    extensions: <String>['jpg', 'jpeg', 'png'],
    uniformTypeIdentifiers: <String>['public.jpeg', 'public.png'],
  );

  final XFile? file = await openFile(
    acceptedTypeGroups: <XTypeGroup>[imageTypeGroup],
  );

  if (file != null) {
    final String content = await file.readAsString();
  }
}
```

### Opening Multiple Files

```dart
import 'package:file_selector/file_selector.dart';

Future<void> pickMultipleFiles() async {
  const XTypeGroup pdfGroup = XTypeGroup(
    label: 'PDF Documents',
    extensions: <String>['pdf'],
    uniformTypeIdentifiers: <String>['com.adobe.pdf'],
  );

  final List<XFile> files = await openFiles(
    acceptedTypeGroups: <XTypeGroup>[pdfGroup],
  );

  for (final XFile file in files) {
    final int length = await file.length();
  }
}
```

### Saving a File (Desktop Only: Linux, macOS, Windows)

```dart
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';

Future<void> saveTextFile() async {
  const String suggestedName = 'report.txt';
  final FileSaveLocation? location = await getSaveLocation(
    suggestedName: suggestedName,
  );

  if (location == null) {
    // User canceled the save dialog
    return;
  }

  final Uint8List fileData = Uint8List.fromList('Hello World!'.codeUnits);
  final XFile textFile = XFile.fromData(
    fileData,
    mimeType: 'text/plain',
    name: suggestedName,
  );

  await textFile.saveTo(location.path);
}
```

### Selecting a Directory

```dart
import 'package:file_selector/file_selector.dart';

Future<void> pickDirectory() async {
  final String? directoryPath = await getDirectoryPath(
    confirmButtonText: 'Select Folder',
  );

  if (directoryPath != null) {
    // Use selected directoryPath
  }
}
```
