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

  test('toFilePath', () async {
    final directory = PlatformScopedStorageXDirectory(
      PlatformScopedStorageXDirectoryCreationParams(uri: testDirectory.uri.toString()),
    );

    expect(directory.toFilePath(), Uri.parse(directory.params.uri).toFilePath());
  });

  test('toFilePath path does not contain a scheme', () async {
    final file = PlatformScopedStorageXDirectory(
      PlatformScopedStorageXDirectoryCreationParams(uri: testDirectory.uri.toString()),
    );

    expect(Uri.parse(file.params.uri).hasScheme, isTrue);
    expect(Uri.parse(file.toFilePath()!).hasScheme, isFalse);
  });

  test('toFilePath adds trailing slash', () async {
    final directory = PlatformScopedStorageXDirectory(
      const PlatformScopedStorageXDirectoryCreationParams(uri: 'my/dir'),
    );

    expect(directory.toFilePath(), anyOf(endsWith('/'), endsWith(r'\')));
  });
}
