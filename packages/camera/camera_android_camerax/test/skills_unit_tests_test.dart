// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// This proxy test discovers and executes unit tests for agent skills.
///
/// By default, CI ignores hidden directories like `.agents`, meaning tests
/// written for our skills aren't automatically discovered. This test bridges
/// that gap by manually scanning `.agents/skills` for valid Dart packages and
/// executing `dart test` within them.
///
/// DISCLAIMER: This is a temporary pattern while the camera_android_camerax
/// team figures out how to properly scale the agentic development pattern and
/// integrate skill testing into the standard flutter/packages CI infrastructure.
void main() {
  test('Agent Skills unit tests pass', () async {
    // Determine skills directory relative to the package root.
    final skillsDir = Directory(p.join(Directory.current.path, '.agents', 'skills'));

    if (!skillsDir.existsSync()) {
      fail(
        'The .agents/skills directory was not found. If this package has no skills, this test should be removed.',
      );
    }

    final failedSkills = <String>[];

    final Iterable<Directory> skillDirs = skillsDir
        .listSync(followLinks: false)
        .whereType<Directory>();
    for (final skillDir in skillDirs) {
      final pubspec = File(p.join(skillDir.path, 'pubspec.yaml'));
      final testDir = Directory(p.join(skillDir.path, 'test'));

      if (pubspec.existsSync() && testDir.existsSync()) {
        final String skillName = p.basename(skillDir.path);
        debugPrint('Running tests for agent skill: $skillName');
        final ProcessResult pubGetResult = await Process.run('dart', [
          'pub',
          'get',
        ], workingDirectory: skillDir.path);
        if (pubGetResult.exitCode != 0) {
          failedSkills.add(skillName);
          debugPrint('--- $skillName pub get output ---');
          debugPrint(pubGetResult.stdout.toString());
          debugPrint(pubGetResult.stderr.toString());
          continue;
        }

        final ProcessResult result = await Process.run('dart', [
          'test',
        ], workingDirectory: skillDir.path);

        if (result.exitCode != 0) {
          failedSkills.add(skillName);
          debugPrint('--- $skillName test output ---');
          debugPrint(result.stdout.toString());
          debugPrint(result.stderr.toString());
        } else {
          debugPrint('Tests passed for $skillName');
        }
      }
    }

    expect(
      failedSkills,
      isEmpty,
      reason: "The following agent skills had failing tests: ${failedSkills.join(', ')}",
    );
  });
}
