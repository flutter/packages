// Platform Interface

import 'dart:convert';
import 'dart:typed_data';

abstract base class XFilePlatform {
  static XFilePlatform? instance;

  PlatformXFile createPlatformXFile(String path);
}

abstract base class PlatformXFile {
  PlatformXFile(this.path);

  final String path;

  Future<DateTime> lastModified();

  /// Reads the entire file contents as a list of bytes.
  Future<Uint8List> readAsBytes();

  /// Reads the entire file contents as a string using the given Encoding.
  Future<String> readAsString({Encoding encoding = utf8});

  /// The length of the file.
  Future<int> length();

  Stream<Uint8List> openRead([int? start, int? end]);
}
