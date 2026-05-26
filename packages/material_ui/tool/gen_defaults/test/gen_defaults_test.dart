// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:test/test.dart';
import 'test_fixtures/test_templates.dart';

void main() {
  Directory? tempDir;
  String testPath() => tempDir!.path;

  group('gen_defaults templates', () {
    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('gen_defaults');
    });

    tearDown(() {
      tempDir!.deleteSync(recursive: true);
    });

    test('will generate a part file ending in _defaults.g.dart', () {
      final template = ButtonTemplate(testPath());
      template.generateFile(verbose: true);

      final file = File('${testPath()}/button_defaults.g.dart');
      expect(file.existsSync(), isTrue);
    });

    test('will generate a file with the correct header text', () {
      final template = ButtonTemplate(testPath());
      template.generateFile();

      final file = File('${testPath()}/button_defaults.g.dart');
      final String fileContents = file.readAsStringSync();
      expect(fileContents, contains(_fileHeader));
    });

    test('will generate a file with the expected contents', () {
      final template = ButtonTemplate(testPath());
      template.generateFile();

      final file = File('${testPath()}/button_defaults.g.dart');
      final String fileContents = file.readAsStringSync();
      expect(fileContents, contains(_buttonDefaultsClass));
    });

    test('will completely overwrite any previous code', () {
      final file = File('${testPath()}/button_defaults.g.dart');
      const randomText = 'Pre-existing random text.';
      file.writeAsStringSync(randomText);

      final template = ButtonTemplate(testPath());
      template.generateFile();
      final String fileContents = file.readAsStringSync();
      expect(fileContents, isNot(contains(randomText)));
      expect(fileContents, contains(_buttonDefaultsClass));
    });

    test('will run dart format over the generated file', () {
      final template = UnformattedTemplate(testPath());
      template.generateFile();

      final file = File('${testPath()}/unformatted_defaults.g.dart');
      expect(file.readAsStringSync(), contains(formattedClass));
    });

    test('materialLib path resolves correctly based on MaterialVersion', () {
      final m3Template = TestM3Template();
      final m3ExpressiveTemplate = TestM3ExpressiveTemplate();
      const materialUiDir = 'packages/material_ui';
      const generatedDir = 'lib/src/generated';

      final bool hasPackageDir = Directory(materialUiDir).existsSync();
      if (hasPackageDir) {
        expect(m3Template.materialLib, '$materialUiDir/$generatedDir');
        expect(
          m3ExpressiveTemplate.materialLib,
          '$materialUiDir/$generatedDir/material_3_expressive',
        );
      } else {
        expect(m3Template.materialLib, generatedDir);
        expect(m3ExpressiveTemplate.materialLib, '$generatedDir/material_3_expressive');
      }
    });
  });
}

const _fileHeader = '''
// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Do not edit by hand. The code is generated from data in the Material
// Design token database by the script:
//   packages/material_ui/tool/gen_defaults/bin/gen_defaults.dart.
''';

const _buttonDefaultsClass = '''
class _ButtonDefaults {
  static const double height = 40.0;
  static const double borderRadius = 8.0;
}
''';

const formattedClass = '''
class UnformattedClass {
  final int x = 1;
  final String y = 'hello';
}
''';
