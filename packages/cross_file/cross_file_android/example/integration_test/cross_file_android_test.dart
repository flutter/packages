// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:cross_file_io/cross_file_io.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Can read from file using dart:io implementation', (WidgetTester tester) async {
    final Directory dir = await getApplicationCacheDirectory();

    final xDir = PlatformFileSystemXDirectory(PlatformFileSystemXDirectoryCreationParams(dir.path));
    expect(await xDir.exists(), isTrue);

    final file = PlatformFileSystemXFile(
      PlatformFileSystemXFileCreationParams(path.join(dir.path, 'hello.txt')),
    );
    (file.extension! as IOFileSystemXFileExtension).file
      ..createSync()
      ..writeAsStringSync('Hello, World!');

    expect(await file.readAsString(), 'Hello, World!');
  });
}
