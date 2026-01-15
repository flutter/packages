// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file_android/src/android_library.g.dart' as android;
import 'package:cross_file_android/src/android_scoped_storage_cross_file.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'android_shared_storage_cross_file_test.mocks.dart';

@GenerateMocks(<Type>[
  android.ContentResolver,
  android.DocumentFile,
  android.InputStream,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    android.PigeonOverrides.pigeon_reset();
  });

  test('lastModified', () async {
    final mockDocumentFile = MockDocumentFile();
    const lastModified = 123;
    when(mockDocumentFile.lastModified()).thenAnswer((_) async => lastModified);

    const uri = 'uri';
    android.PigeonOverrides.documentFile_fromSingleUri =
        ({required String singleUri}) {
          expect(singleUri, uri);
          return mockDocumentFile;
        };

    final file = AndroidScopedStorageXFile(
      const PlatformScopedStorageXFileCreationParams(uri: uri),
    );

    expect(
      await file.lastModified(),
      DateTime.fromMillisecondsSinceEpoch(lastModified),
    );
  });

  test('length', () async {
    final mockDocumentFile = MockDocumentFile();
    const length = 123;
    when(mockDocumentFile.length()).thenAnswer((_) async => length);

    const uri = 'uri';
    android.PigeonOverrides.documentFile_fromSingleUri =
        ({required String singleUri}) {
          expect(singleUri, uri);
          return mockDocumentFile;
        };

    final file = AndroidScopedStorageXFile(
      const PlatformScopedStorageXFileCreationParams(uri: uri),
    );

    expect(await file.length(), length);
  });

  group('openRead', () {
    void setUpInputStreamWithBytes(
      MockInputStream mockInputStream,
      Uint8List bytes,
    ) {
      Iterable<int> remainingBytes = bytes.toList();

      when(mockInputStream.skip(any)).thenAnswer((Invocation invocation) async {
        final amount = invocation.positionalArguments[0] as int;
        if (amount < 0) {
          return 0;
        }

        final Iterable<int> newRemainingBytes = remainingBytes.skip(amount);

        final int diff = remainingBytes.length - newRemainingBytes.length;
        remainingBytes = newRemainingBytes;
        return diff;
      });

      when(mockInputStream.readBytes(any)).thenAnswer((
        Invocation invocation,
      ) async {
        final len = invocation.positionalArguments[0] as int;

        final List<int> bytesRead = remainingBytes.take(len).toList();
        remainingBytes = remainingBytes.skip(len);

        return android.InputStreamReadBytesResponse.pigeon_detached(
          returnValue: remainingBytes.isEmpty ? -1 : bytesRead.length,
          bytes: Uint8List.fromList(bytesRead),
        );
      });
    }

    Uint8List combineLists(List<Uint8List> lists) {
      return Uint8List.fromList(
        lists.expand((Uint8List element) => element).toList(),
      );
    }

    test('openRead finishes successfully', () async {
      final testBytes = Uint8List.fromList([0, 1, 2]);

      final mockDocumentFile = MockDocumentFile();
      when(mockDocumentFile.length()).thenAnswer((_) async => testBytes.length);

      const uri = 'uri';
      android.PigeonOverrides.documentFile_fromSingleUri =
          ({required String singleUri}) {
            expect(singleUri, uri);
            return mockDocumentFile;
          };

      final mockInputStream = MockInputStream();
      setUpInputStreamWithBytes(mockInputStream, testBytes);

      final mockContentResolver = MockContentResolver();
      when(
        mockContentResolver.openInputStream(uri),
      ).thenAnswer((_) async => mockInputStream);
      android.PigeonOverrides.contentResolver_instance = mockContentResolver;

      final file = AndroidScopedStorageXFile(
        const PlatformScopedStorageXFileCreationParams(uri: uri),
      );

      expect(combineLists(await file.openRead().toList()), testBytes);
    });

    test(
      'openRead finishes successfully with file larger than max array len',
      () async {
        final testBytes = Uint8List.fromList(
          List.filled(AndroidScopedStorageXFile.maxByteArrayLen + 1, 0),
        );

        final mockDocumentFile = MockDocumentFile();
        when(
          mockDocumentFile.length(),
        ).thenAnswer((_) async => testBytes.length);

        const uri = 'uri';
        android.PigeonOverrides.documentFile_fromSingleUri =
            ({required String singleUri}) {
              expect(singleUri, uri);
              return mockDocumentFile;
            };

        final mockInputStream = MockInputStream();
        setUpInputStreamWithBytes(mockInputStream, testBytes);

        final mockContentResolver = MockContentResolver();
        when(
          mockContentResolver.openInputStream(uri),
        ).thenAnswer((_) async => mockInputStream);
        android.PigeonOverrides.contentResolver_instance = mockContentResolver;

        final file = AndroidScopedStorageXFile(
          const PlatformScopedStorageXFileCreationParams(uri: uri),
        );

        expect(combineLists(await file.openRead().toList()), testBytes);
      },
    );

    test('openRead finishes successfully with subset of array', () async {
      final testBytes = Uint8List.fromList(<int>[0, 0, 0, 1, 1, 1, 0, 0, 0]);

      final mockDocumentFile = MockDocumentFile();
      when(mockDocumentFile.length()).thenAnswer((_) async => testBytes.length);

      const uri = 'uri';
      android.PigeonOverrides.documentFile_fromSingleUri =
          ({required String singleUri}) {
            expect(singleUri, uri);
            return mockDocumentFile;
          };

      final mockInputStream = MockInputStream();
      setUpInputStreamWithBytes(mockInputStream, testBytes);

      final mockContentResolver = MockContentResolver();
      when(
        mockContentResolver.openInputStream(uri),
      ).thenAnswer((_) async => mockInputStream);
      android.PigeonOverrides.contentResolver_instance = mockContentResolver;

      final file = AndroidScopedStorageXFile(
        const PlatformScopedStorageXFileCreationParams(uri: uri),
      );

      expect(combineLists(await file.openRead(3, 6).toList()), <int>[1, 1, 1]);
    });
  });

  test('readAsBytes', () async {
    final testBytes = Uint8List.fromList([0, 1, 2]);

    final mockDocumentFile = MockDocumentFile();
    when(mockDocumentFile.length()).thenAnswer((_) async => testBytes.length);

    const uri = 'uri';
    android.PigeonOverrides.documentFile_fromSingleUri =
        ({required String singleUri}) {
          expect(singleUri, uri);
          return mockDocumentFile;
        };

    final mockInputStream = MockInputStream();
    when(mockInputStream.readAllBytes()).thenAnswer((_) async => testBytes);

    final mockContentResolver = MockContentResolver();
    when(
      mockContentResolver.openInputStream(uri),
    ).thenAnswer((_) async => mockInputStream);
    android.PigeonOverrides.contentResolver_instance = mockContentResolver;

    final file = AndroidScopedStorageXFile(
      const PlatformScopedStorageXFileCreationParams(uri: uri),
    );

    expect(await file.readAsBytes(), testBytes);
  });

  test('readAsString', () async {
    const testString = 'Hello, World!';
    final Uint8List testBytes = utf8.encode(testString);

    final mockDocumentFile = MockDocumentFile();
    when(mockDocumentFile.length()).thenAnswer((_) async => testBytes.length);

    const uri = 'uri';
    android.PigeonOverrides.documentFile_fromSingleUri =
        ({required String singleUri}) {
          expect(singleUri, uri);
          return mockDocumentFile;
        };

    final mockInputStream = MockInputStream();
    when(mockInputStream.readAllBytes()).thenAnswer((_) async => testBytes);

    final mockContentResolver = MockContentResolver();
    when(
      mockContentResolver.openInputStream(uri),
    ).thenAnswer((_) async => mockInputStream);
    android.PigeonOverrides.contentResolver_instance = mockContentResolver;

    final file = AndroidScopedStorageXFile(
      const PlatformScopedStorageXFileCreationParams(uri: uri),
    );

    expect(await file.readAsString(), testString);
  });

  test('canRead', () async {
    final mockDocumentFile = MockDocumentFile();
    const canRead = false;
    when(mockDocumentFile.canRead()).thenAnswer((_) async => canRead);

    const uri = 'uri';
    android.PigeonOverrides.documentFile_fromSingleUri =
        ({required String singleUri}) {
          expect(singleUri, uri);
          return mockDocumentFile;
        };

    final file = AndroidScopedStorageXFile(
      const PlatformScopedStorageXFileCreationParams(uri: uri),
    );

    expect(await file.canRead(), canRead);
  });

  test('exists', () async {
    final mockDocumentFile = MockDocumentFile();
    when(mockDocumentFile.exists()).thenAnswer((_) async => true);
    when(mockDocumentFile.isFile()).thenAnswer((_) async => true);

    const uri = 'uri';
    android.PigeonOverrides.documentFile_fromSingleUri =
        ({required String singleUri}) {
          expect(singleUri, uri);
          return mockDocumentFile;
        };

    final file = AndroidScopedStorageXFile(
      const PlatformScopedStorageXFileCreationParams(uri: uri),
    );

    expect(await file.exists(), true);
  });

  test('name', () async {
    final mockDocumentFile = MockDocumentFile();
    const name = 'name';
    when(mockDocumentFile.getName()).thenAnswer((_) async => name);

    const uri = 'uri';
    android.PigeonOverrides.documentFile_fromSingleUri =
        ({required String singleUri}) {
          expect(singleUri, uri);
          return mockDocumentFile;
        };

    final file = AndroidScopedStorageXFile(
      const PlatformScopedStorageXFileCreationParams(uri: uri),
    );

    expect(await file.name(), name);
  });
}
