// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:test/test.dart';
import '../templates/template.dart';
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

    for (final isM3E in <bool>[true, false]) {
      TokenTemplate buttonTemplate() =>
          isM3E ? M3EIconButtonTemplate(testPath()) : M3IconButtonTemplate(testPath());

      String filePath() {
        final fileName = 'icon_button_m3${isM3E ? 'e' : ''}_defaults.g.dart';
        return '${testPath()}/$fileName';
      }

      group(isM3E ? 'M3E Template' : 'M3 Template', () {
        test(
          'will generate a part file ending in icon_button_m3${isM3E ? 'e' : ''}_defaults.g.dart',
          () {
            buttonTemplate().generateFile(verbose: true);
            expect(File(filePath()).existsSync(), isTrue);
          },
        );

        test('will generate a file with the correct header text', () {
          buttonTemplate().generateFile(verbose: true);
          final String fileContents = File(filePath()).readAsStringSync();
          expect(fileContents, contains(_fileHeader));
        });

        test('will generate a file with the expected contents', () {
          buttonTemplate().generateFile(verbose: true);
          final String fileContents = File(filePath()).readAsStringSync();
          expect(
            fileContents,
            contains(isM3E ? _buttonExpressiveDefaultsClass : _buttonDefaultsClass),
          );
        });

        test('will completely overwrite any previous code', () {
          final file = File(filePath());
          const randomText = 'Pre-existing random text.';
          file.writeAsStringSync(randomText);

          buttonTemplate().generateFile(verbose: true);
          final String fileContents = file.readAsStringSync();
          expect(fileContents, isNot(contains(randomText)));
        });
      });
    }

    test('will run dart format over the generated file', () {
      final template = UnformattedTemplate(testPath());
      template.generateFile();

      final file = File('${testPath()}/unformatted_m3_defaults.g.dart');
      expect(file.readAsStringSync(), contains(formattedClass));
    });

    test('throws AssertionError if class name is not defined in generateContents', () {
      final template = InvalidTemplate(testPath());
      expect(
        () => template.generateFile(),
        throwsA(
          isA<AssertionError>().having(
            (AssertionError e) => e.message,
            'message',
            contains('Make sure you are utilizing the passed `className` parameter.'),
          ),
        ),
      );
    });

    test('throws AssertionError if name is not in Spaced / TitleCase', () {
      final template = SnakeCaseNameTemplate(testPath());
      expect(
        () => template.generateFile(),
        throwsA(
          isA<AssertionError>().having(
            (AssertionError e) => e.message,
            'message',
            contains('must use spaces and capitalized words'),
          ),
        ),
      );
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

const _buttonExpressiveDefaultsClass = '''
class _M3EIconButtonDefaults {
  static const double height = 40.0;
  static const double borderRadius = 8.0;
}
''';

const _buttonDefaultsClass = '''
class _M3IconButtonDefaults {
  static const double height = 40.0;
  static const double borderRadius = 8.0;
}
''';

const formattedClass = '''
class _M3UnformattedDefaults {
  final int x = 1;
  final String y = 'hello';
}
''';
