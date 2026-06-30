// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:cross_file_io/cross_file_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Can read from file using dart:io implementation', (WidgetTester tester) async {
    final Directory dir = await getApplicationCacheDirectory();

    final xDir = XDirectory.fromPath(dir.path);
    expect(await xDir.exists(), isTrue);

    final file = XFile.fromPath(path.join(dir.path, 'hello.txt'));
    file.getExtension<IOXFileExtension>().file
      ..createSync()
      ..writeAsStringSync('Hello, World!');

    expect(await file.readAsString(), 'Hello, World!');
  }, skip: kIsWeb);
}
