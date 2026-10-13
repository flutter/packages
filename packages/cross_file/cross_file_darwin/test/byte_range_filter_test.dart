// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:cross_file_darwin/src/byte_range_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ByteRangeFilter', () {
    test('correctly reads all bytes with 0 start and null end', () async {
      final filter = ByteRangeFilter(start: 0);

      final bytes = Uint8List.fromList(<int>[1, 2, 3]);
      expect(filter.addBytes(bytes), bytes);
    });

    test('correctly reads desired sublist', () async {
      final bytes = Uint8List.fromList(<int>[0, 1, 2, 3, 4]);
      final filter = ByteRangeFilter(start: 1, end: 4);

      // Ignore byte before desired sublist.
      expect(filter.addBytes(subListFromIndex(bytes, 0)), isEmpty);
      // Read byte at start of desired sublist.
      expect(filter.addBytes(subListFromIndex(bytes, 1)), subListFromIndex(bytes, 1));
      // Read byte between start and end of desired sublist.
      expect(filter.addBytes(subListFromIndex(bytes, 2)), subListFromIndex(bytes, 2));
      // Read byte at end of desire sublist.
      expect(filter.addBytes(subListFromIndex(bytes, 3)), subListFromIndex(bytes, 3));
      // Ignore byte after desired sublist.
      expect(filter.addBytes(subListFromIndex(bytes, 4)), isEmpty);
    });
  });
}

Uint8List subListFromIndex(Uint8List list, int index) {
  return list.sublist(index, index + 1);
}
