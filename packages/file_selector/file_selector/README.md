# file_selector

<?code-excerpt path-base="example/lib"?>

[![pub package](https://img.shields.io/pub/v/file_selector.svg)](https://pub.dartlang.org/packages/file_selector)

A Flutter plugin that manages files and interactions with file dialogs.

|             | Android | iOS     | Linux | macOS  | Web | Windows     |
|-------------|---------|---------|-------|--------|-----|-------------|
| **Support** | SDK 19+ | iOS 12+ | Any   | 10.14+ | Any | Windows 10+ |

## Setup

### macOS

You will need to [add an entitlement][entitlement] for either read-only access:
```xml
  <key>com.apple.security.files.user-selected.read-only</key>
  <true/>
```
or read/write access:
```xml
  <key>com.apple.security.files.user-selected.read-write</key>
  <true/>
```
depending on your use case.

### Examples

Here are small examples that show you how to use the API.
Please also take a look at our [example][example] app.

#### Open a single file

<?code-excerpt "open_image_page.dart (SingleOpen)"?>
```dart
const XTypeGroup typeGroup = XTypeGroup(
  label: 'images',
  extensions: <String>['jpg', 'png'],
);
final XFile? file =
    await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
```

#### Open multiple files at once

<?code-excerpt "open_multiple_images_page.dart (MultiOpen)"?>
```dart
const XTypeGroup jpgsTypeGroup = XTypeGroup(
  label: 'JPEGs',
  extensions: <String>['jpg', 'jpeg'],
);
const XTypeGroup pngTypeGroup = XTypeGroup(
  label: 'PNGs',
  extensions: <String>['png'],
);
final List<XFile> files = await openFiles(acceptedTypeGroups: <XTypeGroup>[
  jpgsTypeGroup,
  pngTypeGroup,
]);
```

#### Save a file

<?code-excerpt "readme_standalone_excerpts.dart (Save)"?>
```dart
const String fileName = 'suggested_name.txt';
final FileSaveLocation? result =
    await getSaveLocation(suggestedName: fileName);
if (result == null) {
  // Operation was canceled by the user.
  return;
}

final Uint8List fileData = Uint8List.fromList('Hello World!'.codeUnits);
const String mimeType = 'text/plain';
final XFile textFile =
    XFile.fromData(fileData, mimeType: mimeType, name: fileName);
await textFile.saveTo(result.path);
```

#### Get a directory path

<?code-excerpt "readme_standalone_excerpts.dart (GetDirectory)"?>
```dart
final String? directoryPath = await getDirectoryPath();
if (directoryPath == null) {
  // Operation was canceled by the user.
  return;
}
```

### Filtering by file types

Different platforms support different type group filter options. To avoid
`ArgumentError`s on some platforms, ensure that any `XTypeGroup`s you pass set
filters that cover all platforms you are targeting, or that you conditionally
pass different `XTypeGroup`s based on `Platform`.

|                          | Andoid | iOS | Linux | macOS  | Web | Windows     |
|--------------------------|--------|-----|-------|--------|-----|-------------|
| `extensions`             | ✔️      |     | ✔️     | ✔️      | ✔️   | ✔️           |
| `mimeTypes`              | ✔️      |     | ✔️     | ✔️†     | ✔️   |             |
| `uniformTypeIdentifiers` |        | ✔️   |       | ✔️      |     |             |
| `webWildCards`           |        |     |       |        | ✔️   |             |

† `mimeTypes` are not supported on version of macOS earlier than 11 (Big Sur).

### Features supported by platform

| Feature                | Description                        | Android | iOS      | Linux      | macOS    | Windows      | Web         |
| ---------------------- |----------------------------------- |---------|--------- | ---------- | -------- | ------------ | ----------- |
| Choose a single file   | Pick a file/image                  | ✔️       | ✔️       | ✔️        | ✔️       | ✔️          | ✔️          |
| Choose multiple files  | Pick multiple files/images         | ✔️       | ✔️       | ✔️        | ✔️       | ✔️          | ✔️          |
| Choose a save location | Pick a directory to save a file in | ❌       | ❌       | ✔️        | ✔️       | ✔️          | ❌          |
| Choose a directory     | Pick a directory and get its path  | ✔️†       | ❌       | ✔️        | ✔️       | ✔️          | ❌          |

† Choosing a directory is no supported on versions of Android before SDK 21 (Lollipop).

[example]:./example
[entitlement]: https://docs.flutter.dev/desktop#entitlements-and-the-app-sandbox
