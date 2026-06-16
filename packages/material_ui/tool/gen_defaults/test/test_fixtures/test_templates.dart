// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../../templates/template.dart';
import 'button_token_data.dart';

class M3EButtonTemplate extends M3ETokenTemplate {
  M3EButtonTemplate(this.customMaterialLib);

  final String customMaterialLib;

  @override
  String get name => 'button';

  @override
  String get materialLib => customMaterialLib;

  @override
  String generateContents(String className) {
    return '''
class $className {
  static const double height = ${TokenButton.height};
  static const double borderRadius = ${TokenButton.borderRadius};
}
''';
  }
}

class M3ButtonTemplate extends M3TokenTemplate {
  M3ButtonTemplate(this.customMaterialLib);

  final String customMaterialLib;

  @override
  String get name => 'button';

  @override
  String get materialLib => customMaterialLib;

  @override
  String generateContents(String className) {
    return '''
class $className {
  static const double height = ${TokenButton.height};
  static const double borderRadius = ${TokenButton.borderRadius};
}
''';
  }
}

class UnformattedTemplate extends M3TokenTemplate {
  UnformattedTemplate(this.customMaterialLib);

  final String customMaterialLib;

  @override
  String get name => 'unformatted';

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
  String get name => 'invalid';

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
