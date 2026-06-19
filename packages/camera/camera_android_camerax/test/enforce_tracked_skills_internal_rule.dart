// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
    final ProcessResult processResult;
    try {
      processResult = await Process.run('git', ['ls-files', context.directory.path]);
    } on ProcessException catch (e) {
      return [
        ValidationError(
          ruleId: name,
          severity: severity,
          file: 'SKILL.md',
          message:
              'Failed to run git to check tracked status. Is git installed and on the PATH? Error: $e',
        ),
      ];
    }
    if (processResult.exitCode != 0) {
      return [];
    }
    final String output = (processResult.stdout as String).trim();
    if (output.isEmpty) {
      // Not tracked by git, no enforcement needed
      return [];
    }

    final Object? yaml = context.parsedYaml;
    if (yaml is! Map) {
      return [
        ValidationError(
          ruleId: name,
          severity: severity,
          file: 'SKILL.md',
          message: 'Tracked skills must have "metadata: internal: true" in SKILL.md frontmatter.',
        ),
      ];
    }

    final Object? metadata = yaml['metadata'];
    if (metadata is! Map || metadata['internal'] != true) {
      return [
        ValidationError(
          ruleId: name,
          severity: severity,
          file: 'SKILL.md',
          message: 'Tracked skills must have "metadata: internal: true" in SKILL.md frontmatter.',
        ),
      ];
    }

    return [];
  }
}
