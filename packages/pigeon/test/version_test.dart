// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:pigeon/src/generator_tools.dart';
import 'package:test/test.dart';

void main() {
  test('pigeon version matches pubspec', () {
    final String pubspecPath = '${Directory.current.path}/pubspec.yaml';
    final String pubspec = File(pubspecPath).readAsStringSync();
    final RegExp regex = RegExp(r'version:\s*(.*?) #');
    final RegExpMatch? match = regex.firstMatch(pubspec);
    expect(match, isNotNull);
    expect(pigeonVersion, match?.group(1)?.trim());
  });
}
