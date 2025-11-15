import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file_ios/src/foundation.g.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

base class IOSXFile extends PlatformSharedStorageXFile {
  IOSXFile(super.params) : super.implementation();

  final FileManager _fileManager = FileManager.defaultManager;

  @override
  Future<bool> canRead() {
    // TODO: implement canRead
    throw UnimplementedError();
  }

  @override
  Future<bool> exists() {
    return _fileManager.fileExists(params.path);
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
    final bool canRead = await URL.startAccessingSecurityScopedResource(params.path);
    if (canRead) {
      final Uint8List? bytes = await _fileManager.contents(params.path);
      URL.stopAccessingSecurityScopedResource(params.path);

      if (bytes case Uint8List bytes) {
        return bytes;
      }
    }

    throw UnsupportedError('Can access bytes to file: ${params.path}');
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) {
    // TODO: implement readAsString
    throw UnimplementedError();
  }
}
