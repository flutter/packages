import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show immutable;

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:meta/meta.dart';

@immutable
@optionalTypeArgs
class XFile<T extends PlatformXFileExtension> {
  XFile(String path)
    : this.fromPlatformCreationParams(PlatformXFileCreationParams(path: path));

  XFile.fromPlatformCreationParams(PlatformXFileCreationParams params)
    : this.fromPlatform(PlatformXFile(params));

  XFile.fromPlatform(this.platform);

  final PlatformXFile platform;

  String get path => platform.params.path;

  /// Provides a nonnull platform class extension.
  ///
  /// Will throw an exception if the specified platform extension can not be
  /// returned.
  S getPlatformExtension<S extends T>() {
    return platform.extension! as S;
  }

  /// Attempt to provide the platform class extension.
  ///
  /// Returns null if the specified platform extension cannot be retrieved.
  S? maybeGetPlatformExtension<S extends T>() {
    return platform.extension is S ? platform.extension! as S : null;
  }

  Future<DateTime> lastModified() => platform.lastModified();

  /// The length of the file.
  Future<int> length() => platform.length();

  /// Whether file exists.
  Future<bool> exists() => platform.exists();

  Future<bool> canRead() => platform.canRead();

  Stream<List<int>> openRead([int? start, int? end]) =>
      platform.openRead(start, end);

  /// Reads the entire file contents as a list of bytes.
  Future<Uint8List> readAsBytes() => platform.readAsBytes();

  /// Reads the entire file contents as a string using the given Encoding.
  Future<String> readAsString({Encoding encoding = utf8}) =>
      platform.readAsString(encoding: encoding);
}
