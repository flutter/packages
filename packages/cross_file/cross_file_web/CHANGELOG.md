## 1.1.1

* Adds removal of `Finalizer` callback when the blob-backed creation params from
  `WebScopedStorageXFileCreationParams.fromBlob` is disposed manually.
  This prevents a disposed web `PlatformXFile` from calling `URL.revokeObjectURL` again after
  garbage collection.
* Updates minimum supported SDK version to Flutter 3.44/Dart 3.12.

## 1.1.0

* Adds a library that can be compiled when imported on non-web platforms. Includes
  cross-platform safe references to `WebScopedStorageXFileCreationParams`,
  `WebScopedStorageXFileExtension`, and `CrossFileWeb`. Add the following import to use:
  `import 'package:cross_file_web/cross_file_web_safe.dart`.
* Adds support to create creation params from a `Uint8List`. See
  `WebScopedStorageXFileCreationParams.fromBytes`.
* Updates minimum supported SDK version to Flutter 3.41/Dart 3.11.

## 1.0.0

* Initial release.
