// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('vm') // Uses dart:io
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lib/google_fonts_lite.dart does not transitively import part files', () {
    final String liteEntryContent = File('lib/google_fonts_lite.dart').readAsStringSync();
    expect(liteEntryContent.contains('google_fonts.dart'), isFalse);
    expect(liteEntryContent.contains('google_fonts_all_parts.dart'), isFalse);

    final String liteSrcContent = File('lib/src/google_fonts_lite.dart').readAsStringSync();
    expect(liteSrcContent.contains('google_fonts.dart'), isFalse);
    expect(liteSrcContent.contains('google_fonts_all_parts.dart'), isFalse);
    expect(liteSrcContent.contains('google_fonts_parts/'), isFalse);

    final String baseFileContent = File('lib/src/google_fonts_base.dart').readAsStringSync();
    expect(
      baseFileContent.contains("import '../google_fonts.dart'"),
      isFalse,
      reason: 'google_fonts_base.dart must not import google_fonts.dart to maintain tree-shaking',
    );
    expect(baseFileContent.contains("import 'google_fonts_config.dart'"), isTrue);
    expect(baseFileContent.contains('google_fonts_all_parts.dart'), isFalse);
    expect(baseFileContent.contains('google_fonts_parts/'), isFalse);
  });
}
