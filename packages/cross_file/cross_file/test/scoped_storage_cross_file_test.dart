// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_stubs.dart';

void main() {
  group('XFile', () {
    test('lastModified', () async {
      final lastModified = DateTime.now();
      CrossFilePlatform.instance = TestCrossFilePlatform(
        onCreatePlatformScopedStorageXFile:
            (PlatformScopedStorageXFileCreationParams params) =>
                TestScopedStorageXFile(
                  params,
                  onLastModified: () async => lastModified,
                ),
      );

      final file = ScopedStorageXFile('uri');

      expect(await file.lastModified(), lastModified);
    });

    test('length', () async {
      const length = 42;
      CrossFilePlatform.instance = TestCrossFilePlatform(
        onCreatePlatformScopedStorageXFile:
            (PlatformScopedStorageXFileCreationParams params) =>
                TestScopedStorageXFile(params, onLength: () async => length),
      );

      final file = ScopedStorageXFile('uri');

      expect(await file.length(), length);
    });

    test('openRead', () async {
      final data = <Uint8List>[
        Uint8List.fromList(<int>[5, 6]),
      ];
      CrossFilePlatform.instance = TestCrossFilePlatform(
        onCreatePlatformScopedStorageXFile:
            (PlatformScopedStorageXFileCreationParams params) =>
                TestScopedStorageXFile(
                  params,
                  onOpenRead: () => Stream.fromIterable(data),
                ),
      );

      final file = ScopedStorageXFile('uri');

      expect(await file.openRead().toList(), data);
    });

    test('readAsBytes', () async {
      final bytes = Uint8List.fromList(<int>[1, 2, 3]);
      CrossFilePlatform.instance = TestCrossFilePlatform(
        onCreatePlatformScopedStorageXFile:
            (PlatformScopedStorageXFileCreationParams params) =>
                TestScopedStorageXFile(
                  params,
                  onReadAsBytes: () async => bytes,
                ),
      );

      final file = ScopedStorageXFile('uri');

      expect(await file.readAsBytes(), bytes);
    });

    test('readAsString', () async {
      const message = 'Hello, World!';
      CrossFilePlatform.instance = TestCrossFilePlatform(
        onCreatePlatformScopedStorageXFile:
            (PlatformScopedStorageXFileCreationParams params) =>
                TestScopedStorageXFile(
                  params,
                  onReadAsString: ({required Encoding encoding}) async =>
                      message,
                ),
      );

      final file = ScopedStorageXFile('uri');

      expect(await file.readAsString(), message);
    });

    test('canRead', () async {
      const canRead = false;
      CrossFilePlatform.instance = TestCrossFilePlatform(
        onCreatePlatformScopedStorageXFile:
            (PlatformScopedStorageXFileCreationParams params) =>
                TestScopedStorageXFile(params, onCanRead: () async => canRead),
      );

      final file = ScopedStorageXFile('uri');

      expect(await file.canRead(), canRead);
    });

    test('exists', () async {
      const exists = true;
      CrossFilePlatform.instance = TestCrossFilePlatform(
        onCreatePlatformScopedStorageXFile:
            (PlatformScopedStorageXFileCreationParams params) =>
                TestScopedStorageXFile(params, onExists: () async => exists),
      );

      final file = ScopedStorageXFile('uri');

      expect(await file.exists(), exists);
    });

    test('name', () async {
      const name = 'name';
      CrossFilePlatform.instance = TestCrossFilePlatform(
        onCreatePlatformScopedStorageXFile:
            (PlatformScopedStorageXFileCreationParams params) =>
                TestScopedStorageXFile(params, onName: () async => name),
      );

      final file = ScopedStorageXFile('uri');

      expect(await file.name(), name);
    });
  });
}
