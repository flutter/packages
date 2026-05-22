// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../../templates/template.dart';
import 'button_token_data.dart';

class ButtonTemplate extends TokenTemplate {
  ButtonTemplate(this.customMaterialLib);

  final String customMaterialLib;

  @override
  String get name => 'button';

  @override
  String get materialLib => customMaterialLib;

  @override
  String generateContents() {
    return '''
abstract final class _ButtonDefaults {
  static const double height = ${TokenButton.height};
  static const double borderRadius = ${TokenButton.borderRadius};
}
''';
  }
}
