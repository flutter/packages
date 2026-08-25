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

  final javaFile = File('android/src/main/java/io/flutter/plugins/camerax/DummyEvalFeature.java');
  javaFile.createSync(recursive: true);
  javaFile.writeAsStringSync('''
// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

public class DummyEvalFeature {
    public void doNothing() {}
}
''');

  final javaTestFile = File(
    'android/src/test/java/io/flutter/plugins/camerax/DummyEvalFeatureTest.java',
  );
  javaTestFile.createSync(recursive: true);
  javaTestFile.writeAsStringSync('''
// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import org.junit.Test;
import static org.junit.Assert.assertTrue;

public class DummyEvalFeatureTest {
    @Test
    public void testDoNothing() {
        DummyEvalFeature feature = new DummyEvalFeature();
        feature.doNothing();
        assertTrue(true);
    }
}
''');

  // Use repo tooling to bump version and add changelog entry.
  final ProcessResult toolResult = Process.runSync('dart', <String>[
    'run',
    '../../../script/tool/bin/flutter_plugin_tools.dart',
    'update-release-info',
    '--packages=camera_android_camerax',
    '--version=bugfix',
    '--changelog=Adds `DummyEvalFeature` and tests.',
  ]);

  final pubspecFile = File('pubspec.yaml');
  final changelogFile = File('CHANGELOG.md');

  // Fallback if git worktree prevents package:git from running flutter_plugin_tools
  if (toolResult.exitCode != 0 || !changelogFile.readAsStringSync().contains('DummyEvalFeature')) {
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

* Adds `DummyEvalFeature` and tests.

$changelogContent''');
    }
  }

  Process.runSync('git', <String>['add', javaFile.path, javaTestFile.path, 'pubspec.yaml', 'CHANGELOG.md']);
  Process.runSync('git', <String>[
    '-c',
    'user.name=Author',
    '-c',
    'user.email=author@example.com',
    'commit',
    '-m',
    'Add DummyEvalFeature.java, tests, and changelog update',
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
