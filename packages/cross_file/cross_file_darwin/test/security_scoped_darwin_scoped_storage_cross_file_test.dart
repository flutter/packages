// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:cross_file_darwin/cross_file_darwin.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

final File testFile = File(path.join(Directory.current.path, 'test', 'test_file.txt'));

void main() {
  setUp(() {
    CrossFilePlatform.instance = CrossFileDarwin();
  });

  test('lastModified', () async {
    final file = PlatformScopedStorageXFile(
      PlatformScopedStorageXFileCreationParams(uri: testFile.uri.toString()),
    );

    expect(await file.lastModified(), testFile.lastModifiedSync());
  });

  test('length', () async {
    final file = PlatformScopedStorageXFile(
      PlatformScopedStorageXFileCreationParams(uri: testFile.uri.toString()),
    );

    expect(await file.length(), await testFile.length());
  });

  test('openRead', () async {
    final file = PlatformScopedStorageXFile(
      PlatformScopedStorageXFileCreationParams(uri: testFile.uri.toString()),
    );

    expect(await file.openRead().toList(), await testFile.openRead().toList());
  });

  test('readAsBytes', () async {
    final file = PlatformScopedStorageXFile(
      PlatformScopedStorageXFileCreationParams(uri: testFile.uri.toString()),
    );

    expect(await file.readAsBytes(), await testFile.readAsBytes());
  });

  test('readAsString', () async {
    final file = PlatformScopedStorageXFile(
      PlatformScopedStorageXFileCreationParams(uri: testFile.uri.toString()),
    );

    expect(await file.readAsString(), await testFile.readAsString());
  });

  test('exists', () async {
    final file = PlatformScopedStorageXFile(
      PlatformScopedStorageXFileCreationParams(uri: testFile.uri.toString()),
    );

    expect(await file.exists(), testFile.existsSync());
  });

  test('name', () async {
    final file = PlatformScopedStorageXFile(
      PlatformScopedStorageXFileCreationParams(uri: testFile.uri.toString()),
    );

    expect(await file.name(), 'test_file.txt');
  });

  test('canWrite', () async {
    final Directory tempDir = Directory.systemTemp.createTempSync();
    final tempFile = File(path.join(tempDir.path, 'temp_file.txt'))..writeAsStringSync('test');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final file = PlatformScopedStorageXFile(
      PlatformScopedStorageXFileCreationParams(uri: tempFile.uri.toString()),
    );

    expect(await file.canWrite(), isTrue);
  });

  test('openWrite', () async {
    final tempDir = Directory.systemTemp.createTempSync();
    final tempFile = File(path.join(tempDir.path, 'temp_file.txt'));
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final file = PlatformScopedStorageXFile(
      PlatformScopedStorageXFileCreationParams(uri: tempFile.uri.toString()),
    );

    final sink = file.openWrite(const PlatformOpenWriteParams());
    sink.add(utf8.encode('hello openWrite'));
    await sink.close();

    expect(await tempFile.readAsString(), 'hello openWrite');
  });

  test('writeAsString', () async {
    final tempDir = Directory.systemTemp.createTempSync();
    final tempFile = File(path.join(tempDir.path, 'temp_file.txt'));
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final file = PlatformScopedStorageXFile(
      PlatformScopedStorageXFileCreationParams(uri: tempFile.uri.toString()),
    );

    final PlatformXFile writtenFile = await file.writeAsString(
      PlatformWriteAsStringParams('hello writeAsString', encoding: utf8),
    );

    expect(writtenFile.params.uri, tempFile.uri.toString());
    expect(await tempFile.readAsString(), 'hello writeAsString');
  });

  test('delete', () async {
    final tempDir = Directory.systemTemp.createTempSync();
    final tempFile = File(path.join(tempDir.path, 'temp_file.txt'))
      ..writeAsStringSync('to be deleted');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final file = PlatformScopedStorageXFile(
      PlatformScopedStorageXFileCreationParams(uri: tempFile.uri.toString()),
    );

    expect(await tempFile.existsSync(), isTrue);
    final bool success = await file.delete(const PlatformFileDeleteParams());
    expect(success, isTrue);
    expect(await tempFile.existsSync(), isFalse);
  });
}
