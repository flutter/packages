// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CrossFilePlatform', () {
    group('FileSystem', () {
      test('_DefaultFileSystemXFile.exists() returns false', () async {
        final platform = TestCrossFilePlatform();

        expect(
          await platform
              .createPlatformFileSystemXFile(PlatformFileSystemXFileCreationParams('test'))
              .exists(),
          false,
        );
      });

      test('_DefaultFileSystemXFile.openRead should throw error by adding it to stream', () async {
        final platform = TestCrossFilePlatform();

        final PlatformFileSystemXFile file = platform.createPlatformFileSystemXFile(
          PlatformFileSystemXFileCreationParams('test'),
        );

        // Ensures the error is caught and added to the stream.
        await expectLater(file.openRead().drain, throwsUnsupportedError);
      });

      test('_DefaultFileSystemXDirectory.exists() returns false', () async {
        final platform = TestCrossFilePlatform();

        expect(
          await platform
              .createPlatformFileSystemXDirectory(
                PlatformFileSystemXDirectoryCreationParams('test'),
              )
              .exists(),
          false,
        );
      });

      test('_DefaultFileSystemXDirectory.list should throw error by adding it to stream', () async {
        final platform = TestCrossFilePlatform();

        final PlatformFileSystemXDirectory dir = platform.createPlatformFileSystemXDirectory(
          PlatformFileSystemXDirectoryCreationParams('test'),
        );

        // Ensures the error is caught and added to the stream.
        await expectLater(dir.list(const PlatformListParams()).drain, throwsUnsupportedError);
      });
    });

    group('ScopedStorage', () {
      test('_DefaultScopedStorageXFile.exists() returns false', () async {
        final platform = TestCrossFilePlatform();

        expect(
          await platform
              .createPlatformScopedStorageXFile(
                const PlatformScopedStorageXFileCreationParams(uri: 'test'),
              )
              .exists(),
          false,
        );
      });

      test(
        '_DefaultScopedStorageXFile.openRead should throw error by adding it to stream',
        () async {
          final platform = TestCrossFilePlatform();

          final PlatformScopedStorageXFile file = platform.createPlatformScopedStorageXFile(
            const PlatformScopedStorageXFileCreationParams(uri: 'test'),
          );

          // Ensures the error is caught and added to the stream.
          await expectLater(file.openRead().drain, throwsUnsupportedError);
        },
      );

      test('_DefaultScopedStorageXDirectory.exists() returns false', () async {
        final platform = TestCrossFilePlatform();

        expect(
          await platform
              .createPlatformScopedStorageXDirectory(
                const PlatformScopedStorageXDirectoryCreationParams(uri: 'test'),
              )
              .exists(),
          false,
        );
      });

      test(
        '_DefaultScopedStorageXDirectory.list should throw error by adding it to stream',
        () async {
          final platform = TestCrossFilePlatform();

          final PlatformScopedStorageXDirectory dir = platform
              .createPlatformScopedStorageXDirectory(
                const PlatformScopedStorageXDirectoryCreationParams(uri: 'test'),
              );

          // Ensures the error is caught and added to the stream.
          await expectLater(dir.list(const PlatformListParams()).drain, throwsUnsupportedError);
        },
      );
    });
  });
}

final class TestCrossFilePlatform extends CrossFilePlatform {}
