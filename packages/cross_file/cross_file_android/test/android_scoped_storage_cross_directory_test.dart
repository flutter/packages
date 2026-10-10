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
    android.PigeonOverrides.documentFile_fromTreeUri = ({required String treeUri}) {
      expect(treeUri, uri);
      return mockDocumentFile;
    };

    final directory = AndroidScopedStorageXDirectory(
      const PlatformScopedStorageXDirectoryCreationParams(uri: uri),
    );

    expect(await directory.exists(), true);
  });

  test('canRead', () async {
    final mockDocumentFile = MockDocumentFile();
    const canRead = false;
    when(mockDocumentFile.canRead()).thenAnswer((_) async => canRead);

    const uri = 'uri';
    android.PigeonOverrides.documentFile_fromTreeUri = ({required String treeUri}) {
      expect(treeUri, uri);
      return mockDocumentFile;
    };

    final directory = AndroidScopedStorageXDirectory(
      const PlatformScopedStorageXDirectoryCreationParams(uri: uri),
    );

    expect(await directory.canRead(), canRead);
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
    android.PigeonOverrides.documentFile_fromTreeUri = ({required String treeUri}) {
      expect(treeUri, uri);
      return mockDirectory;
    };

    android.PigeonOverrides.documentFile_fromSingleUri = ({required String singleUri}) {
      expect(singleUri, fileUri);
      return mockFile;
    };

    final dir = AndroidScopedStorageXDirectory(
      const PlatformScopedStorageXDirectoryCreationParams(uri: uri),
    );

    final List<String> entityUris = await dir
        .list(const PlatformListParams())
        .map((PlatformXEntity entity) => entity.params.uri)
        .toList();

    expect(entityUris, <String>[fileUri]);
  });

  test('canWrite', () async {
    final mockDocumentFile = MockDocumentFile();
    const canWrite = true;
    when(mockDocumentFile.canWrite()).thenAnswer((_) async => canWrite);

    const uri = 'uri';
    android.PigeonOverrides.documentFile_fromTreeUri = ({required String treeUri}) {
      expect(treeUri, uri);
      return mockDocumentFile;
    };

    final directory = AndroidScopedStorageXDirectory(
      const PlatformScopedStorageXDirectoryCreationParams(uri: uri),
    );

    expect(await directory.canWrite(), canWrite);
  });

  test('createFile', () async {
    const fileName = 'test.txt';
    const fileUri = 'fileUri';
    final mockFile = MockDocumentFile();
    when(mockFile.getUri()).thenAnswer((_) async => fileUri);

    final mockDirectory = MockDocumentFile();
    when(mockDirectory.createFile(fileName)).thenAnswer((_) async => mockFile);

    const uri = 'uri';
    android.PigeonOverrides.documentFile_fromTreeUri = ({required String treeUri}) {
      expect(treeUri, uri);
      return mockDirectory;
    };

    android.PigeonOverrides.documentFile_fromSingleUri = ({required String singleUri}) {
      expect(singleUri, fileUri);
      return mockFile;
    };

    final directory = AndroidScopedStorageXDirectory(
      const PlatformScopedStorageXDirectoryCreationParams(uri: uri),
    );

    final PlatformXFile file = await directory.createFile(const PlatformCreateParams(fileName));

    expect(file.params.uri, fileUri);
    verify(mockDirectory.createFile(fileName)).called(1);
  });

  test('createDirectory', () async {
    const dirName = 'subDir';
    const subDirUri = 'subDirUri';
    final mockSubDir = MockDocumentFile();
    when(mockSubDir.getUri()).thenAnswer((_) async => subDirUri);

    final mockDirectory = MockDocumentFile();
    when(mockDirectory.createDirectory(dirName)).thenAnswer((_) async => mockSubDir);

    const uri = 'uri';
    android.PigeonOverrides.documentFile_fromTreeUri = ({required String treeUri}) {
      if (treeUri == uri) {
        return mockDirectory;
      } else if (treeUri == subDirUri) {
        return mockSubDir;
      }
      throw UnsupportedError('Unexpected treeUri: $treeUri');
    };

    final directory = AndroidScopedStorageXDirectory(
      const PlatformScopedStorageXDirectoryCreationParams(uri: uri),
    );

    final PlatformXDirectory subDir = await directory.createDirectory(
      const PlatformCreateParams(dirName),
    );

    expect(subDir.params.uri, subDirUri);
    verify(mockDirectory.createDirectory(dirName)).called(1);
  });
}
