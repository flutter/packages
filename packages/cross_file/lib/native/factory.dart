// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:typed_data';

import '../cross_file.dart';
import '../src/implementations/io_bytes_x_file.dart';
import '../src/implementations/io_x_file.dart';

/// Creates [XFile] objects from different native sources.
abstract interface class XFileFactory {
  /// Creates an [XFile] from a `dart:io` [File].
  ///
  /// Allows passing the [mimeType] attribute of the file, if needed.
  static XFile fromFile(
    File file, {
    String? mimeType,
  }) {
    return IOXFile(
      file,
      mimeType: mimeType,
    );
  }

  /// Creates an [XFile] from a `dart:io` [File]'s [path].
  ///
  /// Allows passing the [mimeType] attribute of the file, if needed.
  static XFile fromPath(
    String path, {
    String? mimeType,
  }) {
    return IOXFile.fromPath(
      path,
      mimeType: mimeType,
    );
  }

  /// Creates an [XFile] from an array of [bytes].
  ///
  /// Allows passing the [mimeType], [displayName] and [lastModified] attributes
  /// of the file, if needed.
  static XFile fromBytes(
    Uint8List bytes, {
    String? mimeType,
    String? displayName,
    DateTime? lastModified,
  }) {
    return BytesXFile(
      bytes,
      mimeType: mimeType,
      displayName: displayName,
      lastModified: lastModified,
    );
  }
}
