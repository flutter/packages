import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'cross_file_platform.dart';

@immutable
base class PlatformXFileCreationParams {
  const PlatformXFileCreationParams({required this.path});

  final String path;
}

mixin PlatformXFileExtension {}

abstract base class PlatformXFile {
  /// Creates a new [PlatformXFile]
  factory PlatformXFile(PlatformXFileCreationParams params) {
    assert(
      CrossFilePlatform.instance != null,
      'A platform implementation for `cross_file` has not been set. Please '
      'ensure that an implementation of `XFilePlatform` has been set to '
      '`CrossFilePlatform.instance` before use. For unit testing, '
      '`CrossFilePlatform.instance` can be set with your own test implementation.',
    );
    final PlatformXFile file = CrossFilePlatform.instance!.createPlatformXFile(
      params,
    );
    return file;
  }

  @protected
  PlatformXFile.implementation(this.params);

  final PlatformXFileCreationParams params;

  PlatformXFileExtension? get extension => null;

  Future<DateTime> lastModified();

  /// The length of the file.
  Future<int> length();

  /// Whether file exists.
  Future<bool> exists();

  Future<bool> canRead();

  Stream<List<int>> openRead([int? start, int? end]);

  /// Reads the entire file contents as a list of bytes.
  Future<Uint8List> readAsBytes();

  /// Reads the entire file contents as a string using the given Encoding.
  Future<String> readAsString({Encoding encoding = utf8});
}
