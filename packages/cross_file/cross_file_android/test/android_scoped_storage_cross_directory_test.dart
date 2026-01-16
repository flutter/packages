// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_android/src/android_library.g.dart' as android;
import 'package:cross_file_android/src/android_scoped_storage_cross_directory.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'android_scoped_storage_cross_directory_test.mocks.dart';

@GenerateMocks(<Type>[android.DocumentFile])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    android.PigeonOverrides.pigeon_reset();
  });

  test('exists', () async {
    final mockDocumentFile = MockDocumentFile();
    when(mockDocumentFile.exists()).thenAnswer((_) async => true);
    when(mockDocumentFile.isDirectory()).thenAnswer((_) async => true);

    const uri = 'uri';
    android.PigeonOverrides.documentFile_fromTreeUri =
        ({required String treeUri}) {
          expect(treeUri, uri);
          return mockDocumentFile;
        };

    final file = AndroidScopedStorageXDirectory(
      const PlatformScopedStorageXDirectoryCreationParams(uri: uri),
    );

    expect(await file.exists(), true);
  });

  test('list', () async {
    final mockFile = MockDocumentFile();
    const fileUri = 'fileUri';
    when(mockFile.getUri()).thenAnswer((_) async => fileUri);
    when(mockFile.isFile()).thenAnswer((_) async => true);
    final files = <android.DocumentFile>[mockFile];

    final mockDirectory = MockDocumentFile();
    when(mockDirectory.listFiles()).thenAnswer((_) async => files);

    const uri = 'uri';
    android.PigeonOverrides.documentFile_fromTreeUri =
        ({required String treeUri}) {
          expect(treeUri, uri);
          return mockDirectory;
        };

    android.PigeonOverrides.documentFile_fromSingleUri =
        ({required String singleUri}) {
          expect(singleUri, fileUri);
          return mockFile;
        };

    final dir = AndroidScopedStorageXDirectory(
      const PlatformScopedStorageXDirectoryCreationParams(uri: uri),
    );

    final List<String> entityUris = await dir
        .list(ListParams())
        .map((PlatformXFileEntity entity) => entity.params.uri)
        .toList();

    expect(entityUris, <String>['fileUri']);
  });
}
