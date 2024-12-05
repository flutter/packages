// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import '../web_helpers/web_helpers.dart';
import 'base_bytes_x_file.dart';

/// A CrossFile backed by an [Uint8List].
class BytesXFile extends BaseBytesXFile {
  /// Construct an [XFile] from its data [bytes].
  BytesXFile(
    super.bytes, {
    super.mimeType,
    super.displayName,
    super.lastModified,
  });

  /// Saves the data of this CrossFile at the location indicated by path.
  /// For the web implementation, the path variable is ignored.
  @override
  Future<void> saveTo(String path) async {
    // Convert [bytes] into a JS Blob, and save it in [path].
    await downloadBlob(
      bytesToBlob(bytes, mimeType),
      name.isEmpty ? null : name,
    );
  }
}
