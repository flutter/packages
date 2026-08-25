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

  // Use repo tooling to bump version and add changelog entry without backticks.
  final ProcessResult toolResult = Process.runSync('dart', <String>[
    'run',
    '../../../script/tool/bin/flutter_plugin_tools.dart',
    'update-release-info',
    '--packages=camera_android_camerax',
    '--version=bugfix',
    '--changelog=Document how Dash likes getting pictures taken with takePicture.',
  ]);

  final pubspecFile = File('pubspec.yaml');
  final changelogFile = File('CHANGELOG.md');

  // Fallback if git worktree prevents package:git from running flutter_plugin_tools
  if (toolResult.exitCode != 0 || !changelogFile.readAsStringSync().contains('Dash')) {
    final String pubspecContent = pubspecFile.readAsStringSync();
    final versionRegex = RegExp(r'version:\s*(\d+\.\d+\.\d+(\+\d+)?)');
    final RegExpMatch? versionMatch = versionRegex.firstMatch(pubspecContent);
    if (versionMatch != null) {
      final String currentVersion = versionMatch.group(1)!;
      final String newVersion = _bumpVersion(currentVersion);
      pubspecFile.writeAsStringSync(
        pubspecContent.replaceFirst(versionRegex, 'version: $newVersion'),
      );

      final String changelogContent = changelogFile.readAsStringSync();
      changelogFile.writeAsStringSync('''
## $newVersion

* Document how Dash likes getting pictures taken with takePicture.

$changelogContent''');
    }
  }

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
