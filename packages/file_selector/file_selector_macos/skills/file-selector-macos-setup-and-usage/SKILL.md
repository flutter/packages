---
name: file-selector-macos-setup-and-usage
description: Set up and use file_selector_macos, the macOS implementation of Flutter's file_selector plugin with required macOS App Sandbox entitlements.
---

# Setting Up and Using file_selector_macos

`file_selector_macos` is the endorsed macOS platform implementation of the Flutter [`file_selector`](https://pub.dev/packages/file_selector) plugin, using native Cocoa `NSOpenPanel` and `NSSavePanel` dialogs.

## 1. Installation and Setup

Because `file_selector_macos` is endorsed by `file_selector`, adding `file_selector` to your `pubspec.yaml` automatically includes macOS support:

```yaml
dependencies:
  file_selector: ^1.1.0
```

If you import `package:file_selector_macos/file_selector_macos.dart` directly, add it to your `pubspec.yaml`:

```yaml
dependencies:
  file_selector: ^1.1.0
  file_selector_macos: ^0.9.5
```

## 2. Platform-Specific Configuration (macOS Entitlements)

macOS applications run in an App Sandbox by default. You **must** add user-selected file access entitlements to your macOS target's `.entitlements` files (`macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`), or file dialogs will fail to open or return accessible paths.

For read-only file selection (`openFile`, `openFiles`):
```xml
<key>com.apple.security.files.user-selected.read-only</key>
<true/>
```

For saving files or modifying files in selected directories (`getSaveLocation`, `getDirectoryPath`):
```xml
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
```

### Supported Operations and Filters on macOS
- **Operations**: Supports `openFile`, `openFiles`, `getSaveLocation`, and `getDirectoryPath` / `getDirectoryPaths`.
- **Filters (`XTypeGroup`)**: Supports `extensions`, `uniformTypeIdentifiers`, and `mimeTypes` (macOS 11 Big Sur and later).

## 3. Usage and API Examples

### Opening and Saving Files on macOS

```dart
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';

Future<void> openAndSaveMacOSFile() async {
  const XTypeGroup imageGroup = XTypeGroup(
    label: 'Images',
    extensions: <String>['png', 'jpg'],
    uniformTypeIdentifiers: <String>['public.png', 'public.jpeg'],
  );

  // Open a file using NSOpenPanel
  final XFile? selectedFile = await openFile(
    acceptedTypeGroups: <XTypeGroup>[imageGroup],
    confirmButtonText: 'Choose Image',
  );

  // Choose a save path using NSSavePanel
  final FileSaveLocation? saveResult = await getSaveLocation(
    suggestedName: 'exported_image.png',
    confirmButtonText: 'Export',
  );

  if (saveResult != null && selectedFile != null) {
    final Uint8List bytes = await selectedFile.readAsBytes();
    final XFile output = XFile.fromData(bytes, name: 'exported_image.png');
    await output.saveTo(saveResult.path);
  }
}
```
