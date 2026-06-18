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
    final processResult = await Process.run('git', ['ls-files']);
    expect(processResult.exitCode, 0, reason: 'git ls-files should succeed');

    final output = processResult.stdout as String;
    final lines = output.split('\n').where((line) => line.trim().isNotEmpty);

    final trackedSkillDirs = <String>{};
    for (final line in lines) {
      final parts = line.split('/');
      final agentsIndex = parts.indexOf('.agents');
      // We look for files inside .agents/skills/<skill-name>/
      // So parts length must be at least agentsIndex + 4
      if (agentsIndex != -1 &&
          agentsIndex + 3 < parts.length &&
          parts[agentsIndex + 1] == 'skills') {
        trackedSkillDirs.add(parts[agentsIndex + 2]);
      }
    }

    expect(trackedSkillDirs, isNotEmpty, reason: 'Should find at least one tracked skill');

    // 2. Parse configuration manually to avoid internal API imports
    final yamlFile = File('dart_skills_lint.yaml');
    final yamlConfig = loadYaml(yamlFile.readAsStringSync()) as YamlMap;
    final toolConfig = yamlConfig['dart_skills_lint'] as YamlMap?;
    expect(toolConfig, isNotNull, reason: 'dart_skills_lint config missing');

    for (final skillDir in trackedSkillDirs) {
      final expectedPath = '.agents/skills/$skillDir';
      bool hasRule = false;

      // Check directories
      final dirs = toolConfig!['directories'] as YamlList?;
      if (dirs != null) {
        for (final dynamic dir in dirs) {
          if (dir is YamlMap) {
            final path = dir['path'] as String?;
            if (path == expectedPath || path == '.agents/skills') {
              final rules = dir['rules'] as YamlMap?;
              if (rules != null && rules['prevent-skills-sh-publishing'] != null) {
                hasRule = true;
              }
            }
          }
        }
      }

      // Check individual_skills
      final individualSkills = toolConfig['individual_skills'] as YamlList?;
      if (individualSkills != null) {
        for (final dynamic skill in individualSkills) {
          if (skill is YamlMap) {
            final path = skill['path'] as String?;
            if (path == expectedPath) {
              final rules = skill['rules'] as YamlMap?;
              if (rules != null && rules['prevent-skills-sh-publishing'] != null) {
                hasRule = true;
              }
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
