// Copyright 2013 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Version: 36.0.6

import 'color_role.dart';
import 'shape_struct.dart';

class TokenPlainTooltip {
  /// md.comp.plain-tooltip.container.color
  static const TokenColorRole containerColor = TokenColorRole.inverseSurface;

  /// md.comp.plain-tooltip.supporting-text.color
  static const TokenColorRole supportingTextColor =
      TokenColorRole.inverseOnSurface;

  /// md.comp.plain-tooltip.container.shape
  static const ShapeStruct containerShape = ShapeStruct(
    family: 'SHAPE_FAMILY_ROUNDED_CORNERS',
    topLeft: 4.00,
    topRight: 4.00,
    bottomLeft: 4.00,
    bottomRight: 4.00,
  );

  /// md.comp.plain-tooltip.supporting-text.type
  static const double supportingTextTypeFontSize = 12.00;

  /// md.comp.plain-tooltip.supporting-text.type
  static const double supportingTextTypeFontWeight = 400;

  /// md.comp.plain-tooltip.supporting-text.type
  static const double supportingTextTypeLineHeight = 16.00;

  /// md.comp.plain-tooltip.supporting-text.type
  static const double supportingTextTypeLetterSpacing = 0.40;

  /// md.comp.plain-tooltip.supporting-text.type
  static const String supportingTextTypeFontFamily = 'Roboto';

  /// md.comp.plain-tooltip.supporting-text.font
  static const String supportingTextFont = 'Roboto';
}
