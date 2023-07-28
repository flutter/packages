// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:xdg_directories/xdg_directories.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('XDG Directories', (WidgetTester _) async {
    // Check that getUserDirectory() returns a Directory.
    expect(
      getUserDirectory('Home') != null,
      true,
      reason: 'getUserDirectory() should return a Directory',
    );

    // Check that dataHome returns a Directory.
    expect(
      dataHome.path.isNotEmpty,
      true,
      reason: 'dataHome should return a Directory',
    );

    // Check that configHome returns a Directory.
    expect(
      configHome.path.isNotEmpty,
      true,
      reason: 'configHome should return a Directory',
    );

    // Check that cacheHome returns a Directory.
    expect(
      cacheHome.path.isNotEmpty,
      true,
      reason: 'cacheHome should return a Directory',
    );

    // Check that dataDirs returns a List<Directory>.
    expect(
      dataDirs.isNotEmpty,
      true,
      reason: 'dataDirs should return a List<Directory>',
    );

    // Check that configDirs returns a List<Directory>.
    expect(
      configDirs.isNotEmpty,
      true,
      reason: 'configDirs should return a List<Directory>',
    );
  });
}
