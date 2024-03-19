// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// Constant values associated with legacy Material Design specifications.
class LegacyMaterialConstants {
  /// The height of the toolbar component of the [AppBar].
  static const double kToolbarHeight = 56.0;

  /// The height of the bottom navigation bar.
  static const double kBottomNavigationBarHeight = 56.0;

  /// The height of a tab bar containing text.
  static const double kTextTabBarHeight = kMinInteractiveDimension;

  /// The amount of time theme change animations should last.
  static const Duration kThemeChangeDuration = Duration(milliseconds: 200);

  /// The default radius of a circular material ink response in logical pixels.
  static const double kRadialReactionRadius = 20.0;

  /// The amount of time a circular material ink response should take to expand
  /// to its full size.
  static const Duration kRadialReactionDuration = Duration(milliseconds: 100);

  /// The value of the alpha channel to use when drawing a circular material ink
  /// response.
  static const int kRadialReactionAlpha = 0x1F;

  /// The duration of the horizontal scroll animation that occurs when a tab is
  /// tapped.
  static const Duration kTabScrollDuration = Duration(milliseconds: 300);

  /// The horizontal padding included by [Tab]s.
  static const EdgeInsets kTabLabelPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
  );

  /// The padding added around material list items.
  static const EdgeInsets kMaterialListPadding = EdgeInsets.symmetric(
    vertical: 8.0,
  );

  /// The default color for [ThemeData.iconTheme] when [ThemeData.brightness] is
  /// [Brightness.dark]. This color is used in [IconButton] to detect whether
  /// [IconTheme.of(context).color] is the same as the default color of
  /// [ThemeData.iconTheme].
  static const Color kDefaultIconLightColor = Color(0xFFFFFFFF);

  /// The default color for [LegacyThemeData.iconTheme] when
  /// [LegacyThemeData.brightness] is [Brightness.light]. This color is used in
  /// [IconButton] to detect whether [IconThemeData.color] is the same
  /// as the default color of [LegacyThemeData.iconTheme].
  static const Color kDefaultIconDarkColor = Color(0xDD000000);

  // Deriving these values is black magic. The spec claims that pressed buttons
  // have a highlight of 0x66999999, but that's clearly wrong. The videos in the
  // spec show that buttons have a composited highlight of #E1E1E1 on a background
  // of #FAFAFA. Assuming that the highlight really has an opacity of 0x66, we can
  // solve for the actual color of the highlight:
  /// The default color for [LegacyThemeData.highlightColor] when the
  /// [LegacyThemeData.brightness] is [Brightness.light].
  static const Color kLightThemeHighlightColor = Color(0x66BCBCBC);

  // The same video shows the splash compositing to #D7D7D7 on a background of
  // #E1E1E1. Again, assuming the splash has an opacity of 0x66, we can solve for
  // the actual color of the splash:
  /// The default color for [LegacyThemeData.splashColor] when the
  /// [LegacyThemeData.brightness] is [Brightness.light].
  static const Color kLightThemeSplashColor = Color(0x66C8C8C8);

  // Unfortunately, a similar video isn't available for the dark theme, which
  // means we assume the values in the spec are actually correct.
  /// The default color for [LegacyThemeData.highlightColor] when the
  /// [LegacyThemeData.brightness] is [Brightness.dark].
  static const Color kDarkThemeHighlightColor = Color(0x40CCCCCC);

  // Unfortunately, a similar video isn't available for the dark theme, which
  // means we assume the values in the spec are actually correct.
  /// The default color for [LegacyThemeData.splashColor] when the
  /// [LegacyThemeData.brightness] is [Brightness.dark].
  static const Color kDarkThemeSplashColor = Color(0x40CCCCCC);
}
