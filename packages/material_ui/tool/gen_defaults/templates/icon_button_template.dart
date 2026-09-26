// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/icon_button_filled.dart';
import '../data/icon_button_large.dart';
import '../data/icon_button_medium.dart';
import '../data/icon_button_outlined.dart';
import '../data/icon_button_small.dart';
import '../data/icon_button_standard.dart';
import '../data/icon_button_tonal.dart';
import '../data/icon_button_xlarge.dart';
import '../data/icon_button_xsmall.dart';
import 'template.dart';

class IconButtonTemplateM3E extends TokenTemplateM3E {
  const IconButtonTemplateM3E(this.name);

  @override
  final String name;

  @override
  String get parentFilePath => 'icon_button.dart';

  @override
  String generateContents(String className) {
    return switch (name) {
      'Icon Button' => _generateStandardDefaults(className),
      'Filled Icon Button' => _generateFilledDefaults(className),
      'Filled Tonal Icon Button' => _generateFilledTonalDefaults(className),
      'Outlined Icon Button' => _generateOutlinedDefaults(className),
      _ => throw UnsupportedError('Unsupported IconButton variant: $name'),
    };
  }

  String _sizeSwitch({
    required String xSmall,
    required String small,
    required String medium,
    required String large,
    required String xLarge,
  }) {
    return '''
switch (sizeVariant) {
      ButtonSizeVariant.xSmall => $xSmall,
      ButtonSizeVariant.small => $small,
      ButtonSizeVariant.medium => $medium,
      ButtonSizeVariant.large => $large,
      ButtonSizeVariant.xLarge => $xLarge,
    }''';
  }

  String get _paddingSwitch {
    return _sizeSwitch(
      xSmall: _edgeInsetsSwitch(
        defaultLeading: TokenIconButtonXsmall.defaultLeadingSpace,
        defaultTrailing: TokenIconButtonXsmall.defaultTrailingSpace,
        narrowLeading: TokenIconButtonXsmall.narrowLeadingSpace,
        narrowTrailing: TokenIconButtonXsmall.narrowTrailingSpace,
        wideLeading: TokenIconButtonXsmall.wideLeadingSpace,
        wideTrailing: TokenIconButtonXsmall.wideTrailingSpace,
      ),
      small: _edgeInsetsSwitch(
        defaultLeading: TokenIconButtonSmall.defaultLeadingSpace,
        defaultTrailing: TokenIconButtonSmall.defaultTrailingSpace,
        narrowLeading: TokenIconButtonSmall.narrowLeadingSpace,
        narrowTrailing: TokenIconButtonSmall.narrowTrailingSpace,
        wideLeading: TokenIconButtonSmall.wideLeadingSpace,
        wideTrailing: TokenIconButtonSmall.wideTrailingSpace,
      ),
      medium: _edgeInsetsSwitch(
        defaultLeading: TokenIconButtonMedium.defaultLeadingSpace,
        defaultTrailing: TokenIconButtonMedium.defaultTrailingSpace,
        narrowLeading: TokenIconButtonMedium.narrowLeadingSpace,
        narrowTrailing: TokenIconButtonMedium.narrowTrailingSpace,
        wideLeading: TokenIconButtonMedium.wideLeadingSpace,
        wideTrailing: TokenIconButtonMedium.wideTrailingSpace,
      ),
      large: _edgeInsetsSwitch(
        defaultLeading: TokenIconButtonLarge.defaultLeadingSpace,
        defaultTrailing: TokenIconButtonLarge.defaultTrailingSpace,
        narrowLeading: TokenIconButtonLarge.narrowLeadingSpace,
        narrowTrailing: TokenIconButtonLarge.narrowTrailingSpace,
        wideLeading: TokenIconButtonLarge.wideLeadingSpace,
        wideTrailing: TokenIconButtonLarge.wideTrailingSpace,
      ),
      xLarge: _edgeInsetsSwitch(
        defaultLeading: TokenIconButtonXlarge.defaultLeadingSpace,
        defaultTrailing: TokenIconButtonXlarge.defaultTrailingSpace,
        narrowLeading: TokenIconButtonXlarge.narrowLeadingSpace,
        narrowTrailing: TokenIconButtonXlarge.narrowTrailingSpace,
        wideLeading: TokenIconButtonXlarge.wideLeadingSpace,
        wideTrailing: TokenIconButtonXlarge.wideTrailingSpace,
      ),
    );
  }

  String _edgeInsetsSwitch({
    required double defaultLeading,
    required double defaultTrailing,
    required double narrowLeading,
    required double narrowTrailing,
    required double wideLeading,
    required double wideTrailing,
  }) {
    return '''
switch (iconButtonWidth) {
        IconButtonWidthVariant.narrow => const EdgeInsetsDirectional.fromSTEB($narrowLeading, $defaultLeading, $narrowTrailing, $defaultTrailing),
        IconButtonWidthVariant.standard => const EdgeInsetsDirectional.fromSTEB($defaultLeading, $defaultLeading, $defaultTrailing, $defaultTrailing),
        IconButtonWidthVariant.wide => const EdgeInsetsDirectional.fromSTEB($wideLeading, $defaultLeading, $wideTrailing, $defaultTrailing),
      }''';
  }

  String get _minimumSizeSwitch {
    return _sizeSwitch(
      xSmall: _minimumSizeWidthSwitch(
        iconSize: TokenIconButtonXsmall.iconSize,
        height: TokenIconButtonXsmall.containerHeight,
        defaultLeading: TokenIconButtonXsmall.defaultLeadingSpace,
        defaultTrailing: TokenIconButtonXsmall.defaultTrailingSpace,
        narrowLeading: TokenIconButtonXsmall.narrowLeadingSpace,
        narrowTrailing: TokenIconButtonXsmall.narrowTrailingSpace,
        wideLeading: TokenIconButtonXsmall.wideLeadingSpace,
        wideTrailing: TokenIconButtonXsmall.wideTrailingSpace,
      ),
      small: _minimumSizeWidthSwitch(
        iconSize: TokenIconButtonSmall.iconSize,
        height: TokenIconButtonSmall.containerHeight,
        defaultLeading: TokenIconButtonSmall.defaultLeadingSpace,
        defaultTrailing: TokenIconButtonSmall.defaultTrailingSpace,
        narrowLeading: TokenIconButtonSmall.narrowLeadingSpace,
        narrowTrailing: TokenIconButtonSmall.narrowTrailingSpace,
        wideLeading: TokenIconButtonSmall.wideLeadingSpace,
        wideTrailing: TokenIconButtonSmall.wideTrailingSpace,
      ),
      medium: _minimumSizeWidthSwitch(
        iconSize: TokenIconButtonMedium.iconSize,
        height: TokenIconButtonMedium.containerHeight,
        defaultLeading: TokenIconButtonMedium.defaultLeadingSpace,
        defaultTrailing: TokenIconButtonMedium.defaultTrailingSpace,
        narrowLeading: TokenIconButtonMedium.narrowLeadingSpace,
        narrowTrailing: TokenIconButtonMedium.narrowTrailingSpace,
        wideLeading: TokenIconButtonMedium.wideLeadingSpace,
        wideTrailing: TokenIconButtonMedium.wideTrailingSpace,
      ),
      large: _minimumSizeWidthSwitch(
        iconSize: TokenIconButtonLarge.iconSize,
        height: TokenIconButtonLarge.containerHeight,
        defaultLeading: TokenIconButtonLarge.defaultLeadingSpace,
        defaultTrailing: TokenIconButtonLarge.defaultTrailingSpace,
        narrowLeading: TokenIconButtonLarge.narrowLeadingSpace,
        narrowTrailing: TokenIconButtonLarge.narrowTrailingSpace,
        wideLeading: TokenIconButtonLarge.wideLeadingSpace,
        wideTrailing: TokenIconButtonLarge.wideTrailingSpace,
      ),
      xLarge: _minimumSizeWidthSwitch(
        iconSize: TokenIconButtonXlarge.iconSize,
        height: TokenIconButtonXlarge.containerHeight,
        defaultLeading: TokenIconButtonXlarge.defaultLeadingSpace,
        defaultTrailing: TokenIconButtonXlarge.defaultTrailingSpace,
        narrowLeading: TokenIconButtonXlarge.narrowLeadingSpace,
        narrowTrailing: TokenIconButtonXlarge.narrowTrailingSpace,
        wideLeading: TokenIconButtonXlarge.wideLeadingSpace,
        wideTrailing: TokenIconButtonXlarge.wideTrailingSpace,
      ),
    );
  }

  String _minimumSizeWidthSwitch({
    required double iconSize,
    required double height,
    required double defaultLeading,
    required double defaultTrailing,
    required double narrowLeading,
    required double narrowTrailing,
    required double wideLeading,
    required double wideTrailing,
  }) {
    return '''
switch (iconButtonWidth) {
        IconButtonWidthVariant.narrow => const Size(${iconSize + narrowLeading + narrowTrailing}, $height),
        IconButtonWidthVariant.standard => const Size(${iconSize + defaultLeading + defaultTrailing}, $height),
        IconButtonWidthVariant.wide => const Size(${iconSize + wideLeading + wideTrailing}, $height),
      }''';
  }

  String get _iconSizeSwitch {
    return _sizeSwitch(
      xSmall: '${TokenIconButtonXsmall.iconSize}',
      small: '${TokenIconButtonSmall.iconSize}',
      medium: '${TokenIconButtonMedium.iconSize}',
      large: '${TokenIconButtonLarge.iconSize}',
      xLarge: '${TokenIconButtonXlarge.iconSize}',
    );
  }

  String get _outlineWidthSwitch {
    return _sizeSwitch(
      xSmall: '${TokenIconButtonXsmall.outlinedOutlineWidth}',
      small: '${TokenIconButtonSmall.outlinedOutlineWidth}',
      medium: '${TokenIconButtonMedium.outlinedOutlineWidth}',
      large: '${TokenIconButtonLarge.outlinedOutlineWidth}',
      xLarge: '${TokenIconButtonXlarge.outlinedOutlineWidth}',
    );
  }

  String get _containerRoundShapeSwitch {
    return _sizeSwitch(
      xSmall: shape(TokenIconButtonXsmall.containerShapeRound),
      small: shape(TokenIconButtonSmall.containerShapeRound),
      medium: shape(TokenIconButtonMedium.containerShapeRound),
      large: shape(TokenIconButtonLarge.containerShapeRound),
      xLarge: shape(TokenIconButtonXlarge.containerShapeRound),
    );
  }

  String get _containerSquareShapeSwitch {
    return _sizeSwitch(
      xSmall: shape(TokenIconButtonXsmall.containerShapeSquare),
      small: shape(TokenIconButtonSmall.containerShapeSquare),
      medium: shape(TokenIconButtonMedium.containerShapeSquare),
      large: shape(TokenIconButtonLarge.containerShapeSquare),
      xLarge: shape(TokenIconButtonXlarge.containerShapeSquare),
    );
  }

  String get _containerShapeSwitch {
    return '''
switch (shapeVariant) {
      ButtonShapeVariant.round => $_containerRoundShapeSwitch,
      ButtonShapeVariant.square => $_containerSquareShapeSwitch,
    }''';
  }

  String get _pressedShapeSwitch {
    return _sizeSwitch(
      xSmall: shape(TokenIconButtonXsmall.pressedContainerShape),
      small: shape(TokenIconButtonSmall.pressedContainerShape),
      medium: shape(TokenIconButtonMedium.pressedContainerShape),
      large: shape(TokenIconButtonLarge.pressedContainerShape),
      xLarge: shape(TokenIconButtonXlarge.pressedContainerShape),
    );
  }

  String get _selectedRoundShapeSwitch {
    return _sizeSwitch(
      xSmall: shape(TokenIconButtonXsmall.selectedContainerShapeRound),
      small: shape(TokenIconButtonSmall.selectedContainerShapeRound),
      medium: shape(TokenIconButtonMedium.selectedContainerShapeRound),
      large: shape(TokenIconButtonLarge.selectedContainerShapeRound),
      xLarge: shape(TokenIconButtonXlarge.selectedContainerShapeRound),
    );
  }

  String get _selectedSquareShapeSwitch {
    return _sizeSwitch(
      xSmall: shape(TokenIconButtonXsmall.selectedContainerShapeSquare),
      small: shape(TokenIconButtonSmall.selectedContainerShapeSquare),
      medium: shape(TokenIconButtonMedium.selectedContainerShapeSquare),
      large: shape(TokenIconButtonLarge.selectedContainerShapeSquare),
      xLarge: shape(TokenIconButtonXlarge.selectedContainerShapeSquare),
    );
  }

  String get _selectedShapeSwitch {
    return '''
switch (shapeVariant) {
      ButtonShapeVariant.round => $_selectedRoundShapeSwitch,
      ButtonShapeVariant.square => $_selectedSquareShapeSwitch,
    }''';
  }

  String get _variantFields {
    return '''
  final ButtonSizeVariant? _sizeVariant;
  final IconButtonWidthVariant? _iconButtonWidth;
  final ButtonShapeVariant? _shapeVariant;
''';
  }

  String get _variantGetters {
    return '''
  @override
  ButtonSizeVariant get sizeVariant => _sizeVariant ?? ButtonSizeVariant.small;

  @override
  IconButtonWidthVariant get iconButtonWidth => _iconButtonWidth ?? IconButtonWidthVariant.standard;

  @override
  ButtonShapeVariant get shapeVariant => _shapeVariant ?? ButtonShapeVariant.round;
''';
  }

  String get _sizeDependentProperties {
    return '''
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
  WidgetStateProperty<OutlinedBorder>? get shape =>
    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.pressed)) {
        return $_pressedShapeSwitch;
      }
      if (toggleable && states.contains(WidgetState.selected)) {
        return $_selectedShapeSwitch;
      }
      return $_containerShapeSwitch;
    });
''';
  }

  String _generateStandardDefaults(String className) {
    return '''
class $className extends ButtonStyle {
  $className(
    this.context,
    this.toggleable,
    ButtonSizeVariant? sizeVariant,
    IconButtonWidthVariant? iconButtonWidth,
    ButtonShapeVariant? shapeVariant,
  ) : _sizeVariant = sizeVariant,
      _iconButtonWidth = iconButtonWidth,
      _shapeVariant = shapeVariant,
      super(
        animationDuration: kThemeChangeDuration,
        enableFeedback: true,
        alignment: Alignment.center,
      );

  final BuildContext context;
  final bool toggleable;
$_variantFields
  late final ColorScheme _colors = Theme.of(context).colorScheme;

$_variantGetters

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
    const WidgetStatePropertyAll<Color?>(Colors.transparent);

  @override
  WidgetStateProperty<Color?>? get foregroundColor =>
    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return ${colorWithOpacity(TokenIconButtonStandard.disabledIconColor, TokenIconButtonStandard.disabledIconOpacity)};
      }
      if (toggleable && states.contains(WidgetState.selected)) {
        return ${color(TokenIconButtonStandard.selectedIconColor)};
      }
      return ${color(TokenIconButtonStandard.iconColor)};
    });

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (toggleable && states.contains(WidgetState.selected)) {
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
        return ${colorWithOpacity(TokenIconButtonStandard.pressedStateLayerColor, TokenIconButtonStandard.pressedStateLayerOpacity)};
      }
      if (states.contains(WidgetState.hovered)) {
        return ${colorWithOpacity(TokenIconButtonStandard.hoveredStateLayerColor, TokenIconButtonStandard.hoveredStateLayerOpacity)};
      }
      if (states.contains(WidgetState.focused)) {
        return ${colorWithOpacity(TokenIconButtonStandard.focusedStateLayerColor, TokenIconButtonStandard.focusedStateLayerOpacity)};
      }
      return Colors.transparent;
    });

  @override
  WidgetStateProperty<double>? get elevation =>
    const WidgetStatePropertyAll<double>(0.0);

  @override
  WidgetStateProperty<Color>? get shadowColor =>
    const WidgetStatePropertyAll<Color>(Colors.transparent);

  @override
  WidgetStateProperty<Color>? get surfaceTintColor =>
    const WidgetStatePropertyAll<Color>(Colors.transparent);

$_sizeDependentProperties

  @override
  WidgetStateProperty<BorderSide?>? get side => null;

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

  String _generateFilledDefaults(String className) {
    return '''
class $className extends ButtonStyle {
  $className(
    this.context,
    this.toggleable,
    ButtonSizeVariant? sizeVariant,
    IconButtonWidthVariant? iconButtonWidth,
    ButtonShapeVariant? shapeVariant,
  ) : _sizeVariant = sizeVariant,
      _iconButtonWidth = iconButtonWidth,
      _shapeVariant = shapeVariant,
      super(
        animationDuration: kThemeChangeDuration,
        enableFeedback: true,
        alignment: Alignment.center,
      );

  final BuildContext context;
  final bool toggleable;
$_variantFields
  late final ColorScheme _colors = Theme.of(context).colorScheme;

$_variantGetters

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return ${colorWithOpacity(TokenIconButtonFilled.disabledContainerColor, TokenIconButtonFilled.disabledContainerOpacity)};
      }
      if (toggleable && states.contains(WidgetState.selected)) {
        return ${color(TokenIconButtonFilled.selectedContainerColor)};
      }
      if (toggleable) {
        return ${color(TokenIconButtonFilled.unselectedContainerColor)};
      }
      return ${color(TokenIconButtonFilled.containerColor)};
    });

  @override
  WidgetStateProperty<Color?>? get foregroundColor =>
    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return ${colorWithOpacity(TokenIconButtonFilled.disabledIconColor, TokenIconButtonFilled.disabledIconOpacity)};
      }
      if (toggleable && states.contains(WidgetState.selected)) {
        return ${color(TokenIconButtonFilled.selectedIconColor)};
      }
      if (toggleable) {
        return ${color(TokenIconButtonFilled.unselectedIconColor)};
      }
      return ${color(TokenIconButtonFilled.iconColor)};
    });

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (toggleable && states.contains(WidgetState.selected)) {
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
        if (states.contains(WidgetState.pressed)) {
          return ${colorWithOpacity(TokenIconButtonFilled.unselectedPressedStateLayerColor, TokenIconButtonFilled.pressedStateLayerOpacity)};
        }
        if (states.contains(WidgetState.hovered)) {
          return ${colorWithOpacity(TokenIconButtonFilled.unselectedHoveredStateLayerColor, TokenIconButtonFilled.hoveredStateLayerOpacity)};
        }
        if (states.contains(WidgetState.focused)) {
          return ${colorWithOpacity(TokenIconButtonFilled.unselectedFocusedStateLayerColor, TokenIconButtonFilled.focusedStateLayerOpacity)};
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
    });

  @override
  WidgetStateProperty<double>? get elevation =>
    const WidgetStatePropertyAll<double>(0.0);

  @override
  WidgetStateProperty<Color>? get shadowColor =>
    const WidgetStatePropertyAll<Color>(Colors.transparent);

  @override
  WidgetStateProperty<Color>? get surfaceTintColor =>
    const WidgetStatePropertyAll<Color>(Colors.transparent);

$_sizeDependentProperties

  @override
  WidgetStateProperty<BorderSide?>? get side => null;

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

  String _generateFilledTonalDefaults(String className) {
    return '''
class $className extends ButtonStyle {
  $className(
    this.context,
    this.toggleable,
    ButtonSizeVariant? sizeVariant,
    IconButtonWidthVariant? iconButtonWidth,
    ButtonShapeVariant? shapeVariant,
  ) : _sizeVariant = sizeVariant,
      _iconButtonWidth = iconButtonWidth,
      _shapeVariant = shapeVariant,
      super(
        animationDuration: kThemeChangeDuration,
        enableFeedback: true,
        alignment: Alignment.center,
      );

  final BuildContext context;
  final bool toggleable;
$_variantFields
  late final ColorScheme _colors = Theme.of(context).colorScheme;

$_variantGetters

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return ${colorWithOpacity(TokenIconButtonTonal.disabledContainerColor, TokenIconButtonTonal.disabledContainerOpacity)};
      }
      if (toggleable && states.contains(WidgetState.selected)) {
        return ${color(TokenIconButtonTonal.selectedContainerColor)};
      }
      if (toggleable) {
        return ${color(TokenIconButtonTonal.unselectedContainerColor)};
      }
      return ${color(TokenIconButtonTonal.containerColor)};
    });

  @override
  WidgetStateProperty<Color?>? get foregroundColor =>
    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return ${colorWithOpacity(TokenIconButtonTonal.disabledIconColor, TokenIconButtonTonal.disabledIconOpacity)};
      }
      if (toggleable && states.contains(WidgetState.selected)) {
        return ${color(TokenIconButtonTonal.selectedIconColor)};
      }
      if (toggleable) {
        return ${color(TokenIconButtonTonal.unselectedIconColor)};
      }
      return ${color(TokenIconButtonTonal.iconColor)};
    });

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (toggleable && states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.pressed)) {
          return ${colorWithOpacity(TokenIconButtonTonal.selectedPressedStateLayerColor, TokenIconButtonTonal.pressedStateLayerOpacity)};
        }
        if (states.contains(WidgetState.hovered)) {
          return ${colorWithOpacity(TokenIconButtonTonal.selectedHoveredStateLayerColor, TokenIconButtonTonal.hoveredStateLayerOpacity)};
        }
        if (states.contains(WidgetState.focused)) {
          return ${colorWithOpacity(TokenIconButtonTonal.selectedFocusedStateLayerColor, TokenIconButtonTonal.focusedStateLayerOpacity)};
        }
      }
      if (toggleable) {
        if (states.contains(WidgetState.pressed)) {
          return ${colorWithOpacity(TokenIconButtonTonal.unselectedPressedStateLayerColor, TokenIconButtonTonal.pressedStateLayerOpacity)};
        }
        if (states.contains(WidgetState.hovered)) {
          return ${colorWithOpacity(TokenIconButtonTonal.unselectedHoveredStateLayerColor, TokenIconButtonTonal.hoveredStateLayerOpacity)};
        }
        if (states.contains(WidgetState.focused)) {
          return ${colorWithOpacity(TokenIconButtonTonal.unselectedFocusedStateLayerColor, TokenIconButtonTonal.focusedStateLayerOpacity)};
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
    });

  @override
  WidgetStateProperty<double>? get elevation =>
    const WidgetStatePropertyAll<double>(0.0);

  @override
  WidgetStateProperty<Color>? get shadowColor =>
    const WidgetStatePropertyAll<Color>(Colors.transparent);

  @override
  WidgetStateProperty<Color>? get surfaceTintColor =>
    const WidgetStatePropertyAll<Color>(Colors.transparent);

$_sizeDependentProperties

  @override
  WidgetStateProperty<BorderSide?>? get side => null;

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

  String _generateOutlinedDefaults(String className) {
    return '''
class $className extends ButtonStyle {
  $className(
    this.context,
    this.toggleable,
    ButtonSizeVariant? sizeVariant,
    IconButtonWidthVariant? iconButtonWidth,
    ButtonShapeVariant? shapeVariant,
  ) : _sizeVariant = sizeVariant,
      _iconButtonWidth = iconButtonWidth,
      _shapeVariant = shapeVariant,
      super(
        animationDuration: kThemeChangeDuration,
        enableFeedback: true,
        alignment: Alignment.center,
      );

  final BuildContext context;
  final bool toggleable;
$_variantFields
  late final ColorScheme _colors = Theme.of(context).colorScheme;

$_variantGetters

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        if (toggleable && states.contains(WidgetState.selected)) {
          return ${colorWithOpacity(TokenIconButtonOutlined.selectedDisabledContainerColor, TokenIconButtonOutlined.selectedDisabledContainerOpacity)};
        }
        return Colors.transparent;
      }
      if (toggleable && states.contains(WidgetState.selected)) {
        return ${color(TokenIconButtonOutlined.selectedContainerColor)};
      }
      return Colors.transparent;
    });

  @override
  WidgetStateProperty<Color?>? get foregroundColor =>
    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return ${colorWithOpacity(TokenIconButtonOutlined.disabledIconColor, TokenIconButtonOutlined.disabledIconOpacity)};
      }
      if (toggleable && states.contains(WidgetState.selected)) {
        return ${color(TokenIconButtonOutlined.selectedIconColor)};
      }
      return ${color(TokenIconButtonOutlined.iconColor)};
    });

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (toggleable && states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.pressed)) {
          return ${colorWithOpacity(TokenIconButtonOutlined.selectedPressedStateLayerColor, TokenIconButtonOutlined.pressedStateLayerOpacity)};
        }
        if (states.contains(WidgetState.hovered)) {
          return ${colorWithOpacity(TokenIconButtonOutlined.selectedHoveredStateLayerColor, TokenIconButtonOutlined.hoveredStateLayerOpacity)};
        }
        if (states.contains(WidgetState.focused)) {
          return ${colorWithOpacity(TokenIconButtonOutlined.selectedFocusedStateLayerColor, TokenIconButtonOutlined.focusedStateLayerOpacity)};
        }
      }
      if (states.contains(WidgetState.pressed)) {
        return ${colorWithOpacity(TokenIconButtonOutlined.pressedStateLayerColor, TokenIconButtonOutlined.pressedStateLayerOpacity)};
      }
      if (states.contains(WidgetState.hovered)) {
        return ${colorWithOpacity(TokenIconButtonOutlined.hoveredStateLayerColor, TokenIconButtonOutlined.hoveredStateLayerOpacity)};
      }
      if (states.contains(WidgetState.focused)) {
        return ${colorWithOpacity(TokenIconButtonOutlined.focusedStateLayerColor, TokenIconButtonOutlined.focusedStateLayerOpacity)};
      }
      return Colors.transparent;
    });

  @override
  WidgetStateProperty<double>? get elevation =>
    const WidgetStatePropertyAll<double>(0.0);

  @override
  WidgetStateProperty<Color>? get shadowColor =>
    const WidgetStatePropertyAll<Color>(Colors.transparent);

  @override
  WidgetStateProperty<Color>? get surfaceTintColor =>
    const WidgetStatePropertyAll<Color>(Colors.transparent);

$_sizeDependentProperties

  @override
  WidgetStateProperty<BorderSide?>? get side =>
    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (toggleable && states.contains(WidgetState.selected)) {
        return null;
      }
      if (states.contains(WidgetState.disabled)) {
        return BorderSide(color: ${color(TokenIconButtonOutlined.unselectedDisabledOutlineColor)}, width: $_outlineWidthSwitch);
      }
      return BorderSide(color: ${color(TokenIconButtonOutlined.outlineColor)}, width: $_outlineWidthSwitch);
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
}
