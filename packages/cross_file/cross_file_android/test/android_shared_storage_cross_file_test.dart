// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_android/src/android_library.g.dart' as android;
import 'package:cross_file_android/src/android_shared_storage_cross_file.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'android_shared_storage_cross_file_test.mocks.dart';

@GenerateMocks(<Type>[android.DocumentFile, android.ContentResolver])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    android.PigeonOverrides.pigeon_reset();
  });

  test('lastModified', () async {
    final mockDocumentFile = MockDocumentFile();
    const lastModified = 123;
    when(mockDocumentFile.lastModified()).thenAnswer((_) async => lastModified);
    android.PigeonOverrides.documentFile_fromSingleUri =
        ({required String singleUri}) {
          return mockDocumentFile;
        };

    final file = AndroidSharedStorageXFile(
      const PlatformSharedStorageXFileCreationParams(uri: ''),
    );

    expect(
      await file.lastModified(),
      DateTime.fromMillisecondsSinceEpoch(lastModified),
    );
  });
}
