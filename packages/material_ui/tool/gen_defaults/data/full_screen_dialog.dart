// Copyright 2013 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Version: 38.1.2

import 'color_role.dart';
import 'shape_struct.dart';
import 'typescale_struct.dart';

class TokenFullScreenDialog {
  /// md.comp.full-screen-dialog.container.color
  static const TokenColorRole containerColor = TokenColorRole.surface;

  /// md.comp.full-screen-dialog.container.elevation
  static const double containerElevation = 0.00;

  /// md.comp.full-screen-dialog.container.shape
  static const ShapeStruct containerShape = ShapeStruct(
    family: 'SHAPE_FAMILY_ROUNDED_CORNERS',
    topLeft: 0.00,
    topRight: 0.00,
    bottomLeft: 0.00,
    bottomRight: 0.00,
  );

  /// md.comp.full-screen-dialog.header.action.focus.label-text.color
  static const TokenColorRole headerActionFocusLabelTextColor =
      TokenColorRole.primary;

  /// md.comp.full-screen-dialog.header.action.focus.state-layer.color
  static const TokenColorRole headerActionFocusStateLayerColor =
      TokenColorRole.primary;

  /// md.comp.full-screen-dialog.header.action.focus.state-layer.opacity
  static const double headerActionFocusStateLayerOpacity = 0.10;

  /// md.comp.full-screen-dialog.header.action.hover.label-text.color
  static const TokenColorRole headerActionHoverLabelTextColor =
      TokenColorRole.primary;

  /// md.comp.full-screen-dialog.header.action.hover.state-layer.color
  static const TokenColorRole headerActionHoverStateLayerColor =
      TokenColorRole.primary;

  /// md.comp.full-screen-dialog.header.action.hover.state-layer.opacity
  static const double headerActionHoverStateLayerOpacity = 0.08;

  /// md.comp.full-screen-dialog.header.action.label-text.color
  static const TokenColorRole headerActionLabelTextColor =
      TokenColorRole.primary;

  /// md.comp.full-screen-dialog.header.action.label-text.type
  static const TypescaleStruct headerActionLabelTextType = TypescaleStruct(
    fontFamily: 'Roboto',
    fontSize: 14.00,
    fontWeight: 500,
    lineHeight: 20.00,
    letterSpacing: 0.10,
  );

  /// md.comp.full-screen-dialog.header.action.pressed.label-text.color
  static const TokenColorRole headerActionPressedLabelTextColor =
      TokenColorRole.primary;

  /// md.comp.full-screen-dialog.header.action.pressed.state-layer.color
  static const TokenColorRole headerActionPressedStateLayerColor =
      TokenColorRole.primary;

  /// md.comp.full-screen-dialog.header.action.pressed.state-layer.opacity
  static const double headerActionPressedStateLayerOpacity = 0.10;

  /// md.comp.full-screen-dialog.header.container.color
  static const TokenColorRole headerContainerColor = TokenColorRole.surface;

  /// md.comp.full-screen-dialog.header.container.elevation
  static const double headerContainerElevation = 0.00;

  /// md.comp.full-screen-dialog.header.container.height
  static const double headerContainerHeight = 56.00;

  /// md.comp.full-screen-dialog.header.headline.color
  static const TokenColorRole headerHeadlineColor = TokenColorRole.onSurface;

  /// md.comp.full-screen-dialog.header.headline.type
  static const TypescaleStruct headerHeadlineType = TypescaleStruct(
    fontFamily: 'Roboto',
    fontSize: 22.00,
    fontWeight: 400,
    lineHeight: 28.00,
    letterSpacing: 0.00,
  );

  /// md.comp.full-screen-dialog.header.icon.color
  static const TokenColorRole headerIconColor = TokenColorRole.onSurface;

  /// md.comp.full-screen-dialog.header.icon.size
  static const double headerIconSize = 24.00;

  /// md.comp.full-screen-dialog.header.on-scroll.container.color
  static const TokenColorRole headerOnScrollContainerColor =
      TokenColorRole.surfaceContainer;

  /// md.comp.full-screen-dialog.header.on-scroll.container.elevation
  static const double headerOnScrollContainerElevation = 3.00;
}
