// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/button.dart';
import '../data/button_elevated.dart';
import '../data/button_filled.dart';
import '../data/button_large.dart';
import '../data/button_medium.dart';
import '../data/button_outlined.dart';
import '../data/button_small.dart';
import '../data/button_text.dart';
import '../data/button_tonal.dart';
import '../data/button_xlarge.dart';
import '../data/button_xsmall.dart';
import '../data/color_role.dart';
import 'template.dart';

enum _ButtonVariant { elevated, filled, filledTonal, outlined, text }

// The states that can change the color of a button part, in the order that the
// generated code checks them.
enum _InteractiveState { pressed, hovered, focused }

// The token colors of a button part in the resting, pressed, hovered, and
// focused states. A null resting color means that the part has no color when
// the button is at rest, like the state layer.
class _StateColors {
  const _StateColors({
    this.resting,
    required this.pressed,
    required this.hovered,
    required this.focused,
  });

  final TokenColorRole? resting;
  final TokenColorRole pressed;
  final TokenColorRole hovered;
  final TokenColorRole focused;

  TokenColorRole forState(_InteractiveState state) => switch (state) {
    _InteractiveState.pressed => pressed,
    _InteractiveState.hovered => hovered,
    _InteractiveState.focused => focused,
  };
}

class ButtonTemplateM3 extends TokenTemplateM3 {
  const ButtonTemplateM3(this.name);

  @override
  final String name;

  @override
  String get parentFilePath => switch (_variant) {
    _ButtonVariant.elevated => 'elevated_button.dart',
    _ButtonVariant.filled || _ButtonVariant.filledTonal => 'filled_button.dart',
    _ButtonVariant.outlined => 'outlined_button.dart',
    _ButtonVariant.text => 'text_button.dart',
  };

  // Some exported md.comp.button.* tokens differ from Flutter's existing M3
  // button defaults. Preserve those existing values so the defaults do not
  // change during this template migration.
  // TODO(QuncCccccc): Replace these values with tokens.
  static const double _legacyDisabledContainerOpacity = 0.12;
  static const double _legacyHoverElevation = 3.0;
  static const double _legacyFilledHoverElevation = 1.0;
  static const double _legacyIconSize = 18.0;

  _ButtonVariant get _variant => switch (name) {
    'Elevated Button' => _ButtonVariant.elevated,
    'Filled Button' => _ButtonVariant.filled,
    'Filled Tonal Button' => _ButtonVariant.filledTonal,
    'Outlined Button' => _ButtonVariant.outlined,
    'Text Button' => _ButtonVariant.text,
    _ => throw UnsupportedError('Unsupported button template name: $name'),
  };

  TokenColorRole? get _containerColor => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.containerColor,
    _ButtonVariant.filled => TokenButtonFilled.containerColor,
    _ButtonVariant.filledTonal => TokenButtonTonal.containerColor,
    _ButtonVariant.outlined || _ButtonVariant.text => null,
  };

  TokenColorRole get _labelTextColor => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.labelTextColor,
    _ButtonVariant.filled => TokenButtonFilled.labelTextColor,
    _ButtonVariant.filledTonal => TokenButtonTonal.labelTextColor,
    _ButtonVariant.outlined => TokenColorRole.primary,
    _ButtonVariant.text => TokenButtonText.labelTextColor,
  };

  TokenColorRole get _stateLayerColor => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.pressedStateLayerColor,
    _ButtonVariant.filled => TokenButtonFilled.pressedStateLayerColor,
    _ButtonVariant.filledTonal => TokenButtonTonal.pressedStateLayerColor,
    _ButtonVariant.outlined => TokenColorRole.primary,
    _ButtonVariant.text => TokenButtonText.pressedStateLayerColor,
  };

  TokenColorRole get _iconColor => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.iconColor,
    _ButtonVariant.filled => TokenButtonFilled.iconColor,
    _ButtonVariant.filledTonal => TokenButtonTonal.iconColor,
    _ButtonVariant.outlined => TokenColorRole.primary,
    _ButtonVariant.text => TokenButtonText.iconColor,
  };

  double get _disabledContainerElevation => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.disabledContainerElevation,
    _ButtonVariant.filled => TokenButtonFilled.disabledContainerElevation,
    _ButtonVariant.filledTonal => TokenButtonTonal.disabledContainerElevation,
    _ButtonVariant.outlined || _ButtonVariant.text => TokenButton.disabledContainerElevation,
  };

  double get _pressedContainerElevation => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.pressedContainerElevation,
    _ButtonVariant.filled => TokenButtonFilled.pressedContainerElevation,
    _ButtonVariant.filledTonal => TokenButtonTonal.pressedContainerElevation,
    _ButtonVariant.outlined || _ButtonVariant.text => TokenButton.pressedContainerElevation,
  };

  double get _focusedContainerElevation => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.focusedContainerElevation,
    _ButtonVariant.filled => TokenButtonFilled.focusedContainerElevation,
    _ButtonVariant.filledTonal => TokenButtonTonal.focusedContainerElevation,
    _ButtonVariant.outlined || _ButtonVariant.text => TokenButton.focusedContainerElevation,
  };

  double get _containerElevation => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.containerElevation,
    _ButtonVariant.filled => TokenButtonFilled.containerElevation,
    _ButtonVariant.filledTonal => TokenButtonTonal.containerElevation,
    _ButtonVariant.outlined || _ButtonVariant.text => TokenButton.containerElevation,
  };

  double get _hoveredContainerElevation => switch (_variant) {
    _ButtonVariant.elevated => _legacyHoverElevation,
    _ButtonVariant.filled || _ButtonVariant.filledTonal => _legacyFilledHoverElevation,
    _ButtonVariant.outlined || _ButtonVariant.text => TokenButton.containerElevation,
  };

  double get _pressedStateLayerOpacity => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.pressedStateLayerOpacity,
    _ButtonVariant.filled => TokenButtonFilled.pressedStateLayerOpacity,
    _ButtonVariant.filledTonal => TokenButtonTonal.pressedStateLayerOpacity,
    _ButtonVariant.outlined => TokenButtonOutlined.pressedStateLayerOpacity,
    _ButtonVariant.text => TokenButtonText.pressedStateLayerOpacity,
  };

  double get _hoveredStateLayerOpacity => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.hoveredStateLayerOpacity,
    _ButtonVariant.filled => TokenButtonFilled.hoveredStateLayerOpacity,
    _ButtonVariant.filledTonal => TokenButtonTonal.hoveredStateLayerOpacity,
    _ButtonVariant.outlined => TokenButtonOutlined.hoveredStateLayerOpacity,
    _ButtonVariant.text => TokenButtonText.hoveredStateLayerOpacity,
  };

  double get _focusedStateLayerOpacity => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.focusedStateLayerOpacity,
    _ButtonVariant.filled => TokenButtonFilled.focusedStateLayerOpacity,
    _ButtonVariant.filledTonal => TokenButtonTonal.focusedStateLayerOpacity,
    _ButtonVariant.outlined => TokenButtonOutlined.focusedStateLayerOpacity,
    _ButtonVariant.text => TokenButtonText.focusedStateLayerOpacity,
  };

  String get _buttonTextStyle {
    return textStyle(TokenButton.labelText, 'Theme.of(context).textTheme');
  }

  String get _backgroundColor {
    final TokenColorRole? containerColor = _containerColor;
    if (containerColor == null) {
      return 'const MaterialStatePropertyAll<Color>(Colors.transparent)';
    }
    return '''
WidgetStateProperty.resolveWith((Set<WidgetState> states) {
  if (states.contains(WidgetState.disabled)) {
    return ${colorWithOpacity(TokenButton.disabledContainerColor, _legacyDisabledContainerOpacity)};
  }
  return ${color(containerColor)};
})''';
  }

  String get _shadowColor {
    return switch (_variant) {
      _ButtonVariant.elevated =>
        'MaterialStatePropertyAll<Color>(${color(TokenButtonElevated.containerShadowColor)})',
      _ButtonVariant.filled =>
        'MaterialStatePropertyAll<Color>(${color(TokenButtonFilled.containerShadowColor)})',
      _ButtonVariant.filledTonal =>
        'MaterialStatePropertyAll<Color>(${color(TokenButtonTonal.containerShadowColor)})',
      _ButtonVariant.outlined ||
      _ButtonVariant.text => 'const MaterialStatePropertyAll<Color>(Colors.transparent)',
    };
  }

  String get _elevation {
    if (_variant == _ButtonVariant.outlined || _variant == _ButtonVariant.text) {
      return 'const MaterialStatePropertyAll<double>(0.0)';
    }
    return '''
WidgetStateProperty.resolveWith((Set<WidgetState> states) {
  if (states.contains(WidgetState.disabled)) {
    return ${number(_disabledContainerElevation)};
  }
  if (states.contains(WidgetState.pressed)) {
    return ${number(_pressedContainerElevation)};
  }
  if (states.contains(WidgetState.hovered)) {
    return ${number(_hoveredContainerElevation)};
  }
  if (states.contains(WidgetState.focused)) {
    return ${number(_focusedContainerElevation)};
  }
  return ${number(_containerElevation)};
})''';
  }

  String get _side {
    if (_variant != _ButtonVariant.outlined) {
      return '// No default side';
    }
    return '''
@override
WidgetStateProperty<BorderSide>? get side =>
  WidgetStateProperty.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return BorderSide(color: ${colorWithOpacity(TokenButton.disabledContainerColor, _legacyDisabledContainerOpacity)});
    }
    if (states.contains(WidgetState.focused)) {
      return BorderSide(color: ${color(TokenColorRole.primary)});
    }
    return BorderSide(color: ${color(TokenColorRole.outline)});
  });''';
  }

  @override
  String generateContents(String className) =>
      '''
class $className extends ButtonStyle {
  $className(this.context)
    : super(
        animationDuration: kThemeChangeDuration,
        enableFeedback: true,
        alignment: Alignment.center,
      );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  WidgetStateProperty<TextStyle?> get textStyle =>
      MaterialStatePropertyAll<TextStyle?>($_buttonTextStyle);

  @override
  WidgetStateProperty<Color?>? get backgroundColor => $_backgroundColor;

  @override
  WidgetStateProperty<Color?>? get foregroundColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return ${colorWithOpacity(TokenButton.disabledLabelTextColor, TokenButton.disabledLabelTextOpacity)};
        }
        return ${color(_labelTextColor)};
      });

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return ${colorWithOpacity(_stateLayerColor, _pressedStateLayerOpacity)};
        }
        if (states.contains(WidgetState.hovered)) {
          return ${colorWithOpacity(_stateLayerColor, _hoveredStateLayerOpacity)};
        }
        if (states.contains(WidgetState.focused)) {
          return ${colorWithOpacity(_stateLayerColor, _focusedStateLayerOpacity)};
        }
        return null;
      });

  @override
  WidgetStateProperty<Color>? get shadowColor => $_shadowColor;

  @override
  WidgetStateProperty<Color>? get surfaceTintColor =>
      const MaterialStatePropertyAll<Color>(Colors.transparent);

  @override
  WidgetStateProperty<double>? get elevation => $_elevation;

  @override
  WidgetStateProperty<EdgeInsetsGeometry>? get padding =>
      MaterialStatePropertyAll<EdgeInsetsGeometry>(_scaledPadding(context));

  @override
  WidgetStateProperty<Size>? get minimumSize =>
      const MaterialStatePropertyAll<Size>(Size(64.0, ${number(TokenButton.containerHeight)}));

  // No default fixedSize

  @override
  WidgetStateProperty<double>? get iconSize => const MaterialStatePropertyAll<double>($_legacyIconSize);

  @override
  WidgetStateProperty<Color>? get iconColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return ${colorWithOpacity(TokenButton.disabledIconColor, TokenButton.disabledIconOpacity)};
      }
      if (states.contains(WidgetState.pressed)) {
        return ${color(_iconColor)};
      }
      if (states.contains(WidgetState.hovered)) {
        return ${color(_iconColor)};
      }
      if (states.contains(WidgetState.focused)) {
        return ${color(_iconColor)};
      }
      return ${color(_iconColor)};
    });
  }

  @override
  WidgetStateProperty<Size>? get maximumSize => const MaterialStatePropertyAll<Size>(Size.infinite);

  $_side

  @override
  WidgetStateProperty<OutlinedBorder>? get shape =>
      const MaterialStatePropertyAll<OutlinedBorder>(${shape(TokenButton.containerShapeRound, '')});

  @override
  WidgetStateProperty<MouseCursor?>? get mouseCursor => WidgetStateMouseCursor.adaptiveClickable;

  @override
  VisualDensity? get visualDensity => Theme.of(context).visualDensity;

  @override
  MaterialTapTargetSize? get tapTargetSize => Theme.of(context).materialTapTargetSize;

  @override
  InteractiveInkFeatureFactory? get splashFactory => Theme.of(context).splashFactory;
}
''';
}

class ButtonTemplateM3E extends TokenTemplateM3E {
  const ButtonTemplateM3E(this.name);

  @override
  final String name;

  _ButtonVariant get _variant => switch (name) {
    'Elevated Button' => _ButtonVariant.elevated,
    'Filled Button' => _ButtonVariant.filled,
    'Filled Tonal Button' => _ButtonVariant.filledTonal,
    'Outlined Button' => _ButtonVariant.outlined,
    'Text Button' => _ButtonVariant.text,
    _ => throw UnsupportedError('Unsupported expressive button template name: $name'),
  };

  @override
  String get parentFilePath => switch (_variant) {
    _ButtonVariant.elevated => 'elevated_button.dart',
    _ButtonVariant.filled || _ButtonVariant.filledTonal => 'filled_button.dart',
    _ButtonVariant.outlined => 'outlined_button.dart',
    _ButtonVariant.text => 'text_button.dart',
  };

  // Text buttons have no selected or unselected tokens, so they can't be
  // toggle buttons.
  bool get _hasToggleTokens => _variant != _ButtonVariant.text;

  // Outlined and text buttons have no container color tokens, so their
  // containers are transparent.
  TokenColorRole? get _containerColor => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.containerColor,
    _ButtonVariant.filled => TokenButtonFilled.containerColor,
    _ButtonVariant.filledTonal => TokenButtonTonal.containerColor,
    _ButtonVariant.outlined || _ButtonVariant.text => null,
  };

  TokenColorRole? get _disabledContainerColor => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.disabledContainerColor,
    _ButtonVariant.filled => TokenButtonFilled.disabledContainerColor,
    _ButtonVariant.filledTonal => TokenButtonTonal.disabledContainerColor,
    _ButtonVariant.outlined => null,
    _ButtonVariant.text => TokenButtonText.disabledContainerColor,
  };

  double get _disabledContainerOpacity => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.disabledContainerOpacity,
    _ButtonVariant.filled => TokenButtonFilled.disabledContainerOpacity,
    _ButtonVariant.filledTonal => TokenButtonTonal.disabledContainerOpacity,
    _ButtonVariant.outlined => TokenButtonOutlined.disabledContainerOpacity,
    _ButtonVariant.text => TokenButtonText.disabledContainerOpacity,
  };

  TokenColorRole? get _selectedContainerColor => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.selectedContainerColor,
    _ButtonVariant.filled => TokenButtonFilled.selectedContainerColor,
    _ButtonVariant.filledTonal => TokenButtonTonal.selectedContainerColor,
    _ButtonVariant.outlined => TokenButtonOutlined.selectedContainerColor,
    _ButtonVariant.text => null,
  };

  // Only outlined buttons have a container color for disabled selected toggle
  // buttons.
  TokenColorRole? get _selectedDisabledContainerColor => switch (_variant) {
    _ButtonVariant.outlined => TokenButtonOutlined.selectedDisabledContainerColor,
    _ButtonVariant.elevated ||
    _ButtonVariant.filled ||
    _ButtonVariant.filledTonal ||
    _ButtonVariant.text => null,
  };

  TokenColorRole? get _unselectedContainerColor => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.unselectedContainerColor,
    _ButtonVariant.filled => TokenButtonFilled.unselectedContainerColor,
    _ButtonVariant.filledTonal => TokenButtonTonal.unselectedContainerColor,
    _ButtonVariant.outlined || _ButtonVariant.text => null,
  };

  // Outlined and text buttons have no shadow color or elevation tokens, so
  // they use the common button tokens.
  TokenColorRole get _containerShadowColor => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.containerShadowColor,
    _ButtonVariant.filled => TokenButtonFilled.containerShadowColor,
    _ButtonVariant.filledTonal => TokenButtonTonal.containerShadowColor,
    _ButtonVariant.outlined || _ButtonVariant.text => TokenButton.containerShadowColor,
  };

  double get _containerElevation => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.containerElevation,
    _ButtonVariant.filled => TokenButtonFilled.containerElevation,
    _ButtonVariant.filledTonal => TokenButtonTonal.containerElevation,
    _ButtonVariant.outlined || _ButtonVariant.text => TokenButton.containerElevation,
  };

  double get _disabledContainerElevation => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.disabledContainerElevation,
    _ButtonVariant.filled => TokenButtonFilled.disabledContainerElevation,
    _ButtonVariant.filledTonal => TokenButtonTonal.disabledContainerElevation,
    _ButtonVariant.outlined || _ButtonVariant.text => TokenButton.disabledContainerElevation,
  };

  double get _pressedContainerElevation => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.pressedContainerElevation,
    _ButtonVariant.filled => TokenButtonFilled.pressedContainerElevation,
    _ButtonVariant.filledTonal => TokenButtonTonal.pressedContainerElevation,
    _ButtonVariant.outlined || _ButtonVariant.text => TokenButton.pressedContainerElevation,
  };

  double get _focusedContainerElevation => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.focusedContainerElevation,
    _ButtonVariant.filled => TokenButtonFilled.focusedContainerElevation,
    _ButtonVariant.filledTonal => TokenButtonTonal.focusedContainerElevation,
    _ButtonVariant.outlined || _ButtonVariant.text => TokenButton.focusedContainerElevation,
  };

  _StateColors get _labelTextColors => switch (_variant) {
    _ButtonVariant.elevated => const _StateColors(
      resting: TokenButtonElevated.labelTextColor,
      pressed: TokenButtonElevated.pressedLabelTextColor,
      hovered: TokenButtonElevated.hoveredLabelTextColor,
      focused: TokenButtonElevated.focusedLabelTextColor,
    ),
    _ButtonVariant.filled => const _StateColors(
      resting: TokenButtonFilled.labelTextColor,
      pressed: TokenButtonFilled.pressedLabelTextColor,
      hovered: TokenButtonFilled.hoveredLabelTextColor,
      focused: TokenButtonFilled.focusedLabelTextColor,
    ),
    _ButtonVariant.filledTonal => const _StateColors(
      resting: TokenButtonTonal.labelTextColor,
      pressed: TokenButtonTonal.pressedLabelTextColor,
      hovered: TokenButtonTonal.hoveredLabelTextColor,
      focused: TokenButtonTonal.focusedLabelTextColor,
    ),
    _ButtonVariant.outlined => const _StateColors(
      resting: TokenButtonOutlined.labelTextColor,
      pressed: TokenButtonOutlined.pressedLabelTextColor,
      hovered: TokenButtonOutlined.hoveredLabelTextColor,
      focused: TokenButtonOutlined.focusedLabelTextColor,
    ),
    _ButtonVariant.text => const _StateColors(
      resting: TokenButtonText.labelTextColor,
      pressed: TokenButtonText.pressedLabelTextColor,
      hovered: TokenButtonText.hoveredLabelTextColor,
      focused: TokenButtonText.focusedLabelTextColor,
    ),
  };

  _StateColors? get _selectedLabelTextColors => switch (_variant) {
    _ButtonVariant.elevated => const _StateColors(
      resting: TokenButtonElevated.selectedLabelTextColor,
      pressed: TokenButtonElevated.selectedPressedLabelTextColor,
      hovered: TokenButtonElevated.selectedHoveredLabelTextColor,
      focused: TokenButtonElevated.selectedFocusedLabelTextColor,
    ),
    _ButtonVariant.filled => const _StateColors(
      resting: TokenButtonFilled.selectedLabelTextColor,
      pressed: TokenButtonFilled.selectedPressedLabelTextColor,
      hovered: TokenButtonFilled.selectedHoveredLabelTextColor,
      focused: TokenButtonFilled.selectedFocusedLabelTextColor,
    ),
    _ButtonVariant.filledTonal => const _StateColors(
      resting: TokenButtonTonal.selectedLabelTextColor,
      pressed: TokenButtonTonal.selectedPressedLabelTextColor,
      hovered: TokenButtonTonal.selectedHoveredLabelTextColor,
      focused: TokenButtonTonal.selectedFocusedLabelTextColor,
    ),
    _ButtonVariant.outlined => const _StateColors(
      resting: TokenButtonOutlined.selectedLabelTextColor,
      pressed: TokenButtonOutlined.selectedPressedLabelTextColor,
      hovered: TokenButtonOutlined.selectedHoveredLabelTextColor,
      focused: TokenButtonOutlined.selectedFocusedLabelTextColor,
    ),
    _ButtonVariant.text => null,
  };

  _StateColors? get _unselectedLabelTextColors => switch (_variant) {
    _ButtonVariant.elevated => const _StateColors(
      resting: TokenButtonElevated.unselectedLabelTextColor,
      pressed: TokenButtonElevated.unselectedPressedLabelTextColor,
      hovered: TokenButtonElevated.unselectedHoveredLabelTextColor,
      focused: TokenButtonElevated.unselectedFocusedLabelTextColor,
    ),
    _ButtonVariant.filled => const _StateColors(
      resting: TokenButtonFilled.unselectedLabelTextColor,
      pressed: TokenButtonFilled.unselectedPressedLabelTextColor,
      hovered: TokenButtonFilled.unselectedHoveredLabelTextColor,
      focused: TokenButtonFilled.unselectedFocusedLabelTextColor,
    ),
    _ButtonVariant.filledTonal => const _StateColors(
      resting: TokenButtonTonal.unselectedLabelTextColor,
      pressed: TokenButtonTonal.unselectedPressedLabelTextColor,
      hovered: TokenButtonTonal.unselectedHoveredLabelTextColor,
      focused: TokenButtonTonal.unselectedFocusedLabelTextColor,
    ),
    _ButtonVariant.outlined => const _StateColors(
      resting: TokenButtonOutlined.unselectedLabelTextColor,
      pressed: TokenButtonOutlined.unselectedPressedLabelTextColor,
      hovered: TokenButtonOutlined.unselectedHoveredLabelTextColor,
      focused: TokenButtonOutlined.unselectedFocusedLabelTextColor,
    ),
    _ButtonVariant.text => null,
  };

  TokenColorRole get _disabledLabelTextColor => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.disabledLabelTextColor,
    _ButtonVariant.filled => TokenButtonFilled.disabledLabelTextColor,
    _ButtonVariant.filledTonal => TokenButtonTonal.disabledLabelTextColor,
    _ButtonVariant.outlined => TokenButtonOutlined.disabledLabelTextColor,
    _ButtonVariant.text => TokenButtonText.disabledLabelTextColor,
  };

  double get _disabledLabelTextOpacity => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.disabledLabelTextOpacity,
    _ButtonVariant.filled => TokenButtonFilled.disabledLabelTextOpacity,
    _ButtonVariant.filledTonal => TokenButtonTonal.disabledLabelTextOpacity,
    _ButtonVariant.outlined => TokenButtonOutlined.disabledLabelTextOpacity,
    _ButtonVariant.text => TokenButtonText.disabledLabelTextOpacity,
  };

  _StateColors get _iconColors => switch (_variant) {
    _ButtonVariant.elevated => const _StateColors(
      resting: TokenButtonElevated.iconColor,
      pressed: TokenButtonElevated.pressedIconColor,
      hovered: TokenButtonElevated.hoveredIconColor,
      focused: TokenButtonElevated.focusedIconColor,
    ),
    _ButtonVariant.filled => const _StateColors(
      resting: TokenButtonFilled.iconColor,
      pressed: TokenButtonFilled.pressedIconColor,
      hovered: TokenButtonFilled.hoveredIconColor,
      focused: TokenButtonFilled.focusedIconColor,
    ),
    _ButtonVariant.filledTonal => const _StateColors(
      resting: TokenButtonTonal.iconColor,
      pressed: TokenButtonTonal.pressedIconColor,
      hovered: TokenButtonTonal.hoveredIconColor,
      focused: TokenButtonTonal.focusedIconColor,
    ),
    _ButtonVariant.outlined => const _StateColors(
      resting: TokenButtonOutlined.iconColor,
      pressed: TokenButtonOutlined.pressedIconColor,
      hovered: TokenButtonOutlined.hoveredIconColor,
      focused: TokenButtonOutlined.focusedIconColor,
    ),
    _ButtonVariant.text => const _StateColors(
      resting: TokenButtonText.iconColor,
      pressed: TokenButtonText.pressedIconColor,
      hovered: TokenButtonText.hoveredIconColor,
      focused: TokenButtonText.focusedIconColor,
    ),
  };

  _StateColors? get _selectedIconColors => switch (_variant) {
    _ButtonVariant.elevated => const _StateColors(
      resting: TokenButtonElevated.selectedIconColor,
      pressed: TokenButtonElevated.selectedPressedIconColor,
      hovered: TokenButtonElevated.selectedHoveredIconColor,
      focused: TokenButtonElevated.selectedFocusedIconColor,
    ),
    _ButtonVariant.filled => const _StateColors(
      resting: TokenButtonFilled.selectedIconColor,
      pressed: TokenButtonFilled.selectedPressedIconColor,
      hovered: TokenButtonFilled.selectedHoveredIconColor,
      focused: TokenButtonFilled.selectedFocusedIconColor,
    ),
    _ButtonVariant.filledTonal => const _StateColors(
      resting: TokenButtonTonal.selectedIconColor,
      pressed: TokenButtonTonal.selectedPressedIconColor,
      hovered: TokenButtonTonal.selectedHoveredIconColor,
      focused: TokenButtonTonal.selectedFocusedIconColor,
    ),
    _ButtonVariant.outlined => const _StateColors(
      resting: TokenButtonOutlined.selectedIconColor,
      pressed: TokenButtonOutlined.selectedPressedIconColor,
      hovered: TokenButtonOutlined.selectedHoveredIconColor,
      focused: TokenButtonOutlined.selectedFocusedIconColor,
    ),
    _ButtonVariant.text => null,
  };

  _StateColors? get _unselectedIconColors => switch (_variant) {
    _ButtonVariant.elevated => const _StateColors(
      resting: TokenButtonElevated.unselectedIconColor,
      pressed: TokenButtonElevated.unselectedPressedIconColor,
      hovered: TokenButtonElevated.unselectedHoveredIconColor,
      focused: TokenButtonElevated.unselectedFocusedIconColor,
    ),
    _ButtonVariant.filled => const _StateColors(
      resting: TokenButtonFilled.unselectedIconColor,
      pressed: TokenButtonFilled.unselectedPressedIconColor,
      hovered: TokenButtonFilled.unselectedHoveredIconColor,
      focused: TokenButtonFilled.unselectedFocusedIconColor,
    ),
    _ButtonVariant.filledTonal => const _StateColors(
      resting: TokenButtonTonal.unselectedIconColor,
      pressed: TokenButtonTonal.unselectedPressedIconColor,
      hovered: TokenButtonTonal.unselectedHoveredIconColor,
      focused: TokenButtonTonal.unselectedFocusedIconColor,
    ),
    _ButtonVariant.outlined => const _StateColors(
      resting: TokenButtonOutlined.unselectedIconColor,
      pressed: TokenButtonOutlined.unselectedPressedIconColor,
      hovered: TokenButtonOutlined.unselectedHoveredIconColor,
      focused: TokenButtonOutlined.unselectedFocusedIconColor,
    ),
    _ButtonVariant.text => null,
  };

  TokenColorRole get _disabledIconColor => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.disabledIconColor,
    _ButtonVariant.filled => TokenButtonFilled.disabledIconColor,
    _ButtonVariant.filledTonal => TokenButtonTonal.disabledIconColor,
    _ButtonVariant.outlined => TokenButtonOutlined.disabledIconColor,
    _ButtonVariant.text => TokenButtonText.disabledIconColor,
  };

  double get _disabledIconOpacity => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.disabledIconOpacity,
    _ButtonVariant.filled => TokenButtonFilled.disabledIconOpacity,
    _ButtonVariant.filledTonal => TokenButtonTonal.disabledIconOpacity,
    _ButtonVariant.outlined => TokenButtonOutlined.disabledIconOpacity,
    _ButtonVariant.text => TokenButtonText.disabledIconOpacity,
  };

  // The overlay colors of a button that isn't toggleable.
  _StateColors get _stateLayerColors => switch (_variant) {
    _ButtonVariant.elevated => const _StateColors(
      pressed: TokenButtonElevated.pressedStateLayerColor,
      hovered: TokenButtonElevated.hoveredStateLayerColor,
      focused: TokenButtonElevated.focusedStateLayerColor,
    ),
    _ButtonVariant.filled => const _StateColors(
      pressed: TokenButtonFilled.pressedStateLayerColor,
      hovered: TokenButtonFilled.hoveredStateLayerColor,
      focused: TokenButtonFilled.focusedStateLayerColor,
    ),
    _ButtonVariant.filledTonal => const _StateColors(
      pressed: TokenButtonTonal.pressedStateLayerColor,
      hovered: TokenButtonTonal.hoveredStateLayerColor,
      focused: TokenButtonTonal.focusedStateLayerColor,
    ),
    _ButtonVariant.outlined => const _StateColors(
      pressed: TokenButtonOutlined.pressedStateLayerColor,
      hovered: TokenButtonOutlined.hoveredStateLayerColor,
      focused: TokenButtonOutlined.focusedStateLayerColor,
    ),
    _ButtonVariant.text => const _StateColors(
      pressed: TokenButtonText.pressedStateLayerColor,
      hovered: TokenButtonText.hoveredStateLayerColor,
      focused: TokenButtonText.focusedStateLayerColor,
    ),
  };

  // The overlay colors of a selected toggle button.
  _StateColors? get _selectedStateLayerColors => switch (_variant) {
    _ButtonVariant.elevated => const _StateColors(
      pressed: TokenButtonElevated.selectedPressedStateLayerColor,
      hovered: TokenButtonElevated.selectedHoveredStateLayerColor,
      focused: TokenButtonElevated.selectedFocusedStateLayerColor,
    ),
    _ButtonVariant.filled => const _StateColors(
      pressed: TokenButtonFilled.selectedPressedStateLayerColor,
      hovered: TokenButtonFilled.selectedHoveredStateLayerColor,
      focused: TokenButtonFilled.selectedFocusedStateLayerColor,
    ),
    _ButtonVariant.filledTonal => const _StateColors(
      pressed: TokenButtonTonal.selectedPressedStateLayerColor,
      hovered: TokenButtonTonal.selectedHoveredStateLayerColor,
      focused: TokenButtonTonal.selectedFocusedStateLayerColor,
    ),
    _ButtonVariant.outlined => const _StateColors(
      pressed: TokenButtonOutlined.selectedPressedStateLayerColor,
      hovered: TokenButtonOutlined.selectedHoveredStateLayerColor,
      focused: TokenButtonOutlined.selectedFocusedStateLayerColor,
    ),
    _ButtonVariant.text => null,
  };

  // The overlay colors of an unselected toggle button.
  _StateColors? get _unselectedStateLayerColors => switch (_variant) {
    _ButtonVariant.elevated => const _StateColors(
      pressed: TokenButtonElevated.unselectedPressedStateLayerColor,
      hovered: TokenButtonElevated.unselectedHoveredStateLayerColor,
      focused: TokenButtonElevated.unselectedFocusedStateLayerColor,
    ),
    _ButtonVariant.filled => const _StateColors(
      pressed: TokenButtonFilled.unselectedPressedStateLayerColor,
      hovered: TokenButtonFilled.unselectedHoveredStateLayerColor,
      focused: TokenButtonFilled.unselectedFocusedStateLayerColor,
    ),
    _ButtonVariant.filledTonal => const _StateColors(
      pressed: TokenButtonTonal.unselectedPressedStateLayerColor,
      hovered: TokenButtonTonal.unselectedHoveredStateLayerColor,
      focused: TokenButtonTonal.unselectedFocusedStateLayerColor,
    ),
    _ButtonVariant.outlined => const _StateColors(
      pressed: TokenButtonOutlined.unselectedPressedStateLayerColor,
      hovered: TokenButtonOutlined.unselectedHoveredStateLayerColor,
      focused: TokenButtonOutlined.unselectedFocusedStateLayerColor,
    ),
    _ButtonVariant.text => null,
  };

  double get _pressedStateLayerOpacity => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.pressedStateLayerOpacity,
    _ButtonVariant.filled => TokenButtonFilled.pressedStateLayerOpacity,
    _ButtonVariant.filledTonal => TokenButtonTonal.pressedStateLayerOpacity,
    _ButtonVariant.outlined => TokenButtonOutlined.pressedStateLayerOpacity,
    _ButtonVariant.text => TokenButtonText.pressedStateLayerOpacity,
  };

  double get _hoveredStateLayerOpacity => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.hoveredStateLayerOpacity,
    _ButtonVariant.filled => TokenButtonFilled.hoveredStateLayerOpacity,
    _ButtonVariant.filledTonal => TokenButtonTonal.hoveredStateLayerOpacity,
    _ButtonVariant.outlined => TokenButtonOutlined.hoveredStateLayerOpacity,
    _ButtonVariant.text => TokenButtonText.hoveredStateLayerOpacity,
  };

  double get _focusedStateLayerOpacity => switch (_variant) {
    _ButtonVariant.elevated => TokenButtonElevated.focusedStateLayerOpacity,
    _ButtonVariant.filled => TokenButtonFilled.focusedStateLayerOpacity,
    _ButtonVariant.filledTonal => TokenButtonTonal.focusedStateLayerOpacity,
    _ButtonVariant.outlined => TokenButtonOutlined.focusedStateLayerOpacity,
    _ButtonVariant.text => TokenButtonText.focusedStateLayerOpacity,
  };

  // Only outlined buttons have outline tokens.
  static const _StateColors _outlineColors = _StateColors(
    resting: TokenButtonOutlined.outlineColor,
    pressed: TokenButtonOutlined.pressedOutlineColor,
    hovered: TokenButtonOutlined.hoveredOutlineColor,
    focused: TokenButtonOutlined.focusedOutlineColor,
  );

  // There is no unselected outline color token for the resting state, so an
  // unselected toggle button at rest uses the outline color.
  static const _StateColors _unselectedOutlineColors = _StateColors(
    resting: TokenButtonOutlined.outlineColor,
    pressed: TokenButtonOutlined.unselectedPressedOutlineColor,
    hovered: TokenButtonOutlined.unselectedHoveredOutlineColor,
    focused: TokenButtonOutlined.unselectedFocusedOutlineColor,
  );

  // Returns the code that resolves [colors] for the pressed, hovered, focused,
  // and resting states, in that order. A state has its own branch only when its
  // color differs from the resting color. [format] converts a color to code,
  // and gets the state, or null for the resting state.
  String _resolveStateColors(
    _StateColors colors,
    String Function(TokenColorRole role, _InteractiveState? state) format,
  ) {
    final buffer = StringBuffer();
    for (final _InteractiveState state in _InteractiveState.values) {
      final TokenColorRole role = colors.forState(state);
      if (role != colors.resting) {
        buffer.writeln('if (states.contains(WidgetState.${state.name})) {');
        buffer.writeln('  return ${format(role, state)};');
        buffer.writeln('}');
      }
    }
    final TokenColorRole? resting = colors.resting;
    buffer.write('return ${resting == null ? 'null' : format(resting, null)};');
    return buffer.toString();
  }

  // Returns the code that resolves the color of the label or the icon.
  String _resolveContentColor({
    required String disabled,
    required _StateColors colors,
    required _StateColors? selectedColors,
    required _StateColors? unselectedColors,
  }) {
    String resolve(_StateColors colors) =>
        _resolveStateColors(colors, (TokenColorRole role, _) => color(role));
    final buffer = StringBuffer();
    buffer.writeln('if (states.contains(WidgetState.disabled)) {');
    buffer.writeln('  return $disabled;');
    buffer.writeln('}');
    if (selectedColors != null) {
      buffer.writeln('if (toggleable && states.contains(WidgetState.selected)) {');
      buffer.writeln(resolve(selectedColors));
      buffer.writeln('}');
    }
    if (unselectedColors != null) {
      buffer.writeln('if (toggleable) {');
      buffer.writeln(resolve(unselectedColors));
      buffer.writeln('}');
    }
    buffer.write(resolve(colors));
    return buffer.toString();
  }

  String _colorOrTransparent(TokenColorRole? role) =>
      role == null ? 'Colors.transparent' : color(role);

  String get _backgroundColor {
    final buffer = StringBuffer();
    buffer.writeln('if (states.contains(WidgetState.disabled)) {');
    final TokenColorRole? selectedDisabledContainerColor = _selectedDisabledContainerColor;
    if (selectedDisabledContainerColor != null) {
      buffer.writeln('if (toggleable && states.contains(WidgetState.selected)) {');
      buffer.writeln(
        '  return ${colorWithOpacity(selectedDisabledContainerColor, _disabledContainerOpacity)};',
      );
      buffer.writeln('}');
    }
    final TokenColorRole? disabledContainerColor = _disabledContainerColor;
    buffer.writeln(
      '  return ${disabledContainerColor == null ? 'Colors.transparent' : colorWithOpacity(disabledContainerColor, _disabledContainerOpacity)};',
    );
    buffer.writeln('}');
    final TokenColorRole? selectedContainerColor = _selectedContainerColor;
    if (selectedContainerColor != null) {
      buffer.writeln('if (toggleable && states.contains(WidgetState.selected)) {');
      buffer.writeln('  return ${color(selectedContainerColor)};');
      buffer.writeln('}');
    }
    if (_hasToggleTokens) {
      buffer.writeln('if (toggleable) {');
      buffer.writeln('  return ${_colorOrTransparent(_unselectedContainerColor)};');
      buffer.writeln('}');
    }
    buffer.write('return ${_colorOrTransparent(_containerColor)};');
    return buffer.toString();
  }

  String get _overlayColor {
    String resolve(_StateColors colors) => _resolveStateColors(
      colors,
      (TokenColorRole role, _InteractiveState? state) => colorWithOpacity(role, switch (state) {
        _InteractiveState.pressed => _pressedStateLayerOpacity,
        _InteractiveState.hovered => _hoveredStateLayerOpacity,
        _InteractiveState.focused || null => _focusedStateLayerOpacity,
      }),
    );
    final buffer = StringBuffer();
    final _StateColors? selectedStateLayerColors = _selectedStateLayerColors;
    if (selectedStateLayerColors != null) {
      buffer.writeln('if (toggleable && states.contains(WidgetState.selected)) {');
      buffer.writeln(resolve(selectedStateLayerColors));
      buffer.writeln('}');
    }
    final _StateColors? unselectedStateLayerColors = _unselectedStateLayerColors;
    if (unselectedStateLayerColors != null) {
      buffer.writeln('if (toggleable) {');
      buffer.writeln(resolve(unselectedStateLayerColors));
      buffer.writeln('}');
    }
    buffer.write(resolve(_stateLayerColors));
    return buffer.toString();
  }

  // Selected toggle buttons have no outline tokens, so they have no outline.
  String get _side {
    if (_variant != _ButtonVariant.outlined) {
      return '';
    }
    String resolve(_StateColors colors) => _resolveStateColors(
      colors,
      (TokenColorRole role, _) => 'BorderSide(color: ${color(role)}, width: width)',
    );
    return '''
  @override
  WidgetStateProperty<BorderSide?>? get side =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (toggleable && states.contains(WidgetState.selected)) {
          return BorderSide.none;
        }
        final double width = $_outlineWidthSwitch;
        if (toggleable) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(color: ${color(TokenButtonOutlined.unselectedDisabledOutlineColor)}, width: width);
          }
          ${resolve(_unselectedOutlineColors)}
        }
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: ${color(TokenButtonOutlined.disabledOutlineColor)}, width: width);
        }
        ${resolve(_outlineColors)}
      });
''';
  }

  String _sizeSwitch({
    required String xSmall,
    required String small,
    required String medium,
    required String large,
    required String xLarge,
  }) =>
      '''
switch (sizeVariant) {
      ButtonSizeVariant.xSmall => $xSmall,
      ButtonSizeVariant.small => $small,
      ButtonSizeVariant.medium => $medium,
      ButtonSizeVariant.large => $large,
      ButtonSizeVariant.xLarge => $xLarge,
    }''';

  String get _textStyleSwitch => _sizeSwitch(
    xSmall: textStyle(TokenButtonXsmall.labelText, 'Theme.of(context).textTheme'),
    small: textStyle(TokenButtonSmall.labelText, 'Theme.of(context).textTheme'),
    medium: textStyle(TokenButtonMedium.labelText, 'Theme.of(context).textTheme'),
    large: textStyle(TokenButtonLarge.labelText, 'Theme.of(context).textTheme'),
    xLarge: textStyle(TokenButtonXlarge.labelText, 'Theme.of(context).textTheme'),
  );

  // Uses symmetric padding when the leading and trailing spaces are equal, and
  // directional padding otherwise.
  String _horizontalPadding(double leadingSpace, double trailingSpace) =>
      leadingSpace == trailingSpace
      ? 'const EdgeInsets.symmetric(horizontal: $leadingSpace)'
      : 'const EdgeInsetsDirectional.only(start: $leadingSpace, end: $trailingSpace)';

  String get _paddingSwitch => _sizeSwitch(
    xSmall: _horizontalPadding(TokenButtonXsmall.leadingSpace, TokenButtonXsmall.trailingSpace),
    small: _horizontalPadding(TokenButtonSmall.leadingSpace, TokenButtonSmall.trailingSpace),
    medium: _horizontalPadding(TokenButtonMedium.leadingSpace, TokenButtonMedium.trailingSpace),
    large: _horizontalPadding(TokenButtonLarge.leadingSpace, TokenButtonLarge.trailingSpace),
    xLarge: _horizontalPadding(TokenButtonXlarge.leadingSpace, TokenButtonXlarge.trailingSpace),
  );

  // No token defines the minimum width. Keep the existing buttons' default.
  static const double _minimumWidth = 64.0;

  String get _minimumSizeSwitch => _sizeSwitch(
    xSmall: 'const Size($_minimumWidth, ${TokenButtonXsmall.containerHeight})',
    small: 'const Size($_minimumWidth, ${TokenButtonSmall.containerHeight})',
    medium: 'const Size($_minimumWidth, ${TokenButtonMedium.containerHeight})',
    large: 'const Size($_minimumWidth, ${TokenButtonLarge.containerHeight})',
    xLarge: 'const Size($_minimumWidth, ${TokenButtonXlarge.containerHeight})',
  );

  String get _iconSizeSwitch => _sizeSwitch(
    xSmall: '${TokenButtonXsmall.iconSize}',
    small: '${TokenButtonSmall.iconSize}',
    medium: '${TokenButtonMedium.iconSize}',
    large: '${TokenButtonLarge.iconSize}',
    xLarge: '${TokenButtonXlarge.iconSize}',
  );

  String get _iconLabelSpaceSwitch => _sizeSwitch(
    xSmall: '${TokenButtonXsmall.iconLabelSpace}',
    small: '${TokenButtonSmall.iconLabelSpace}',
    medium: '${TokenButtonMedium.iconLabelSpace}',
    large: '${TokenButtonLarge.iconLabelSpace}',
    xLarge: '${TokenButtonXlarge.iconLabelSpace}',
  );

  String get _outlineWidthSwitch => _sizeSwitch(
    xSmall: '${TokenButtonXsmall.outlinedOutlineWidth}',
    small: '${TokenButtonSmall.outlinedOutlineWidth}',
    medium: '${TokenButtonMedium.outlinedOutlineWidth}',
    large: '${TokenButtonLarge.outlinedOutlineWidth}',
    xLarge: '${TokenButtonXlarge.outlinedOutlineWidth}',
  );

  String get _roundShapeSwitch => _sizeSwitch(
    xSmall: shape(TokenButtonXsmall.containerShapeRound),
    small: shape(TokenButtonSmall.containerShapeRound),
    medium: shape(TokenButtonMedium.containerShapeRound),
    large: shape(TokenButtonLarge.containerShapeRound),
    xLarge: shape(TokenButtonXlarge.containerShapeRound),
  );

  String get _squareShapeSwitch => _sizeSwitch(
    xSmall: shape(TokenButtonXsmall.containerShapeSquare),
    small: shape(TokenButtonSmall.containerShapeSquare),
    medium: shape(TokenButtonMedium.containerShapeSquare),
    large: shape(TokenButtonLarge.containerShapeSquare),
    xLarge: shape(TokenButtonXlarge.containerShapeSquare),
  );

  String get _selectedRoundShapeSwitch => _sizeSwitch(
    xSmall: shape(TokenButtonXsmall.selectedContainerShapeRound),
    small: shape(TokenButtonSmall.selectedContainerShapeRound),
    medium: shape(TokenButtonMedium.selectedContainerShapeRound),
    large: shape(TokenButtonLarge.selectedContainerShapeRound),
    xLarge: shape(TokenButtonXlarge.selectedContainerShapeRound),
  );

  String get _selectedSquareShapeSwitch => _sizeSwitch(
    xSmall: shape(TokenButtonXsmall.selectedContainerShapeSquare),
    small: shape(TokenButtonSmall.selectedContainerShapeSquare),
    medium: shape(TokenButtonMedium.selectedContainerShapeSquare),
    large: shape(TokenButtonLarge.selectedContainerShapeSquare),
    xLarge: shape(TokenButtonXlarge.selectedContainerShapeSquare),
  );

  String get _pressedShapeSwitch => _sizeSwitch(
    xSmall: shape(TokenButtonXsmall.pressedContainerShape),
    small: shape(TokenButtonSmall.pressedContainerShape),
    medium: shape(TokenButtonMedium.pressedContainerShape),
    large: shape(TokenButtonLarge.pressedContainerShape),
    xLarge: shape(TokenButtonXlarge.pressedContainerShape),
  );

  // Text buttons can't be toggle buttons, so they have no selected shape.
  String get _selectedShape {
    if (!_hasToggleTokens) {
      return '';
    }
    return '''
if (toggleable && states.contains(WidgetState.selected)) {
          return switch (shapeVariant) {
            ButtonShapeVariant.round => $_selectedRoundShapeSwitch,
            ButtonShapeVariant.square => $_selectedSquareShapeSwitch,
          };
        }''';
  }

  @override
  String generateContents(String className) =>
      '''
class $className extends ButtonStyle {
  $className(
    this.context,
    this.toggleable,
    ButtonSizeVariant? sizeVariant,
    ButtonShapeVariant? shapeVariant,
  ) : _sizeVariant = sizeVariant,
      _shapeVariant = shapeVariant,
      super(
        animationDuration: kThemeChangeDuration,
        enableFeedback: true,
        alignment: Alignment.center,
      );

  final BuildContext context;
  final bool toggleable;
  final ButtonSizeVariant? _sizeVariant;
  final ButtonShapeVariant? _shapeVariant;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  ButtonSizeVariant get sizeVariant => _sizeVariant ?? ButtonSizeVariant.small;

  @override
  ButtonShapeVariant get shapeVariant => _shapeVariant ?? ButtonShapeVariant.round;

  /// The space between the icon and the label for the given [sizeVariant].
  static double iconLabelSpace(ButtonSizeVariant sizeVariant) => $_iconLabelSpaceSwitch;

  @override
  WidgetStateProperty<TextStyle?> get textStyle =>
      WidgetStatePropertyAll<TextStyle?>($_textStyleSwitch);

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        $_backgroundColor
      });

  @override
  WidgetStateProperty<Color?>? get foregroundColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        ${_resolveContentColor(disabled: colorWithOpacity(_disabledLabelTextColor, _disabledLabelTextOpacity), colors: _labelTextColors, selectedColors: _selectedLabelTextColors, unselectedColors: _unselectedLabelTextColors)}
      });

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        $_overlayColor
      });

  @override
  WidgetStateProperty<Color>? get shadowColor =>
      WidgetStatePropertyAll<Color>(${color(_containerShadowColor)});

  @override
  WidgetStateProperty<Color>? get surfaceTintColor =>
      const WidgetStatePropertyAll<Color>(Colors.transparent);

  @override
  WidgetStateProperty<double>? get elevation =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return $_disabledContainerElevation;
        }
        if (states.contains(WidgetState.pressed)) {
          return $_pressedContainerElevation;
        }
        if (states.contains(WidgetState.focused)) {
          return $_focusedContainerElevation;
        }
        return $_containerElevation;
      });

  @override
  WidgetStateProperty<EdgeInsetsGeometry>? get padding =>
      WidgetStatePropertyAll<EdgeInsetsGeometry>($_paddingSwitch);

  @override
  WidgetStateProperty<Size>? get minimumSize =>
      WidgetStatePropertyAll<Size>($_minimumSizeSwitch);

  @override
  WidgetStateProperty<Size>? get maximumSize =>
      const WidgetStatePropertyAll<Size>(Size.infinite);

$_side
  @override
  WidgetStateProperty<double>? get iconSize =>
      WidgetStatePropertyAll<double>($_iconSizeSwitch);

  @override
  WidgetStateProperty<Color>? get iconColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        ${_resolveContentColor(disabled: colorWithOpacity(_disabledIconColor, _disabledIconOpacity), colors: _iconColors, selectedColors: _selectedIconColors, unselectedColors: _unselectedIconColors)}
      });

  @override
  WidgetStateProperty<OutlinedBorder>? get shape =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return $_pressedShapeSwitch;
        }
        $_selectedShape
        return switch (shapeVariant) {
          ButtonShapeVariant.round => $_roundShapeSwitch,
          ButtonShapeVariant.square => $_squareShapeSwitch,
        };
      });

  @override
  WidgetStateProperty<MouseCursor?>? get mouseCursor => WidgetStateMouseCursor.adaptiveClickable;

  @override
  VisualDensity? get visualDensity => VisualDensity.standard;

  @override
  MaterialTapTargetSize? get tapTargetSize => MaterialTapTargetSize.padded;

  @override
  InteractiveInkFeatureFactory? get splashFactory => Theme.of(context).splashFactory;
}
''';
}
