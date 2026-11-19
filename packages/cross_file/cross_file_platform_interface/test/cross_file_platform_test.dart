// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'dart:typed_data';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CrossFilePlatform', () {
    group('FileSystem', () {
      test('PlatformFileSystemXFile returns correct uri', () {
        final platform = TestCrossFilePlatform();

        expect(
          platform
              .createPlatformFileSystemXFile(PlatformFileSystemXFileCreationParams('my/path.txt'))
              .params
              .uri,
          'my/path.txt',
        );

        expect(
          platform
              .createPlatformFileSystemXFile(PlatformFileSystemXFileCreationParams('/my/path.txt'))
              .params
              .uri,
          'file:///my/path.txt',
        );
      });

      test('PlatformFileSystemXFile.toFilePath returns correct path', () {
        // Match relative path.
        final relativeFile = TestFileSystemXFile(
          PlatformFileSystemXFileCreationParams('my/path.txt'),
        );
        expect(relativeFile.toFilePath(), Uri.file('my/path.txt').toFilePath());

        // Match absolute path.
        final absoluteFile = TestFileSystemXFile(
          PlatformFileSystemXFileCreationParams('/my/path.txt'),
        );
        expect(absoluteFile.toFilePath(), Uri.parse('/my/path.txt').toFilePath());
      });

      test('PlatformFileSystemXDirectory returns correct URI', () {
        final platform = TestCrossFilePlatform();

        expect(
          platform
              .createPlatformFileSystemXDirectory(
                PlatformFileSystemXDirectoryCreationParams('my/path'),
              )
              .params
              .uri,
          'my/path/',
        );

        expect(
          platform
              .createPlatformFileSystemXFile(PlatformFileSystemXFileCreationParams('/my/path/'))
              .params
              .uri,
          'file:///my/path/',
        );
      });

      test('PlatformFileSystemXDirectory.toFilePath returns correct path', () {
        final relativeDirectory = TestFileSystemXDirectory(
          PlatformFileSystemXDirectoryCreationParams('my/path'),
        );

        // Match relative path.
        expect(relativeDirectory.toFilePath(), Uri.directory('my/path').toFilePath());

        // Match absolute path.
        final absoluteDirectory = TestFileSystemXDirectory(
          PlatformFileSystemXDirectoryCreationParams('/my/path/'),
        );
        expect(absoluteDirectory.toFilePath(), Uri.parse('/my/path/').toFilePath());
      });

      test('PlatformFileSystemXDirectory.toFilePath adds a trailing slash', () {
        final directory = TestFileSystemXDirectory(
          PlatformFileSystemXDirectoryCreationParams('my/dir'),
        );

        expect(directory.toFilePath(), anyOf(endsWith('/'), endsWith(r'\')));
      });

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

      test('_DefaultFileSystemXFile.toFilePath returns null', () {
        final platform = TestCrossFilePlatform();

        expect(
          platform
              .createPlatformFileSystemXFile(PlatformFileSystemXFileCreationParams('my/path.txt'))
              .toFilePath(),
          null,
        );
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

      test('_DefaultFileSystemXDirectory.toFilePath returns null', () {
        final platform = TestCrossFilePlatform();

        expect(
          platform
              .createPlatformFileSystemXDirectory(
                PlatformFileSystemXDirectoryCreationParams('my/dir/'),
              )
              .toFilePath(),
          null,
        );
      });
    });

    group('ScopedStorage', () {
      test('_DefaultScopedStorageXFile.toFilePath returns null by default', () {
        final platform = TestCrossFilePlatform();
        final PlatformScopedStorageXFile file = platform.createPlatformScopedStorageXFile(
          const PlatformScopedStorageXFileCreationParams(uri: 'test'),
        );

        expect(file.toFilePath(), null);
      });

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

      test('_DefaultScopedStorageXDirectory.toFilePath returns null by default', () {
        final platform = TestCrossFilePlatform();
        final PlatformScopedStorageXDirectory directory = platform
            .createPlatformScopedStorageXDirectory(
              const PlatformScopedStorageXDirectoryCreationParams(uri: 'test'),
            );

        expect(directory.toFilePath(), null);
      });

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

final class TestFileSystemXFile extends PlatformFileSystemXFile {
  TestFileSystemXFile(super.params) : super.implementation();

  @override
  Future<bool> exists() {
    throw UnimplementedError();
  }

  @override
  Future<DateTime?> lastModified() {
    throw UnimplementedError();
  }

  @override
  Future<int?> length() {
    throw UnimplementedError();
  }

  @override
  Future<String?> name() {
    throw UnimplementedError();
  }

  @override
  Stream<Uint8List> openRead([int? start, int? end]) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> readAsBytes() {
    throw UnimplementedError();
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) {
    throw UnimplementedError();
  }

  @override
  Future<PlatformFileSystemXFile> writeAsBytes(PlatformWriteAsBytesParams params) {
    throw UnimplementedError();
  }
}

final class TestFileSystemXDirectory extends PlatformFileSystemXDirectory {
  TestFileSystemXDirectory(super.params) : super.implementation();

  @override
  Future<bool> exists() {
    throw UnimplementedError();
  }

  @override
  Stream<PlatformXEntity> list(PlatformListParams params) {
    throw UnimplementedError();
  }
}
