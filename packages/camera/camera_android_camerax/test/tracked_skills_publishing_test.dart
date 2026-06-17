// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  test('all tracked skills have prevent-skills-sh-publishing rule explicitly configured', () async {
    // Explanation:
    // Any skill in .agents/skills/ that is checked into version control is considered an internal skill.
    // It must explicitly have the `prevent-skills-sh-publishing` rule configured in dart_skills_lint.yaml
    // to prevent accidental publishing.

    // 1. Get tracked files using git ls-files
    final ProcessResult processResult = await Process.run('git', ['ls-files', '.agents/skills']);
    expect(processResult.exitCode, 0, reason: 'git ls-files should succeed');

    final output = processResult.stdout as String;
    final Iterable<String> lines = output.split('\n').where((line) => line.trim().isNotEmpty);

    final trackedSkillDirs = <String>{};
    for (final line in lines) {
      final List<String> parts = line.split('/');
      // We look for files inside .agents/skills/<skill-name>/
      // parts[0] is .agents, parts[1] is skills
      if (parts.length >= 4 && parts[0] == '.agents' && parts[1] == 'skills') {
        trackedSkillDirs.add(parts[2]);
      }
    }

    expect(trackedSkillDirs, isNotEmpty, reason: 'Should find at least one tracked skill');

    // 2. Parse configuration
    final File yamlFile = File('dart_skills_lint.yaml');
    final YamlMap yamlConfig = loadYaml(yamlFile.readAsStringSync());
    final YamlMap? toolConfig = yamlConfig['dart_skills_lint'] as YamlMap?;
    expect(toolConfig, isNotNull, reason: 'dart_skills_lint config missing');

    for (final skillDir in trackedSkillDirs) {
      final expectedPath = '.agents/skills/$skillDir';
      bool hasRule = false;

      // Check directories
      final dirs = toolConfig!['directories'] as YamlList?;
      if (dirs != null) {
        for (final dir in dirs) {
          if (dir is YamlMap && (dir['path'] == expectedPath || dir['path'] == '.agents/skills')) {
            if (dir['rules'] is YamlMap && dir['rules']['prevent-skills-sh-publishing'] != null) {
              hasRule = true;
            }
          }
        }
      }

      // Check hypothetical individual_skills
      final individualSkills = toolConfig['individual_skills'] as YamlList?;
      if (individualSkills != null) {
        for (final skill in individualSkills) {
          if (skill is YamlMap && skill['path'] == expectedPath) {
            if (skill['rules'] is YamlMap && skill['rules']['prevent-skills-sh-publishing'] != null) {
              hasRule = true;
            }
          }
        }
      }

      expect(
        hasRule,
        isTrue,
        reason:
            'The tracked skill "$skillDir" must have "prevent-skills-sh-publishing" explicitly configured in dart_skills_lint.yaml.',
      );
    }
  });
}
