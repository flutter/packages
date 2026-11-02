// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/outlined_segmented_button.dart';
import 'template.dart';

class SegmentedButtonTemplateM3 extends TokenTemplateM3 {
  const SegmentedButtonTemplateM3();

  @override
  String get name => 'Segmented Button';

  @override
  String get parentFilePath => 'segmented_button.dart';

  @override
  String generateContents(String className) =>
      '''
class $className extends SegmentedButtonThemeData {
  $className(this.context);
  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;
  @override ButtonStyle? get style {
    return ButtonStyle(
      textStyle: WidgetStatePropertyAll<TextStyle?>(${textStyle(TokenOutlinedSegmentedButton.labelTextType, '_theme.textTheme')}),
      backgroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return null;
        }
        if (states.contains(WidgetState.selected)) {
          return ${color(TokenOutlinedSegmentedButton.selectedContainerColor)};
        }
        return null;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return ${colorWithOpacity(TokenOutlinedSegmentedButton.disabledLabelTextColor, TokenOutlinedSegmentedButton.disabledLabelTextOpacity)};
        }
        if (states.contains(WidgetState.selected)) {
          if (states.contains(WidgetState.pressed)) {
            return ${color(TokenOutlinedSegmentedButton.selectedPressedLabelTextColor)};
          }
          if (states.contains(WidgetState.hovered)) {
            return ${color(TokenOutlinedSegmentedButton.selectedHoverLabelTextColor)};
          }
          if (states.contains(WidgetState.focused)) {
            return ${color(TokenOutlinedSegmentedButton.selectedFocusLabelTextColor)};
          }
          return ${color(TokenOutlinedSegmentedButton.selectedLabelTextColor)};
        } else {
          if (states.contains(WidgetState.pressed)) {
            return ${color(TokenOutlinedSegmentedButton.unselectedPressedLabelTextColor)};
          }
          if (states.contains(WidgetState.hovered)) {
            return ${color(TokenOutlinedSegmentedButton.unselectedHoverLabelTextColor)};
          }
          if (states.contains(WidgetState.focused)) {
            return ${color(TokenOutlinedSegmentedButton.unselectedFocusLabelTextColor)};
          }
          return ${color(TokenOutlinedSegmentedButton.unselectedLabelTextColor)};
        }
      }),
      overlayColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          if (states.contains(WidgetState.pressed)) {
            return ${colorWithOpacity(TokenOutlinedSegmentedButton.selectedPressedStateLayerColor, TokenOutlinedSegmentedButton.pressedStateLayerOpacity)};
          }
          if (states.contains(WidgetState.hovered)) {
            return ${colorWithOpacity(TokenOutlinedSegmentedButton.selectedHoverStateLayerColor, TokenOutlinedSegmentedButton.hoverStateLayerOpacity)};
          }
          if (states.contains(WidgetState.focused)) {
            return ${colorWithOpacity(TokenOutlinedSegmentedButton.selectedFocusStateLayerColor, TokenOutlinedSegmentedButton.focusStateLayerOpacity)};
          }
        } else {
          if (states.contains(WidgetState.pressed)) {
            return ${colorWithOpacity(TokenOutlinedSegmentedButton.unselectedPressedStateLayerColor, TokenOutlinedSegmentedButton.pressedStateLayerOpacity)};
          }
          if (states.contains(WidgetState.hovered)) {
            return ${colorWithOpacity(TokenOutlinedSegmentedButton.unselectedHoverStateLayerColor, TokenOutlinedSegmentedButton.hoverStateLayerOpacity)};
          }
          if (states.contains(WidgetState.focused)) {
            return ${colorWithOpacity(TokenOutlinedSegmentedButton.unselectedFocusStateLayerColor, TokenOutlinedSegmentedButton.focusStateLayerOpacity)};
          }
        }
        return null;
      }),
      surfaceTintColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
      elevation: const WidgetStatePropertyAll<double>(0),
      iconSize: const WidgetStatePropertyAll<double?>(${TokenOutlinedSegmentedButton.withIconIconSize}),
      side: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return ${border(colorWithOpacity(TokenOutlinedSegmentedButton.disabledOutlineColor, TokenOutlinedSegmentedButton.disabledOutlineOpacity), width: TokenOutlinedSegmentedButton.outlineWidth)};
        }
        return ${border(color(TokenOutlinedSegmentedButton.outlineColor), width: TokenOutlinedSegmentedButton.outlineWidth)};
      }),
      shape: const WidgetStatePropertyAll<OutlinedBorder>(${shape(TokenOutlinedSegmentedButton.shape, '')}),
      minimumSize: const WidgetStatePropertyAll<Size?>(Size.fromHeight(${TokenOutlinedSegmentedButton.containerHeight})),
    );
  }
  @override
  Widget? get selectedIcon => const Icon(Icons.check);

  static WidgetStateProperty<Color?> resolveStateColor(
    Color? unselectedColor,
    Color? selectedColor,
    Color? overlayColor,
  ) {
    final Color? selected = overlayColor ?? selectedColor;
    final Color? unselected = overlayColor ?? unselectedColor;
    return WidgetStateProperty<Color?>.fromMap(
      <WidgetStatesConstraint, Color?>{
        WidgetState.selected & WidgetState.pressed: selected?.withOpacity(${TokenOutlinedSegmentedButton.pressedStateLayerOpacity}),
        WidgetState.selected & WidgetState.hovered: selected?.withOpacity(${TokenOutlinedSegmentedButton.hoverStateLayerOpacity}),
        WidgetState.selected & WidgetState.focused: selected?.withOpacity(${TokenOutlinedSegmentedButton.focusStateLayerOpacity}),
        WidgetState.pressed: unselected?.withOpacity(${TokenOutlinedSegmentedButton.pressedStateLayerOpacity}),
        WidgetState.hovered: unselected?.withOpacity(${TokenOutlinedSegmentedButton.hoverStateLayerOpacity}),
        WidgetState.focused: unselected?.withOpacity(${TokenOutlinedSegmentedButton.focusStateLayerOpacity}),
        WidgetState.any: Colors.transparent,
      },
    );
  }
}
''';
}
