// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:skills_lint/skills_lint.dart';
import 'package:test/test.dart';

void main() {
  test('validate skills', () async {
    final Configuration config = await ConfigParser.loadConfig();
    // validateSkills returns true even if the config has parsing errors, so
    // check those separately. skills_lint 0.6.0 plans to make validateSkills
    // fail on them: https://github.com/google/skills_lint.dart/issues/152
    expect(config.parsingErrors, isEmpty);
    final bool isValid = await validateSkills(config: config);
    expect(isValid, isTrue, reason: 'Skills validation failed. See above for details.');
  });
}
