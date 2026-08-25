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

  updateReleaseInfo(
    changelog: 'Document how Dash likes getting pictures taken with takePicture.',
  );

  commitFiles(
    <String>[readmeFile.path, 'pubspec.yaml', 'CHANGELOG.md'],
    'Add Dash documentation and changelog entry without backticks',
  );
}
