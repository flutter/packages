// Copyright 2013 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Version: 38.0.1

import 'color_role.dart';
import 'shape_struct.dart';
import 'typescale.dart';
import 'typescale_struct.dart';

class TokenBanner {
  /// md.comp.banner.container.elevation
  static const double containerElevation = 1.00;

  /// md.comp.banner.container.shape
  static const ShapeStruct containerShape = ShapeStruct(
    family: 'SHAPE_FAMILY_ROUNDED_CORNERS',
    topLeft: 0.00,
    topRight: 0.00,
    bottomLeft: 0.00,
    bottomRight: 0.00,
  );

  /// md.comp.banner.desktop.with-single-line.container.height
  static const double desktopWithSingleLineContainerHeight = 52.00;

  /// md.comp.banner.desktop.with-three-lines.container.height
  static const double desktopWithThreeLinesContainerHeight = 90.00;

  /// md.comp.banner.desktop.with-two-lines.with-image.container.height
  static const double desktopWithTwoLinesWithImageContainerHeight = 72.00;

  /// md.comp.banner.mobile.with-single-line.container.height
  static const double mobileWithSingleLineContainerHeight = 54.00;

  /// md.comp.banner.mobile.with-two-lines.container.height
  static const double mobileWithTwoLinesContainerHeight = 112.00;

  /// md.comp.banner.mobile.with-two-lines.with-image.container.height
  static const double mobileWithTwoLinesWithImageContainerHeight = 120.00;

  /// md.comp.banner.supporting-text.type
  static const TypescaleStruct supportingTextType = TokenTypescale.bodyMedium;

  /// md.comp.banner.with-image.image.shape
  static const ShapeStruct withImageImageShape = ShapeStruct(
    family: 'SHAPE_FAMILY_CIRCULAR',
    topLeft: 0.00,
    topRight: 0.00,
    bottomLeft: 0.00,
    bottomRight: 0.00,
  );

  /// md.comp.banner.with-image.image.size
  static const double withImageImageSize = 40.00;
}

class TokenBannerDark {
  /// md.comp.banner.container.color
  static const TokenColorRole containerColor =
      TokenColorRole.surfaceContainerLow;
}

class TokenBannerDarkDefault {
  /// md.comp.banner.supporting-text.color
  static const TokenColorRole supportingTextColor =
      TokenColorRole.onSurfaceVariant;
}

class TokenBannerDarkHighContrast {
  /// md.comp.banner.supporting-text.color
  static const TokenColorRole supportingTextColor =
      TokenColorRole.onSurfaceVariant;
}

class TokenBannerDarkMediumContrast {
  /// md.comp.banner.supporting-text.color
  static const TokenColorRole supportingTextColor =
      TokenColorRole.onSurfaceVariant;
}

class TokenBannerLight {
  /// md.comp.banner.container.color
  static const TokenColorRole containerColor =
      TokenColorRole.surfaceContainerLow;
}

class TokenBannerLightDefault {
  /// md.comp.banner.supporting-text.color
  static const TokenColorRole supportingTextColor =
      TokenColorRole.onSurfaceVariant;
}

class TokenBannerLightHighContrast {
  /// md.comp.banner.supporting-text.color
  static const TokenColorRole supportingTextColor =
      TokenColorRole.onSurfaceVariant;
}

class TokenBannerLightMediumContrast {
  /// md.comp.banner.supporting-text.color
  static const TokenColorRole supportingTextColor =
      TokenColorRole.onSurfaceVariant;
}
