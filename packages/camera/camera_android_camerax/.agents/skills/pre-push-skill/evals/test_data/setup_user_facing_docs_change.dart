// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

void main() {
  final ProcessResult branchResult = Process.runSync('git', <String>['branch', '--show-current']);
  final String branch = branchResult.stdout.toString().trim();
  if (branch == 'main') {
    stdout.writeln('Error: Cannot run setup scripts on main branch.');
    exit(1);
  }

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

  Process.runSync('git', <String>['add', readmeFile.path, 'pubspec.yaml', 'CHANGELOG.md']);
  Process.runSync('git', <String>[
    '-c',
    'user.name=Author',
    '-c',
    'user.email=author@example.com',
    'commit',
    '-m',
    'Add Dash documentation and changelog entry without backticks',
  ]);
}
