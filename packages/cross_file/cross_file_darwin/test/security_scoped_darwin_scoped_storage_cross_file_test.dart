// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:cross_file_darwin/cross_file_darwin.dart';
import 'package:cross_file_darwin/src/darwin_scoped_storage_cross_file.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker/leak_tracker.dart';
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

  test('finalizer callback is made when file is garbage collected', () async {
    SecurityScopedDarwinScopedStorageXFile.finalizer = Finalizer<String>(
      expectAsync1((String uri) {
        expect(uri, testFile.uri.toString());
      }),
    );

    final WeakReference<SecurityScopedDarwinScopedStorageXFile> file = await _createAndDropFile();

    await forceGC();
    expect(file.target, isNull);
  });

  test(
    'finalizer callback is not made when file is garbage collected after being disposed',
    () async {
      SecurityScopedDarwinScopedStorageXFile.finalizer = Finalizer<String>(
        expectAsync1((_) {}, count: 0),
      );

      final WeakReference<SecurityScopedDarwinScopedStorageXFile> file = await _createAndDropFile(
        dispose: true,
      );

      await forceGC();
      expect(file.target, isNull);
    },
  );
}

@pragma('vm:never-inline')
Future<WeakReference<SecurityScopedDarwinScopedStorageXFile>> _createAndDropFile({
  bool dispose = false,
}) async {
  final file = SecurityScopedDarwinScopedStorageXFile(
    PlatformScopedStorageXFileCreationParams(uri: testFile.uri.toString()),
  );
  if (dispose) {
    await file.dispose();
  }
  return WeakReference(file);
}
