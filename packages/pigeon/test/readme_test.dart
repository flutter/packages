// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:test/test.dart';

void main() {
  final File readmeFile = File('README.md');
  final String readmeText = readmeFile.readAsStringSync();

  group('README.md', () {
    test('does not include deprecated command for running pigeon', () {
      expect(readmeText, isNot(contains('flutter pub run pigeon')));
    });
    test('includes the current command for running pigeon', () {
      expect(readmeText, contains('dart run pigeon'));
    });
  });
}
