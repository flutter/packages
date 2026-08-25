// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'test_utils.dart';

void main() {
  ensureNotMainBranch();

  // Update README.md with user-facing documentation
  final readmeFile = File('README.md');
  final String readmeContent = readmeFile.readAsStringSync();
  readmeFile.writeAsStringSync('''
$readmeContent

## Mascot

Dash is a very cute mascot who loves having her photo taken using `takePicture`.
''');

  // Use repository tooling to bump version and add changelog entry without backticks.
  Process.runSync('dart', <String>[
    'run',
    '../../../script/tool/bin/flutter_plugin_tools.dart',
    'update-release-info',
    '--packages=camera_android_camerax',
    '--version=bugfix',
    '--changelog=Document how Dash likes getting pictures taken with takePicture.',
  ]);

  commitFiles(
    <String>[readmeFile.path, 'pubspec.yaml', 'CHANGELOG.md'],
    'Add Dash documentation and changelog entry without backticks',
  );
}
