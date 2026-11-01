// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/typescale.dart';
import '../data/typescale_emphasized.dart';
import '../data/typescale_struct.dart';
import 'template.dart';

const List<(String, TypescaleStruct)> _baseTextStyles = <(String, TypescaleStruct)>[
  ('displayLarge', TokenTypescale.displayLarge),
  ('displayMedium', TokenTypescale.displayMedium),
  ('displaySmall', TokenTypescale.displaySmall),
  ('headlineLarge', TokenTypescale.headlineLarge),
  ('headlineMedium', TokenTypescale.headlineMedium),
  ('headlineSmall', TokenTypescale.headlineSmall),
  ('titleLarge', TokenTypescale.titleLarge),
  ('titleMedium', TokenTypescale.titleMedium),
  ('titleSmall', TokenTypescale.titleSmall),
  ('labelLarge', TokenTypescale.labelLarge),
  ('labelMedium', TokenTypescale.labelMedium),
  ('labelSmall', TokenTypescale.labelSmall),
  ('bodyLarge', TokenTypescale.bodyLarge),
  ('bodyMedium', TokenTypescale.bodyMedium),
  ('bodySmall', TokenTypescale.bodySmall),
];

const List<(String, TypescaleStruct)> _emphasizedTextStyles = <(String, TypescaleStruct)>[
  ('displayLargeEmphasized', TokenTypescaleEmphasized.displayLarge),
  ('displayMediumEmphasized', TokenTypescaleEmphasized.displayMedium),
  ('displaySmallEmphasized', TokenTypescaleEmphasized.displaySmall),
  ('headlineLargeEmphasized', TokenTypescaleEmphasized.headlineLarge),
  ('headlineMediumEmphasized', TokenTypescaleEmphasized.headlineMedium),
  ('headlineSmallEmphasized', TokenTypescaleEmphasized.headlineSmall),
  ('titleLargeEmphasized', TokenTypescaleEmphasized.titleLarge),
  ('titleMediumEmphasized', TokenTypescaleEmphasized.titleMedium),
  ('titleSmallEmphasized', TokenTypescaleEmphasized.titleSmall),
  ('labelLargeEmphasized', TokenTypescaleEmphasized.labelLarge),
  ('labelMediumEmphasized', TokenTypescaleEmphasized.labelMedium),
  ('labelSmallEmphasized', TokenTypescaleEmphasized.labelSmall),
  ('bodyLargeEmphasized', TokenTypescaleEmphasized.bodyLarge),
  ('bodyMediumEmphasized', TokenTypescaleEmphasized.bodyMedium),
  ('bodySmallEmphasized', TokenTypescaleEmphasized.bodySmall),
];

mixin TypographyTokenMixin on TokenTemplate {
  @override
  String get name => 'Typography';

  @override
  String get parentFilePath => 'typography.dart';

  String get _typographyYear;

  List<(String, TypescaleStruct)> get _textStyles;

  @override
  String generateContents(String className) =>
      '''
abstract final class $className {
  ${_textTheme('englishLike', 'alphabetic')}

  ${_textTheme('dense', 'ideographic')}

  ${_textTheme('tall', 'alphabetic')}
}
''';

  String _textTheme(String name, String baseline) {
    final theme = StringBuffer('static const TextTheme $name = TextTheme(\n');
    for (final (String styleName, TypescaleStruct token) in _textStyles) {
      theme.writeln(
        '    $styleName: ${_textStyleDef(token, '$name $styleName $_typographyYear', baseline)},',
      );
    }
    theme.write('  );');
    return theme.toString();
  }

  String _textStyleDef(TypescaleStruct typescaleStruct, String debugLabel, String baseline) {
    final style = StringBuffer("TextStyle(debugLabel: '$debugLabel'");
    style.write(', inherit: false');
    style.write(', fontSize: ${_fontSize(typescaleStruct)}');
    style.write(', fontWeight: ${_fontWeight(typescaleStruct)}');
    style.write(', letterSpacing: ${_fontSpacing(typescaleStruct)}');
    style.write(', height: ${_fontHeight(typescaleStruct)}');
    style.write(', textBaseline: TextBaseline.$baseline');
    style.write(', leadingDistribution: TextLeadingDistribution.even');
    style.write(')');
    return style.toString();
  }

  String _fontSize(TypescaleStruct typescaleStruct) {
    return number(typescaleStruct.fontSize);
  }

  String _fontWeight(TypescaleStruct typescaleStruct) {
    final double weightValue = typescaleStruct.fontWeight;
    return 'FontWeight.w${weightValue.toInt()}';
  }

  String _fontSpacing(TypescaleStruct typescaleStruct) {
    return number(typescaleStruct.letterSpacing);
  }

  String _fontHeight(TypescaleStruct typescaleStruct) {
    final double size = typescaleStruct.fontSize;
    final double lineHeight = typescaleStruct.lineHeight;
    return (lineHeight / size).toStringAsFixed(2);
  }
}

class TypographyTemplateM3 extends TokenTemplateM3 with TypographyTokenMixin {
  const TypographyTemplateM3();

  @override
  String get className => '_M3Typography';

  @override
  String get _typographyYear => '2021';

  @override
  List<(String, TypescaleStruct)> get _textStyles => _baseTextStyles;
}

class TypographyTemplateM3E extends TokenTemplateM3E with TypographyTokenMixin {
  const TypographyTemplateM3E();

  @override
  String get className => '_M3ETypography';

  @override
  String get _typographyYear => '2025';

  @override
  List<(String, TypescaleStruct)> get _textStyles => <(String, TypescaleStruct)>[
    ..._baseTextStyles,
    ..._emphasizedTextStyles,
  ];
}
