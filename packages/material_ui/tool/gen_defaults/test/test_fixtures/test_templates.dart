// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../../templates/template.dart';
import 'button_token_data.dart';

class ButtonTemplate extends M3ETokenTemplate {
  ButtonTemplate(this.customMaterialLib);

  final String customMaterialLib;

  @override
  String get name => 'button';

  @override
  String get materialLib => customMaterialLib;

  @override
  String generateContents() {
    return '''
class _ButtonDefaults {
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
  String generateContents() {
    return '''
class   UnformattedClass   {
final    int    x = 1  ;
  final String y   =   'hello' ;
}
''';
  }
}

class TestM3Template extends M3TokenTemplate {
  @override
  String get name => 'm3';

  @override
  String generateContents() => '';
}

class TestM3ExpressiveTemplate extends M3ETokenTemplate {
  @override
  String get name => 'm3e';

  @override
  String generateContents() => '';
}
