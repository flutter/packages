// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file/cross_file.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_stubs.dart';

void main() {
  group('XDirectory', () {
    test('exists', () async {
      const exists = true;
      CrossFilePlatform.instance = TestCrossFilePlatform(
        onCreatePlatformScopedStorageXDirectory:
            (PlatformScopedStorageXDirectoryCreationParams params) =>
                TestScopedStorageXDirectory(
                  params,
                  onExists: () async => exists,
                ),
      );

      final directory = ScopedStorageXDirectory(uri: 'uri');

      expect(await directory.exists(), exists);
    });

    test('list', () async {
      final entities = <PlatformXFileEntity>[
        TestScopedStorageXFile(
          const PlatformScopedStorageXFileCreationParams(uri: 'uri1'),
        ),
        TestScopedStorageXDirectory(
          const PlatformScopedStorageXDirectoryCreationParams(uri: 'uri2'),
        ),
        TestXFileEntity(const PlatformXFileCreationParams(uri: 'uri3')),
      ];
      CrossFilePlatform.instance = TestCrossFilePlatform(
        onCreatePlatformScopedStorageXDirectory:
            (PlatformScopedStorageXDirectoryCreationParams params) =>
                TestScopedStorageXDirectory(
                  params,
                  onList: (ListParams params) => Stream.fromIterable(entities),
                ),
      );

      final directory = ScopedStorageXDirectory(uri: 'uri');

      final List<XFileEntity> directoryEntities = await directory
          .list()
          .toList();
      expect(directoryEntities.length, entities.length);
      expect(directoryEntities.first, isA<ScopedStorageXFile>());
      expect(directoryEntities.first.uri, entities.first.params.uri);
      expect(directoryEntities[1], isA<ScopedStorageXDirectory>());
      expect(directoryEntities[1].uri, entities[1].params.uri);
      expect(directoryEntities[2], isA<XFileEntity>());
      expect(directoryEntities[2].uri, entities[2].params.uri);
    });
  });
}
