// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:cross_file_darwin/cross_file_darwin.dart';
import 'package:cross_file_darwin/src/darwin_scoped_storage_cross_directory.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker/leak_tracker.dart';
import 'package:path/path.dart' as path;

final Directory testDirectory = Directory(path.join(Directory.current.path, 'test'));

void main() {
  setUp(() {
    CrossFilePlatform.instance = CrossFileDarwin();
  });

  test('exists', () async {
    final directory = PlatformScopedStorageXDirectory(
      PlatformScopedStorageXDirectoryCreationParams(uri: testDirectory.uri.toString()),
    );

    expect(await directory.exists(), testDirectory.existsSync());
  });

  test('list', () async {
    final directory = PlatformScopedStorageXDirectory(
      PlatformScopedStorageXDirectoryCreationParams(uri: testDirectory.uri.toString()),
    );

    expect(
      (await directory.list(const PlatformListParams()).toList()).map(
        (PlatformXEntity entity) => entity.params.uri,
      ),
      (await testDirectory.list().toList()).map((FileSystemEntity entity) => entity.uri.toString()),
    );
  });

  test('finalizer callback is made when directory is garbage collected', () async {
    SecurityScopedDarwinScopedStorageXDirectory.finalizer = Finalizer<String>(
      expectAsync1((String uri) {
        expect(uri, testDirectory.uri.toString());
      }),
    );

    final WeakReference<SecurityScopedDarwinScopedStorageXDirectory> dir =
        await _createAndDropDirectory();

    await forceGC();
    expect(dir.target, isNull);
  });

  test(
    'finalizer callback is not made when directory is garbage collected after being disposed',
    () async {
      SecurityScopedDarwinScopedStorageXDirectory.finalizer = Finalizer<String>(
        expectAsync1((_) {}, count: 0),
      );

      final WeakReference<SecurityScopedDarwinScopedStorageXDirectory> dir =
          await _createAndDropDirectory(dispose: true);

      await forceGC();
      expect(dir.target, isNull);
    },
  );
}

// Allocate and register the instance inside a non-inlined helper so the
// async test frame does not retain a hidden stack/register reference to
// the object across `await forceGC()`.
@pragma('vm:never-inline')
Future<WeakReference<SecurityScopedDarwinScopedStorageXDirectory>> _createAndDropDirectory({
  bool dispose = false,
}) async {
  final dir = SecurityScopedDarwinScopedStorageXDirectory(
    PlatformScopedStorageXDirectoryCreationParams(uri: testDirectory.uri.toString()),
  );
  if (dispose) {
    await dir.dispose();
  }
  return WeakReference(dir);
}
