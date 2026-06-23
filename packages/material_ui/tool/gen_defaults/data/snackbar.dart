// Copyright 2013 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Version: 38.0.1

import 'color_role.dart';
import 'shape_struct.dart';
import 'typescale.dart';
import 'typescale_struct.dart';

class TokenSnackbar {
  /// md.comp.snackbar.action.focus.state-layer.opacity
  static const double actionFocusStateLayerOpacity = 0.10;

  /// md.comp.snackbar.action.hover.state-layer.opacity
  static const double actionHoverStateLayerOpacity = 0.08;

  /// md.comp.snackbar.action.label-text.type
  static const TypescaleStruct actionLabelTextType = TokenTypescale.titleSmall;

  /// md.comp.snackbar.action.pressed.state-layer.opacity
  static const double actionPressedStateLayerOpacity = 0.10;

  /// md.comp.snackbar.container.elevation
  static const double containerElevation = 6.00;

  /// md.comp.snackbar.container.shape
  static const ShapeStruct containerShape = ShapeStruct(
    family: 'SHAPE_FAMILY_ROUNDED_CORNERS',
    topLeft: 4.00,
    topRight: 4.00,
    bottomLeft: 4.00,
    bottomRight: 4.00,
  );

  /// md.comp.snackbar.icon.focus.state-layer.opacity
  static const double iconFocusStateLayerOpacity = 0.10;

  /// md.comp.snackbar.icon.hover.state-layer.opacity
  static const double iconHoverStateLayerOpacity = 0.08;

  /// md.comp.snackbar.icon.pressed.state-layer.opacity
  static const double iconPressedStateLayerOpacity = 0.10;

  /// md.comp.snackbar.icon.size
  static const double iconSize = 24.00;

  /// md.comp.snackbar.supporting-text.type
  static const TypescaleStruct supportingTextType = TokenTypescale.bodyMedium;

  /// md.comp.snackbar.with-single-line.container.height
  static const double withSingleLineContainerHeight = 48.00;

  /// md.comp.snackbar.with-two-lines.container.height
  static const double withTwoLinesContainerHeight = 68.00;
}

class TokenSnackbarDark {
  /// md.comp.snackbar.container.color
  static const TokenColorRole containerColor = TokenColorRole.inverseSurface;

  /// md.comp.snackbar.container.shadow-color
  static const TokenColorRole containerShadowColor = TokenColorRole.shadow;
}

class TokenSnackbarDarkDefault {
  /// md.comp.snackbar.action.focus.label-text.color
  static const TokenColorRole actionFocusLabelTextColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.action.focus.state-layer.color
  static const TokenColorRole actionFocusStateLayerColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.action.hover.label-text.color
  static const TokenColorRole actionHoverLabelTextColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.action.hover.state-layer.color
  static const TokenColorRole actionHoverStateLayerColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.action.label-text.color
  static const TokenColorRole actionLabelTextColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.action.pressed.label-text.color
  static const TokenColorRole actionPressedLabelTextColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.action.pressed.state-layer.color
  static const TokenColorRole actionPressedStateLayerColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.icon.color
  static const TokenColorRole iconColor = TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.focus.icon.color
  static const TokenColorRole iconFocusIconColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.focus.state-layer.color
  static const TokenColorRole iconFocusStateLayerColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.hover.icon.color
  static const TokenColorRole iconHoverIconColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.hover.state-layer.color
  static const TokenColorRole iconHoverStateLayerColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.pressed.icon.color
  static const TokenColorRole iconPressedIconColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.pressed.state-layer.color
  static const TokenColorRole iconPressedStateLayerColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.supporting-text.color
  static const TokenColorRole supportingTextColor =
      TokenColorRole.inverseOnSurface;
}

class TokenSnackbarDarkHighContrast {
  /// md.comp.snackbar.action.focus.label-text.color
  static const TokenColorRole actionFocusLabelTextColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.action.focus.state-layer.color
  static const TokenColorRole actionFocusStateLayerColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.action.hover.label-text.color
  static const TokenColorRole actionHoverLabelTextColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.action.hover.state-layer.color
  static const TokenColorRole actionHoverStateLayerColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.action.label-text.color
  static const TokenColorRole actionLabelTextColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.action.pressed.label-text.color
  static const TokenColorRole actionPressedLabelTextColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.action.pressed.state-layer.color
  static const TokenColorRole actionPressedStateLayerColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.icon.color
  static const TokenColorRole iconColor = TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.focus.icon.color
  static const TokenColorRole iconFocusIconColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.focus.state-layer.color
  static const TokenColorRole iconFocusStateLayerColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.hover.icon.color
  static const TokenColorRole iconHoverIconColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.hover.state-layer.color
  static const TokenColorRole iconHoverStateLayerColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.pressed.icon.color
  static const TokenColorRole iconPressedIconColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.pressed.state-layer.color
  static const TokenColorRole iconPressedStateLayerColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.supporting-text.color
  static const TokenColorRole supportingTextColor =
      TokenColorRole.inverseOnSurface;
}

class TokenSnackbarDarkMediumContrast {
  /// md.comp.snackbar.action.focus.label-text.color
  static const TokenColorRole actionFocusLabelTextColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.action.focus.state-layer.color
  static const TokenColorRole actionFocusStateLayerColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.action.hover.label-text.color
  static const TokenColorRole actionHoverLabelTextColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.action.hover.state-layer.color
  static const TokenColorRole actionHoverStateLayerColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.action.label-text.color
  static const TokenColorRole actionLabelTextColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.action.pressed.label-text.color
  static const TokenColorRole actionPressedLabelTextColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.action.pressed.state-layer.color
  static const TokenColorRole actionPressedStateLayerColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.icon.color
  static const TokenColorRole iconColor = TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.focus.icon.color
  static const TokenColorRole iconFocusIconColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.focus.state-layer.color
  static const TokenColorRole iconFocusStateLayerColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.hover.icon.color
  static const TokenColorRole iconHoverIconColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.hover.state-layer.color
  static const TokenColorRole iconHoverStateLayerColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.pressed.icon.color
  static const TokenColorRole iconPressedIconColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.pressed.state-layer.color
  static const TokenColorRole iconPressedStateLayerColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.supporting-text.color
  static const TokenColorRole supportingTextColor =
      TokenColorRole.inverseOnSurface;
}

class TokenSnackbarLight {
  /// md.comp.snackbar.action.focus.label-text.color
  static const TokenColorRole actionFocusLabelTextColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.action.focus.state-layer.color
  static const TokenColorRole actionFocusStateLayerColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.action.hover.label-text.color
  static const TokenColorRole actionHoverLabelTextColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.action.hover.state-layer.color
  static const TokenColorRole actionHoverStateLayerColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.action.label-text.color
  static const TokenColorRole actionLabelTextColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.action.pressed.label-text.color
  static const TokenColorRole actionPressedLabelTextColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.action.pressed.state-layer.color
  static const TokenColorRole actionPressedStateLayerColor =
      TokenColorRole.inversePrimary;

  /// md.comp.snackbar.container.color
  static const TokenColorRole containerColor = TokenColorRole.inverseSurface;

  /// md.comp.snackbar.container.shadow-color
  static const TokenColorRole containerShadowColor = TokenColorRole.shadow;
}

class TokenSnackbarLightDefault {
  /// md.comp.snackbar.icon.color
  static const TokenColorRole iconColor = TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.focus.icon.color
  static const TokenColorRole iconFocusIconColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.focus.state-layer.color
  static const TokenColorRole iconFocusStateLayerColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.hover.icon.color
  static const TokenColorRole iconHoverIconColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.hover.state-layer.color
  static const TokenColorRole iconHoverStateLayerColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.pressed.icon.color
  static const TokenColorRole iconPressedIconColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.pressed.state-layer.color
  static const TokenColorRole iconPressedStateLayerColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.supporting-text.color
  static const TokenColorRole supportingTextColor =
      TokenColorRole.inverseOnSurface;
}

class TokenSnackbarLightHighContrast {
  /// md.comp.snackbar.icon.color
  static const TokenColorRole iconColor = TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.focus.icon.color
  static const TokenColorRole iconFocusIconColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.focus.state-layer.color
  static const TokenColorRole iconFocusStateLayerColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.hover.icon.color
  static const TokenColorRole iconHoverIconColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.hover.state-layer.color
  static const TokenColorRole iconHoverStateLayerColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.pressed.icon.color
  static const TokenColorRole iconPressedIconColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.pressed.state-layer.color
  static const TokenColorRole iconPressedStateLayerColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.supporting-text.color
  static const TokenColorRole supportingTextColor =
      TokenColorRole.inverseOnSurface;
}

class TokenSnackbarLightMediumContrast {
  /// md.comp.snackbar.icon.color
  static const TokenColorRole iconColor = TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.focus.icon.color
  static const TokenColorRole iconFocusIconColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.focus.state-layer.color
  static const TokenColorRole iconFocusStateLayerColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.hover.icon.color
  static const TokenColorRole iconHoverIconColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.hover.state-layer.color
  static const TokenColorRole iconHoverStateLayerColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.pressed.icon.color
  static const TokenColorRole iconPressedIconColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.icon.pressed.state-layer.color
  static const TokenColorRole iconPressedStateLayerColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.snackbar.supporting-text.color
  static const TokenColorRole supportingTextColor =
      TokenColorRole.inverseOnSurface;
}
