// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/color_role.dart';
import '../data/switch.dart';
import 'template.dart';

class SwitchTemplateM3 extends TokenTemplateM3 {
  const SwitchTemplateM3();

  @override
  String get name => 'Switch';

  @override
  String get parentFilePath => 'switch.dart';

  // TODO(QuncCccccc): Remove this legacy color when the selected icon color
  // change can be made separately from this template migration.
  static const TokenColorRole _legacySelectedIconColor = TokenColorRole.onPrimaryContainer;

  @override
  String generateContents(String className) =>
      '''
class $className extends SwitchThemeData {
  $className(this.context);

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  WidgetStateProperty<Color> get thumbColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        if (states.contains(WidgetState.selected)) {
          return ${colorWithOpacity(TokenSwitch.disabledSelectedHandleColor, TokenSwitch.disabledSelectedHandleOpacity)};
        }
        return ${colorWithOpacity(TokenSwitch.disabledUnselectedHandleColor, TokenSwitch.disabledUnselectedHandleOpacity)};
      }
      if (states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.pressed)) {
          return ${color(TokenSwitch.selectedPressedHandleColor)};
        }
        if (states.contains(WidgetState.hovered)) {
          return ${color(TokenSwitch.selectedHoverHandleColor)};
        }
        if (states.contains(WidgetState.focused)) {
          return ${color(TokenSwitch.selectedFocusHandleColor)};
        }
        return ${color(TokenSwitch.selectedHandleColor)};
      }
      if (states.contains(WidgetState.pressed)) {
        return ${color(TokenSwitch.unselectedPressedHandleColor)};
      }
      if (states.contains(WidgetState.hovered)) {
        return ${color(TokenSwitch.unselectedHoverHandleColor)};
      }
      if (states.contains(WidgetState.focused)) {
        return ${color(TokenSwitch.unselectedFocusHandleColor)};
      }
      return ${color(TokenSwitch.unselectedHandleColor)};
    });
  }

  @override
  WidgetStateProperty<Color> get trackColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        if (states.contains(WidgetState.selected)) {
          return ${colorWithOpacity(TokenSwitch.disabledSelectedTrackColor, TokenSwitch.disabledTrackOpacity)};
        }
        return ${colorWithOpacity(TokenSwitch.disabledUnselectedTrackColor, TokenSwitch.disabledTrackOpacity)};
      }
      if (states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.pressed)) {
          return ${color(TokenSwitch.selectedPressedTrackColor)};
        }
        if (states.contains(WidgetState.hovered)) {
          return ${color(TokenSwitch.selectedHoverTrackColor)};
        }
        if (states.contains(WidgetState.focused)) {
          return ${color(TokenSwitch.selectedFocusTrackColor)};
        }
        return ${color(TokenSwitch.selectedTrackColor)};
      }
      if (states.contains(WidgetState.pressed)) {
        return ${color(TokenSwitch.unselectedPressedTrackColor)};
      }
      if (states.contains(WidgetState.hovered)) {
        return ${color(TokenSwitch.unselectedHoverTrackColor)};
      }
      if (states.contains(WidgetState.focused)) {
        return ${color(TokenSwitch.unselectedFocusTrackColor)};
      }
      return ${color(TokenSwitch.unselectedTrackColor)};
    });
  }

  @override
  WidgetStateProperty<Color?> get trackOutlineColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.transparent;
      }
      if (states.contains(WidgetState.disabled)) {
        return ${colorWithOpacity(TokenSwitch.disabledUnselectedTrackOutlineColor, TokenSwitch.disabledTrackOpacity)};
      }
      return ${color(TokenSwitch.unselectedTrackOutlineColor)};
    });
  }

  @override
  WidgetStateProperty<Color?> get overlayColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.pressed)) {
          return ${colorWithOpacity(TokenSwitch.selectedPressedStateLayerColor, TokenSwitch.selectedPressedStateLayerOpacity)};
        }
        if (states.contains(WidgetState.hovered)) {
          return ${colorWithOpacity(TokenSwitch.selectedHoverStateLayerColor, TokenSwitch.selectedHoverStateLayerOpacity)};
        }
        if (states.contains(WidgetState.focused)) {
          return ${colorWithOpacity(TokenSwitch.selectedFocusStateLayerColor, TokenSwitch.selectedFocusStateLayerOpacity)};
        }
        return null;
      }
      if (states.contains(WidgetState.pressed)) {
        return ${colorWithOpacity(TokenSwitch.unselectedPressedStateLayerColor, TokenSwitch.unselectedPressedStateLayerOpacity)};
      }
      if (states.contains(WidgetState.hovered)) {
        return ${colorWithOpacity(TokenSwitch.unselectedHoverStateLayerColor, TokenSwitch.unselectedHoverStateLayerOpacity)};
      }
      if (states.contains(WidgetState.focused)) {
        return ${colorWithOpacity(TokenSwitch.unselectedFocusStateLayerColor, TokenSwitch.unselectedFocusStateLayerOpacity)};
      }
      return null;
    });
  }

  @override
  WidgetStateProperty<MouseCursor> get mouseCursor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states)
      => WidgetStateMouseCursor.clickable.resolve(states));
  }

  @override
  MaterialStatePropertyAll<double> get trackOutlineWidth => const MaterialStatePropertyAll<double>(${TokenSwitch.trackOutlineWidth});

  @override
  double get splashRadius => ${TokenSwitch.stateLayerSize} / 2;

  @override
  EdgeInsetsGeometry? get padding => const EdgeInsets.symmetric(horizontal: 4);
}

class _SwitchConfigM3 with _SwitchConfig {
  _SwitchConfigM3(this.context)
    : _colors = Theme.of(context).colorScheme;

  BuildContext context;
  final ColorScheme _colors;

  static const double iconSize = ${TokenSwitch.unselectedIconSize};

  @override
  double get activeThumbRadius => ${TokenSwitch.selectedHandleWidth} / 2;

  @override
  WidgetStateProperty<Color> get iconColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        if (states.contains(WidgetState.selected)) {
          return ${colorWithOpacity(TokenSwitch.disabledSelectedIconColor, TokenSwitch.disabledSelectedIconOpacity)};
        }
        return ${colorWithOpacity(TokenSwitch.disabledUnselectedIconColor, TokenSwitch.disabledUnselectedIconOpacity)};
      }
      if (states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.pressed)) {
          return ${color(_legacySelectedIconColor)};
        }
        if (states.contains(WidgetState.hovered)) {
          return ${color(_legacySelectedIconColor)};
        }
        if (states.contains(WidgetState.focused)) {
          return ${color(_legacySelectedIconColor)};
        }
        return ${color(_legacySelectedIconColor)};
      }
      if (states.contains(WidgetState.pressed)) {
        return ${color(TokenSwitch.unselectedPressedIconColor)};
      }
      if (states.contains(WidgetState.hovered)) {
        return ${color(TokenSwitch.unselectedHoverIconColor)};
      }
      if (states.contains(WidgetState.focused)) {
        return ${color(TokenSwitch.unselectedFocusIconColor)};
      }
      return ${color(TokenSwitch.unselectedIconColor)};
    });
  }

  @override
  double get inactiveThumbRadius => ${TokenSwitch.unselectedHandleWidth} / 2;

  @override
  double get pressedThumbRadius => ${TokenSwitch.pressedHandleWidth} / 2;

  @override
  double get switchHeight => switchMinSize.height + 8.0;

  @override
  double get switchHeightCollapsed => switchMinSize.height;

  @override
  double get switchWidth => 52.0;

  @override
  double get thumbRadiusWithIcon => ${TokenSwitch.withIconHandleWidth} / 2;

  @override
  List<BoxShadow>? get thumbShadow => kElevationToShadow[0];

  @override
  double get trackHeight => ${TokenSwitch.trackHeight};

  @override
  double get trackWidth => ${TokenSwitch.trackWidth};

  // The thumb size at the middle of the track. Hand coded default based on the animation specs.
  @override
  Size get transitionalThumbSize => const Size(34, 22);

  // Hand coded default based on the animation specs.
  @override
  int get toggleDuration => 300;

  // Hand coded default based on the animation specs.
  @override
  double? get thumbOffset => null;

  @override
  Size get switchMinSize => const Size(kMinInteractiveDimension, kMinInteractiveDimension - 8.0);
}
''';
}
