// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../../templates/template.dart';
import 'icon_button_token_data.dart';

class IconButtonTemplateM3E extends TokenTemplateM3E {
  IconButtonTemplateM3E(this.customMaterialLib);

  final String customMaterialLib;

  @override
  String get name => 'Icon Button';

  @override
  String get parentFilePath => 'icon_button.dart';

  @override
  String get materialLib => customMaterialLib;

  @override
  String generateContents(String className) {
    return '''
class $className {
  static const double height = ${TokenIconButton.height};
  static const double borderRadius = ${TokenIconButton.borderRadius};
}
''';
  }
}

class IconButtonTemplateM3 extends TokenTemplateM3 {
  IconButtonTemplateM3(this.customMaterialLib);

  final String customMaterialLib;

  @override
  String get name => 'Icon Button';

  @override
  String get parentFilePath => 'icon_button.dart';

  @override
  String get materialLib => customMaterialLib;

  @override
  String generateContents(String className) {
    return '''
class $className {
  $className(this.context);

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  static const double height = ${TokenIconButton.height};
  static const double borderRadius = ${TokenIconButton.borderRadius};
  Color get iconColor => ${color(TokenIconButton.iconColor, '_colors')};
  Color get disabledIconColor =>
      ${colorWithOpacity(TokenIconButton.disabledIconColor, TokenIconButton.disabledIconOpacity, '_colors')};
  Color get hoveredStateLayerColor =>
      ${colorWithOpacity(TokenIconButton.hoveredStateLayerColor, TokenIconButton.hoveredStateLayerOpacity, '_colors')};
  OutlinedBorder get shape => ${shape(TokenIconButton.pressedContainerShape)};
}
''';
  }
}

class UnformattedTemplate extends TokenTemplateM3 {
  UnformattedTemplate(this.customMaterialLib);

  final String customMaterialLib;

  @override
  String get name => 'Unformatted';

  @override
  String get parentFilePath => 'unformatted.dart';

  @override
  String get materialLib => customMaterialLib;

  @override
  String generateContents(String className) {
    return '''
class   $className   {
final    int    x = 1  ;
  final String y   =   'hello' ;
}
''';
  }
}

class InvalidTemplate extends TokenTemplateM3 {
  InvalidTemplate(this.customMaterialLib);

  final String customMaterialLib;

  @override
  String get name => 'Invalid';

  @override
  String get parentFilePath => 'invalid.dart';

  @override
  String get materialLib => customMaterialLib;

  @override
  String generateContents(String className) {
    return '''
class _SomeOtherClassNameDefaults {
  final int x = 1;
}
''';
  }
}

class SnakeCaseNameTemplate extends TokenTemplateM3 {
  SnakeCaseNameTemplate(this.customMaterialLib);

  final String customMaterialLib;

  @override
  String get name => 'snake_case_name';

  @override
  String get parentFilePath => 'snake_case_name.dart';

  @override
  String get materialLib => customMaterialLib;

  @override
  String generateContents(String className) => '';
}
