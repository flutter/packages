---
name: file-selector-linux-setup-and-usage
description: Set up and use file_selector_linux, the Linux GTK implementation of Flutter's file_selector plugin supporting file open, save, and directory dialogs.
---

# Setting Up and Using file_selector_linux

`file_selector_linux` is the endorsed Linux platform implementation of the Flutter [`file_selector`](https://pub.dev/packages/file_selector) plugin, using native GTK file chooser dialogs (`GtkFileChooserNative`).

## 1. Installation and Setup

Because `file_selector_linux` is endorsed by `file_selector`, adding `file_selector` to your `pubspec.yaml` automatically includes Linux support:

```yaml
dependencies:
  file_selector: ^1.1.0
```

If you need to import `package:file_selector_linux/file_selector_linux.dart` directly, add it to your `pubspec.yaml`:

```yaml
dependencies:
  file_selector: ^1.1.0
  file_selector_linux: ^0.9.4
```

## 2. Platform Capabilities on Linux

- **Supported Operations**:
  - `openFile`: Choose a single file.
  - `openFiles`: Choose multiple files.
  - `getSaveLocation`: Choose a target file path for saving data.
  - `getDirectoryPath` / `getDirectoryPaths`: Choose one or more directories.
- **Supported Filter Types (`XTypeGroup`)**:
  - `extensions`: Supported (e.g. `['jpg', 'png']`).
  - `mimeTypes`: Supported (e.g. `['image/jpeg', 'image/png']`).

## 3. Usage and API Examples

### Opening, Saving, and Selecting Directories on Linux

```dart
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';

Future<void> handleLinuxFileDialogs() async {
  const XTypeGroup textGroup = XTypeGroup(
    label: 'Text Files',
    extensions: <String>['txt', 'md'],
    mimeTypes: <String>['text/plain', 'text/markdown'],
  );

  // Open a single file
  final XFile? inputFile = await openFile(
    acceptedTypeGroups: <XTypeGroup>[textGroup],
    confirmButtonText: 'Open Document',
  );

  // Save a file
  final FileSaveLocation? saveLocation = await getSaveLocation(
    suggestedName: 'notes.txt',
    acceptedTypeGroups: <XTypeGroup>[textGroup],
  );
  if (saveLocation != null) {
    final XFile fileToSave = XFile.fromData(
      Uint8List.fromList('Saved content'.codeUnits),
      name: 'notes.txt',
    );
    await fileToSave.saveTo(saveLocation.path);
  }

  // Select a directory
  final String? selectedDir = await getDirectoryPath();
}
```
