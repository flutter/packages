import 'dart:async';
import 'dart:io';

import 'package:dart_skills_lint/dart_skills_lint.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

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

void main() {
  test('Validate Skills', () async {
    final Level oldLevel = Logger.root.level;
    Logger.root.level = Level.ALL;
    final StreamSubscription<LogRecord> subscription = Logger.root.onRecord.listen((record) {
      debugPrint(record.message);
    });

    try {
      final Configuration config = await ConfigParser.loadConfig();
      final bool isValid = await validateSkills(
        config: config,
        customRules: [EnforceTrackedSkillsInternalRule()],
      );
      expect(isValid, isTrue, reason: 'Skills validation failed. See above for details.');
    } finally {
      Logger.root.level = oldLevel;
      await subscription.cancel();
    }
  });
}
