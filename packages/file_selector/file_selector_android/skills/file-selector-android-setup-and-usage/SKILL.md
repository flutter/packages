---
name: file-selector-android-setup-and-usage
description: Set up and use file_selector_android, the Android implementation of Flutter's file_selector plugin supporting file picking and directory selection via Android Storage Access Framework.
---

# Setting Up and Using file_selector_android

`file_selector_android` is the endorsed Android platform implementation of the Flutter [`file_selector`](https://pub.dev/packages/file_selector) plugin.

## 1. Installation and Setup

Because `file_selector_android` is endorsed by `file_selector`, adding `file_selector` to your `pubspec.yaml` automatically includes Android support:

```yaml
dependencies:
  file_selector: ^1.1.0
```

If you need to import `package:file_selector_android/file_selector_android.dart` directly, add it to your `pubspec.yaml`:

```yaml
dependencies:
  file_selector: ^1.1.0
  file_selector_android: ^0.5.0
```

## 2. Platform-Specific Configuration & Capabilities on Android

- **Android SDK Requirement**: Requires Android SDK 24 (Android 7.0) or higher.
- **Storage Access Framework (SAF)**: Uses standard Android intents (`ACTION_OPEN_DOCUMENT`, `ACTION_OPEN_DOCUMENT_TREE`), meaning no special storage permissions (`READ_EXTERNAL_STORAGE`) are required in `AndroidManifest.xml` to access user-selected files or directories.
- **Supported Operations**:
  - `openFile`: Supported.
  - `openFiles`: Supported.
  - `getDirectoryPath`: Supported (opens Android folder picker).
  - `getSaveLocation`: **Not supported** on Android.
- **Supported Type Filters (`XTypeGroup`)**:
  - `extensions` and `mimeTypes` are supported on Android. `uniformTypeIdentifiers` are ignored by Android, so always include `extensions` or `mimeTypes` in your `XTypeGroup`.

## 3. Usage and API Examples

### Opening Files and Directories on Android via `file_selector`

```dart
import 'package:file_selector/file_selector.dart';

Future<void> selectAndroidFilesAndFolder() async {
  const XTypeGroup typeGroup = XTypeGroup(
    label: 'Documents',
    extensions: <String>['pdf', 'txt'],
    mimeTypes: <String>['application/pdf', 'text/plain'],
  );

  // Pick a single file
  final XFile? file = await openFile(
    acceptedTypeGroups: <XTypeGroup>[typeGroup],
  );

  // Pick a directory path
  final String? folderUriOrPath = await getDirectoryPath();
}
```

### Direct Registration (Testing)

For unit testing or custom registration on Android:

```dart
import 'package:file_selector_android/file_selector_android.dart';

void registerAndroidFileSelector() {
  FileSelectorAndroid.registerWith();
}
```
