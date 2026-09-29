// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/color_role.dart';
import '../data/navigation_bar.dart';
import 'template.dart';

class NavigationBarTemplateM3 extends TokenTemplateM3 {
  const NavigationBarTemplateM3();

  @override
  String get name => 'Navigation Bar';

  @override
  String get parentFilePath => 'navigation_bar.dart';

  // Disabled-state tokens are not currently available. Preserve the existing
  // defaults during this template migration.
  static const TokenColorRole _legacyDisabledColor = TokenColorRole.onSurfaceVariant;
  static const double _legacyDisabledOpacity = 0.38;

  @override
  String generateContents(String className) =>
      '''
class $className extends NavigationBarThemeData {
  $className(this.context)
    : super(
        height: ${number(TokenNavigationBar.containerHeight)},
        elevation: ${number(TokenNavigationBar.containerElevation)},
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor => ${color(TokenNavigationBar.containerColor)};

  @override
  Color? get shadowColor => Colors.transparent;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  WidgetStateProperty<IconThemeData?>? get iconTheme {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      return IconThemeData(
        size: ${number(TokenNavigationBar.iconSize)},
        color: states.contains(WidgetState.disabled)
          ? ${colorWithOpacity(_legacyDisabledColor, _legacyDisabledOpacity)}
          : states.contains(WidgetState.selected)
            ? ${color(TokenNavigationBar.activeIconColor)}
            : ${color(TokenNavigationBar.inactiveIconColor)},
      );
    });
  }

  @override
  Color? get indicatorColor => ${color(TokenNavigationBar.activeIndicatorColor)};

  @override
  ShapeBorder? get indicatorShape => ${shape(TokenNavigationBar.activeIndicatorShape)};

  @override
  WidgetStateProperty<TextStyle?>? get labelTextStyle {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      final TextStyle style = ${textStyle(TokenNavigationBar.labelTextType, '_textTheme')}!;
      return style.apply(
        color: states.contains(WidgetState.disabled)
          ? ${colorWithOpacity(_legacyDisabledColor, _legacyDisabledOpacity)}
          : states.contains(WidgetState.selected)
            ? ${color(TokenNavigationBar.activeLabelTextColor)}
            : ${color(TokenNavigationBar.inactiveLabelTextColor)},
      );
    });
  }

  @override
  EdgeInsetsGeometry? get labelPadding => const EdgeInsets.only(top: 4);
}
''';
}
