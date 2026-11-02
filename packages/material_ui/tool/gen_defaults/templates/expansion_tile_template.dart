// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/color_role.dart';
import '../data/list.dart';
import 'template.dart';

class ExpansionTileTemplateM3 extends TokenTemplateM3 {
  const ExpansionTileTemplateM3();

  @override
  String get name => 'Expansion Tile';

  @override
  String get parentFilePath => 'expansion_tile.dart';

  @override
  String generateContents(String className) =>
      '''
class $className extends ExpansionTileThemeData {
  $className(this.context);

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;

  @override
  Color? get textColor => ${color(TokenList.listItemLabelTextColor)};

  @override
  Color? get iconColor => ${color(TokenColorRole.primary)};

  @override
  Color? get collapsedTextColor => ${color(TokenList.listItemLabelTextColor)};

  @override
  Color? get collapsedIconColor => ${color(TokenList.listItemTrailingIconColor)};
}
''';
}
