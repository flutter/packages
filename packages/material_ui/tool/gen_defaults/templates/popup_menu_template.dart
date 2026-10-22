// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/list.dart';
import '../data/menu.dart';
import 'template.dart';

class PopupMenuTemplateM3 extends TokenTemplateM3 {
  const PopupMenuTemplateM3();

  @override
  String get name => 'Popup Menu';

  @override
  String get parentFilePath => 'popup_menu.dart';

  @override
  String generateContents(String className) =>
      '''
class $className extends PopupMenuThemeData {
  $className(this.context)
    : super(elevation: ${TokenMenu.containerElevation});

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;
  late final TextTheme _textTheme = _theme.textTheme;

  @override WidgetStateProperty<TextStyle?>? get labelTextStyle {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
    // TODO(quncheng): Update this hard-coded value to use the latest tokens.
    final TextStyle style = _textTheme.labelLarge!;
      if (states.contains(WidgetState.disabled)) {
        return style.apply(color: ${colorWithOpacity(TokenList.listItemDisabledLabelTextColor, TokenList.listItemDisabledLabelTextOpacity)});
      }
      return style.apply(color: ${color(TokenList.listItemLabelTextColor)});
    });
  }

  @override
  Color? get color => ${color(TokenMenu.containerColor)};

  @override
  Color? get shadowColor => ${color(TokenMenu.containerShadowColor)};

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  ShapeBorder? get shape => ${shape(TokenMenu.containerShape)};

  // TODO(bleroux): This is taken from https://m3.material.io/components/menus/specs
  // Update this when the token is available.
  @override
  EdgeInsets? get menuPadding => const EdgeInsets.symmetric(vertical: 8.0);

  // TODO(tahatesser): This is taken from https://m3.material.io/components/menus/specs
  // Update this when the token is available.
  static EdgeInsets menuItemPadding  = const EdgeInsets.symmetric(horizontal: 12.0);
}''';
}
