// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:cross_file_io/cross_file_io.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

final Directory testDirectory = Directory(
  path.join(Directory.current.path, 'test'),
);

void main() {
  group('IOXFile', () {
    setUp(() {
      CrossFilePlatform.instance = CrossFileIO();
    });

    test('exists', () async {
      final directory = PlatformXDirectory(
        PlatformXDirectoryCreationParams(uri: testDirectory.path),
      );

      expect(await directory.exists(), testDirectory.existsSync());
    });

    test('list', () async {
      final directory = PlatformXDirectory(
        PlatformXDirectoryCreationParams(uri: testDirectory.path),
      );

      expect(
        (await directory.list(ListParams()).toList()).map(
          (PlatformXFileEntity entity) => entity.params.uri,
        ),
        (await testDirectory.list().toList()).map(
          (FileSystemEntity entity) => entity.uri.toString(),
        ),
      );
    });
  });
}
