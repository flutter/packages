// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../../templates/template.dart';
import 'icon_button_token_data.dart';

class M3EIconButtonTemplate extends M3ETokenTemplate {
  M3EIconButtonTemplate(this.customMaterialLib);

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

class M3IconButtonTemplate extends M3TokenTemplate {
  M3IconButtonTemplate(this.customMaterialLib);

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

class UnformattedTemplate extends M3TokenTemplate {
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

class InvalidTemplate extends M3TokenTemplate {
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

class SnakeCaseNameTemplate extends M3TokenTemplate {
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
