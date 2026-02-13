// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_darwin/src/cross_file_darwin_apis.g.dart';
import 'package:cross_file_darwin/src/darwin_scoped_storage_cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'darwin_scoped_storage_cross_file_test.mocks.dart';

@GenerateMocks(<Type>[CrossFileDarwinApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('startAccessingSecurityScopedResource', () async {
    final mockApi = MockCrossFileDarwinApi();
    const uri = 'uri';
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
    const uri = 'uri';

    final file = DarwinScopedStorageXFile(
      DarwinScopedStorageXFileCreationParams(uri: uri, api: mockApi),
    );

    await file.stopAccessingSecurityScopedResource();
    verify(mockApi.stopAccessingSecurityScopedResource(uri));
  });

  test('tryCreateBookmarkedUrl', () async {
    final mockApi = MockCrossFileDarwinApi();
    const uri = 'uri';
    const bookmarkedUri = 'newUri';
    when(
      mockApi.tryCreateBookmarkedUrl(uri),
    ).thenAnswer((_) async => bookmarkedUri);

    final file = DarwinScopedStorageXFile(
      DarwinScopedStorageXFileCreationParams(uri: uri, api: mockApi),
    );

    expect(await file.toBookmarkedUri(), bookmarkedUri);
  });
}
