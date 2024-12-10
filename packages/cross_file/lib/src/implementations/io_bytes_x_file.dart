// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:typed_data';

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

  @override
  Future<void> saveTo(String path) async {
    final File fileToSave = File(path);
    await fileToSave.writeAsBytes(bytes);
  }
}
