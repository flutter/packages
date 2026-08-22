# cross_file

An abstraction to allow working with files across multiple platforms.

<?code-excerpt path-base="example/lib"?>

[![pub package](https://img.shields.io/pub/v/cross_file.svg)](https://pub.dartlang.org/packages/cross_file)

|             | Android | iOS     | Linux | macOS  | Web | Windows     |
|-------------|---------|---------|-------|--------|-----|-------------|
| **Support** | SDK 24+ | iOS 13+ | Any   | 10.15+ | Any | Windows 10+ |

## Overview

This package provides a unified API for interacting with resources across platforms through two
primary implementation types:

### FileSystem

The `FileSystem` implementation represents resources on a traditional file system. It is used when
resources are identified by standard file paths or `file://` URIs.

* **Classes**: `FileSystemXFile`, `FileSystemXDirectory`.
* **Use Cases**: Desktop applications, app-private storage on mobile, or any environment where
  direct file system access is available.

### ScopedStorage

The `ScopedStorage` implementation represents resources that are managed or restricted by the
platform. These resources are typically identified by platform-specific URIs rather than direct
paths.

* **Classes**: `ScopedStorageXFile`, `ScopedStorageXDirectory`.
* **Use Cases**: Android Content URIs, iOS Security-Scoped bookmarks, Web Object URLs, or Photo
  Library assets.
* **Key Characteristic**: Access to these resources may be ephemeral or requires explicit lifecycle
  management (e.g., using `dispose()` or specific platform extensions).

## Usage

Instantiate a `XFile` using a uri or path and use its methods and properties to access the file and
its metadata.

Example:

<?code-excerpt "readme_excerpts.dart (Instantiate)"?>
```dart
final file = XFile.fileSystem(path: 'assets/hello.txt');

debugPrint('File information:');
debugPrint('- URI: ${file.uri}');
debugPrint('- Name: ${await file.name()}');

if (await file.exists()) {
  final String fileContent = await file.readAsString();
  debugPrint('Content of the file: $fileContent');
}
```

You can find links to the API docs on the [pub page](https://pub.dev/documentation/cross_file/latest/).

### Implementation-Specific Features

Classes in this package contain an underlying platform implementation that provides features that
are specific to an implementation.

To access implementation-specific features, start by adding the platform implementation packages to
your app or package:

* **dart:io** [cross_file_io](https://pub.dev/packages/cross_file_io/install)
* **Android Scoped Storage**: [cross_file_android](https://pub.dev/packages/cross_file_android/install)
* **iOS/macOS App Sandbox**: [cross_file_darwin](https://pub.dev/packages/cross_file_darwin/install)
* **Web**: [cross_file_web](https://pub.dev/packages/cross_file_web/install)

Next, add the imports of the implementation packages to your app or package:

<?code-excerpt "readme_excerpts.dart (platform_imports)"?>
```dart
// Import for Darwin App Sandbox features.
import 'package:cross_file_darwin/cross_file_darwin.dart';
// Import for Web features.
import 'package:cross_file_web/cross_file_web.dart';
```

Now, additional features can be accessed through the platform implementations. Classes
`FileSystemXFile`, `FileSystemXDirectory`, `ScopedStorageXFile`, and `ScopedStorageXDirectory` pass
their functionality to a class provided by the current platform. Below are a couple of ways to
access additional functionality provided by the platform and is followed by an example.

1. Pass a creation params class provided by a platform implementation to a `fromCreationParams`
   constructor (e.g. `FileSystemXFile.fromCreationParams`, `ScopedStorageXFile.fromCreationParams`,
   etc.).
2. Call methods on an implementation of a class by using `getExtension` method (e.g.
   `XFile.getExtension`, `XDirectory.getExtension`, etc.).

Below is an example of using additional iOS/macOS and Web features for a `XFile`.

<?code-excerpt "readme_excerpts.dart (platform_features)"?>
```dart
late final XFile file;

switch (CrossFile.implementation) {
  case CrossFileWeb():
    final params = WebScopedStorageXFileCreationParams.fromObjectUrl(
      objectUrl: 'blob:https://some/url:for/file',
    );
    file = ScopedStorageXFile.fromCreationParams(params);
  case CrossFileDarwin():
    file = ScopedStorageXFile.fromUri(Uri.file('/my/file.txt'));
  default:
    file = XFile.fileSystem(path: '/my/file.txt');
}

await file
    .getExtension<SecurityScopedDarwinScopedStorageXFileExtension>()
    ?.startAccessingSecurityScopedResource();

debugPrint(await file.readAsString());

if (file is ScopedStorageXFile) {
  await file.dispose();
}
```

See https://pub.dev/documentation/cross_file_darwin/latest/cross_file_darwin/cross_file_darwin-library.html
for more details on iOS/macOS App Sandbox features.

See https://pub.dev/documentation/cross_file_android/latest/cross_file_android/cross_file_android-library.html
for more details on Android Scoped Storage features.

See https://pub.dev/documentation/cross_file_io/latest/cross_file_io/cross_file_io-library.html
for more details on `dart:io` features.

See https://pub.dev/documentation/cross_file_web/latest/cross_file_web/cross_file_web-library.html
for more details on Web features.
