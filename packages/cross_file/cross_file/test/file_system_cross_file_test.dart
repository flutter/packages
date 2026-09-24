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
        onCreatePlatformFileSystemXFile: (PlatformFileSystemXFileCreationParams params) =>
            TestFileSystemXFile(params, onLastModified: () async => lastModified),
      );

      final file = XFile.fileSystem(path: 'to/myFile.txt');

      expect(await file.lastModified(), lastModified);
    });

    test('length', () async {
      const length = 42;
      CrossFilePlatform.instance = TestCrossFilePlatform(
        onCreatePlatformFileSystemXFile: (PlatformFileSystemXFileCreationParams params) =>
            TestFileSystemXFile(params, onLength: () async => length),
      );

      final file = XFile.fileSystem(path: 'to/myFile.txt');

      expect(await file.length(), length);
    });

    test('openRead', () async {
      final data = <Uint8List>[
        Uint8List.fromList(<int>[5, 6]),
      ];
      CrossFilePlatform.instance = TestCrossFilePlatform(
        onCreatePlatformFileSystemXFile: (PlatformFileSystemXFileCreationParams params) =>
            TestFileSystemXFile(params, onOpenRead: () => Stream.fromIterable(data)),
      );

      final file = XFile.fileSystem(path: 'to/myFile.txt');

      expect(await file.openRead().toList(), data);
    });

    test('readAsBytes', () async {
      final bytes = Uint8List.fromList(<int>[1, 2, 3]);
      CrossFilePlatform.instance = TestCrossFilePlatform(
        onCreatePlatformFileSystemXFile: (PlatformFileSystemXFileCreationParams params) =>
            TestFileSystemXFile(params, onReadAsBytes: () async => bytes),
      );

      final file = XFile.fileSystem(path: 'to/myFile.txt');

      expect(await file.readAsBytes(), bytes);
    });

    test('readAsString', () async {
      const message = 'Hello, World!';
      CrossFilePlatform.instance = TestCrossFilePlatform(
        onCreatePlatformFileSystemXFile: (PlatformFileSystemXFileCreationParams params) =>
            TestFileSystemXFile(
              params,
              onReadAsString: ({required Encoding encoding}) async => message,
            ),
      );

      final file = XFile.fileSystem(path: 'to/myFile.txt');

      expect(await file.readAsString(), message);
    });

    test('exists', () async {
      const exists = true;
      CrossFilePlatform.instance = TestCrossFilePlatform(
        onCreatePlatformFileSystemXFile: (PlatformFileSystemXFileCreationParams params) =>
            TestFileSystemXFile(params, onExists: () async => exists),
      );

      final file = XFile.fileSystem(path: 'to/myFile.txt');

      expect(await file.exists(), exists);
    });

    test('name', () async {
      const name = 'name';
      CrossFilePlatform.instance = TestCrossFilePlatform(
        onCreatePlatformFileSystemXFile: (PlatformFileSystemXFileCreationParams params) =>
            TestFileSystemXFile(params, onName: () async => name),
      );

      final file = XFile.fileSystem(path: 'to/myFile.txt');

      expect(await file.name(), name);
    });

    test('name', () async {
      const name = 'name';
      CrossFilePlatform.instance = TestCrossFilePlatform(
        onCreatePlatformFileSystemXFile: (PlatformFileSystemXFileCreationParams params) =>
            TestFileSystemXFile(params, onName: () async => name),
      );

      final file = XFile.fileSystem(path: 'to/myFile.txt');

      expect(await file.name(), name);
    });

    test('writeAsBytes', () async {
      final testBytes = Uint8List.fromList(<int>[0, 1, 2, 3]);
      CrossFilePlatform.instance = TestCrossFilePlatform(
        onCreatePlatformFileSystemXFile: (PlatformFileSystemXFileCreationParams params) =>
            TestFileSystemXFile(
              params,
              onWriteAsBytes: expectAsync1((Uint8List bytes) async {
                expect(bytes, testBytes);
                return TestFileSystemXFile(params);
              }),
            ),
      );

      final file = FileSystemXFile('to/myFile.txt');

      await file.writeAsBytes(testBytes);
    });
  });
}
