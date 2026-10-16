// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:cross_file_darwin/cross_file_darwin.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

final Directory testDirectory = Directory(path.join(Directory.current.path, 'test'));

void main() {
  setUp(() {
    CrossFilePlatform.instance = CrossFileDarwin();
  });

  test('exists', () async {
    final directory = PlatformScopedStorageXDirectory(
      PlatformScopedStorageXDirectoryCreationParams(uri: testDirectory.uri.toString()),
    );

    expect(await directory.exists(), testDirectory.existsSync());
  });

  test('list', () async {
    final directory = PlatformScopedStorageXDirectory(
      PlatformScopedStorageXDirectoryCreationParams(uri: testDirectory.uri.toString()),
    );

    expect(
      (await directory.list(const PlatformListParams()).toList()).map(
        (PlatformXEntity entity) => entity.params.uri,
      ),
      (await testDirectory.list().toList()).map((FileSystemEntity entity) => entity.uri.toString()),
    );
  });

  test('createFile', () async {
    final Directory tempDir = Directory.systemTemp.createTempSync();
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final directory = PlatformScopedStorageXDirectory(
      PlatformScopedStorageXDirectoryCreationParams(uri: tempDir.uri.toString()),
    );

    final PlatformXFile file = await directory.createFile(
      const PlatformCreateParams('new_file.txt'),
    );

    final String fileUri = path.join(tempDir.path, 'new_file.txt');
    expect(file.params.uri, Uri.file(fileUri).toString());
    expect(File(fileUri).existsSync(), isTrue);
  });

  test('createDirectory', () async {
    final Directory tempDir = Directory.systemTemp.createTempSync();
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final directory = PlatformScopedStorageXDirectory(
      PlatformScopedStorageXDirectoryCreationParams(uri: tempDir.uri.toString()),
    );

    final PlatformXDirectory subDirectory = await directory.createDirectory(
      const PlatformCreateParams('new_dir'),
    );

    final String subDirectoryUri = path.join(tempDir.path, 'new_dir');
    expect(subDirectory.params.uri, Uri.directory(subDirectoryUri).toString());
    expect(Directory(subDirectoryUri).existsSync(), isTrue);
  });
}
