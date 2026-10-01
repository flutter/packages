// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/color_role.dart';
import '../data/list.dart';
import 'template.dart';

class ListTileTemplateM3 extends TokenTemplateM3 {
  const ListTileTemplateM3();

  @override
  String get name => 'List Tile';

  @override
  String get parentFilePath => 'list_tile.dart';

  // The selected trailing-icon token differs from the existing ListTile
  // default. Preserve the existing color during this template migration.
  static const TokenColorRole _legacySelectedColor = TokenColorRole.primary;

  @override
  String get className => '_ListTileDefaultsM3';

  @override
  String generateContents(String className) =>
      '''
class $className extends ListTileThemeData {
  $className(this.context)
    : super(
        contentPadding: const EdgeInsetsDirectional.only(start: 16.0, end: 24.0),
        minLeadingWidth: ${TokenList.listItemLeadingIconSize},
        minVerticalPadding: 8,
        shape: ${shape(TokenList.listItemContainerShape)},
      );

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;
  late final TextTheme _textTheme = _theme.textTheme;

  @override
  Color? get tileColor => Colors.transparent;

  @override
  TextStyle? get titleTextStyle => ${textStyle(TokenList.listItemLabelTextType, '_textTheme')}!.copyWith(color: ${color(TokenList.listItemLabelTextColor)});

  @override
  TextStyle? get subtitleTextStyle => ${textStyle(TokenList.listItemSupportingTextType, '_textTheme')}!.copyWith(color: ${color(TokenList.listItemSupportingTextColor)});

  @override
  TextStyle? get leadingAndTrailingTextStyle => ${textStyle(TokenList.listItemTrailingSupportingTextType, '_textTheme')}!.copyWith(color: ${color(TokenList.listItemTrailingSupportingTextColor)});

  @override
  Color? get selectedColor => ${color(_legacySelectedColor)};

  @override
  Color? get iconColor => ${color(TokenList.listItemTrailingIconColor)};
}
''';
}
