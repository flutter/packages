// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:dart_skills_lint/dart_skills_lint.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

import 'enforce_tracked_skills_prevent_publishing_rule.dart';

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
        customRules: [EnforceTrackedSkillsPreventPublishingRule()],
      );
      expect(isValid, isTrue, reason: 'Skills validation failed. See above for details.');
    } finally {
      Logger.root.level = oldLevel;
      await subscription.cancel();
    }
  });
}
