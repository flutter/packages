// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'dart:typed_data';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CrossFilePlatform', () {
    group('XFile', () {
      test('calling openWrite throws UnsupportedError', () {
        final file = TestXFile(const PlatformXFileCreationParams(uri: ''));
        expect(
          () => file.openWrite(const PlatformOpenWriteParams()),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('calling writeAsString throws UnsupportedError', () {
        final file = TestXFile(const PlatformXFileCreationParams(uri: ''));
        expect(
          () => file.writeAsString(const PlatformWriteAsStringParams('')),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('calling delete throws UnsupportedError', () {
        final file = TestXFile(const PlatformXFileCreationParams(uri: ''));
        expect(
          () => file.delete(const PlatformFileDeleteParams()),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });

    group('XDirectory', () {
      test('calling createFile throws UnsupportedError', () {
        final dir = TestXDirectory(const PlatformXDirectoryCreationParams(uri: ''));
        expect(
          () => dir.createFile(const PlatformCreateParams('')),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('calling createDirectory throws UnsupportedError', () {
        final dir = TestXDirectory(const PlatformXDirectoryCreationParams(uri: ''));
        expect(
          () => dir.createDirectory(const PlatformCreateParams('')),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('calling delete throws UnsupportedError', () {
        final dir = TestXDirectory(const PlatformXDirectoryCreationParams(uri: ''));
        expect(
          () => dir.delete(const PlatformDirectoryDeleteParams()),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });

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

      test('_DefaultScopedStorageXFile.canWrite() returns false', () async {
        final platform = TestCrossFilePlatform();

        expect(
          await platform
              .createPlatformScopedStorageXFile(
                const PlatformScopedStorageXFileCreationParams(uri: 'test'),
              )
              .canWrite(),
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

      test('_DefaultScopedStorageXDirectory.canWrite() returns false', () async {
        final platform = TestCrossFilePlatform();

        expect(
          await platform
              .createPlatformScopedStorageXDirectory(
                const PlatformScopedStorageXDirectoryCreationParams(uri: 'test'),
              )
              .canWrite(),
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

final class TestXFile extends PlatformXFile {
  TestXFile(super.params);

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
}

final class TestXDirectory extends PlatformXDirectory {
  TestXDirectory(super.params);

  @override
  Future<bool> exists() {
    throw UnimplementedError();
  }

  @override
  Stream<PlatformXEntity> list(PlatformListParams params) {
    throw UnimplementedError();
  }
}
