// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_darwin/src/cross_file_darwin_apis.g.dart';
import 'package:cross_file_darwin/src/darwin_scoped_storage_cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'photo_kit_darwin_scoped_storage_cross_file_test.mocks.dart';

@GenerateMocks(<Type>[AssetResourceReader, AssetResourceReaderDelegate])
void main() {
  setUp(() {
    PigeonOverrides.pigeon_reset();
  });

  test('readBytes', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

    final file = DarwinScopedStorageXFile(
      DarwinScopedStorageXFileCreationParams.photoKit(localIdentifier: 'id'),
    );

    final reader = MockAssetResourceReader();
    final bytes = Uint8List.fromList(<int>[1, 2, 3]);
    when(reader.readBytes('id')).thenAnswer((_) => Future.value(bytes));
    PigeonOverrides.assetResourceReader_new = () {
      return reader;
    };

    expect(await file.readAsBytes(), bytes);

    debugDefaultTargetPlatformOverride = null;
  });

  group('openRead pigeon', () {
    test('correctly reads all bytes with null start and null end', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      final file = DarwinScopedStorageXFile(
        DarwinScopedStorageXFileCreationParams.photoKit(localIdentifier: 'id'),
      );

      final MockAssetResourceReaderDelegate delegate = setUpReaderDelegate();

      final Stream<Uint8List> stream = file.openRead();

      final bytes = Uint8List.fromList(<int>[1, 2, 3]);
      delegate.onDataReceived(delegate, bytes);
      delegate.onCompletion(delegate, null);

      expect(
        await stream.reduce(
          (Uint8List first, Uint8List second) => Uint8List.fromList(<int>[...first, ...second]),
        ),
        bytes,
      );

      debugDefaultTargetPlatformOverride = null;
    });

    test('correctly reads desired sublist', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      final file = DarwinScopedStorageXFile(
        DarwinScopedStorageXFileCreationParams.photoKit(localIdentifier: 'id'),
      );

      final MockAssetResourceReaderDelegate delegate = setUpReaderDelegate();

      final bytes = Uint8List.fromList(<int>[0, 1, 2, 3, 4]);
      final Stream<Uint8List> stream = file.openRead(1, 4);

      // Ignore byte before desired sublist.
      delegate.onDataReceived(delegate, Uint8List.fromList(<int>[bytes[0]]));
      // Read byte at start of desired sublist.
      delegate.onDataReceived(delegate, Uint8List.fromList(<int>[bytes[1]]));
      // Read byte between start and end of desired sublist.
      delegate.onDataReceived(delegate, Uint8List.fromList(<int>[bytes[2]]));
      // Read byte at end of desire sublist
      delegate.onDataReceived(delegate, Uint8List.fromList(<int>[bytes[3]]));
      // Ignore byte after desired sublist.
      delegate.onDataReceived(delegate, Uint8List.fromList(<int>[bytes[4]]));
      delegate.onCompletion(delegate, null);

      expect(
        await stream.reduce(
          (Uint8List first, Uint8List second) => Uint8List.fromList(<int>[...first, ...second]),
        ),
        bytes.sublist(1, 4),
      );

      debugDefaultTargetPlatformOverride = null;
    });
  });
}

MockAssetResourceReaderDelegate setUpReaderDelegate() {
  final reader = MockAssetResourceReader();
  final readerDelegate = MockAssetResourceReaderDelegate();

  when(reader.openRead('id', readerDelegate)).thenAnswer((_) async {
    return true;
  });

  PigeonOverrides.assetResourceReader_new = () {
    return reader;
  };
  PigeonOverrides.assetResourceReaderDelegate_new =
      ({
        required void Function(AssetResourceReaderDelegate instance, Uint8List bytes)
        onDataReceived,
        required void Function(AssetResourceReaderDelegate instance, String? error) onCompletion,
      }) {
        when(readerDelegate.onDataReceived).thenReturn(onDataReceived);
        when(readerDelegate.onCompletion).thenReturn(onCompletion);
        return readerDelegate;
      };

  return readerDelegate;
}
