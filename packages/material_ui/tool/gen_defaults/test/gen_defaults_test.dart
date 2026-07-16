// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:test/test.dart';
import '../data/color_role.dart';
import '../data/shape_struct.dart';
import '../templates/app_bar_template.dart';
import '../templates/bottom_sheet_template.dart';
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
          isM3E ? IconButtonTemplateM3E(testPath()) : IconButtonTemplateM3(testPath());

      String filePath() {
        final fileName = 'icon_button_defaults_m3${isM3E ? 'e' : ''}.g.dart';
        return '${testPath()}/$fileName';
      }

      group(isM3E ? 'M3E Template' : 'M3 Template', () {
        test(
          'will generate a part file ending in icon_button_defaults_m3${isM3E ? 'e' : ''}.g.dart',
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

    test('color generates color expression', () {
      final template = IconButtonTemplateM3(testPath());
      expect(template.color(TokenColorRole.onSurface, '_colors'), '_colors.onSurface');
    });

    test('colorWithOpacity generates color expression with opacity', () {
      final template = IconButtonTemplateM3(testPath());
      expect(
        template.colorWithOpacity(TokenColorRole.onSurface, 0.12, '_colors'),
        '_colors.onSurface.withOpacity(0.12)',
      );
      expect(
        template.colorWithOpacity(TokenColorRole.onSurface, 1.0, '_colors'),
        '_colors.onSurface',
      );
    });

    test('shape generates shape expressions', () {
      final template = IconButtonTemplateM3(testPath());
      expect(
        template.shape(
          const ShapeStruct(
            family: 'SHAPE_FAMILY_ROUNDED_CORNERS',
            topLeft: 8.0,
            topRight: 8.0,
            bottomLeft: 8.0,
            bottomRight: 8.0,
          ),
        ),
        'const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0)))',
      );
      expect(
        template.shape(
          const ShapeStruct(
            family: 'SHAPE_FAMILY_ROUNDED_CORNERS',
            topLeft: 8.0,
            topRight: 8.0,
            bottomLeft: 4.0,
            bottomRight: 4.0,
          ),
        ),
        'const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(8.0), bottom: Radius.circular(4.0)))',
      );
      expect(
        template.shape(
          const ShapeStruct(
            family: 'SHAPE_FAMILY_CIRCULAR',
            topLeft: 0.0,
            topRight: 0.0,
            bottomLeft: 0.0,
            bottomRight: 0.0,
          ),
        ),
        'const StadiumBorder()',
      );
    });

    test('shape throws UnsupportedError for unsupported shape family', () {
      final template = IconButtonTemplateM3(testPath());
      expect(
        () => template.shape(
          const ShapeStruct(
            family: 'SHAPE_FAMILY_UNKNOWN',
            topLeft: 0.0,
            topRight: 0.0,
            bottomLeft: 0.0,
            bottomRight: 0.0,
          ),
        ),
        throwsA(
          isA<UnsupportedError>().having(
            (UnsupportedError e) => e.message,
            'message',
            'Unsupported shape family type: SHAPE_FAMILY_UNKNOWN',
          ),
        ),
      );
    });

    test('AppBarTemplateM3 emits M3 AppBar defaults from app bar tokens', () {
      final String contents = const AppBarTemplateM3().generateContents('_AppBarDefaultsM3');
      expect(contents, contains('class _AppBarDefaultsM3 extends AppBarThemeData'));
      expect(contents, contains('scrolledUnderElevation: 3.0'));
      expect(contents, contains('toolbarHeight: 64.0'));
      expect(contents, contains('Color? get backgroundColor => _colors.surface'));
      expect(contents, contains('Color? get foregroundColor => _colors.onSurface'));
      expect(contents, contains('color: _colors.onSurfaceVariant'));
      expect(contents, contains('static const double expandedHeight = 112.0'));
      expect(contents, contains('static const double expandedHeight = 152.0'));
    });

    test('BottomSheetTemplateM3 emits M3 BottomSheet defaults from bottom sheet tokens', () {
      final String contents = const BottomSheetTemplateM3().generateContents(
        '_BottomSheetDefaultsM3',
      );
      expect(contents, contains('class _BottomSheetDefaultsM3 extends BottomSheetThemeData'));
      expect(contents, contains('elevation: 1.0'));
      expect(contents, contains('modalElevation: 1.0'));
      expect(
        contents,
        contains(
          'shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)))',
        ),
      );
      expect(contents, contains('Color? get backgroundColor => _colors.surfaceContainerLow'));
      expect(contents, contains('Color? get dragHandleColor => _colors.onSurfaceVariant'));
      expect(contents, contains('Size? get dragHandleSize => const Size(32.0, 4.0)'));
    });
    test('will run dart format over the generated file', () {
      final template = UnformattedTemplate(testPath());
      template.generateFile();

      final file = File('${testPath()}/unformatted_defaults_m3.g.dart');
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
class _IconButtonDefaultsM3E {
  static const double height = 40.0;
  static const double borderRadius = 8.0;
}
''';

const _buttonDefaultsClass = '''
class _IconButtonDefaultsM3 {
  _IconButtonDefaultsM3(this.context);

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  static const double height = 40.0;
  static const double borderRadius = 8.0;
  Color get iconColor => _colors.onSurfaceVariant;
  Color get disabledIconColor => _colors.onSurface.withOpacity(0.38);
  Color get hoveredStateLayerColor =>
      _colors.onSurfaceVariant.withOpacity(0.08);
  OutlinedBorder get shape => const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
  );
}
''';

const formattedClass = '''
class _UnformattedDefaultsM3 {
  final int x = 1;
  final String y = 'hello';
}
''';
