// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:test/test.dart';
import 'test_fixtures/button_template.dart';

void main() {
  group('TokenTemplate', () {
    test(
      'Templates will generate a part file ending in _defaults.g.dart with correct parent reference',
      () {
        final Directory tempDir = Directory.systemTemp.createTempSync('gen_defaults');
        try {
          final template = ButtonTemplate(tempDir.path);
          template.generateFile();

          final file = File('${tempDir.path}/button_defaults.g.dart');
          expect(file.readAsStringSync(), '''
// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Do not edit by hand. The code is generated from data in the Material
// Design token database by the script:
//   packages/material_ui/tool/m3e_gen_defaults/bin/gen_defaults.dart.

// dart format off
part of '../button.dart';

abstract final class _ButtonDefaults {
  static const double height = 40.0;
  static const double borderRadius = 8.0;
}
// dart format on
''');
        } finally {
          tempDir.deleteSync(recursive: true);
        }
      },
    );

    test('Templates will completely overwrite any previous code', () {
      final Directory tempDir = Directory.systemTemp.createTempSync('gen_defaults');
      try {
        // Seed the file with pre-existing random text.
        final file = File('${tempDir.path}/button_defaults.g.dart');
        file.writeAsStringSync('Pre-existing random text.');

        final templateNew = ButtonTemplate(tempDir.path);
        templateNew.generateFile();
        expect(file.readAsStringSync(), '''
// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Do not edit by hand. The code is generated from data in the Material
// Design token database by the script:
//   packages/material_ui/tool/m3e_gen_defaults/bin/gen_defaults.dart.

// dart format off
part of '../button.dart';

abstract final class _ButtonDefaults {
  static const double height = 40.0;
  static const double borderRadius = 8.0;
}
// dart format on
''');
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });
  });
}
