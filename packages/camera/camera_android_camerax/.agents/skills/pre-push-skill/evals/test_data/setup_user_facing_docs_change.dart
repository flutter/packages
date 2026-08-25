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

  updateVersionAndChangelog('Document how Dash likes getting pictures taken with takePicture.');

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

/// Updates the package version in `pubspec.yaml` and prepends the new entry to `CHANGELOG.md`.
void updateVersionAndChangelog(String changelogEntry) {
  final pubspecFile = File('pubspec.yaml');
  final String pubspecContent = pubspecFile.readAsStringSync();
  final versionRegex = RegExp(r'version:\s*(\d+\.\d+\.\d+(\+\d+)?)');
  final RegExpMatch? versionMatch = versionRegex.firstMatch(pubspecContent);
  if (versionMatch == null) {
    throw StateError('Could not find version in pubspec.yaml');
  }

  final String currentVersion = versionMatch.group(1)!;
  final String newVersion = _bumpVersion(currentVersion);
  pubspecFile.writeAsStringSync(
    pubspecContent.replaceFirst(versionRegex, 'version: $newVersion'),
  );

  final changelogFile = File('CHANGELOG.md');
  final String changelogContent = changelogFile.readAsStringSync();
  changelogFile.writeAsStringSync('''
## $newVersion

* $changelogEntry

$changelogContent''');
}

String _bumpVersion(String version) {
  if (version.contains('+')) {
    final List<String> parts = version.split('+');
    final int build = int.parse(parts[1]) + 1;
    return '${parts[0]}+$build';
  }
  final List<String> parts = version.split('.');
  final int patch = int.parse(parts[2]) + 1;
  return '${parts[0]}.${parts[1]}.$patch';
}
