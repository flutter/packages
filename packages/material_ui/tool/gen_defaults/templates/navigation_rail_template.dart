// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/navigation_rail.dart';
import 'template.dart';

class NavigationRailTemplateM3 extends TokenTemplateM3 {
  const NavigationRailTemplateM3();

  @override
  String get name => 'Navigation Rail';

  @override
  String get parentFilePath => 'navigation_rail.dart';

  @override
  String generateContents(String className) =>
      '''
class $className extends NavigationRailThemeData {
  $className(this.context)
    : super(
        elevation: ${number(TokenNavigationRail.containerElevation)},
        groupAlignment: -1,
        labelType: NavigationRailLabelType.none,
        useIndicator: true,
        minWidth: ${number(TokenNavigationRail.containerWidth)},
        minExtendedWidth: 256,
      );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor => ${color(TokenNavigationRail.containerColor)};

  @override
  TextStyle? get unselectedLabelTextStyle {
    return ${textStyle(TokenNavigationRail.labelTextType, '_textTheme')}!.copyWith(color: ${color(TokenNavigationRail.inactiveFocusLabelTextColor)});
  }

  @override
  TextStyle? get selectedLabelTextStyle {
    return ${textStyle(TokenNavigationRail.labelTextType, '_textTheme')}!.copyWith(color: ${color(TokenNavigationRail.activeFocusLabelTextColor)});
  }

  @override
  IconThemeData? get unselectedIconTheme {
    return IconThemeData(
      size: ${number(TokenNavigationRail.iconSize)},
      color: ${color(TokenNavigationRail.inactiveIconColor)},
    );
  }

  @override
  IconThemeData? get selectedIconTheme {
    return IconThemeData(
      size: ${number(TokenNavigationRail.iconSize)},
      color: ${color(TokenNavigationRail.activeIconColor)},
    );
  }

  @override
  Color? get indicatorColor => ${color(TokenNavigationRail.activeIndicatorColor)};

  @override
  ShapeBorder? get indicatorShape => ${shape(TokenNavigationRail.activeIndicatorShape)};
}
''';
}
