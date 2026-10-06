// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/divider.dart';
import '../data/primary_navigation_tab.dart';
import '../data/secondary_navigation_tab.dart';
import 'template.dart';

class TabsTemplateM3 extends TokenTemplateM3 {
  const TabsTemplateM3();

  @override
  String get name => 'Tabs';

  @override
  String get parentFilePath => 'tabs.dart';

  @override
  String generateContents(String className) =>
      '''
class _TabsPrimaryDefaultsM3 extends TabBarThemeData {
  _TabsPrimaryDefaultsM3(this.context, this.isScrollable)
    : super(indicatorSize: TabBarIndicatorSize.label);

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;
  final bool isScrollable;

  // This value comes from Divider widget defaults. Token db deprecated 'primary-navigation-tab.divider.color' token.
  @override
  Color? get dividerColor => ${color(TokenDivider.color)};

  // This value comes from Divider widget defaults. Token db deprecated 'primary-navigation-tab.divider.height' token.
  @override
  double? get dividerHeight => ${number(TokenDivider.thickness)};

  @override
  Color? get indicatorColor => ${colorWithOpacity(TokenPrimaryNavigationTab.activeFocusStateLayerColor, TokenPrimaryNavigationTab.activeFocusStateLayerOpacity)};

  @override
  Color? get labelColor => ${color(TokenPrimaryNavigationTab.withLabelTextActiveLabelTextColor)};

  @override
  TextStyle? get labelStyle => ${textStyle(TokenPrimaryNavigationTab.withLabelTextLabelTextType, '_textTheme')};

  @override
  Color? get unselectedLabelColor => ${color(TokenPrimaryNavigationTab.withLabelTextInactiveLabelTextColor)};

  @override
  TextStyle? get unselectedLabelStyle => ${textStyle(TokenPrimaryNavigationTab.withLabelTextLabelTextType, '_textTheme')};

  @override
  WidgetStateProperty<Color?> get overlayColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.pressed)) {
          return ${colorWithOpacity(TokenPrimaryNavigationTab.activePressedStateLayerColor, TokenPrimaryNavigationTab.activePressedStateLayerOpacity)};
        }
        if (states.contains(WidgetState.hovered)) {
          return ${colorWithOpacity(TokenPrimaryNavigationTab.activeHoverStateLayerColor, TokenPrimaryNavigationTab.activeHoverStateLayerOpacity)};
        }
        if (states.contains(WidgetState.focused)) {
          return ${colorWithOpacity(TokenPrimaryNavigationTab.activeFocusStateLayerColor, TokenPrimaryNavigationTab.activeFocusStateLayerOpacity)};
        }
        return null;
      }
      if (states.contains(WidgetState.pressed)) {
        return ${colorWithOpacity(TokenPrimaryNavigationTab.inactivePressedStateLayerColor, TokenPrimaryNavigationTab.inactivePressedStateLayerOpacity)};
      }
      if (states.contains(WidgetState.hovered)) {
        return ${colorWithOpacity(TokenPrimaryNavigationTab.inactiveHoverStateLayerColor, TokenPrimaryNavigationTab.inactiveHoverStateLayerOpacity)};
      }
      if (states.contains(WidgetState.focused)) {
        return ${colorWithOpacity(TokenPrimaryNavigationTab.inactiveFocusStateLayerColor, TokenPrimaryNavigationTab.inactiveFocusStateLayerOpacity)};
      }
      return null;
    });
  }

  @override
  InteractiveInkFeatureFactory? get splashFactory => Theme.of(context).splashFactory;

  @override
  TabAlignment? get tabAlignment => isScrollable ? TabAlignment.startOffset : TabAlignment.fill;

  static double indicatorWeight(TabBarIndicatorSize indicatorSize) {
    return switch (indicatorSize) {
      TabBarIndicatorSize.label => ${number(TokenPrimaryNavigationTab.activeIndicatorHeight)},
      TabBarIndicatorSize.tab   => ${number(TokenSecondaryNavigationTab.activeIndicatorHeight)},
    };
  }

  // TODO(davidmartos96): This value doesn't currently exist in
  // https://m3.material.io/components/tabs/specs
  // Update this when the token is available.
  static const EdgeInsetsGeometry iconMargin = EdgeInsets.only(bottom: 2);
}

class _TabsSecondaryDefaultsM3 extends TabBarThemeData {
  _TabsSecondaryDefaultsM3(this.context, this.isScrollable)
    : super(indicatorSize: TabBarIndicatorSize.tab);

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;
  final bool isScrollable;

  // This value comes from Divider widget defaults. Token db deprecated 'secondary-navigation-tab.divider.color' token.
  @override
  Color? get dividerColor => ${color(TokenDivider.color)};

  // This value comes from Divider widget defaults. Token db deprecated 'secondary-navigation-tab.divider.height' token.
  @override
  double? get dividerHeight => ${number(TokenDivider.thickness)};

  @override
  Color? get indicatorColor => ${color(TokenSecondaryNavigationTab.activeIndicatorColor)};

  @override
  Color? get labelColor => ${color(TokenSecondaryNavigationTab.activeLabelTextColor)};

  @override
  TextStyle? get labelStyle => ${textStyle(TokenSecondaryNavigationTab.labelTextType, '_textTheme')};

  @override
  Color? get unselectedLabelColor => ${color(TokenSecondaryNavigationTab.inactiveLabelTextColor)};

  @override
  TextStyle? get unselectedLabelStyle => ${textStyle(TokenSecondaryNavigationTab.labelTextType, '_textTheme')};

  @override
  WidgetStateProperty<Color?> get overlayColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.pressed)) {
          return ${colorWithOpacity(TokenSecondaryNavigationTab.pressedStateLayerColor, TokenSecondaryNavigationTab.pressedStateLayerOpacity)};
        }
        if (states.contains(WidgetState.hovered)) {
          return ${colorWithOpacity(TokenSecondaryNavigationTab.hoverStateLayerColor, TokenSecondaryNavigationTab.hoverStateLayerOpacity)};
        }
        if (states.contains(WidgetState.focused)) {
          return ${colorWithOpacity(TokenSecondaryNavigationTab.focusStateLayerColor, TokenSecondaryNavigationTab.focusStateLayerOpacity)};
        }
        return null;
      }
      if (states.contains(WidgetState.pressed)) {
        return ${colorWithOpacity(TokenSecondaryNavigationTab.pressedStateLayerColor, TokenSecondaryNavigationTab.pressedStateLayerOpacity)};
      }
      if (states.contains(WidgetState.hovered)) {
        return ${colorWithOpacity(TokenSecondaryNavigationTab.hoverStateLayerColor, TokenSecondaryNavigationTab.hoverStateLayerOpacity)};
      }
      if (states.contains(WidgetState.focused)) {
        return ${colorWithOpacity(TokenSecondaryNavigationTab.focusStateLayerColor, TokenSecondaryNavigationTab.focusStateLayerOpacity)};
      }
      return null;
    });
  }

  @override
  InteractiveInkFeatureFactory? get splashFactory => Theme.of(context).splashFactory;

  @override
  TabAlignment? get tabAlignment => isScrollable ? TabAlignment.startOffset : TabAlignment.fill;

  static double indicatorWeight = ${number(TokenSecondaryNavigationTab.activeIndicatorHeight)};
}
''';
}
