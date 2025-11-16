import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file_ios/src/foundation.g.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

base class IOSXFile extends PlatformSharedStorageXFile {
  IOSXFile(super.params) : super.implementation();

  @override
  Future<bool> canRead() async {
    final URL? url = await URL.fileURLWithPath(params.path);

    if (url case URL url) {
      final bool canRead = await url.startAccessingSecurityScopedResource();
      await url.stopAccessingSecurityScopedResource();
      return canRead;
    }

    return false;
  }

  @override
  Future<bool> exists() {
    return canRead();
  }

  @override
  Future<DateTime> lastModified() {
    // TODO: implement lastModified
    throw UnimplementedError();
  }

  @override
  Future<int> length() {
    // TODO: implement length
    throw UnimplementedError();
  }

  @override
  Future<void> delete() {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Stream<List<int>> openRead([int? start, int? end]) {
    // TODO: implement openRead
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> readAsBytes() async {
    final URL? url = await URL.fileURLWithPath(params.path);

    if (url case URL url) {
      final bool canRead = await url.startAccessingSecurityScopedResource();
      if (canRead) {
        final FileHandle fileHandle = FileHandle.forReadingFromUrl(url: url);
        try {
          final Uint8List? bytes = await fileHandle.readToEnd();
          await url.stopAccessingSecurityScopedResource();

          if (bytes case Uint8List bytes) {
            return bytes;
          }
        } finally {
          fileHandle.close();
        }
      }
    }

    throw UnsupportedError('Cant access bytes to file: ${params.path}');
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async {
    return encoding.decode(await readAsBytes());
  }
}
