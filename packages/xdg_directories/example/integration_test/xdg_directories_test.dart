// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:xdg_directories/xdg_directories.dart';
import 'package:xdg_directories_example/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('xdg_directories_demo', (WidgetTester _) async {
    // Build our app and trigger a frame.
    await _.pumpWidget(const MyApp());

    expect(find.textContaining(dataHome.path), findsOneWidget);
    expect(find.textContaining(configHome.path), findsOneWidget);
    expect(find.textContaining(dataDirs.join('\n')), findsOneWidget);
    expect(find.textContaining(configDirs.join('\n')), findsOneWidget);
    expect(find.textContaining(cacheHome.path), findsOneWidget);
    expect(find.textContaining(runtimeDir?.path ?? ''), findsOneWidget);

    final Set<String> userDirectoryNames = getUserDirectoryNames();

    for (final String userDirectoryName in userDirectoryNames) {
      final String userDirectoryPath =
          getUserDirectory(userDirectoryName)?.path ?? '';

      expect(find.textContaining(userDirectoryPath), findsOneWidget);
    }
  });
}
