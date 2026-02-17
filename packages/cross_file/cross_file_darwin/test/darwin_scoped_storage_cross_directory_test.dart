// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:cross_file_darwin/cross_file_darwin.dart';
import 'package:cross_file_darwin/src/cross_file_darwin_apis.g.dart';
import 'package:cross_file_darwin/src/darwin_scoped_storage_cross_directory.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as path;

import 'darwin_scoped_storage_cross_directory_test.mocks.dart';

final Directory testDirectory = Directory(
  path.join(Directory.current.path, 'test'),
);

@GenerateMocks(<Type>[CrossFileDarwinApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    CrossFilePlatform.instance = CrossFileDarwin();
  });

  test('exists', () async {
    final directory = PlatformXDirectory(
      PlatformXDirectoryCreationParams(uri: testDirectory.path),
    );

    expect(await directory.exists(), testDirectory.existsSync());
  });

  test('list', () async {
    final directory = PlatformScopedStorageXDirectory(
      PlatformScopedStorageXDirectoryCreationParams(uri: testDirectory.path),
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

  test('startAccessingSecurityScopedResource', () async {
    final mockApi = MockCrossFileDarwinApi();
    const uri = 'uri/';
    const result = true;
    when(
      mockApi.startAccessingSecurityScopedResource(uri),
    ).thenAnswer((_) async => result);

    final file = DarwinScopedStorageXDirectory(
      DarwinScopedStorageXDirectoryCreationParams(uri: uri, api: mockApi),
    );

    expect(await file.startAccessingSecurityScopedResource(), result);
  });

  test('stopAccessingSecurityScopedResource', () async {
    final mockApi = MockCrossFileDarwinApi();
    const uri = 'uri/';

    final file = DarwinScopedStorageXDirectory(
      DarwinScopedStorageXDirectoryCreationParams(uri: uri, api: mockApi),
    );

    await file.stopAccessingSecurityScopedResource();
    verify(mockApi.stopAccessingSecurityScopedResource(uri));
  });

  test('tryCreateBookmarkedUrl', () async {
    final mockApi = MockCrossFileDarwinApi();
    const uri = 'uri/';
    const bookmarkedUri = 'newUri/';
    when(
      mockApi.tryCreateBookmarkedUrl(uri),
    ).thenAnswer((_) async => bookmarkedUri);

    final file = DarwinScopedStorageXDirectory(
      DarwinScopedStorageXDirectoryCreationParams(uri: uri, api: mockApi),
    );

    expect(await file.toBookmarkedUri(), bookmarkedUri);
  });
}
