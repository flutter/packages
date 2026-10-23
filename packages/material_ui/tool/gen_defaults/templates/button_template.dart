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
    _ => throw UnsupportedError('Unsupported expressive button template name: $name'),
  };

  @override
  String get parentFilePath => switch (_variant) {
    _ButtonVariant.elevated => 'elevated_button.dart',
    _ButtonVariant.filled || _ButtonVariant.filledTonal => 'filled_button.dart',
    _ButtonVariant.outlined || _ButtonVariant.text => throw UnsupportedError(
      'Unsupported expressive button template name: $name',
    ),
  };

  // Returns the token of this template's button variant. The elevated, filled,
  // and filled tonal buttons have the same set of tokens.
  T _byVariant<T>({required T elevated, required T filled, required T filledTonal}) =>
      switch (_variant) {
        _ButtonVariant.elevated => elevated,
        _ButtonVariant.filled => filled,
        _ButtonVariant.filledTonal => filledTonal,
        _ButtonVariant.outlined || _ButtonVariant.text => throw UnsupportedError(
          'Unsupported expressive button template name: $name',
        ),
      };

  TokenColorRole get _containerColor => _byVariant(
    elevated: TokenButtonElevated.containerColor,
    filled: TokenButtonFilled.containerColor,
    filledTonal: TokenButtonTonal.containerColor,
  );

  TokenColorRole get _disabledContainerColor => _byVariant(
    elevated: TokenButtonElevated.disabledContainerColor,
    filled: TokenButtonFilled.disabledContainerColor,
    filledTonal: TokenButtonTonal.disabledContainerColor,
  );

  double get _disabledContainerOpacity => _byVariant(
    elevated: TokenButtonElevated.disabledContainerOpacity,
    filled: TokenButtonFilled.disabledContainerOpacity,
    filledTonal: TokenButtonTonal.disabledContainerOpacity,
  );

  TokenColorRole get _selectedContainerColor => _byVariant(
    elevated: TokenButtonElevated.selectedContainerColor,
    filled: TokenButtonFilled.selectedContainerColor,
    filledTonal: TokenButtonTonal.selectedContainerColor,
  );

  TokenColorRole get _unselectedContainerColor => _byVariant(
    elevated: TokenButtonElevated.unselectedContainerColor,
    filled: TokenButtonFilled.unselectedContainerColor,
    filledTonal: TokenButtonTonal.unselectedContainerColor,
  );

  TokenColorRole get _containerShadowColor => _byVariant(
    elevated: TokenButtonElevated.containerShadowColor,
    filled: TokenButtonFilled.containerShadowColor,
    filledTonal: TokenButtonTonal.containerShadowColor,
  );

  double get _containerElevation => _byVariant(
    elevated: TokenButtonElevated.containerElevation,
    filled: TokenButtonFilled.containerElevation,
    filledTonal: TokenButtonTonal.containerElevation,
  );

  double get _disabledContainerElevation => _byVariant(
    elevated: TokenButtonElevated.disabledContainerElevation,
    filled: TokenButtonFilled.disabledContainerElevation,
    filledTonal: TokenButtonTonal.disabledContainerElevation,
  );

  double get _pressedContainerElevation => _byVariant(
    elevated: TokenButtonElevated.pressedContainerElevation,
    filled: TokenButtonFilled.pressedContainerElevation,
    filledTonal: TokenButtonTonal.pressedContainerElevation,
  );

  double get _focusedContainerElevation => _byVariant(
    elevated: TokenButtonElevated.focusedContainerElevation,
    filled: TokenButtonFilled.focusedContainerElevation,
    filledTonal: TokenButtonTonal.focusedContainerElevation,
  );

  TokenColorRole get _labelTextColor => _byVariant(
    elevated: TokenButtonElevated.labelTextColor,
    filled: TokenButtonFilled.labelTextColor,
    filledTonal: TokenButtonTonal.labelTextColor,
  );

  TokenColorRole get _disabledLabelTextColor => _byVariant(
    elevated: TokenButtonElevated.disabledLabelTextColor,
    filled: TokenButtonFilled.disabledLabelTextColor,
    filledTonal: TokenButtonTonal.disabledLabelTextColor,
  );

  double get _disabledLabelTextOpacity => _byVariant(
    elevated: TokenButtonElevated.disabledLabelTextOpacity,
    filled: TokenButtonFilled.disabledLabelTextOpacity,
    filledTonal: TokenButtonTonal.disabledLabelTextOpacity,
  );

  TokenColorRole get _selectedLabelTextColor => _byVariant(
    elevated: TokenButtonElevated.selectedLabelTextColor,
    filled: TokenButtonFilled.selectedLabelTextColor,
    filledTonal: TokenButtonTonal.selectedLabelTextColor,
  );

  TokenColorRole get _unselectedLabelTextColor => _byVariant(
    elevated: TokenButtonElevated.unselectedLabelTextColor,
    filled: TokenButtonFilled.unselectedLabelTextColor,
    filledTonal: TokenButtonTonal.unselectedLabelTextColor,
  );

  TokenColorRole get _iconColor => _byVariant(
    elevated: TokenButtonElevated.iconColor,
    filled: TokenButtonFilled.iconColor,
    filledTonal: TokenButtonTonal.iconColor,
  );

  TokenColorRole get _disabledIconColor => _byVariant(
    elevated: TokenButtonElevated.disabledIconColor,
    filled: TokenButtonFilled.disabledIconColor,
    filledTonal: TokenButtonTonal.disabledIconColor,
  );

  double get _disabledIconOpacity => _byVariant(
    elevated: TokenButtonElevated.disabledIconOpacity,
    filled: TokenButtonFilled.disabledIconOpacity,
    filledTonal: TokenButtonTonal.disabledIconOpacity,
  );

  TokenColorRole get _selectedIconColor => _byVariant(
    elevated: TokenButtonElevated.selectedIconColor,
    filled: TokenButtonFilled.selectedIconColor,
    filledTonal: TokenButtonTonal.selectedIconColor,
  );

  TokenColorRole get _unselectedIconColor => _byVariant(
    elevated: TokenButtonElevated.unselectedIconColor,
    filled: TokenButtonFilled.unselectedIconColor,
    filledTonal: TokenButtonTonal.unselectedIconColor,
  );

  double get _pressedStateLayerOpacity => _byVariant(
    elevated: TokenButtonElevated.pressedStateLayerOpacity,
    filled: TokenButtonFilled.pressedStateLayerOpacity,
    filledTonal: TokenButtonTonal.pressedStateLayerOpacity,
  );

  double get _hoveredStateLayerOpacity => _byVariant(
    elevated: TokenButtonElevated.hoveredStateLayerOpacity,
    filled: TokenButtonFilled.hoveredStateLayerOpacity,
    filledTonal: TokenButtonTonal.hoveredStateLayerOpacity,
  );

  double get _focusedStateLayerOpacity => _byVariant(
    elevated: TokenButtonElevated.focusedStateLayerOpacity,
    filled: TokenButtonFilled.focusedStateLayerOpacity,
    filledTonal: TokenButtonTonal.focusedStateLayerOpacity,
  );

  // The overlay colors of a button that isn't toggleable.
  String get _stateLayer => _stateLayerFor(
    pressed: _byVariant(
      elevated: TokenButtonElevated.pressedStateLayerColor,
      filled: TokenButtonFilled.pressedStateLayerColor,
      filledTonal: TokenButtonTonal.pressedStateLayerColor,
    ),
    hovered: _byVariant(
      elevated: TokenButtonElevated.hoveredStateLayerColor,
      filled: TokenButtonFilled.hoveredStateLayerColor,
      filledTonal: TokenButtonTonal.hoveredStateLayerColor,
    ),
    focused: _byVariant(
      elevated: TokenButtonElevated.focusedStateLayerColor,
      filled: TokenButtonFilled.focusedStateLayerColor,
      filledTonal: TokenButtonTonal.focusedStateLayerColor,
    ),
  );

  // The overlay colors of a selected toggle button.
  String get _selectedStateLayer => _stateLayerFor(
    pressed: _byVariant(
      elevated: TokenButtonElevated.selectedPressedStateLayerColor,
      filled: TokenButtonFilled.selectedPressedStateLayerColor,
      filledTonal: TokenButtonTonal.selectedPressedStateLayerColor,
    ),
    hovered: _byVariant(
      elevated: TokenButtonElevated.selectedHoveredStateLayerColor,
      filled: TokenButtonFilled.selectedHoveredStateLayerColor,
      filledTonal: TokenButtonTonal.selectedHoveredStateLayerColor,
    ),
    focused: _byVariant(
      elevated: TokenButtonElevated.selectedFocusedStateLayerColor,
      filled: TokenButtonFilled.selectedFocusedStateLayerColor,
      filledTonal: TokenButtonTonal.selectedFocusedStateLayerColor,
    ),
  );

  // The overlay colors of an unselected toggle button.
  String get _unselectedStateLayer => _stateLayerFor(
    pressed: _byVariant(
      elevated: TokenButtonElevated.unselectedPressedStateLayerColor,
      filled: TokenButtonFilled.unselectedPressedStateLayerColor,
      filledTonal: TokenButtonTonal.unselectedPressedStateLayerColor,
    ),
    hovered: _byVariant(
      elevated: TokenButtonElevated.unselectedHoveredStateLayerColor,
      filled: TokenButtonFilled.unselectedHoveredStateLayerColor,
      filledTonal: TokenButtonTonal.unselectedHoveredStateLayerColor,
    ),
    focused: _byVariant(
      elevated: TokenButtonElevated.unselectedFocusedStateLayerColor,
      filled: TokenButtonFilled.unselectedFocusedStateLayerColor,
      filledTonal: TokenButtonTonal.unselectedFocusedStateLayerColor,
    ),
  );

  String _stateLayerFor({
    required TokenColorRole pressed,
    required TokenColorRole hovered,
    required TokenColorRole focused,
  }) =>
      '''
if (states.contains(WidgetState.pressed)) {
          return ${colorWithOpacity(pressed, _pressedStateLayerOpacity)};
        }
        if (states.contains(WidgetState.hovered)) {
          return ${colorWithOpacity(hovered, _hoveredStateLayerOpacity)};
        }
        if (states.contains(WidgetState.focused)) {
          return ${colorWithOpacity(focused, _focusedStateLayerOpacity)};
        }
        return null;''';

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
        if (states.contains(WidgetState.disabled)) {
          return ${colorWithOpacity(_disabledContainerColor, _disabledContainerOpacity)};
        }
        if (toggleable && states.contains(WidgetState.selected)) {
          return ${color(_selectedContainerColor)};
        }
        if (toggleable) {
          return ${color(_unselectedContainerColor)};
        }
        return ${color(_containerColor)};
      });

  @override
  WidgetStateProperty<Color?>? get foregroundColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return ${colorWithOpacity(_disabledLabelTextColor, _disabledLabelTextOpacity)};
        }
        if (toggleable && states.contains(WidgetState.selected)) {
          return ${color(_selectedLabelTextColor)};
        }
        if (toggleable) {
          return ${color(_unselectedLabelTextColor)};
        }
        return ${color(_labelTextColor)};
      });

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (toggleable && states.contains(WidgetState.selected)) {
          $_selectedStateLayer
        }
        if (toggleable) {
          $_unselectedStateLayer
        }
        $_stateLayer
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

  @override
  WidgetStateProperty<double>? get iconSize =>
      WidgetStatePropertyAll<double>($_iconSizeSwitch);

  @override
  WidgetStateProperty<Color>? get iconColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return ${colorWithOpacity(_disabledIconColor, _disabledIconOpacity)};
        }
        if (toggleable && states.contains(WidgetState.selected)) {
          return ${color(_selectedIconColor)};
        }
        if (toggleable) {
          return ${color(_unselectedIconColor)};
        }
        return ${color(_iconColor)};
      });

  @override
  WidgetStateProperty<OutlinedBorder>? get shape =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return $_pressedShapeSwitch;
        }
        if (toggleable && states.contains(WidgetState.selected)) {
          return switch (shapeVariant) {
            ButtonShapeVariant.round => $_selectedRoundShapeSwitch,
            ButtonShapeVariant.square => $_selectedSquareShapeSwitch,
          };
        }
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
