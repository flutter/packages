// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:xdg_directories/xdg_directories.dart';
import 'package:xdg_directories_example/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('xdg_directories_demo', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    expect(find.textContaining(dataHome.path), findsWidgets);
    expect(find.textContaining(configHome.path), findsWidgets);
    expect(
        find.textContaining(
            dataDirs.map((Directory directory) => directory.path).join('\n')),
        findsWidgets);
    expect(
        find.textContaining(
            configDirs.map((Directory directory) => directory.path).join('\n')),
        findsWidgets);

    expect(
      find.textContaining(cacheHome.path, skipOffstage: false),
      findsWidgets,
    );

    expect(find.textContaining(runtimeDir?.path ?? '', skipOffstage: false),
        findsWidgets);
  });
}
