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
    theme.writeln(
      '    displayLarge: ${_textStyleDef(TokenTypescale.displayLarge, '$name displayLarge 2021', baseline)},',
    );
    theme.writeln(
      '    displayMedium: ${_textStyleDef(TokenTypescale.displayMedium, '$name displayMedium 2021', baseline)},',
    );
    theme.writeln(
      '    displaySmall: ${_textStyleDef(TokenTypescale.displaySmall, '$name displaySmall 2021', baseline)},',
    );
    theme.writeln(
      '    headlineLarge: ${_textStyleDef(TokenTypescale.headlineLarge, '$name headlineLarge 2021', baseline)},',
    );
    theme.writeln(
      '    headlineMedium: ${_textStyleDef(TokenTypescale.headlineMedium, '$name headlineMedium 2021', baseline)},',
    );
    theme.writeln(
      '    headlineSmall: ${_textStyleDef(TokenTypescale.headlineSmall, '$name headlineSmall 2021', baseline)},',
    );
    theme.writeln(
      '    titleLarge: ${_textStyleDef(TokenTypescale.titleLarge, '$name titleLarge 2021', baseline)},',
    );
    theme.writeln(
      '    titleMedium: ${_textStyleDef(TokenTypescale.titleMedium, '$name titleMedium 2021', baseline)},',
    );
    theme.writeln(
      '    titleSmall: ${_textStyleDef(TokenTypescale.titleSmall, '$name titleSmall 2021', baseline)},',
    );
    theme.writeln(
      '    labelLarge: ${_textStyleDef(TokenTypescale.labelLarge, '$name labelLarge 2021', baseline)},',
    );
    theme.writeln(
      '    labelMedium: ${_textStyleDef(TokenTypescale.labelMedium, '$name labelMedium 2021', baseline)},',
    );
    theme.writeln(
      '    labelSmall: ${_textStyleDef(TokenTypescale.labelSmall, '$name labelSmall 2021', baseline)},',
    );
    theme.writeln(
      '    bodyLarge: ${_textStyleDef(TokenTypescale.bodyLarge, '$name bodyLarge 2021', baseline)},',
    );
    theme.writeln(
      '    bodyMedium: ${_textStyleDef(TokenTypescale.bodyMedium, '$name bodyMedium 2021', baseline)},',
    );
    theme.writeln(
      '    bodySmall: ${_textStyleDef(TokenTypescale.bodySmall, '$name bodySmall 2021', baseline)},',
    );
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
