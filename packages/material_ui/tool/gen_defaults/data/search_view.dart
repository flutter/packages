// Copyright 2013 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Version: 38.0.1

import 'color_role.dart';
import 'shape_struct.dart';
import 'typescale.dart';
import 'typescale_struct.dart';

class TokenSearchView {
  /// md.comp.search-view.contained.docked.bar-results.gap
  static const double containedDockedBarResultsGap = 2.00;

  /// md.comp.search-view.contained.docked.bar.shape
  static const ShapeStruct containedDockedBarShape = ShapeStruct(
    family: 'SHAPE_FAMILY_CIRCULAR',
    topLeft: 0.00,
    topRight: 0.00,
    bottomLeft: 0.00,
    bottomRight: 0.00,
  );

  /// md.comp.search-view.contained.docked.results.shape
  static const ShapeStruct containedDockedResultsShape = ShapeStruct(
    family: 'SHAPE_FAMILY_ROUNDED_CORNERS',
    topLeft: 12.00,
    topRight: 12.00,
    bottomLeft: 12.00,
    bottomRight: 12.00,
  );

  /// md.comp.search-view.contained.full-screen.bar.container.height
  static const double containedFullScreenBarContainerHeight = 56.00;

  /// md.comp.search-view.contained.icon-label.gap
  static const double containedIconLabelGap = 4.00;

  /// md.comp.search-view.contained.leading-margin
  static const double containedLeadingMargin = 12.00;

  /// md.comp.search-view.contained.trailing-margin
  static const double containedTrailingMargin = 12.00;

  /// md.comp.search-view.container.elevation
  static const double containerElevation = 6.00;

  /// md.comp.search-view.docked.container.shape
  static const ShapeStruct dockedContainerShape = ShapeStruct(
    family: 'SHAPE_FAMILY_ROUNDED_CORNERS',
    topLeft: 28.00,
    topRight: 28.00,
    bottomLeft: 28.00,
    bottomRight: 28.00,
  );

  /// md.comp.search-view.docked.header.container.height
  static const double dockedHeaderContainerHeight = 56.00;

  /// md.comp.search-view.full-screen.container.shape
  static const ShapeStruct fullScreenContainerShape = ShapeStruct(
    family: 'SHAPE_FAMILY_ROUNDED_CORNERS',
    topLeft: 0.00,
    topRight: 0.00,
    bottomLeft: 0.00,
    bottomRight: 0.00,
  );

  /// md.comp.search-view.full-screen.header.container.height
  static const double fullScreenHeaderContainerHeight = 72.00;

  /// md.comp.search-view.header.input-text.type
  static const TypescaleStruct headerInputTextType = TokenTypescale.bodyLarge;

  /// md.comp.search-view.header.supporting-text.type
  static const TypescaleStruct headerSupportingTextType =
      TokenTypescale.bodyLarge;

  /// md.comp.search-view.leading-icon.leading-icon-label-space
  static const double leadingIconLeadingIconLabelSpace = 16.00;

  /// md.comp.search-view.leading-space
  static const double leadingSpace = 16.00;

  /// md.comp.search-view.trailing-icon.label-trailing-icon-space
  static const double trailingIconLabelTrailingIconSpace = 16.00;

  /// md.comp.search-view.trailing-space
  static const double trailingSpace = 16.00;
}

class TokenSearchViewDark {
  /// md.comp.search-view.contained.background.color
  static const TokenColorRole containedBackgroundColor =
      TokenColorRole.surfaceContainerLow;

  /// md.comp.search-view.container.color
  static const TokenColorRole containerColor =
      TokenColorRole.surfaceContainerHigh;
}

class TokenSearchViewDarkDefault {
  /// md.comp.search-view.divider.color
  static const TokenColorRole dividerColor = TokenColorRole.outline;

  /// md.comp.search-view.header.input-text.color
  static const TokenColorRole headerInputTextColor = TokenColorRole.onSurface;

  /// md.comp.search-view.header.leading-icon.color
  static const TokenColorRole headerLeadingIconColor = TokenColorRole.onSurface;

  /// md.comp.search-view.header.supporting-text.color
  static const TokenColorRole headerSupportingTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.search-view.header.trailing-icon.color
  static const TokenColorRole headerTrailingIconColor =
      TokenColorRole.onSurfaceVariant;
}

class TokenSearchViewDarkHighContrast {
  /// md.comp.search-view.divider.color
  static const TokenColorRole dividerColor = TokenColorRole.outline;

  /// md.comp.search-view.header.input-text.color
  static const TokenColorRole headerInputTextColor = TokenColorRole.onSurface;

  /// md.comp.search-view.header.leading-icon.color
  static const TokenColorRole headerLeadingIconColor = TokenColorRole.onSurface;

  /// md.comp.search-view.header.supporting-text.color
  static const TokenColorRole headerSupportingTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.search-view.header.trailing-icon.color
  static const TokenColorRole headerTrailingIconColor =
      TokenColorRole.onSurfaceVariant;
}

class TokenSearchViewDarkMediumContrast {
  /// md.comp.search-view.divider.color
  static const TokenColorRole dividerColor = TokenColorRole.outline;

  /// md.comp.search-view.header.input-text.color
  static const TokenColorRole headerInputTextColor = TokenColorRole.onSurface;

  /// md.comp.search-view.header.leading-icon.color
  static const TokenColorRole headerLeadingIconColor = TokenColorRole.onSurface;

  /// md.comp.search-view.header.supporting-text.color
  static const TokenColorRole headerSupportingTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.search-view.header.trailing-icon.color
  static const TokenColorRole headerTrailingIconColor =
      TokenColorRole.onSurfaceVariant;
}

class TokenSearchViewLight {
  /// md.comp.search-view.contained.background.color
  static const TokenColorRole containedBackgroundColor =
      TokenColorRole.surfaceContainerLow;

  /// md.comp.search-view.container.color
  static const TokenColorRole containerColor =
      TokenColorRole.surfaceContainerHigh;
}

class TokenSearchViewLightDefault {
  /// md.comp.search-view.divider.color
  static const TokenColorRole dividerColor = TokenColorRole.outline;

  /// md.comp.search-view.header.input-text.color
  static const TokenColorRole headerInputTextColor = TokenColorRole.onSurface;

  /// md.comp.search-view.header.leading-icon.color
  static const TokenColorRole headerLeadingIconColor = TokenColorRole.onSurface;

  /// md.comp.search-view.header.supporting-text.color
  static const TokenColorRole headerSupportingTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.search-view.header.trailing-icon.color
  static const TokenColorRole headerTrailingIconColor =
      TokenColorRole.onSurfaceVariant;
}

class TokenSearchViewLightHighContrast {
  /// md.comp.search-view.divider.color
  static const TokenColorRole dividerColor = TokenColorRole.outline;

  /// md.comp.search-view.header.input-text.color
  static const TokenColorRole headerInputTextColor = TokenColorRole.onSurface;

  /// md.comp.search-view.header.leading-icon.color
  static const TokenColorRole headerLeadingIconColor = TokenColorRole.onSurface;

  /// md.comp.search-view.header.supporting-text.color
  static const TokenColorRole headerSupportingTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.search-view.header.trailing-icon.color
  static const TokenColorRole headerTrailingIconColor =
      TokenColorRole.onSurfaceVariant;
}

class TokenSearchViewLightMediumContrast {
  /// md.comp.search-view.divider.color
  static const TokenColorRole dividerColor = TokenColorRole.outline;

  /// md.comp.search-view.header.input-text.color
  static const TokenColorRole headerInputTextColor = TokenColorRole.onSurface;

  /// md.comp.search-view.header.leading-icon.color
  static const TokenColorRole headerLeadingIconColor = TokenColorRole.onSurface;

  /// md.comp.search-view.header.supporting-text.color
  static const TokenColorRole headerSupportingTextColor =
      TokenColorRole.onSurfaceVariant;

  /// md.comp.search-view.header.trailing-icon.color
  static const TokenColorRole headerTrailingIconColor =
      TokenColorRole.onSurfaceVariant;
}
