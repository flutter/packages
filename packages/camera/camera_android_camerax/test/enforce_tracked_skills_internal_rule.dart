// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:dart_skills_lint/dart_skills_lint.dart';

/// A custom lint rule that enforces that all skills tracked in version control 
/// are marked as internal. 
///
/// This rule is specifically used to prevent the accidental publishing of 
/// workspace-specific agent skills to the global public skills registry. It 
/// uses `git ls-files` to determine if a skill directory is checked into git,
/// and if it is, strictly requires that the `metadata: internal: true` 
/// frontmatter is present in the `SKILL.md` file.
class EnforceTrackedSkillsInternalRule extends SkillRule {
  @override
  String get name => 'enforce-tracked-skills-internal';

  @override
  AnalysisSeverity get severity => AnalysisSeverity.error;

  @override
  Future<List<ValidationError>> validate(SkillContext context) async {
    // Check if any files in the skill directory are tracked in git
    final ProcessResult processResult = await Process.run('git', ['ls-files', context.directory.path]);
    final String output = (processResult.stdout as String).trim();
    if (output.isEmpty) {
      // Not tracked by git, no enforcement needed
      return [];
    }

    final Object? yaml = context.parsedYaml;
    if (yaml == null) {
      return [
        ValidationError(
          ruleId: name,
          severity: severity,
          file: 'SKILL.md',
          message: 'Tracked skills must have "metadata: internal: true" in SKILL.md frontmatter.',
        )
      ];
    }

    final Object? metadata = (yaml as Map)['metadata'];
    if (metadata is! Map || metadata['internal'] != true) {
      return [
        ValidationError(
          ruleId: name,
          severity: severity,
          file: 'SKILL.md',
          message: 'Tracked skills must have "metadata: internal: true" in SKILL.md frontmatter.',
        )
      ];
    }

    return [];
  }
}
