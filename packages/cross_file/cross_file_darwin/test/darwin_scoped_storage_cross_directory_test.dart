// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_darwin/src/cross_file_darwin_apis.g.dart';
import 'package:cross_file_darwin/src/darwin_scoped_storage_cross_directory.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'darwin_scoped_storage_cross_directory_test.mocks.dart';

@GenerateMocks(<Type>[CrossFileDarwinApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PigeonOverrides.pigeon_reset();
  });

  test('exists', () async {
    final mockApi = MockCrossFileDarwinApi();
    const uri = 'uri';
    when(mockApi.fileExists(uri)).thenAnswer(
      (_) async => FileExistsResult(exists: true, isDirectory: true),
    );

    final file = DarwinScopedStorageXDirectory(
      DarwinScopedStorageXDirectoryCreationParams(uri: uri, api: mockApi),
    );

    expect(await file.exists(), true);
  });

  test('list', () async {
    final mockApi = MockCrossFileDarwinApi();
    const uri = 'uri';
    const fileUri = 'fileUri';
    when(mockApi.list(any)).thenAnswer((_) async => <String>[fileUri]);
    when(mockApi.fileExists(fileUri)).thenAnswer(
      (_) async => FileExistsResult(exists: true, isDirectory: false),
    );

    final dir = DarwinScopedStorageXDirectory(
      DarwinScopedStorageXDirectoryCreationParams(uri: uri, api: mockApi),
    );

    final List<String> entityUris = await dir
        .list(ListParams())
        .map((PlatformXFileEntity entity) => entity.params.uri)
        .toList();

    expect(entityUris, <String>[fileUri]);
  });
}
