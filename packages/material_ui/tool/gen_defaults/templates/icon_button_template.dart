// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/color_role.dart';
import '../data/icon_button.dart';
import '../data/icon_button_filled.dart';
import '../data/icon_button_outlined.dart';
import '../data/icon_button_standard.dart';
import '../data/icon_button_tonal.dart';
import 'template.dart';

enum _IconButtonVariant { standard, filled, filledTonal, outlined }

class IconButtonTemplateM3 extends TokenTemplateM3 {
  const IconButtonTemplateM3(this.name);

  @override
  final String name;

  @override
  String get parentFilePath => 'icon_button.dart';

  _IconButtonVariant get _variant => switch (name) {
    'Icon Button' => _IconButtonVariant.standard,
    'Filled Icon Button' => _IconButtonVariant.filled,
    'Filled Tonal Icon Button' => _IconButtonVariant.filledTonal,
    'Outlined Icon Button' => _IconButtonVariant.outlined,
    _ => throw UnsupportedError('Unsupported icon button template name: $name'),
  };

  // The exported md.comp.icon-button.* tokens differ from Flutter's existing
  // M3 icon button defaults. Preserve the old disabled opacity and use direct
  // color roles where needed so this migration does not change the defaults.
  // TODO(QuncCccccc): Replace these values with tokens.
  static const double _legacyDisabledContainerOpacity = 0.12;

  String get _backgroundColor => switch (_variant) {
    _IconButtonVariant.standard => 'const MaterialStatePropertyAll<Color?>(Colors.transparent)',
    _IconButtonVariant.filled =>
      '''
WidgetStateProperty.resolveWith((Set<WidgetState> states) {
  if (states.contains(WidgetState.disabled)) {
    return ${colorWithOpacity(TokenIconButtonFilled.disabledContainerColor, _legacyDisabledContainerOpacity)};
  }
  if (states.contains(WidgetState.selected)) {
    return ${color(TokenIconButtonFilled.selectedContainerColor)};
  }
  if (toggleable) {
    // toggleable but unselected case
    return ${color(TokenColorRole.surfaceContainerHighest)};
  }
  return ${color(TokenIconButtonFilled.containerColor)};
})''',
    _IconButtonVariant.filledTonal =>
      '''
WidgetStateProperty.resolveWith((Set<WidgetState> states) {
  if (states.contains(WidgetState.disabled)) {
    return ${colorWithOpacity(TokenIconButtonTonal.disabledContainerColor, _legacyDisabledContainerOpacity)};
  }
  if (states.contains(WidgetState.selected)) {
    return ${color(TokenColorRole.secondaryContainer)};
  }
  if (toggleable) {
    // toggleable but unselected case
    return ${color(TokenColorRole.surfaceContainerHighest)};
  }
  return ${color(TokenIconButtonTonal.containerColor)};
})''',
    _IconButtonVariant.outlined =>
      '''
WidgetStateProperty.resolveWith((Set<WidgetState> states) {
  if (states.contains(WidgetState.disabled)) {
    if (states.contains(WidgetState.selected)) {
      return ${colorWithOpacity(TokenIconButtonOutlined.selectedDisabledContainerColor, _legacyDisabledContainerOpacity)};
    }
    return Colors.transparent;
  }
  if (states.contains(WidgetState.selected)) {
    return ${color(TokenIconButtonOutlined.selectedContainerColor)};
  }
  return Colors.transparent;
})''',
  };

  String get _foregroundColor => switch (_variant) {
    _IconButtonVariant.standard =>
      '''
WidgetStateProperty.resolveWith((Set<WidgetState> states) {
  if (states.contains(WidgetState.disabled)) {
    return ${colorWithOpacity(TokenIconButtonStandard.disabledIconColor, TokenIconButtonStandard.disabledIconOpacity)};
  }
  if (states.contains(WidgetState.selected)) {
    return ${color(TokenIconButtonStandard.selectedIconColor)};
  }
  return ${color(TokenIconButtonStandard.unselectedIconColor)};
})''',
    _IconButtonVariant.filled =>
      '''
WidgetStateProperty.resolveWith((Set<WidgetState> states) {
  if (states.contains(WidgetState.disabled)) {
    return ${colorWithOpacity(TokenIconButtonFilled.disabledIconColor, TokenIconButtonFilled.disabledIconOpacity)};
  }
  if (states.contains(WidgetState.selected)) {
    return ${color(TokenIconButtonFilled.selectedIconColor)};
  }
  if (toggleable) {
    // toggleable but unselected case
    return ${color(TokenColorRole.primary)};
  }
  return ${color(TokenIconButtonFilled.iconColor)};
})''',
    _IconButtonVariant.filledTonal =>
      '''
WidgetStateProperty.resolveWith((Set<WidgetState> states) {
  if (states.contains(WidgetState.disabled)) {
    return ${colorWithOpacity(TokenIconButtonTonal.disabledIconColor, TokenIconButtonTonal.disabledIconOpacity)};
  }
  if (states.contains(WidgetState.selected)) {
    return ${color(TokenColorRole.onSecondaryContainer)};
  }
  if (toggleable) {
    // toggleable but unselected case
    return ${color(TokenColorRole.onSurfaceVariant)};
  }
  return ${color(TokenIconButtonTonal.iconColor)};
})''',
    _IconButtonVariant.outlined =>
      '''
WidgetStateProperty.resolveWith((Set<WidgetState> states) {
  if (states.contains(WidgetState.disabled)) {
    return ${colorWithOpacity(TokenIconButtonOutlined.disabledIconColor, TokenIconButtonOutlined.disabledIconOpacity)};
  }
  if (states.contains(WidgetState.selected)) {
    return ${color(TokenIconButtonOutlined.selectedIconColor)};
  }
  return ${color(TokenIconButtonOutlined.unselectedIconColor)};
})''',
  };

  String get _overlayColor => switch (_variant) {
    _IconButtonVariant.standard =>
      '''
WidgetStateProperty.resolveWith((Set<WidgetState> states) {
  if (states.contains(WidgetState.selected)) {
    if (states.contains(WidgetState.pressed)) {
      return ${colorWithOpacity(TokenIconButtonStandard.selectedPressedStateLayerColor, TokenIconButtonStandard.pressedStateLayerOpacity)};
    }
    if (states.contains(WidgetState.hovered)) {
      return ${colorWithOpacity(TokenIconButtonStandard.selectedHoveredStateLayerColor, TokenIconButtonStandard.hoveredStateLayerOpacity)};
    }
    if (states.contains(WidgetState.focused)) {
      return ${colorWithOpacity(TokenIconButtonStandard.selectedFocusedStateLayerColor, TokenIconButtonStandard.focusedStateLayerOpacity)};
    }
  }
  if (states.contains(WidgetState.pressed)) {
    return ${colorWithOpacity(TokenIconButtonStandard.unselectedPressedStateLayerColor, TokenIconButtonStandard.pressedStateLayerOpacity)};
  }
  if (states.contains(WidgetState.hovered)) {
    return ${colorWithOpacity(TokenIconButtonStandard.unselectedHoveredStateLayerColor, TokenIconButtonStandard.hoveredStateLayerOpacity)};
  }
  if (states.contains(WidgetState.focused)) {
    return ${colorWithOpacity(TokenIconButtonStandard.unselectedFocusedStateLayerColor, TokenIconButtonStandard.focusedStateLayerOpacity)};
  }
  return Colors.transparent;
})''',
    _IconButtonVariant.filled =>
      '''
WidgetStateProperty.resolveWith((Set<WidgetState> states) {
  if (states.contains(WidgetState.selected)) {
    if (states.contains(WidgetState.pressed)) {
      return ${colorWithOpacity(TokenIconButtonFilled.selectedPressedStateLayerColor, TokenIconButtonFilled.pressedStateLayerOpacity)};
    }
    if (states.contains(WidgetState.hovered)) {
      return ${colorWithOpacity(TokenIconButtonFilled.selectedHoveredStateLayerColor, TokenIconButtonFilled.hoveredStateLayerOpacity)};
    }
    if (states.contains(WidgetState.focused)) {
      return ${colorWithOpacity(TokenIconButtonFilled.selectedFocusedStateLayerColor, TokenIconButtonFilled.focusedStateLayerOpacity)};
    }
  }
  if (toggleable) {
    // toggleable but unselected case
    if (states.contains(WidgetState.pressed)) {
      return ${colorWithOpacity(TokenColorRole.primary, TokenIconButtonFilled.pressedStateLayerOpacity)};
    }
    if (states.contains(WidgetState.hovered)) {
      return ${colorWithOpacity(TokenColorRole.primary, TokenIconButtonFilled.hoveredStateLayerOpacity)};
    }
    if (states.contains(WidgetState.focused)) {
      return ${colorWithOpacity(TokenColorRole.primary, TokenIconButtonFilled.focusedStateLayerOpacity)};
    }
  }
  if (states.contains(WidgetState.pressed)) {
    return ${colorWithOpacity(TokenIconButtonFilled.pressedStateLayerColor, TokenIconButtonFilled.pressedStateLayerOpacity)};
  }
  if (states.contains(WidgetState.hovered)) {
    return ${colorWithOpacity(TokenIconButtonFilled.hoveredStateLayerColor, TokenIconButtonFilled.hoveredStateLayerOpacity)};
  }
  if (states.contains(WidgetState.focused)) {
    return ${colorWithOpacity(TokenIconButtonFilled.focusedStateLayerColor, TokenIconButtonFilled.focusedStateLayerOpacity)};
  }
  return Colors.transparent;
})''',
    _IconButtonVariant.filledTonal =>
      '''
WidgetStateProperty.resolveWith((Set<WidgetState> states) {
  if (states.contains(WidgetState.selected)) {
    if (states.contains(WidgetState.pressed)) {
      return ${colorWithOpacity(TokenColorRole.onSecondaryContainer, TokenIconButtonTonal.pressedStateLayerOpacity)};
    }
    if (states.contains(WidgetState.hovered)) {
      return ${colorWithOpacity(TokenColorRole.onSecondaryContainer, TokenIconButtonTonal.hoveredStateLayerOpacity)};
    }
    if (states.contains(WidgetState.focused)) {
      return ${colorWithOpacity(TokenColorRole.onSecondaryContainer, TokenIconButtonTonal.focusedStateLayerOpacity)};
    }
  }
  if (toggleable) {
    // toggleable but unselected case
    if (states.contains(WidgetState.pressed)) {
      return ${colorWithOpacity(TokenColorRole.onSurfaceVariant, TokenIconButtonTonal.pressedStateLayerOpacity)};
    }
    if (states.contains(WidgetState.hovered)) {
      return ${colorWithOpacity(TokenColorRole.onSurfaceVariant, TokenIconButtonTonal.hoveredStateLayerOpacity)};
    }
    if (states.contains(WidgetState.focused)) {
      return ${colorWithOpacity(TokenColorRole.onSurfaceVariant, TokenIconButtonTonal.focusedStateLayerOpacity)};
    }
  }
  if (states.contains(WidgetState.pressed)) {
    return ${colorWithOpacity(TokenIconButtonTonal.pressedStateLayerColor, TokenIconButtonTonal.pressedStateLayerOpacity)};
  }
  if (states.contains(WidgetState.hovered)) {
    return ${colorWithOpacity(TokenIconButtonTonal.hoveredStateLayerColor, TokenIconButtonTonal.hoveredStateLayerOpacity)};
  }
  if (states.contains(WidgetState.focused)) {
    return ${colorWithOpacity(TokenIconButtonTonal.focusedStateLayerColor, TokenIconButtonTonal.focusedStateLayerOpacity)};
  }
  return Colors.transparent;
})''',
    _IconButtonVariant.outlined =>
      '''
WidgetStateProperty.resolveWith((Set<WidgetState> states) {
  if (states.contains(WidgetState.selected)) {
    if (states.contains(WidgetState.pressed)) {
      return ${colorWithOpacity(TokenIconButtonOutlined.selectedPressedStateLayerColor, TokenIconButtonOutlined.pressedStateLayerOpacity)};
    }
    if (states.contains(WidgetState.hovered)) {
      return ${colorWithOpacity(TokenIconButtonOutlined.selectedHoveredStateLayerColor, TokenIconButtonOutlined.hoveredStateLayerOpacity)};
    }
    if (states.contains(WidgetState.focused)) {
      return ${colorWithOpacity(TokenIconButtonOutlined.selectedFocusedStateLayerColor, TokenIconButtonOutlined.hoveredStateLayerOpacity)};
    }
  }
  if (states.contains(WidgetState.pressed)) {
    return ${colorWithOpacity(TokenColorRole.onSurface, TokenIconButtonOutlined.pressedStateLayerOpacity)};
  }
  if (states.contains(WidgetState.hovered)) {
    return ${colorWithOpacity(TokenIconButtonOutlined.unselectedHoveredStateLayerColor, TokenIconButtonOutlined.hoveredStateLayerOpacity)};
  }
  if (states.contains(WidgetState.focused)) {
    return ${colorWithOpacity(TokenIconButtonOutlined.unselectedFocusedStateLayerColor, TokenIconButtonOutlined.hoveredStateLayerOpacity)};
  }
  return Colors.transparent;
})''',
  };

  String get _side {
    if (_variant != _IconButtonVariant.outlined) {
      return 'null';
    }
    return '''
WidgetStateProperty.resolveWith((Set<WidgetState> states) {
  if (states.contains(WidgetState.selected)) {
    return null;
  } else {
    if (states.contains(WidgetState.disabled)) {
      return ${border(colorWithOpacity(TokenColorRole.onSurface, _legacyDisabledContainerOpacity))};
    }
    return ${border(color(TokenColorRole.outline))};
  }
})''';
  }

  @override
  String generateContents(String className) =>
      '''
class $className extends ButtonStyle {
  $className(this.context, this.toggleable)
    : super(
        animationDuration: kThemeChangeDuration,
        enableFeedback: true,
        alignment: Alignment.center,
      );

  final BuildContext context;
  final bool toggleable;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  // No default text style

  @override
  WidgetStateProperty<Color?>? get backgroundColor => $_backgroundColor;

  @override
  WidgetStateProperty<Color?>? get foregroundColor => $_foregroundColor;

  @override
  WidgetStateProperty<Color?>? get overlayColor => $_overlayColor;

  @override
  WidgetStateProperty<double>? get elevation => const MaterialStatePropertyAll<double>(0.0);

  @override
  WidgetStateProperty<Color>? get shadowColor =>
      const MaterialStatePropertyAll<Color>(Colors.transparent);

  @override
  WidgetStateProperty<Color>? get surfaceTintColor =>
      const MaterialStatePropertyAll<Color>(Colors.transparent);

  @override
  WidgetStateProperty<EdgeInsetsGeometry>? get padding =>
      const MaterialStatePropertyAll<EdgeInsetsGeometry>(EdgeInsets.all(${number(TokenIconButton.defaultLeadingSpace)}));

  @override
  WidgetStateProperty<Size>? get minimumSize =>
      const MaterialStatePropertyAll<Size>(Size(${number(TokenIconButton.containerHeight)}, ${number(TokenIconButton.containerHeight)}));

  // No default fixedSize

  @override
  WidgetStateProperty<Size>? get maximumSize => const MaterialStatePropertyAll<Size>(Size.infinite);

  @override
  WidgetStateProperty<double>? get iconSize => const MaterialStatePropertyAll<double>(${number(TokenIconButton.iconSize)});

  @override
  WidgetStateProperty<BorderSide?>? get side => $_side;

  @override
  WidgetStateProperty<OutlinedBorder>? get shape =>
      const MaterialStatePropertyAll<OutlinedBorder>(${shape(TokenIconButton.containerShapeRound, '')});

  @override
  WidgetStateProperty<MouseCursor?>? get mouseCursor => WidgetStateMouseCursor.adaptiveClickable;

  @override
  VisualDensity? get visualDensity => VisualDensity.standard;

  @override
  MaterialTapTargetSize? get tapTargetSize => Theme.of(context).materialTapTargetSize;

  @override
  InteractiveInkFeatureFactory? get splashFactory => Theme.of(context).splashFactory;
}
''';
}
