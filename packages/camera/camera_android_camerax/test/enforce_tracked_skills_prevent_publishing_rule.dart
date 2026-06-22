// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:dart_skills_lint/dart_skills_lint.dart';
import 'package:path/path.dart' as p;

/// A custom lint rule that enforces that all skills tracked in version control
/// have the `prevent-skills-sh-publishing` rule enabled in `dart_skills_lint.yaml`.
///
/// Third-party skills symlinked from the repository root's `third_party` directory
/// are exempt.
class EnforceTrackedSkillsPreventPublishingRule extends SkillRule {
  @override
  String get name => 'enforce-tracked-skills-prevent-publishing';

  @override
  AnalysisSeverity get severity => AnalysisSeverity.error;

  @override
  Future<List<ValidationError>> validate(SkillContext context) async {
    try {
      final ProcessResult topLevelResult = await Process.run('git', [
        'rev-parse',
        '--show-toplevel',
      ]);
      if (topLevelResult.exitCode == 0) {
        final String repoRoot = (topLevelResult.stdout as String).trim();
        final String resolvedPath = context.directory.resolveSymbolicLinksSync();
        if (resolvedPath.startsWith('$repoRoot/third_party/')) {
          return [];
        }
      }
    } on FileSystemException {
      // Fallback to normal validation if link resolution fails
    }

    // 2. Check if the skill directory is tracked in git
    final ProcessResult processResult;
    try {
      processResult = await Process.run('git', ['ls-files', context.directory.path]);
    } on ProcessException catch (e) {
      return [
        ValidationError(
          ruleId: name,
          severity: severity,
          file: 'dart_skills_lint.yaml',
          message: 'Failed to run git to check tracked status. Error: $e',
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

    // 3. Check dart_skills_lint.yaml config
    final Configuration config = await ConfigParser.loadConfig();
    var ruleEnabled = false;
    var pathFound = false;
    AnalysisSeverity? configuredSeverity;

    final String normalizedContextPath = p.canonicalize(context.directory.absolute.path);
    for (final LintTargetConfig skillConfig in config.individualSkillConfigs) {
      final String normalizedConfigPath = p.canonicalize(File(skillConfig.path).absolute.path);
      if (normalizedConfigPath == normalizedContextPath) {
        pathFound = true;
        configuredSeverity = skillConfig.rules['prevent-skills-sh-publishing'];
        if (configuredSeverity == AnalysisSeverity.error) {
          ruleEnabled = true;
        }
        break;
      }
    }

    if (!ruleEnabled) {
      return [
        ValidationError(
          ruleId: name,
          severity: severity,
          file: 'dart_skills_lint.yaml',
          message: _buildErrorMessage(
            relativePath: context.directory.path,
            pathFound: pathFound,
            configuredSeverity: configuredSeverity,
          ),
        ),
      ];
    }

    return [];
  }

  /// Returns an actionable error message when a skill fails validation.
  ///
  /// The [relativePath] is the path to the skill directory being validated.
  /// If [pathFound] is false, the message indicates that the skill is entirely
  /// missing from `dart_skills_lint.yaml`. If [pathFound] is true but
  /// [configuredSeverity] is null, it indicates the rule is missing. If
  /// [configuredSeverity] is provided, it indicates the rule is set to an
  /// invalid severity.
  ///
  /// The returned string always concludes with the expected YAML snippet.
  String _buildErrorMessage({
    required String relativePath,
    required bool pathFound,
    required AnalysisSeverity? configuredSeverity,
  }) {
    final buffer = StringBuffer();

    if (!pathFound) {
      buffer.writeln(
        'The skill at "$relativePath" is tracked in git, but is missing from dart_skills_lint.yaml.',
      );
      buffer.writeln(
        'Please add it under `individual_skills:` with the `prevent-skills-sh-publishing` rule set to `error`:',
      );
    } else if (configuredSeverity == null) {
      buffer.writeln(
        'The skill at "$relativePath" is listed in dart_skills_lint.yaml, but the `prevent-skills-sh-publishing` rule is missing.',
      );
      buffer.writeln('Please add it to the `rules` section for this skill:');
    } else {
      buffer.writeln(
        'The skill at "$relativePath" has the `prevent-skills-sh-publishing` rule configured as `${configuredSeverity.name}`.',
      );
      buffer.writeln(
        'Tracked skills strictly require this rule to be set to `error` to prevent accidental publishing.',
      );
      buffer.writeln();
      buffer.writeln('Please update dart_skills_lint.yaml:');
    }

    buffer.writeln();
    buffer.writeln('  individual_skills:');
    buffer.writeln('    - path: "$relativePath"');
    buffer.writeln('      rules:');
    buffer.write('        prevent-skills-sh-publishing: error');

    return buffer.toString();
  }
}
