// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:cross_file_darwin/src/cross_file_darwin_apis.g.dart';
import 'package:cross_file_darwin/src/darwin_scoped_storage_cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'photo_kit_darwin_scoped_storage_cross_file_test.mocks.dart';

@GenerateMocks(<Type>[AssetResourceReader])
void main() {
  setUp(() {
    PigeonOverrides.pigeon_reset();
  });

  group('openRead', () {
    test('correctly reads all bytes with null start and null end', () async {
      final file = DarwinScopedStorageXFile(
        DarwinScopedStorageXFileCreationParams.photoKit(localIdentifier: 'id'),
      );

      final MockAssetResourceReader reader = setUpReader();

      final Stream<Uint8List> stream = file.openRead();

      final bytes = Uint8List.fromList(<int>[1, 2, 3]);
      reader.onDataReceived(reader, bytes);
      reader.onCompletion(reader, null);

      expect(
        await stream.reduce(
          (Uint8List first, Uint8List second) => Uint8List.fromList(<int>[...first, ...second]),
        ),
        bytes,
      );
    });

    test('correctly reads desired sublist', () async {
      final file = DarwinScopedStorageXFile(
        DarwinScopedStorageXFileCreationParams.photoKit(localIdentifier: 'id'),
      );

      final MockAssetResourceReader reader = setUpReader();

      final bytes = Uint8List.fromList(<int>[0, 1, 2, 3, 4]);
      final Stream<Uint8List> stream = file.openRead(1, 4);

      // Ignore byte before desired sublist.
      reader.onDataReceived(reader, Uint8List.fromList(<int>[bytes[0]]));
      // Read byte at start of desired sublist.
      reader.onDataReceived(reader, Uint8List.fromList(<int>[bytes[1]]));
      // Read byte between start and end of desired sublist.
      reader.onDataReceived(reader, Uint8List.fromList(<int>[bytes[2]]));
      // Read byte at end of desire sublist
      reader.onDataReceived(reader, Uint8List.fromList(<int>[bytes[3]]));
      // Ignore byte after desired sublist.
      reader.onDataReceived(reader, Uint8List.fromList(<int>[bytes[4]]));
      reader.onCompletion(reader, null);

      expect(
        await stream.reduce(
          (Uint8List first, Uint8List second) => Uint8List.fromList(<int>[...first, ...second]),
        ),
        bytes.sublist(1, 4),
      );
    });
  });
}

MockAssetResourceReader setUpReader() {
  final reader = MockAssetResourceReader();
  when(reader.startRead('id')).thenAnswer((_) async {
    return true;
  });

  PigeonOverrides.assetResourceReader_new =
      ({
        required void Function(AssetResourceReader instance, Uint8List bytes) onDataReceived,
        required void Function(AssetResourceReader instance, String? error) onCompletion,
      }) {
        when(reader.onDataReceived).thenReturn(onDataReceived);
        when(reader.onCompletion).thenReturn(onCompletion);
        return reader;
      };

  return reader;
}
