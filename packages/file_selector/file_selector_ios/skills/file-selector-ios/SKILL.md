---
name: file-selector-ios
description: Set up and use file_selector_ios, the iOS implementation of Flutter's file_selector plugin supporting UIDocumentPickerViewController with Uniform Type Identifiers.
---

# Setting Up and Using file_selector_ios

`file_selector_ios` is the endorsed iOS platform implementation of the Flutter [`file_selector`](https://pub.dev/packages/file_selector) plugin, built using iOS `UIDocumentPickerViewController`.

## 1. Installation and Setup

Because `file_selector_ios` is endorsed by `file_selector`, adding `file_selector` to your `pubspec.yaml` automatically includes iOS support:

```yaml
dependencies:
  file_selector: ^1.1.0
```

If you need to import `package:file_selector_ios/file_selector_ios.dart` directly, add it to your `pubspec.yaml`:

```yaml
dependencies:
  file_selector: ^1.1.0
  file_selector_ios: ^0.5.0
```

## 2. Platform-Specific Configuration & Capabilities on iOS

- **Minimum iOS Version**: Requires iOS 13.0 or higher.
- **Supported Operations**:
  - `openFile`: Supported.
  - `openFiles`: Supported.
  - `getSaveLocation`: **Not supported** on iOS.
  - `getDirectoryPath`: **Not supported** on iOS.
- **CRITICAL: Filtering with Uniform Type Identifiers (`uniformTypeIdentifiers`)**:
  - iOS **only** supports `uniformTypeIdentifiers` (UTIs) in `XTypeGroup` (for example, `'public.jpeg'`, `'public.png'`, `'com.adobe.pdf'`, `'public.plain-text'`).
  - Passing an `XTypeGroup` on iOS that specifies `extensions` or `mimeTypes` without `uniformTypeIdentifiers` will throw an `ArgumentError`. Always include `uniformTypeIdentifiers` when targeting iOS.

## 3. Usage and API Examples

### Opening Files on iOS with Uniform Type Identifiers

```dart
import 'package:file_selector/file_selector.dart';

Future<void> pickFilesOnIOS() async {
  const XTypeGroup imageAndPdfGroup = XTypeGroup(
    label: 'Images and PDFs',
    // Include extensions for cross-platform support
    extensions: <String>['jpg', 'png', 'pdf'],
    // REQUIRED for iOS: specify uniformTypeIdentifiers
    uniformTypeIdentifiers: <String>[
      'public.jpeg',
      'public.png',
      'com.adobe.pdf',
    ],
  );

  final List<XFile> files = await openFiles(
    acceptedTypeGroups: <XTypeGroup>[imageAndPdfGroup],
  );
}
```

### Direct Registration (Testing)

For unit testing or custom registration on iOS:

```dart
import 'package:file_selector_ios/file_selector_ios.dart';

void registerIOSFileSelector() {
  FileSelectorIOS.registerWith();
}
```
