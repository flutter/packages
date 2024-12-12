// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:typed_data';

import '../../cross_file.dart';
import '../../src/implementations/io_bytes_x_file.dart';
import '../../src/implementations/io_x_file.dart';

/// Creates [XFile] objects to maintain backwards-compatibility (dart:io).
abstract interface class XFileLegacyFactory {
  /// Creates an [XFile] from a `dart:io` [File]'s [path] or its optional [bytes].
  static XFile fromPath(
    String path, {
    String? mimeType,
    String? name,
    int? length,
    Uint8List? bytes,
    DateTime? lastModified,
  }) {
    assert(bytes == null);
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
    String? name,
    int? length,
    DateTime? lastModified,
    String? path,
  }) {
    return BytesXFile(
      bytes,
      mimeType: mimeType,
      displayName: name,
      lastModified: lastModified,
    );
  }
}
