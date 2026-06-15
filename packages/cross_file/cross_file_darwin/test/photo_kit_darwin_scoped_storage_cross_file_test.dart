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
    test('null start and null end', () async {
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

    test('oijspio', () async {
      final file = DarwinScopedStorageXFile(
        DarwinScopedStorageXFileCreationParams.photoKit(localIdentifier: 'id'),
      );

      final MockAssetResourceReader reader = setUpReader();

      final Stream<Uint8List> stream = file.openRead(2, 8);

      final allBytes = Uint8List.fromList(<int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
      reader.onDataReceived(reader, allBytes.sublist(0, 2));
      reader.onDataReceived(reader, allBytes.sublist(2, 4));
      reader.onDataReceived(reader, allBytes.sublist(4, 6));
      reader.onDataReceived(reader, allBytes.sublist(6, 8));
      reader.onDataReceived(reader, allBytes.sublist(8, 10));
      reader.onCompletion(reader, null);

      expect(
        await stream.reduce(
          (Uint8List first, Uint8List second) => Uint8List.fromList(<int>[...first, ...second]),
        ),
        allBytes.sublist(2, 8),
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
