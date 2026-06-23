// Copyright 2013 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Version: 38.0.1

import 'color_role.dart';
import 'shape_struct.dart';
import 'typescale.dart';
import 'typescale_struct.dart';

class TokenPlainTooltip {
  /// md.comp.plain-tooltip.container.shape
  static const ShapeStruct containerShape = ShapeStruct(
    family: 'SHAPE_FAMILY_ROUNDED_CORNERS',
    topLeft: 4.00,
    topRight: 4.00,
    bottomLeft: 4.00,
    bottomRight: 4.00,
  );

  /// md.comp.plain-tooltip.supporting-text.type
  static const TypescaleStruct supportingTextType = TokenTypescale.bodySmall;
}

class TokenPlainTooltipDark {
  /// md.comp.plain-tooltip.container.color
  static const TokenColorRole containerColor = TokenColorRole.inverseSurface;
}

class TokenPlainTooltipDarkDefault {
  /// md.comp.plain-tooltip.supporting-text.color
  static const TokenColorRole supportingTextColor =
      TokenColorRole.inverseOnSurface;
}

class TokenPlainTooltipDarkHighContrast {
  /// md.comp.plain-tooltip.supporting-text.color
  static const TokenColorRole supportingTextColor =
      TokenColorRole.inverseOnSurface;
}

class TokenPlainTooltipDarkMediumContrast {
  /// md.comp.plain-tooltip.supporting-text.color
  static const TokenColorRole supportingTextColor =
      TokenColorRole.inverseOnSurface;
}

class TokenPlainTooltipLight {
  /// md.comp.plain-tooltip.container.color
  static const TokenColorRole containerColor = TokenColorRole.inverseSurface;
}

class TokenPlainTooltipLightDefault {
  /// md.comp.plain-tooltip.supporting-text.color
  static const TokenColorRole supportingTextColor =
      TokenColorRole.inverseOnSurface;
}

class TokenPlainTooltipLightHighContrast {
  /// md.comp.plain-tooltip.supporting-text.color
  static const TokenColorRole supportingTextColor =
      TokenColorRole.inverseOnSurface;
}

class TokenPlainTooltipLightMediumContrast {
  /// md.comp.plain-tooltip.supporting-text.color
  static const TokenColorRole supportingTextColor =
      TokenColorRole.inverseOnSurface;
}
