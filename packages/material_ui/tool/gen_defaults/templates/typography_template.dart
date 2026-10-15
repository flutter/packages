// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/typescale.dart';
import '../data/typescale_struct.dart';
import 'template.dart';

class TypographyTemplateM3 extends TokenTemplateM3 {
  const TypographyTemplateM3();

  @override
  String get name => 'Typography';

  @override
  String get parentFilePath => 'typography.dart';

  @override
  String get className => '_M3Typography';

  static const List<(String, TypescaleStruct)> _textStyles = <(String, TypescaleStruct)>[
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
      theme.writeln('    $styleName: ${_textStyleDef(token, '$name $styleName 2021', baseline)},');
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
