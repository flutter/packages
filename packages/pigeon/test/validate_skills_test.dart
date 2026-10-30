// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:skills_lint/skills_lint.dart';
import 'package:test/test.dart';

void main() {
  test('validate skills', () async {
    final config = await ConfigParser.loadConfig();
    expect(config.parsingErrors, isEmpty);
    await validateSkills(config: config);
  });
}
