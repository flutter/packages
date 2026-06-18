// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:dart_skills_lint/dart_skills_lint.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all tracked skills have prevent-skills-sh-publishing rule explicitly configured', () async {
    // Explanation:
    // Any skill in .agents/skills/ that is checked into version control is considered an internal skill.
    // It must explicitly have the `prevent-skills-sh-publishing` rule configured in dart_skills_lint.yaml
    // to prevent accidental publishing.

    // 1. Get tracked files using git ls-files
    final processResult = await Process.run('git', ['ls-files']);
    expect(processResult.exitCode, 0, reason: 'git ls-files should succeed');

    final output = processResult.stdout as String;
    final lines = output.split('\n').where((line) => line.trim().isNotEmpty);

    final trackedSkillDirs = <String>{};
    for (final line in lines) {
      final parts = line.split('/');
      final agentsIndex = parts.indexOf('.agents');
      // We look for files inside .agents/skills/<skill-name>/
      if (agentsIndex != -1 &&
          agentsIndex + 3 < parts.length &&
          parts[agentsIndex + 1] == 'skills') {
        trackedSkillDirs.add(parts[agentsIndex + 2]);
      }
    }

    expect(trackedSkillDirs, isNotEmpty, reason: 'Should find at least one tracked skill');

    // 2. Parse configuration
    final config = await ConfigParser.loadConfig();
    final session = ValidationSession(
      config: config,
      resolvedRules: <String, AnalysisSeverity>{},
      ignoreFileOverride: null,
      customRules: const [],
      printWarnings: false,
      fastFail: false,
      quiet: true,
      generateBaseline: false,
      fix: false,
      fixApply: false,
    );

    for (final skillDir in trackedSkillDirs) {
      final expectedPath = '.agents/skills/$skillDir';
      final resolvedRules = session.resolveRulesForPath(expectedPath);

      expect(
        resolvedRules.containsKey('prevent-skills-sh-publishing'),
        isTrue,
        reason:
            'The tracked skill "$skillDir" must have "prevent-skills-sh-publishing" explicitly configured in dart_skills_lint.yaml.',
      );
    }
  });
}
