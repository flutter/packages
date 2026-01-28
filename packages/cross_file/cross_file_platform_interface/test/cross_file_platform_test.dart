// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'dart:typed_data';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CrossFilePlatform', () {
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

final class TestCrossFilePlatform extends CrossFilePlatform {
  @override
  PlatformXFile createPlatformXFile(PlatformXFileCreationParams params) {
    return TestXFile(params);
  }
}

final class TestXFile extends PlatformXFile {
  TestXFile(super.params) : super.implementation();

  @override
  Future<bool> canRead() {
    throw UnimplementedError();
  }

  @override
  Future<bool> exists() {
    throw UnimplementedError();
  }

  @override
  Future<DateTime> lastModified() {
    throw UnimplementedError();
  }

  @override
  Future<int> length() {
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
  Future<String?> name() {
    throw UnimplementedError();
  }
}
