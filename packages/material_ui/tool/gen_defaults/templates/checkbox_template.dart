// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/checkbox.dart';
import 'template.dart';

class CheckboxTemplateM3 extends TokenTemplateM3 {
  const CheckboxTemplateM3();

  @override
  String get name => 'Checkbox';

  @override
  String get parentFilePath => 'checkbox.dart';

  @override
  String generateContents(String className) =>
      '''
class $className extends CheckboxThemeData {
  $className(BuildContext context)
    : _theme = Theme.of(context),
      _colors = Theme.of(context).colorScheme;

  final ThemeData _theme;
  final ColorScheme _colors;

  @override
  WidgetStateBorderSide? get side {
    return WidgetStateBorderSide.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        if (states.contains(WidgetState.selected)) {
          return ${border('Colors.transparent', width: TokenCheckbox.unselectedDisabledOutlineWidth, prefix: 'const ')};
        }
        return ${border(colorWithOpacity(TokenCheckbox.unselectedDisabledOutlineColor, TokenCheckbox.unselectedDisabledContainerOpacity, '_colors'), width: TokenCheckbox.unselectedDisabledOutlineWidth)};
      }
      if (states.contains(WidgetState.selected)) {
        return ${border('Colors.transparent', width: TokenCheckbox.selectedOutlineWidth, prefix: 'const ')};
      }
      if (states.contains(WidgetState.error)) {
        return ${border(color(TokenCheckbox.unselectedErrorOutlineColor, '_colors'), width: TokenCheckbox.unselectedOutlineWidth)};
      }
      if (states.contains(WidgetState.pressed)) {
        return ${border(color(TokenCheckbox.unselectedPressedOutlineColor, '_colors'), width: TokenCheckbox.unselectedPressedOutlineWidth)};
      }
      if (states.contains(WidgetState.hovered)) {
        return ${border(color(TokenCheckbox.unselectedHoverOutlineColor, '_colors'), width: TokenCheckbox.unselectedHoverOutlineWidth)};
      }
      if (states.contains(WidgetState.focused)) {
        return ${border(color(TokenCheckbox.unselectedFocusOutlineColor, '_colors'), width: TokenCheckbox.unselectedFocusOutlineWidth)};
      }
      return ${border(color(TokenCheckbox.unselectedOutlineColor, '_colors'), width: TokenCheckbox.unselectedOutlineWidth)};
    });
  }

  @override
  WidgetStateProperty<Color> get fillColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        if (states.contains(WidgetState.selected)) {
          return ${colorWithOpacity(TokenCheckbox.selectedDisabledContainerColor, TokenCheckbox.selectedDisabledContainerOpacity, '_colors')};
        }
        return Colors.transparent;
      }
      if (states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.error)) {
          return ${color(TokenCheckbox.selectedErrorContainerColor, '_colors')};
        }
        return ${color(TokenCheckbox.selectedContainerColor, '_colors')};
      }
      return Colors.transparent;
    });
  }

  @override
  WidgetStateProperty<Color> get checkColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        if (states.contains(WidgetState.selected)) {
          return ${color(TokenCheckbox.selectedDisabledIconColor, '_colors')};
        }
        return Colors.transparent; // No icons available when the checkbox is unselected.
      }
      if (states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.error)) {
          return ${color(TokenCheckbox.selectedErrorIconColor, '_colors')};
        }
        return ${color(TokenCheckbox.selectedIconColor, '_colors')};
      }
      return Colors.transparent; // No icons available when the checkbox is unselected.
    });
  }

  @override
  WidgetStateProperty<Color> get overlayColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.error)) {
        if (states.contains(WidgetState.pressed)) {
          return ${colorWithOpacity(TokenCheckbox.errorPressedStateLayerColor, TokenCheckbox.errorPressedStateLayerOpacity, '_colors')};
        }
        if (states.contains(WidgetState.hovered)) {
          return ${colorWithOpacity(TokenCheckbox.errorHoverStateLayerColor, TokenCheckbox.errorHoverStateLayerOpacity, '_colors')};
        }
        if (states.contains(WidgetState.focused)) {
          return ${colorWithOpacity(TokenCheckbox.errorFocusStateLayerColor, TokenCheckbox.errorFocusStateLayerOpacity, '_colors')};
        }
      }
      if (states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.pressed)) {
          return ${colorWithOpacity(TokenCheckbox.selectedPressedStateLayerColor, TokenCheckbox.selectedPressedStateLayerOpacity, '_colors')};
        }
        if (states.contains(WidgetState.hovered)) {
          return ${colorWithOpacity(TokenCheckbox.selectedHoverStateLayerColor, TokenCheckbox.selectedHoverStateLayerOpacity, '_colors')};
        }
        if (states.contains(WidgetState.focused)) {
          return ${colorWithOpacity(TokenCheckbox.selectedFocusStateLayerColor, TokenCheckbox.selectedFocusStateLayerOpacity, '_colors')};
        }
        return Colors.transparent;
      }
      if (states.contains(WidgetState.pressed)) {
        return ${colorWithOpacity(TokenCheckbox.unselectedPressedStateLayerColor, TokenCheckbox.unselectedPressedStateLayerOpacity, '_colors')};
      }
      if (states.contains(WidgetState.hovered)) {
        return ${colorWithOpacity(TokenCheckbox.unselectedHoverStateLayerColor, TokenCheckbox.unselectedHoverStateLayerOpacity, '_colors')};
      }
      if (states.contains(WidgetState.focused)) {
        return ${colorWithOpacity(TokenCheckbox.unselectedFocusStateLayerColor, TokenCheckbox.unselectedFocusStateLayerOpacity, '_colors')};
      }
      return Colors.transparent;
    });
  }

  @override
  double get splashRadius => ${number(TokenCheckbox.stateLayerSize)} / 2;

  @override
  MaterialTapTargetSize get materialTapTargetSize => _theme.materialTapTargetSize;

  @override
  VisualDensity get visualDensity => VisualDensity.standard;

  @override
  OutlinedBorder get shape => ${shape(TokenCheckbox.containerShape)};
}
''';
}
