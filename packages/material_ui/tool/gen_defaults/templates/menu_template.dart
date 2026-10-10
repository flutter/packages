// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/list.dart';
import '../data/menu.dart';
import 'template.dart';

class MenuTemplateM3 extends TokenTemplateM3 {
  const MenuTemplateM3();

  @override
  String get name => 'Menu';

  @override
  String get parentFilePath => 'menu_anchor.dart';

  @override
  String generateContents(String className) =>
      '''
class _MenuBarDefaultsM3 extends MenuStyle {
  _MenuBarDefaultsM3(this.context)
    : super(
      elevation: const MaterialStatePropertyAll<double?>(${number(TokenMenu.containerElevation)}),
      shape: const MaterialStatePropertyAll<OutlinedBorder>(_defaultMenuBorder),
      alignment: AlignmentDirectional.bottomStart,
    );

  static const RoundedRectangleBorder _defaultMenuBorder =
    ${shape(TokenMenu.containerShape, '')};

  final BuildContext context;

  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  WidgetStateProperty<Color?> get backgroundColor {
    return MaterialStatePropertyAll<Color?>(${color(TokenMenu.containerColor)});
  }

  @override
  WidgetStateProperty<Color?>? get shadowColor {
    return MaterialStatePropertyAll<Color?>(${color(TokenMenu.containerShadowColor)});
  }

  @override
  WidgetStateProperty<Color?>? get surfaceTintColor {
    return const MaterialStatePropertyAll<Color?>(Colors.transparent);
  }

  @override
  WidgetStateProperty<EdgeInsetsGeometry?>? get padding {
    return const MaterialStatePropertyAll<EdgeInsetsGeometry>(
      EdgeInsetsDirectional.symmetric(
        horizontal: _kTopLevelMenuHorizontalMinPadding
      ),
    );
  }

  @override
  VisualDensity get visualDensity => Theme.of(context).visualDensity;
}

class _MenuButtonDefaultsM3 extends ButtonStyle {
  _MenuButtonDefaultsM3(this.context)
    : super(
      animationDuration: kThemeChangeDuration,
      enableFeedback: true,
      alignment: AlignmentDirectional.centerStart,
    );

  final BuildContext context;

  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  WidgetStateProperty<Color?>? get backgroundColor {
    return ButtonStyleButton.allOrNull<Color>(Colors.transparent);
  }

  // No default shadow color

  // No default surface tint color

  @override
  WidgetStateProperty<double>? get elevation {
    return ButtonStyleButton.allOrNull<double>(0.0);
  }

  @override
  WidgetStateProperty<Color?>? get foregroundColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return ${colorWithOpacity(TokenList.listItemDisabledLabelTextColor, TokenList.listItemDisabledLabelTextOpacity)};
      }
      if (states.contains(WidgetState.pressed)) {
        return ${color(TokenList.listItemPressedLabelTextColor)};
      }
      if (states.contains(WidgetState.hovered)) {
        return ${color(TokenList.listItemHoverLabelTextColor)};
      }
      if (states.contains(WidgetState.focused)) {
        return ${color(TokenList.listItemFocusLabelTextColor)};
      }
      return ${color(TokenList.listItemLabelTextColor)};
    });
  }

  @override
  WidgetStateProperty<Color?>? get iconColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return ${colorWithOpacity(TokenList.listItemDisabledLeadingIconColor, TokenList.listItemDisabledLeadingIconOpacity)};
      }
      if (states.contains(WidgetState.pressed)) {
        return ${color(TokenList.listItemPressedLeadingIconIconColor)};
      }
      if (states.contains(WidgetState.hovered)) {
        return ${color(TokenList.listItemHoverLeadingIconIconColor)};
      }
      if (states.contains(WidgetState.focused)) {
        return ${color(TokenList.listItemFocusLeadingIconIconColor)};
      }
      return ${color(TokenList.listItemLeadingIconColor)};
    });
  }

  // No default fixedSize

  @override
  WidgetStateProperty<double>? get iconSize {
    return const MaterialStatePropertyAll<double>(${number(TokenList.listItemLeadingIconSize)});
  }

  @override
  WidgetStateProperty<Size>? get maximumSize {
    return ButtonStyleButton.allOrNull<Size>(Size.infinite);
  }

  @override
  WidgetStateProperty<Size>? get minimumSize {
    return ButtonStyleButton.allOrNull<Size>(const Size(64.0, 48.0));
  }

  @override
  WidgetStateProperty<MouseCursor?>? get mouseCursor => WidgetStateMouseCursor.adaptiveClickable;

  @override
  WidgetStateProperty<Color?>? get overlayColor {
    return WidgetStateProperty.resolveWith(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return ${colorWithOpacity(TokenList.listItemPressedStateLayerColor, TokenList.listItemPressedStateLayerOpacity)};
        }
        if (states.contains(WidgetState.hovered)) {
          return ${colorWithOpacity(TokenList.listItemHoverStateLayerColor, TokenList.listItemHoverStateLayerOpacity)};
        }
        if (states.contains(WidgetState.focused)) {
          return ${colorWithOpacity(TokenList.listItemFocusStateLayerColor, TokenList.listItemFocusStateLayerOpacity)};
        }
        return Colors.transparent;
      },
    );
  }

  @override
  WidgetStateProperty<EdgeInsetsGeometry>? get padding {
    return ButtonStyleButton.allOrNull<EdgeInsetsGeometry>(_scaledPadding(context));
  }

  // No default side

  @override
  WidgetStateProperty<OutlinedBorder>? get shape {
    return ButtonStyleButton.allOrNull<OutlinedBorder>(const RoundedRectangleBorder());
  }

  @override
  InteractiveInkFeatureFactory? get splashFactory => Theme.of(context).splashFactory;

  @override
  MaterialTapTargetSize? get tapTargetSize => Theme.of(context).materialTapTargetSize;

  @override
  WidgetStateProperty<TextStyle?> get textStyle {
    // TODO(tahatesser): This is taken from https://m3.material.io/components/menus/specs
    // Update this when the token is available.
    return MaterialStatePropertyAll<TextStyle?>(_textTheme.labelLarge);
  }

  @override
  VisualDensity? get visualDensity => Theme.of(context).visualDensity;

  // The horizontal padding number comes from the spec.
  EdgeInsetsGeometry _scaledPadding(BuildContext context) {
    VisualDensity visualDensity = Theme.of(context).visualDensity;
    // When horizontal VisualDensity is greater than zero, set it to zero
    // because the [ButtonStyleButton] has already handle the padding based on the density.
    // However, the [ButtonStyleButton] doesn't allow the [VisualDensity] adjustment
    // to reduce the width of the left/right padding, so we need to handle it here if
    // the density is less than zero, such as on desktop platforms.
    if (visualDensity.horizontal > 0) {
      visualDensity = VisualDensity(vertical: visualDensity.vertical);
    }
    // Since the threshold paddings used below are empirical values determined
    // at a font size of 14.0, 14.0 is used as the base value for scaling the
    // padding.
    final double fontSize = Theme.of(context).textTheme.labelLarge?.fontSize ?? 14.0;
    final double fontSizeRatio = MediaQuery.textScalerOf(context).scale(fontSize) / 14.0;
    return ButtonStyleButton.scaledPadding(
      EdgeInsets.symmetric(horizontal: math.max(
        _kMenuViewPadding,
        _kLabelItemDefaultSpacing + visualDensity.baseSizeAdjustment.dx,
      )),
      EdgeInsets.symmetric(horizontal: math.max(
        _kMenuViewPadding,
        8 + visualDensity.baseSizeAdjustment.dx,
      )),
      const EdgeInsets.symmetric(horizontal: _kMenuViewPadding),
      fontSizeRatio,
    );
  }
}

class $className extends MenuStyle {
  $className(this.context)
    : super(
      elevation: const MaterialStatePropertyAll<double?>(${number(TokenMenu.containerElevation)}),
      shape: const MaterialStatePropertyAll<OutlinedBorder>(_defaultMenuBorder),
      alignment: AlignmentDirectional.topEnd,
    );

  static const RoundedRectangleBorder _defaultMenuBorder =
    ${shape(TokenMenu.containerShape, '')};

  final BuildContext context;

  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  WidgetStateProperty<Color?> get backgroundColor {
    return MaterialStatePropertyAll<Color?>(${color(TokenMenu.containerColor)});
  }

  @override
  WidgetStateProperty<Color?>? get surfaceTintColor {
    return const MaterialStatePropertyAll<Color?>(Colors.transparent);
  }

  @override
  WidgetStateProperty<Color?>? get shadowColor {
    return MaterialStatePropertyAll<Color?>(${color(TokenMenu.containerShadowColor)});
  }

  @override
  WidgetStateProperty<EdgeInsetsGeometry?>? get padding {
    return const MaterialStatePropertyAll<EdgeInsetsGeometry>(
      EdgeInsetsDirectional.symmetric(vertical: _kMenuVerticalMinPadding),
    );
  }

  @override
  VisualDensity get visualDensity => Theme.of(context).visualDensity;
}
''';
}
