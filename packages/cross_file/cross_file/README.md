# cross_file

An abstraction to allow working with files across multiple platforms.

## Usage

Import `package:cross_file/cross_file.dart`, instantiate a `XFile`
using a path or byte array and use its methods and properties to
access the file and its metadata.

Example:

<?code-excerpt "example/lib/readme_excerpts.dart (Instantiate)"?>
```dart
final file = XFile('assets/hello.txt');

print('File information:');
print('- URI: ${file.uri}');
print('- Name: ${await file.name()}');

if (await file.canRead()) {
  final String fileContent = await file.readAsString();
  debugPrint('Content of the file: $fileContent');
}
```

You will find links to the API docs on the [pub page](https://pub.dev/packages/cross_file).

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

<?code-excerpt "main.dart (platform_imports)"?>
```dart
// Import for Android Scoped Storage features.
import 'package:cross_file_android/cross_file_android.dart';
// Import for iOS/macOS App Sandbox features.
import 'package:cross_file_darwin/cross_file_darwin.dart';
```

Now, additional features can be accessed through the platform implementations. Classes
[XFile], [XDirectory], [ScopedStorageXFile], and [ScopedStorageXDirectory] pass their
functionality to a class provided by the current platform. Below are a couple of ways to access
additional functionality provided by the platform and is followed by an example.

1. Pass a creation params class provided by a platform implementation to a `fromCreationParams`
   constructor (e.g. `XFile.fromCreationParams`, `XDirectory.fromCreationParams`, etc.).
2. Call methods on an implementation of a class by using `getExtension`/`maybeGetExtension` methods (e.g.
   `XFile.getExtension`, `XDirectory.maybeGetExtension`, etc.).

Below is an example of setting additional iOS/macOS and Android parameters on a `XFile`.

<?code-excerpt "main.dart (platform_features)"?>
```dart
var params = const PlatformXFileCreationParams(uri: 'my/file.txt');

if (CrossFilePlatform.instance is CrossFileIO) {
  params = IOXFileCreationParams.fromCreationParams(
    params,
  );
}

final file = XFile.fromCreationParams(params);

final IOXFileExtension? ioExtension = file.maybeGetExtension<IOXFileExtension>();
if (ioExtension != null) {
  print(ioExtension.file.path);
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
