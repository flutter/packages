// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';
import 'package:pigeon/generator_tools.dart';
import 'dart:io';

void main() {
  test('pigeon version matches pubspec', () {    
    String pubspecPath = '${Directory.current.path}/pubspec.yaml';
    String pubspec = File(pubspecPath).readAsStringSync();
    RegExp regex = RegExp('version:\s*(.*)');
    RegExpMatch match = regex.firstMatch(pubspec);
    expect(match, isNotNull);
    expect(pigeonVersion, match.group(1).trim());
  });
}
