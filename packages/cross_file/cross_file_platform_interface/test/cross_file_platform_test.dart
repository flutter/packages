// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CrossFilePlatform', () {
    test(
      'Default implementation of createPlatformXFile should return an implementation that returns false for exists()',
      () async {
        final platform = TestCrossFilePlatform();

        expect(
          await platform
              .createPlatformXFile(
                const PlatformXFileCreationParams(uri: 'test'),
              )
              .exists(),
          false,
        );
      },
    );

    test(
      'Default implementation of createPlatformXDirectory should return an implementation that returns false for exists()',
      () async {
        final platform = TestCrossFilePlatform();

        expect(
          await platform
              .createPlatformXDirectory(
                const PlatformXDirectoryCreationParams(uri: 'test'),
              )
              .exists(),
          false,
        );
      },
    );

    test(
      'Default implementation of createPlatformScopedStorageXFile should return an implementation that returns false for exists()',
      () async {
        final platform = TestCrossFilePlatform();

        expect(
          await platform
              .createPlatformScopedStorageXFile(
                const PlatformScopedStorageXFileCreationParams(uri: 'test'),
              )
              .exists(),
          false,
        );
      },
    );

    test(
      'Default implementation of createPlatformScopedStorageXDirectory should return an implementation that returns false for exists()',
      () async {
        final platform = TestCrossFilePlatform();

        expect(
          await platform
              .createPlatformScopedStorageXDirectory(
                const PlatformScopedStorageXDirectoryCreationParams(
                  uri: 'test',
                ),
              )
              .exists(),
          false,
        );
      },
    );
  });
}

final class TestCrossFilePlatform extends CrossFilePlatform {}
