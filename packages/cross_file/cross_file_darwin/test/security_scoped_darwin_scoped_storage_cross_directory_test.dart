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
      (await directory.list(ListParams()).toList()).map(
        (PlatformXEntity entity) => entity.params.uri,
      ),
      (await testDirectory.list().toList()).map((FileSystemEntity entity) => entity.uri.toString()),
    );
  });
}
