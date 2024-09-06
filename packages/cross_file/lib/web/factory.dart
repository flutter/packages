// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:web/web.dart' as web;

import '../src/implementations/blob_x_file.dart';
import '../src/implementations/web_bytes_x_file.dart';
import '../src/x_file.dart';

/// Creates [XFile] objects from different web sources.
abstract interface class XFileFactory {
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

  /// Creates an [XFile] from a browser [web.Blob].
  ///
  /// Allows passing the [mimeType], [displayName] and [lastModified] attributes
  /// of the file, if needed.
  static XFile fromBlob(
    web.Blob blob, {
    String? mimeType,
    String? displayName,
    DateTime? lastModified,
  }) {
    return BlobXFile(
      blob,
      mimeType: mimeType,
      displayName: displayName,
      lastModified: lastModified,
    );
  }

  /// Creates an [XFile] from a browser [web.File].
  ///
  /// Extracts the metadata (MIME-type, name and last modification date) from
  /// the `File` itself.
  static XFile fromFile(web.File file) {
    return BlobXFile.fromFile(file);
  }

  /// Creates an [XFile] from a browser [web.Blob]'s Object URL.
  ///
  /// The Object URL must have been created in the same JS `document` that the
  /// is attempting to read the URL, and not revoked.
  ///
  /// Allows passing the [mimeType], [displayName] and [lastModified] attributes
  /// of the file, if needed.
  ///
  /// See: https://developer.mozilla.org/en-US/docs/Web/API/URL/createObjectURL_static
  static Future<XFile> fromObjectUrl(
    String objectUrl, {
    String? mimeType,
    String? displayName,
    DateTime? lastModified,
  }) {
    return BlobXFile.fromObjectURL(
      objectUrl,
      mimeType: mimeType,
      displayName: displayName,
      lastModified: lastModified,
    );
  }
}
