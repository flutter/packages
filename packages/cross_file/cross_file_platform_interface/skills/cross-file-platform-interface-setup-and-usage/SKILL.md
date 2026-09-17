---
name: cross-file-platform-interface-setup-and-usage
description: Set up and use cross_file_platform_interface to implement or extend platform-specific file handling abstractions for the cross_file package.
---

# Setting Up and Using cross_file_platform_interface

The `cross_file_platform_interface` package provides a common platform interface for the [`cross_file`](https://pub.dev/packages/cross_file) package. It allows platform-specific implementations of `cross_file` to support the same `XFile` API contract across different environments.

## 1. Installation

Add `cross_file_platform_interface` to your platform implementation package's `pubspec.yaml`:

```bash
flutter pub add cross_file_platform_interface
```

Or manually in `pubspec.yaml`:

```yaml
dependencies:
  cross_file_platform_interface: ^1.0.0
```

## 2. Design Guidelines and Best Practices

- **Extend, Do Not Implement**: Always `extend` `CrossFilePlatform` and `XFilePlatform` rather than using `implements`. Adding new methods with default implementations to platform interfaces is considered a non-breaking change in Flutter plugins. Classes that `implement` the interface will break when new methods are added.
- **Avoid Breaking Changes**: Strongly prefer non-breaking changes (such as adding optional parameters or new methods with fallback behavior) over breaking changes.

## 3. Usage and API Examples

### Implementing a Custom Platform Implementation

To create a new platform implementation of `cross_file`, extend `CrossFilePlatform` and override its factory methods to return your custom `XFilePlatform` subclass:

```dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

/// Custom platform implementation of [CrossFilePlatform].
class CustomCrossFilePlatform extends CrossFilePlatform {
  /// Registers this class as the default instance of [CrossFilePlatform].
  static void registerWith() {
    CrossFilePlatform.instance = CustomCrossFilePlatform();
  }

  @override
  XFilePlatform createXFile(
    String path, {
    String? mimeType,
    String? name,
    int? length,
    Uint8List? bytes,
    DateTime? lastModified,
  }) {
    return CustomXFilePlatform(
      path,
      mimeType: mimeType,
      name: name,
      length: length,
      bytes: bytes,
      lastModified: lastModified,
    );
  }

  @override
  XFilePlatform createXFileFromData(
    Uint8List bytes, {
    String? mimeType,
    String? name,
    int? length,
    DateTime? lastModified,
    String? path,
  }) {
    return CustomXFilePlatform(
      path ?? '',
      bytes: bytes,
      mimeType: mimeType,
      name: name,
      length: length ?? bytes.length,
      lastModified: lastModified,
    );
  }
}

/// Custom platform implementation of [XFilePlatform].
class CustomXFilePlatform extends XFilePlatform {
  CustomXFilePlatform(
    this._path, {
    this.mimeType,
    String? name,
    int? length,
    Uint8List? bytes,
    DateTime? lastModified,
  })  : _name = name ?? _path.split('/').last,
        _length = length,
        _bytes = bytes,
        _lastModified = lastModified,
        super(_path);

  final String _path;
  final String _name;
  final int? _length;
  final Uint8List? _bytes;
  final DateTime? _lastModified;

  @override
  final String? mimeType;

  @override
  String get path => _path;

  @override
  String get name => _name;

  @override
  Future<int> length() async => _length ?? _bytes?.length ?? 0;

  @override
  Future<DateTime> lastModified() async =>
      _lastModified ?? DateTime.fromMillisecondsSinceEpoch(0);

  @override
  Future<Uint8List> readAsBytes() async {
    if (_bytes != null) {
      return _bytes;
    }
    throw UnimplementedError('Reading from path is not implemented.');
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async {
    final Uint8List bytes = await readAsBytes();
    return encoding.decode(bytes);
  }

  @override
  Stream<Uint8List> openRead([int? start, int? end]) async* {
    final Uint8List bytes = await readAsBytes();
    yield bytes.sublist(start ?? 0, end);
  }

  @override
  Future<void> saveTo(String path) async {
    // Platform-specific save logic here.
  }
}
```
