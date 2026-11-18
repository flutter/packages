// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file/cross_file.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_stubs.dart';

void main() {
  group('XEntity', () {
    test('toFilePath', () {
      const path = '/my/file.txt';
      final entity = XEntity(
        TestXEntity(
          const PlatformXFileCreationParams(uri: 'some/other/path.txt'),
          onToFilePath: () => path,
        ),
      );

      expect(entity.toFilePath(), path);
    });
  });
}
