---
name: cross-file-setup-and-usage
description: Set up and use the cross_file package (XFile) to work with files, byte streams, and file metadata consistently across mobile, desktop, and web platforms.
---

# Setting Up and Using cross_file

The `cross_file` package provides `XFile`, a cross-platform abstraction for working with files across Android, iOS, macOS, Windows, Linux, and Web. It enables plugins (such as `image_picker` or `file_selector`) and applications to read file contents, streams, and metadata without directly depending on `dart:io` or `package:web`.

## 1. Installation

Add `cross_file` to your project's `pubspec.yaml`:

```bash
flutter pub add cross_file
```

Or manually in `pubspec.yaml`:

```yaml
dependencies:
  cross_file: ^0.3.5+5
```

## 2. Platform Considerations

### MIME Types
- **Web**: `XFile.mimeType` automatically reflects browser-provided file metadata when available.
- **Native (Mobile/Desktop)**: Native implementations do not infer MIME types from file paths or contents. `mimeType` returns the value explicitly passed to the `XFile` constructor or `XFile.fromData`, if provided.

### Web Limitations
- On the Web platform, `XFile` is backed by browser `Blob` objects and object URLs.
- Safari has known limitations when reading Blobs larger than 4 GB and may hang. `cross_file` attempts to throw an `Exception` before accessing files known to exceed 4 GB on Safari so your application can handle it gracefully.

## 3. Usage and API Examples

Import the package in your Dart code:

```dart
import 'package:cross_file/cross_file.dart';
```

### Instantiating an `XFile` from a File Path

```dart
import 'package:cross_file/cross_file.dart';

Future<void> inspectFileFromPath(String filePath) async {
  final XFile file = XFile(filePath, mimeType: 'text/plain');

  print('Path: ${file.path}');
  print('Name: ${file.name}');
  print('MIME Type: ${file.mimeType}');
  print('Size: ${await file.length()} bytes');
  print('Last Modified: ${await file.lastModified()}');

  // Read entire file as a String
  final String content = await file.readAsString();
  print('Content: $content');
}
```

### Instantiating an `XFile` from In-Memory Bytes

Use `XFile.fromData` when you have raw `Uint8List` bytes in memory (for example, generated images, downloaded payloads, or canvas exports):

```dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:cross_file/cross_file.dart';

Future<void> createFromBytes() async {
  final Uint8List bytes = Uint8List.fromList(utf8.encode('Hello from memory!'));

  final XFile memoryFile = XFile.fromData(
    bytes,
    name: 'greeting.txt',
    mimeType: 'text/plain',
    lastModified: DateTime.now(),
  );

  final Uint8List readBack = await memoryFile.readAsBytes();
  print('Read ${readBack.length} bytes from XFile');
}
```

### Streaming Large Files

For large files, use `openRead()` to process chunks as a `Stream<Uint8List>` instead of loading the entire file into memory at once:

```dart
import 'dart:typed_data';
import 'package:cross_file/cross_file.dart';

Future<int> countBytesInStream(XFile file) async {
  int totalBytes = 0;
  final Stream<Uint8List> stream = file.openRead();

  await for (final Uint8List chunk in stream) {
    totalBytes += chunk.length;
  }
  return totalBytes;
}
```

You can also read a specific byte slice using `openRead(start, end)`:

```dart
final Stream<Uint8List> headerStream = file.openRead(0, 64);
```

### Saving an `XFile` to Disk

Use `saveTo` to persist the `XFile` to a target path on native platforms (or trigger/copy storage on supported targets):

```dart
Future<void> saveCopy(XFile sourceFile, String destinationPath) async {
  await sourceFile.saveTo(destinationPath);
}
```
