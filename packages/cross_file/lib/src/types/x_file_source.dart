// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

/// Access to a file controlled by the creator of the object.
///
/// An implementation of this class can back
/// all of the operations made on an XFile.
abstract class XFileSource {
  /// The MIME type of the source.
  String? get mimeType;

  /// The location of the source in the file system
  ///
  /// This should not be trusted to always be valid, if not at all.
  ///
  /// For the web implementation, this should be a blob URL.
  String? get path;

  /// The name of the file as it was selected by the user in their device.
  ///
  /// This represents most of the time the basename of `path` excepted on web.
  String? get name;

  /// Get the last-modified time for the CrossFile
  ///
  /// This should not be trusted to always be valid, if not at all.
  Future<DateTime> lastModified();

  /// Get the length of the file.
  ///
  /// This should not be trusted to always be valid, if not at all.
  Future<int> length();

  /// Create a new independent [Stream] for the contents of this source.
  /// If `start` is present, the source will be read from byte-offset `start`. Otherwise from the beginning (index 0).
  ///
  /// If `end` is present, only up to byte-index `end` will be read. Otherwise, until end of file.
  ///
  /// In order to make sure that system resources are freed, the stream must be read to completion or the subscription on the stream must be cancelled.
  Stream<Uint8List> openRead([int? start, int? end]);
}
