// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:test/test.dart';
import '../data/color_role.dart';
import '../data/shape_struct.dart';
import '../templates/app_bar_template.dart';
import '../templates/badge_template.dart';
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

    test('ActionChipTemplateM3 emits M3 ActionChip defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('AppBarTemplateM3 emits M3 AppBar defaults from tokens', () {
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

    test('BadgeTemplateM3 emits M3 Badge defaults from badge tokens', () {
      final String contents = const BadgeTemplateM3().generateContents('_BadgeDefaultsM3');
      expect(contents, contains('class _BadgeDefaultsM3 extends BadgeThemeData'));
      expect(contents, contains('smallSize: 6.0'));
      expect(contents, contains('largeSize: 16.0'));
      expect(contents, contains('padding: const EdgeInsets.symmetric(horizontal: 4)'));
      expect(contents, contains('alignment: AlignmentDirectional.topEnd'));
      expect(contents, contains('Color? get backgroundColor => _colors.error'));
      expect(contents, contains('Color? get textColor => _colors.onError'));
      expect(
        contents,
        contains('TextStyle? get textStyle => Theme.of(context).textTheme.labelSmall'),
      );
    });

    test('BannerTemplateM3 emits M3 Banner defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('BottomAppBarTemplateM3 emits M3 BottomAppBar defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('BottomSheetTemplateM3 emits M3 BottomSheet defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('ButtonTemplateM3 emits M3 Button defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('CardTemplateM3 emits M3 Card defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('CheckboxTemplateM3 emits M3 Checkbox defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('ChipTemplateM3 emits M3 Chip defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('ColorSchemeTemplateM3 emits M3 ColorScheme defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('DatePickerTemplateM3 emits M3 DatePicker defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('DialogTemplateM3 emits M3 Dialog defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('DividerTemplateM3 emits M3 Divider defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('DrawerTemplateM3 emits M3 Drawer defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('ExpansionTileTemplateM3 emits M3 ExpansionTile defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('FabTemplateM3 emits M3 Fab defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('FilterChipTemplateM3 emits M3 FilterChip defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('IconButtonTemplateM3 emits M3 IconButton defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('InputChipTemplateM3 emits M3 InputChip defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('InputDecoratorTemplateM3 emits M3 InputDecorator defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('ListTileTemplateM3 emits M3 ListTile defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('MenuTemplateM3 emits M3 Menu defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('MotionTemplateM3 emits M3 Motion defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('NavigationBarTemplateM3 emits M3 NavigationBar defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('NavigationDrawerTemplateM3 emits M3 NavigationDrawer defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('NavigationRailTemplateM3 emits M3 NavigationRail defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('PopupMenuTemplateM3 emits M3 PopupMenu defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('ProgressIndicatorTemplateM3 emits M3 ProgressIndicator defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('RadioTemplateM3 emits M3 Radio defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('RangeSliderTemplateM3 emits M3 RangeSlider defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('SearchBarTemplateM3 emits M3 SearchBar defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('SearchViewTemplateM3 emits M3 SearchView defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('SegmentedButtonTemplateM3 emits M3 SegmentedButton defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('SliderTemplateM3 emits M3 Slider defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('SnackbarTemplateM3 emits M3 Snackbar defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('SurfaceTintTemplateM3 emits M3 SurfaceTint defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('SwitchTemplateM3 emits M3 Switch defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('TabsTemplateM3 emits M3 Tabs defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('TextFieldTemplateM3 emits M3 TextField defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('TimePickerTemplateM3 emits M3 TimePicker defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
    });

    test('TypographyTemplateM3 emits M3 Typography defaults from tokens', () {
      // Intentionally empty, will be implemented during migration. See:
      // https://github.com/flutter/flutter/issues/187899
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
