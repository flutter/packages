// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/color_role.dart';
import '../data/navigation_drawer.dart';
import 'template.dart';

class NavigationDrawerTemplateM3 extends TokenTemplateM3 {
  const NavigationDrawerTemplateM3();

  @override
  String get name => 'Navigation Drawer';

  @override
  String get parentFilePath => 'navigation_drawer.dart';

  // Disabled-state tokens are not currently available. Preserve the existing
  // defaults during this template migration.
  static const TokenColorRole _legacyDisabledColor = TokenColorRole.onSurfaceVariant;
  static const double _legacyDisabledOpacity = 0.38;

  @override
  String generateContents(String className) =>
      '''
class $className extends NavigationDrawerThemeData {
  $className(this.context)
    : super(
        elevation: ${number(TokenNavigationDrawer.modalContainerElevation)},
        tileHeight: ${number(TokenNavigationDrawer.activeIndicatorHeight)},
        indicatorShape: ${shape(TokenNavigationDrawer.activeIndicatorShape)},
        indicatorSize: const Size(${number(TokenNavigationDrawer.activeIndicatorWidth)}, ${number(TokenNavigationDrawer.activeIndicatorHeight)}),
      );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor => ${color(TokenNavigationDrawer.modalContainerColor)};

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  Color? get shadowColor => Colors.transparent;

  @override
  Color? get indicatorColor => ${color(TokenNavigationDrawer.activeIndicatorColor)};

  @override
  WidgetStateProperty<IconThemeData?>? get iconTheme {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      return IconThemeData(
        size: ${number(TokenNavigationDrawer.iconSize)},
        color: states.contains(WidgetState.disabled)
          ? ${colorWithOpacity(_legacyDisabledColor, _legacyDisabledOpacity)}
          : states.contains(WidgetState.selected)
            ? ${color(TokenNavigationDrawer.activeIconColor)}
            : ${color(TokenNavigationDrawer.inactiveIconColor)},
      );
    });
  }

  @override
  WidgetStateProperty<TextStyle?>? get labelTextStyle {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      final TextStyle style = ${textStyle(TokenNavigationDrawer.labelTextType, '_textTheme')}!;
      return style.apply(
        color: states.contains(WidgetState.disabled)
          ? ${colorWithOpacity(_legacyDisabledColor, _legacyDisabledOpacity)}
          : states.contains(WidgetState.selected)
            ? ${color(TokenNavigationDrawer.activeLabelTextColor)}
            : ${color(TokenNavigationDrawer.inactiveLabelTextColor)},
      );
    });
  }
}
''';
}
