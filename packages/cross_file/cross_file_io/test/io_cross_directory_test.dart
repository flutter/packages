// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:cross_file_io/cross_file_io.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

final Directory testDirectory = Directory(path.join(Directory.current.path, 'test'));

void main() {
  group('IOXDirectory', () {
    setUp(() {
      CrossFilePlatform.instance = CrossFileIO();
    });

    test('exists', () async {
      final directory = PlatformFileSystemXDirectory(
        PlatformFileSystemXDirectoryCreationParams(testDirectory.path),
      );

      expect(await directory.exists(), testDirectory.existsSync());
    });

    test('list', () async {
      final directory = PlatformFileSystemXDirectory(
        PlatformFileSystemXDirectoryCreationParams(testDirectory.path),
      );

      expect(
        (await directory.list(const PlatformListParams()).toList()).map(
          (PlatformXEntity entity) => entity.params.uri,
        ),
        (await testDirectory.list().toList()).map(
          (FileSystemEntity entity) => entity.uri.toString(),
        ),
      );
    });

    test('createFile', () async {
      final Directory tempDir = Directory.systemTemp.createTempSync();
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final directory = PlatformFileSystemXDirectory(
        PlatformFileSystemXDirectoryCreationParams(tempDir.path),
      );
      final PlatformXFile file = await directory.createFile(
        const PlatformCreateParams('new_file.txt'),
      );

      expect(await file.exists(), true);
      expect(await file.name(), 'new_file.txt');
    });

    test('createDirectory', () async {
      final Directory tempDir = Directory.systemTemp.createTempSync();
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final directory = PlatformFileSystemXDirectory(
        PlatformFileSystemXDirectoryCreationParams(tempDir.path),
      );
      final PlatformXDirectory subDir = await directory.createDirectory(
        const PlatformCreateParams('new_dir'),
      );

      expect(await subDir.exists(), true);
      final Directory ioDir = (subDir.extension! as IOFileSystemXDirectoryExtension).directory;
      expect(path.basename(ioDir.path), 'new_dir');
    });

    test('delete', () async {
      final Directory tempDir = Directory.systemTemp.createTempSync();
      addTearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });

      final directory = PlatformFileSystemXDirectory(
        PlatformFileSystemXDirectoryCreationParams(tempDir.path),
      );
      expect(await directory.exists(), true);

      final bool result = await directory.delete(const PlatformDirectoryDeleteParams());
      expect(result, true);
      expect(await directory.exists(), false);
    });

    test('delete non-existent directory returns false', () async {
      final Directory tempDir = Directory.systemTemp;
      final nonExistent = Directory(path.join(tempDir.path, 'non_existent_dir'));

      final directory = PlatformFileSystemXDirectory(
        PlatformFileSystemXDirectoryCreationParams(nonExistent.path),
      );
      expect(await directory.exists(), false);

      final bool result = await directory.delete(const PlatformDirectoryDeleteParams());
      expect(result, false);
    });
  });
}
