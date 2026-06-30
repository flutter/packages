// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';
import 'dart:typed_data';

/// Byte range filter for a continuous stream of data.
///
/// Takes incoming chunks of bytes (Uint8List) as they arrive, and slices out
/// only the portion that falls within a specific ([start], [end]) index range.
///
/// All byte chunks are passed to [addBytes] which returns only the bytes that
/// are within the desired range.
class ByteRangeFilter {
  /// Constructs a [ByteRangeFilter].
  ByteRangeFilter({required this.start, this.end})
    : assert(start >= 0),
      assert(end == null || end >= start);

  /// Starting index, inclusive.
  final int start;

  /// End index, exclusive.
  final int? end;

  int _currentByteIndex = 0;

  /// Adds a chunk of bytes to be filtered.
  ///
  /// Returns a list of bytes if they are within the desired range of [start]
  /// and [end]. Otherwise, returns an empty list.
  Uint8List addBytes(Uint8List bytes) {
    Uint8List? inRangeBytes;
    final int newByteIndex = _currentByteIndex + bytes.length;

    if (end == null) {
      if (_currentByteIndex >= start) {
        inRangeBytes = bytes;
      } else {
        if (newByteIndex > start) {
          inRangeBytes = bytes.sublist(start - _currentByteIndex);
        }
      }
    } else if (end case final int end) {
      final int bytesLeftToRead = end - max(_currentByteIndex, start);

      if (bytesLeftToRead > 0) {
        if (_currentByteIndex >= start) {
          inRangeBytes = bytes.sublist(0, min(bytesLeftToRead, bytes.length));
        } else if (newByteIndex > start) {
          inRangeBytes = bytes.sublist(
            start - _currentByteIndex,
            min(start - _currentByteIndex + bytesLeftToRead, bytes.length),
          );
        }
      }
    }

    _currentByteIndex = newByteIndex;
    return inRangeBytes ?? Uint8List(0);
  }
}
