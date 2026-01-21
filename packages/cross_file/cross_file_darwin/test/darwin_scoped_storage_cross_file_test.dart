// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file_darwin/src/cross_file_darwin_apis.g.dart';
import 'package:cross_file_darwin/src/darwin_scoped_storage_cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'darwin_scoped_storage_cross_file_test.mocks.dart';

@GenerateMocks(<Type>[FileHandle, CrossFileDarwinApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PigeonOverrides.pigeon_reset();
  });

  test('lastModified', () async {
    final mockApi = MockCrossFileDarwinApi();
    const uri = 'uri';
    const modificationDate = 123;
    when(
      mockApi.fileModificationDate(uri),
    ).thenAnswer((_) async => modificationDate);

    final file = DarwinScopedStorageXFile(
      DarwinScopedStorageXFileCreationParams(uri: uri, api: mockApi),
    );

    expect(
      await file.lastModified(),
      DateTime.fromMillisecondsSinceEpoch(modificationDate),
    );
  });

  test('length', () async {
    final mockApi = MockCrossFileDarwinApi();
    const uri = 'uri';
    const size = 123;
    when(mockApi.fileSize(uri)).thenAnswer((_) async => size);

    final file = DarwinScopedStorageXFile(
      DarwinScopedStorageXFileCreationParams(uri: uri, api: mockApi),
    );

    expect(await file.length(), size);
  });

  group('openRead', () {
    test('openRead finishes successfully', () async {
      final testBytes = Uint8List.fromList([0, 1, 2]);

      final mockApi = MockCrossFileDarwinApi();
      const uri = 'uri';
      when(mockApi.fileSize(uri)).thenAnswer((_) async => testBytes.length);

      final mockFileHandle = MockFileHandle();
      setUpFileHandleWithBytes(mockFileHandle, testBytes);
      PigeonOverrides.fileHandle_forReadingAtPath = (String path) async {
        expect(path, uri);
        return mockFileHandle;
      };

      final file = DarwinScopedStorageXFile(
        DarwinScopedStorageXFileCreationParams(uri: uri, api: mockApi),
      );

      expect(combineLists(await file.openRead().toList()), testBytes);
    });

    test(
      'openRead finishes successfully with file larger than max array len',
      () async {
        final testBytes = Uint8List.fromList(
          List.filled(DarwinScopedStorageXFile.maxByteArrayLen + 1, 0),
        );

        final mockApi = MockCrossFileDarwinApi();
        const uri = 'uri';
        when(mockApi.fileSize(uri)).thenAnswer((_) async => testBytes.length);

        final mockFileHandle = MockFileHandle();
        setUpFileHandleWithBytes(mockFileHandle, testBytes);
        PigeonOverrides.fileHandle_forReadingAtPath = (String path) async {
          expect(path, uri);
          return mockFileHandle;
        };

        final file = DarwinScopedStorageXFile(
          DarwinScopedStorageXFileCreationParams(uri: uri, api: mockApi),
        );

        expect(combineLists(await file.openRead().toList()), testBytes);
      },
    );

    test('openRead finishes successfully with subset of array', () async {
      final testBytes = Uint8List.fromList(<int>[0, 0, 0, 1, 1, 1, 0, 0, 0]);

      final mockApi = MockCrossFileDarwinApi();
      const uri = 'uri';
      when(mockApi.fileSize(uri)).thenAnswer((_) async => testBytes.length);

      final mockFileHandle = MockFileHandle();
      setUpFileHandleWithBytes(mockFileHandle, testBytes);
      PigeonOverrides.fileHandle_forReadingAtPath = (String path) async {
        expect(path, uri);
        return mockFileHandle;
      };

      final file = DarwinScopedStorageXFile(
        DarwinScopedStorageXFileCreationParams(uri: uri, api: mockApi),
      );

      expect(combineLists(await file.openRead(3, 6).toList()), <int>[1, 1, 1]);
    });
  });

  test('readAsBytes', () async {
    final testBytes = Uint8List.fromList([0, 1, 2]);

    final mockApi = MockCrossFileDarwinApi();
    const uri = 'uri';
    when(mockApi.fileSize(uri)).thenAnswer((_) async => testBytes.length);

    final mockFileHandle = MockFileHandle();
    when(mockFileHandle.readToEnd()).thenAnswer((_) async => testBytes);
    PigeonOverrides.fileHandle_forReadingAtPath = (String path) async {
      expect(path, uri);
      return mockFileHandle;
    };

    final file = DarwinScopedStorageXFile(
      DarwinScopedStorageXFileCreationParams(uri: uri, api: mockApi),
    );

    expect(await file.readAsBytes(), testBytes);
  });

  test('readAsString', () async {
    const testString = 'Hello, World!';
    final Uint8List testBytes = utf8.encode(testString);

    final mockApi = MockCrossFileDarwinApi();
    const uri = 'uri';
    when(mockApi.fileSize(uri)).thenAnswer((_) async => testBytes.length);

    final mockFileHandle = MockFileHandle();
    setUpFileHandleWithBytes(mockFileHandle, testBytes);
    PigeonOverrides.fileHandle_forReadingAtPath = (String path) async {
      expect(path, uri);
      return mockFileHandle;
    };

    final file = DarwinScopedStorageXFile(
      DarwinScopedStorageXFileCreationParams(uri: uri, api: mockApi),
    );

    expect(await file.readAsString(), testString);
  });

  test('canRead', () async {
    final mockApi = MockCrossFileDarwinApi();
    const uri = 'uri';
    const canRead = false;
    when(mockApi.isReadableFile(uri)).thenAnswer((_) async => canRead);

    final file = DarwinScopedStorageXFile(
      DarwinScopedStorageXFileCreationParams(uri: uri, api: mockApi),
    );

    expect(await file.canRead(), canRead);
  });

  test('exists', () async {
    final mockApi = MockCrossFileDarwinApi();
    const uri = 'uri';
    when(mockApi.fileExists(uri)).thenAnswer(
      (_) async => FileExistsResult(exists: true, isDirectory: false),
    );

    final file = DarwinScopedStorageXFile(
      DarwinScopedStorageXFileCreationParams(uri: uri, api: mockApi),
    );

    expect(await file.exists(), true);
  });

  test('name', () async {
    final mockApi = MockCrossFileDarwinApi();
    const name = 'myfile.txt';
    const uri = 'hello/$name';

    final file = DarwinScopedStorageXFile(
      DarwinScopedStorageXFileCreationParams(uri: uri, api: mockApi),
    );

    expect(await file.name(), name);
  });
}

void setUpFileHandleWithBytes(MockFileHandle mockFileHandle, Uint8List bytes) {
  int offset = 0;

  when(mockFileHandle.seek(any)).thenAnswer((Invocation invocation) async {
    offset = invocation.positionalArguments[0] as int;
  });

  when(mockFileHandle.readUpToCount(any)).thenAnswer((
    Invocation invocation,
  ) async {
    final count = invocation.positionalArguments[0] as int;
    final Uint8List nextBytes = bytes.sublist(offset, offset + count);
    offset += count;
    return nextBytes;
  });
}

Uint8List combineLists(List<Uint8List> lists) {
  return Uint8List.fromList(
    lists.expand((Uint8List element) => element).toList(),
  );
}
