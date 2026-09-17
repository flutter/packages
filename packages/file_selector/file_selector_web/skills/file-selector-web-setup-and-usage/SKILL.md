---
name: file-selector-web-setup-and-usage
description: Set up and use file_selector_web, the Web implementation of Flutter's file_selector plugin using HTML input file elements.
---

# Setting Up and Using file_selector_web

`file_selector_web` is the endorsed Web platform implementation of the Flutter [`file_selector`](https://pub.dev/packages/file_selector) plugin, using browser `<input type="file">` elements.

## 1. Installation and Setup

Because `file_selector_web` is endorsed by `file_selector`, adding `file_selector` to your `pubspec.yaml` automatically includes Web support:

```yaml
dependencies:
  file_selector: ^1.1.0
```

If you import `package:file_selector_web/file_selector_web.dart` directly, add it to your `pubspec.yaml`:

```yaml
dependencies:
  file_selector: ^1.1.0
  file_selector_web: ^0.9.5
```

## 2. Platform-Specific Limitations & Filters on Web

- **Supported Operations**:
  - `openFile`: Supported.
  - `openFiles`: Supported.
  - `getSaveLocation`: **Not supported** on Web.
  - `getDirectoryPath`: **Not supported** on Web.
- **Supported Filter Options (`XTypeGroup`)**:
  - `extensions`: Supported (converted to `.ext`).
  - `mimeTypes`: Supported (e.g. `image/png`).
  - `webWildCards`: Supported (e.g. `image/*`, `audio/*`, `video/*`).
- **Browser `cancel` Event Limitation**:
  - Detecting when a user closes the file picker dialog without selecting a file relies on the HTML `<input>` `cancel` event (`https://caniuse.com/mdn-api_htmlinputelement_cancel_event`), which is supported in modern browsers.
- **Reading File Data on Web**:
  - On Web, `XFile.path` is a browser blob URL. Always read file contents using `await file.readAsBytes()` or `await file.readAsString()` rather than passing `file.path` to `dart:io` `File`.

## 3. Usage and API Examples

### Opening Files on Web with `webWildCards` and `mimeTypes`

```dart
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';

Future<void> pickWebImage() async {
  const XTypeGroup webImageGroup = XTypeGroup(
    label: 'Web Images',
    extensions: <String>['jpg', 'png', 'webp'],
    mimeTypes: <String>['image/jpeg', 'image/png', 'image/webp'],
    webWildCards: <String>['image/*'],
  );

  final XFile? file = await openFile(
    acceptedTypeGroups: <XTypeGroup>[webImageGroup],
  );

  if (file != null) {
    // Use XFile methods to read bytes on Web
    final Uint8List bytes = await file.readAsBytes();
  }
}
```
