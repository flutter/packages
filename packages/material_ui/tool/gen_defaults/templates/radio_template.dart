// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/radio_button.dart';
import 'template.dart';

class RadioTemplateM3 extends TokenTemplateM3 {
  const RadioTemplateM3();

  @override
  String get name => 'Radio';

  @override
  String get parentFilePath => 'radio.dart';

  @override
  String generateContents(String className) =>
      '''
class $className extends RadioThemeData {
  $className(this.context);

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;

  @override
  WidgetStateProperty<Color> get fillColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.disabled)) {
          return ${colorWithOpacity(TokenRadioButton.disabledSelectedIconColor, TokenRadioButton.disabledSelectedIconOpacity)};
        }
        if (states.contains(WidgetState.pressed)) {
          return ${color(TokenRadioButton.selectedPressedIconColor)};
        }
        if (states.contains(WidgetState.hovered)) {
          return ${color(TokenRadioButton.selectedHoverIconColor)};
        }
        if (states.contains(WidgetState.focused)) {
          return ${color(TokenRadioButton.selectedFocusIconColor)};
        }
        return ${color(TokenRadioButton.selectedIconColor)};
      }
      if (states.contains(WidgetState.disabled)) {
        return ${colorWithOpacity(TokenRadioButton.disabledUnselectedIconColor, TokenRadioButton.disabledUnselectedIconOpacity)};
      }
      if (states.contains(WidgetState.pressed)) {
        return ${color(TokenRadioButton.unselectedPressedIconColor)};
      }
      if (states.contains(WidgetState.hovered)) {
        return ${color(TokenRadioButton.unselectedHoverIconColor)};
      }
      if (states.contains(WidgetState.focused)) {
        return ${color(TokenRadioButton.unselectedFocusIconColor)};
      }
      return ${color(TokenRadioButton.unselectedIconColor)};
    });
  }

  @override
  WidgetStateProperty<Color> get overlayColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.pressed)) {
          return ${colorWithOpacity(TokenRadioButton.selectedPressedStateLayerColor, TokenRadioButton.selectedPressedStateLayerOpacity)};
        }
        if (states.contains(WidgetState.hovered)) {
          return ${colorWithOpacity(TokenRadioButton.selectedHoverStateLayerColor, TokenRadioButton.selectedHoverStateLayerOpacity)};
        }
        if (states.contains(WidgetState.focused)) {
          return ${colorWithOpacity(TokenRadioButton.selectedFocusStateLayerColor, TokenRadioButton.selectedFocusStateLayerOpacity)};
        }
        return Colors.transparent;
      }
      if (states.contains(WidgetState.pressed)) {
        return ${colorWithOpacity(TokenRadioButton.unselectedPressedStateLayerColor, TokenRadioButton.unselectedPressedStateLayerOpacity)};
      }
      if (states.contains(WidgetState.hovered)) {
        return ${colorWithOpacity(TokenRadioButton.unselectedHoverStateLayerColor, TokenRadioButton.unselectedHoverStateLayerOpacity)};
      }
      if (states.contains(WidgetState.focused)) {
        return ${colorWithOpacity(TokenRadioButton.unselectedFocusStateLayerColor, TokenRadioButton.unselectedFocusStateLayerOpacity)};
      }
      return Colors.transparent;
    });
  }

  @override
  MaterialTapTargetSize get materialTapTargetSize => _theme.materialTapTargetSize;

  @override
  VisualDensity get visualDensity => _theme.visualDensity;

  @override
  WidgetStateProperty<Color> get backgroundColor =>
      WidgetStateProperty.all<Color>(Colors.transparent);
}
''';
}
