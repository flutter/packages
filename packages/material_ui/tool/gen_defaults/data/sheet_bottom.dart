// Copyright 2013 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Version: 38.0.1

import 'color_role.dart';
import 'shape_struct.dart';

class TokenSheetBottom {
  /// md.comp.sheet.bottom.docked.container.shape
  static const ShapeStruct dockedContainerShape = ShapeStruct(
    family: 'SHAPE_FAMILY_ROUNDED_CORNERS',
    topLeft: 28.00,
    topRight: 28.00,
    bottomLeft: 0.00,
    bottomRight: 0.00,
  );

  /// md.comp.sheet.bottom.docked.drag-handle.height
  static const double dockedDragHandleHeight = 4.00;

  /// md.comp.sheet.bottom.docked.drag-handle.width
  static const double dockedDragHandleWidth = 32.00;

  /// md.comp.sheet.bottom.docked.minimized.container.shape
  static const ShapeStruct dockedMinimizedContainerShape = ShapeStruct(
    family: 'SHAPE_FAMILY_ROUNDED_CORNERS',
    topLeft: 0.00,
    topRight: 0.00,
    bottomLeft: 0.00,
    bottomRight: 0.00,
  );

  /// md.comp.sheet.bottom.docked.modal.container.elevation
  static const double dockedModalContainerElevation = 1.00;

  /// md.comp.sheet.bottom.docked.standard.container.elevation
  static const double dockedStandardContainerElevation = 1.00;

  /// md.comp.sheet.bottom.focus.indicator.outline.offset
  static const double focusIndicatorOutlineOffset = 2.00;

  /// md.comp.sheet.bottom.focus.indicator.thickness
  static const double focusIndicatorThickness = 3.00;
}

class TokenSheetBottomDark {
  /// md.comp.sheet.bottom.docked.container.color
  static const TokenColorRole dockedContainerColor =
      TokenColorRole.surfaceContainerLow;
}

class TokenSheetBottomDarkDefault {
  /// md.comp.sheet.bottom.docked.drag-handle.color
  static const TokenColorRole dockedDragHandleColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.sheet.bottom.focus.indicator.color
  static const TokenColorRole focusIndicatorColor = TokenColorRole.secondary;
}

class TokenSheetBottomDarkHighContrast {
  /// md.comp.sheet.bottom.docked.drag-handle.color
  static const TokenColorRole dockedDragHandleColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.sheet.bottom.focus.indicator.color
  static const TokenColorRole focusIndicatorColor = TokenColorRole.secondary;
}

class TokenSheetBottomDarkMediumContrast {
  /// md.comp.sheet.bottom.docked.drag-handle.color
  static const TokenColorRole dockedDragHandleColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.sheet.bottom.focus.indicator.color
  static const TokenColorRole focusIndicatorColor = TokenColorRole.secondary;
}

class TokenSheetBottomLight {
  /// md.comp.sheet.bottom.docked.container.color
  static const TokenColorRole dockedContainerColor =
      TokenColorRole.surfaceContainerLow;
}

class TokenSheetBottomLightDefault {
  /// md.comp.sheet.bottom.docked.drag-handle.color
  static const TokenColorRole dockedDragHandleColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.sheet.bottom.focus.indicator.color
  static const TokenColorRole focusIndicatorColor = TokenColorRole.secondary;
}

class TokenSheetBottomLightHighContrast {
  /// md.comp.sheet.bottom.docked.drag-handle.color
  static const TokenColorRole dockedDragHandleColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.sheet.bottom.focus.indicator.color
  static const TokenColorRole focusIndicatorColor = TokenColorRole.secondary;
}

class TokenSheetBottomLightMediumContrast {
  /// md.comp.sheet.bottom.docked.drag-handle.color
  static const TokenColorRole dockedDragHandleColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.sheet.bottom.focus.indicator.color
  static const TokenColorRole focusIndicatorColor = TokenColorRole.secondary;
}
