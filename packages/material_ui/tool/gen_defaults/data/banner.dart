// Copyright 2013 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Version: 38.0.15

import 'color_role.dart';
import 'shape_struct.dart';
import 'typescale_struct.dart';

class TokenBanner {
  /// md.comp.banner.container.color
  static const TokenColorRole containerColor =
      TokenColorRole.surfaceContainerLow;

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

  /// md.comp.banner.supporting-text.color
  static const TokenColorRole supportingTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.banner.supporting-text.type
  static const TypescaleStruct supportingTextType = TypescaleStruct(
    fontFamily: 'Roboto',
    fontSize: 14.00,
    fontWeight: 400,
    lineHeight: 20.00,
    letterSpacing: 0.25,
  );

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
