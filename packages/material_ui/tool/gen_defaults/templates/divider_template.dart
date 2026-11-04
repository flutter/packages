// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/divider.dart';
import 'template.dart';

class DividerTemplateM3 extends TokenTemplateM3 {
  const DividerTemplateM3();

  @override
  String get name => 'Divider';

  @override
  String get parentFilePath => 'divider.dart';

  @override
  String generateContents(String className) =>
      '''
class $className extends DividerThemeData {
  const $className(this.context) : super(
    space: 16,
    thickness: ${TokenDivider.thickness},
    indent: 0,
    endIndent: 0,
  );

  final BuildContext context;

  @override Color? get color => ${color(TokenDivider.color, 'Theme.of(context).colorScheme')};
}
''';
}
