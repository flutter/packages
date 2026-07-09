// Copyright 2013 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Version: 38.0.15

import 'color_role.dart';
import 'shape_struct.dart';
import 'typescale_struct.dart';

class TokenRichTooltip {
  /// md.comp.rich-tooltip.action.focus.label-text.color
  static const TokenColorRole actionFocusLabelTextColor =
      TokenColorRole.primary;

  /// md.comp.rich-tooltip.action.focus.state-layer.color
  static const TokenColorRole actionFocusStateLayerColor =
      TokenColorRole.primary;

  /// md.comp.rich-tooltip.action.focus.state-layer.opacity
  static const double actionFocusStateLayerOpacity = 0.10;

  /// md.comp.rich-tooltip.action.hover.label-text.color
  static const TokenColorRole actionHoverLabelTextColor =
      TokenColorRole.primary;

  /// md.comp.rich-tooltip.action.hover.state-layer.color
  static const TokenColorRole actionHoverStateLayerColor =
      TokenColorRole.primary;

  /// md.comp.rich-tooltip.action.hover.state-layer.opacity
  static const double actionHoverStateLayerOpacity = 0.08;

  /// md.comp.rich-tooltip.action.label-text.color
  static const TokenColorRole actionLabelTextColor = TokenColorRole.primary;

  /// md.comp.rich-tooltip.action.label-text.type
  static const TypescaleStruct actionLabelTextType = TypescaleStruct(
    fontFamily: 'Roboto',
    fontSize: 14.00,
    fontWeight: 500,
    lineHeight: 20.00,
    letterSpacing: 0.10,
  );

  /// md.comp.rich-tooltip.action.pressed.label-text.color
  static const TokenColorRole actionPressedLabelTextColor =
      TokenColorRole.primary;

  /// md.comp.rich-tooltip.action.pressed.state-layer.color
  static const TokenColorRole actionPressedStateLayerColor =
      TokenColorRole.primary;

  /// md.comp.rich-tooltip.action.pressed.state-layer.opacity
  static const double actionPressedStateLayerOpacity = 0.10;

  /// md.comp.rich-tooltip.container.color
  static const TokenColorRole containerColor = TokenColorRole.surfaceContainer;

  /// md.comp.rich-tooltip.container.elevation
  static const double containerElevation = 3.00;

  /// md.comp.rich-tooltip.container.shadow-color
  static const TokenColorRole containerShadowColor = TokenColorRole.shadow;

  /// md.comp.rich-tooltip.container.shape
  static const ShapeStruct containerShape = ShapeStruct(
    family: 'SHAPE_FAMILY_ROUNDED_CORNERS',
    topLeft: 12.00,
    topRight: 12.00,
    bottomLeft: 12.00,
    bottomRight: 12.00,
  );

  /// md.comp.rich-tooltip.subhead.color
  static const TokenColorRole subheadColor = TokenColorRole.onSurfaceVariant;

  /// md.comp.rich-tooltip.subhead.type
  static const TypescaleStruct subheadType = TypescaleStruct(
    fontFamily: 'Roboto',
    fontSize: 14.00,
    fontWeight: 500,
    lineHeight: 20.00,
    letterSpacing: 0.10,
  );

  /// md.comp.rich-tooltip.supporting-text.color
  static const TokenColorRole supportingTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.rich-tooltip.supporting-text.type
  static const TypescaleStruct supportingTextType = TypescaleStruct(
    fontFamily: 'Roboto',
    fontSize: 14.00,
    fontWeight: 400,
    lineHeight: 20.00,
    letterSpacing: 0.25,
  );
}
