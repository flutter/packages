// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file_io/cross_file_io.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

final File testFile = File(path.join(Directory.current.path, 'test', 'test_file.txt'));

void main() {
  group('IOXFile', () {
    setUp(() {
      CrossFilePlatform.instance = CrossFileIO();
    });

    test('lastModified', () async {
      final file = PlatformFileSystemXFile(PlatformFileSystemXFileCreationParams(testFile.path));

      expect(await file.lastModified(), testFile.lastModifiedSync());
    });

    test('length', () async {
      final file = PlatformFileSystemXFile(PlatformFileSystemXFileCreationParams(testFile.path));

      expect(await file.length(), await testFile.length());
    });

    test('openRead', () async {
      final file = PlatformFileSystemXFile(PlatformFileSystemXFileCreationParams(testFile.path));

      expect(await file.openRead().toList(), await testFile.openRead().toList());
    });

    test('readAsBytes', () async {
      final file = PlatformFileSystemXFile(PlatformFileSystemXFileCreationParams(testFile.path));

      expect(await file.readAsBytes(), await testFile.readAsBytes());
    });

    test('readAsString', () async {
      final file = PlatformFileSystemXFile(PlatformFileSystemXFileCreationParams(testFile.path));

      expect(await file.readAsString(), await testFile.readAsString());
    });

    test('exists', () async {
      final file = PlatformFileSystemXFile(PlatformFileSystemXFileCreationParams(testFile.path));

      expect(await file.exists(), testFile.existsSync());
    });

    test('name', () async {
      final file = PlatformFileSystemXFile(PlatformFileSystemXFileCreationParams(testFile.path));

      expect(await file.name(), 'test_file.txt');
    });

    test('writeAsBytes', () async {
      final Directory tempDir = Directory.systemTemp;
      final tempFile = File(path.join(tempDir.path, 'test_file.txt'));

      final bytes = Uint8List.fromList([0, 1, 2, 3]);
      final file = PlatformFileSystemXFile(PlatformFileSystemXFileCreationParams(tempFile.path));
      await file.writeAsBytes(PlatformWriteAsBytesParams(bytes));

      expect(await file.readAsBytes(), bytes);
    });
  });
}
