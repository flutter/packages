// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:cross_file_darwin/cross_file_darwin.dart';
import 'package:cross_file_darwin/src/cross_file_darwin_apis.g.dart';
import 'package:cross_file_darwin/src/darwin_scoped_storage_cross_file.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as path;

import 'darwin_scoped_storage_cross_file_test.mocks.dart';

final File testFile = File(
  path.join(Directory.current.path, 'test', 'test_file.txt'),
);

@GenerateMocks(<Type>[CrossFileDarwinApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  test('canRead', () async {
    final mockApi = MockCrossFileDarwinApi();
    const uri = 'uri';
    const result = true;
    when(mockApi.isReadableFile(uri)).thenAnswer((_) async => result);

    final file = DarwinScopedStorageXFile(
      DarwinScopedStorageXFileCreationParams(uri: uri, api: mockApi),
    );

    expect(await file.canRead(), result);
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

  test('startAccessingSecurityScopedResource', () async {
    final mockApi = MockCrossFileDarwinApi();
    final uri = testFile.uri.toString();
    const result = true;
    when(
      mockApi.startAccessingSecurityScopedResource(uri),
    ).thenAnswer((_) async => result);

    final file = DarwinScopedStorageXFile(
      DarwinScopedStorageXFileCreationParams(uri: uri, api: mockApi),
    );

    expect(await file.startAccessingSecurityScopedResource(), result);
  });

  test('stopAccessingSecurityScopedResource', () async {
    final mockApi = MockCrossFileDarwinApi();
    final uri = testFile.uri.toString();

    final file = DarwinScopedStorageXFile(
      DarwinScopedStorageXFileCreationParams(uri: uri, api: mockApi),
    );

    await file.stopAccessingSecurityScopedResource();
    verify(mockApi.stopAccessingSecurityScopedResource(uri));
  });
}
