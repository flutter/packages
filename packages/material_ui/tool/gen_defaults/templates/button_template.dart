// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/button.dart';
import '../data/button_elevated.dart';
import '../data/button_filled.dart';
import '../data/button_outlined.dart';
import '../data/button_text.dart';
import '../data/button_tonal.dart';
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
    return ${colorWithOpacity(TokenButton.disabledContainerColor, _legacyDisabledContainerOpacity, '_colors')};
  }
  return ${color(containerColor, '_colors')};
})''';
  }

  String get _shadowColor {
    return switch (_variant) {
      _ButtonVariant.elevated =>
        'MaterialStatePropertyAll<Color>(${color(TokenButtonElevated.containerShadowColor, '_colors')})',
      _ButtonVariant.filled =>
        'MaterialStatePropertyAll<Color>(${color(TokenButtonFilled.containerShadowColor, '_colors')})',
      _ButtonVariant.filledTonal =>
        'MaterialStatePropertyAll<Color>(${color(TokenButtonTonal.containerShadowColor, '_colors')})',
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
      return BorderSide(color: ${colorWithOpacity(TokenButton.disabledContainerColor, _legacyDisabledContainerOpacity, '_colors')});
    }
    if (states.contains(WidgetState.focused)) {
      return BorderSide(color: ${color(TokenColorRole.primary, '_colors')});
    }
    return BorderSide(color: ${color(TokenColorRole.outline, '_colors')});
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
          return ${colorWithOpacity(TokenButton.disabledLabelTextColor, TokenButton.disabledLabelTextOpacity, '_colors')};
        }
        return ${color(_labelTextColor, '_colors')};
      });

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return ${colorWithOpacity(_stateLayerColor, _pressedStateLayerOpacity, '_colors')};
        }
        if (states.contains(WidgetState.hovered)) {
          return ${colorWithOpacity(_stateLayerColor, _hoveredStateLayerOpacity, '_colors')};
        }
        if (states.contains(WidgetState.focused)) {
          return ${colorWithOpacity(_stateLayerColor, _focusedStateLayerOpacity, '_colors')};
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
        return ${colorWithOpacity(TokenButton.disabledIconColor, TokenButton.disabledIconOpacity, '_colors')};
      }
      if (states.contains(WidgetState.pressed)) {
        return ${color(_iconColor, '_colors')};
      }
      if (states.contains(WidgetState.hovered)) {
        return ${color(_iconColor, '_colors')};
      }
      if (states.contains(WidgetState.focused)) {
        return ${color(_iconColor, '_colors')};
      }
      return ${color(_iconColor, '_colors')};
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
