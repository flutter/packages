// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';
import 'dart:typed_data';

/// Byte range filter for a continuous stream of data.
///
/// Takes incoming chunks of bytes ([Uint8List]) as they arrive, and slices out
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
    final int chunkStart = _currentByteIndex;
    final int chunkEnd = chunkStart + bytes.length;
    _currentByteIndex = chunkEnd;

    // 1. Early-exit short-circuit
    if (end != null && chunkStart >= end!) {
      return Uint8List(0);
    }

    // 2. Compute absolute interval intersection
    final int intersectStart = max(chunkStart, start);
    final int intersectEnd = end == null ? chunkEnd : min(chunkEnd, end!);

    if (intersectStart < intersectEnd) {
      // 3. Convert absolute indices to chunk-local offsets
      final int localStart = intersectStart - chunkStart;
      final int localEnd = intersectEnd - chunkStart;

      // 4. Zero-copy view
      return Uint8List.sublistView(bytes, localStart, localEnd);
    }

    return Uint8List(0);
  }
}
