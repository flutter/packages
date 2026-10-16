// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
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
      addTearDown(() => tempFile.deleteSync());

      final bytes = Uint8List.fromList([0, 1, 2, 3]);
      final file = PlatformFileSystemXFile(PlatformFileSystemXFileCreationParams(tempFile.path));
      await file.writeAsBytes(PlatformWriteAsBytesParams(bytes));

      expect(await file.readAsBytes(), bytes);
    });

    test('writeAsString', () async {
      final Directory tempDir = Directory.systemTemp;
      final tempFile = File(path.join(tempDir.path, 'test_write_as_string.txt'));
      addTearDown(() => tempFile.deleteSync());

      final file = PlatformFileSystemXFile(PlatformFileSystemXFileCreationParams(tempFile.path));
      await file.writeAsString(const PlatformWriteAsStringParams('Hello, world!'));

      expect(await file.readAsString(), 'Hello, world!');
    });

    test('openWrite', () async {
      final Directory tempDir = Directory.systemTemp;
      final tempFile = File(path.join(tempDir.path, 'test_open_write.txt'));
      addTearDown(() => tempFile.deleteSync());

      final file = PlatformFileSystemXFile(PlatformFileSystemXFileCreationParams(tempFile.path));
      final StreamSink<Uint8List> sink = file.openWrite(const PlatformOpenWriteParams());

      final bytes = Uint8List.fromList([10, 20, 30]);
      sink.add(bytes);
      await sink.close();

      expect(await file.readAsBytes(), bytes);
    });

    test('delete', () async {
      final Directory tempDir = Directory.systemTemp;
      final tempFile = File(path.join(tempDir.path, 'test_delete.txt'));
      tempFile.writeAsStringSync('delete me');

      final file = PlatformFileSystemXFile(PlatformFileSystemXFileCreationParams(tempFile.path));
      expect(await file.exists(), true);

      final bool result = await file.delete(const PlatformFileDeleteParams());
      expect(result, true);
      expect(await file.exists(), false);
    });

    test('delete non-existent file returns false', () async {
      final Directory tempDir = Directory.systemTemp;
      final tempFile = File(path.join(tempDir.path, 'non_existent.txt'));

      final file = PlatformFileSystemXFile(PlatformFileSystemXFileCreationParams(tempFile.path));
      expect(await file.exists(), false);

      final bool result = await file.delete(const PlatformFileDeleteParams());
      expect(result, false);
    });
  });
}
