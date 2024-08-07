// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

const Set<TargetPlatform> _desktop = <TargetPlatform>{
  TargetPlatform.linux,
  TargetPlatform.macOS,
  TargetPlatform.windows
};

const Set<TargetPlatform> _mobile = <TargetPlatform>{
  TargetPlatform.android,
  TargetPlatform.fuchsia,
  TargetPlatform.iOS,
};

/// A group of standard breakpoints built according to the material
/// specifications for screen width size.
///
/// See also:
///
///  * [AdaptiveScaffold], which uses some of these Breakpoints as defaults.
class Breakpoints {
  /// This is a standard breakpoint that can be used as a fallthrough in the
  /// case that no other breakpoint is active.
  ///
  /// It is active from a width of -1 dp to infinity.
  static const Breakpoint standard = WidthPlatformBreakpoint(beginWidth: -1);

  /// A window whose width is less than 600 dp and greater than 0 dp.
  static const Breakpoint small = WidthPlatformBreakpoint(
    beginWidth: 0,
    endWidth: 600,
    endHeight: 480,
  );

  /// A window whose width is greater than 0 dp.
  static const Breakpoint smallAndUp = WidthPlatformBreakpoint(
    beginWidth: 0,
    endHeight: 480,
  );

  /// A desktop screen whose width is less than 600 dp and greater than 0 dp.
  static const Breakpoint smallDesktop = WidthPlatformBreakpoint(
    beginWidth: 0,
    endWidth: 600,
    endHeight: 480,
    platform: _desktop,
  );

  /// A mobile screen whose width is less than 600 dp and greater than 0 dp.
  static const Breakpoint smallMobile = WidthPlatformBreakpoint(
    beginWidth: 0,
    endWidth: 600,
    endHeight: 480,
    platform: _mobile,
  );

  /// A window whose width is between 600 dp and 840 dp.
  static const Breakpoint medium = WidthPlatformBreakpoint(
    beginWidth: 600,
    endWidth: 840,
    beginHeight: 480,
    endHeight: 900,
  );

  /// A window whose width is greater than 600 dp.
  static const Breakpoint mediumAndUp = WidthPlatformBreakpoint(
    beginWidth: 600,
    beginHeight: 480,
    endHeight: 900,
  );

  /// A desktop window whose width is between 600 dp and 840 dp.
  static const Breakpoint mediumDesktop = WidthPlatformBreakpoint(
    beginWidth: 600,
    endWidth: 840,
    beginHeight: 480,
    endHeight: 900,
    platform: _desktop,
  );

  /// A mobile window whose width is between 600 dp and 840 dp.
  static const Breakpoint mediumMobile = WidthPlatformBreakpoint(
    beginWidth: 600,
    endWidth: 840,
    beginHeight: 480,
    endHeight: 900,
    platform: _mobile,
  );

  /// A window whose width is between 840 dp and 1200 dp.
  static const Breakpoint mediumLarge = WidthPlatformBreakpoint(
    beginWidth: 840,
    endWidth: 1200,
    beginHeight: 900,
  );

  /// A window whose width is greater than 840 dp.
  static const Breakpoint mediumLargeAndUp = WidthPlatformBreakpoint(
    beginWidth: 840,
    beginHeight: 900,
  );

  /// A desktop window whose width is between 840 dp and 1200 dp.
  static const Breakpoint mediumLargeDesktop = WidthPlatformBreakpoint(
    beginWidth: 840,
    endWidth: 1200,
    beginHeight: 900,
    platform: _desktop,
  );

  /// A mobile window whose width is between 840 dp and 1200 dp.
  static const Breakpoint mediumLargeMobile = WidthPlatformBreakpoint(
    beginWidth: 840,
    endWidth: 1200,
    beginHeight: 900,
    platform: _mobile,
  );

  /// A window whose width is between 1200 dp and 1600 dp.
  static const Breakpoint large = WidthPlatformBreakpoint(
    beginWidth: 1200,
    endWidth: 1600,
    beginHeight: 900,
  );

  /// A window whose width is greater than 1200 dp.
  static const Breakpoint largeAndUp = WidthPlatformBreakpoint(
    beginWidth: 1200,
    beginHeight: 900,
  );

  /// A desktop window whose width is between 1200 dp and 1600 dp.
  static const Breakpoint largeDesktop = WidthPlatformBreakpoint(
    beginWidth: 1200,
    endWidth: 1600,
    beginHeight: 900,
    platform: _desktop,
  );

  /// A mobile window whose width is between 1200 dp and 1600 dp.
  static const Breakpoint largeMobile = WidthPlatformBreakpoint(
    beginWidth: 1200,
    endWidth: 1600,
    beginHeight: 900,
    platform: _mobile,
  );

  /// A window whose width is greater than 1600 dp.
  static const Breakpoint extraLarge = WidthPlatformBreakpoint(
    beginWidth: 1600,
    beginHeight: 900,
  );

  /// A desktop window whose width is greater than 1600 dp.
  static const Breakpoint extraLargeDesktop = WidthPlatformBreakpoint(
      beginWidth: 1600, beginHeight: 900, platform: _desktop);

  /// A mobile window whose width is greater than 1600 dp.
  static const Breakpoint extraLargeMobile = WidthPlatformBreakpoint(
    beginWidth: 1600,
    beginHeight: 900,
    platform: _mobile,
  );
}

/// A class that can be used to quickly generate [Breakpoint]s that depend on
/// the screen width and the platform.
class WidthPlatformBreakpoint extends Breakpoint {
  /// Returns a const [Breakpoint] with the given constraints.
  const WidthPlatformBreakpoint({
    this.beginWidth,
    this.endWidth,
    this.beginHeight,
    this.endHeight,
    this.platform,
  });

  /// The beginning width dp value. If left null then the [Breakpoint] will have
  /// no lower bound.
  final double? beginWidth;

  /// The end width dp value. If left null then the [Breakpoint] will have no
  /// upper bound.
  final double? endWidth;

  /// The beginning height dp value. If left null then the [Breakpoint] will have
  /// no lower bound.
  final double? beginHeight;

  /// The end height dp value. If left null then the [Breakpoint] will have no
  /// upper bound.
  final double? endHeight;

  /// A Set of [TargetPlatform]s that the [Breakpoint] will be active on. If
  /// left null then it will be active on all platforms.
  final Set<TargetPlatform>? platform;

  @override
  bool isActive(BuildContext context) {
    final TargetPlatform host = Theme.of(context).platform;
    final bool isRightPlatform = platform?.contains(host) ?? true;

    final double width = MediaQuery.sizeOf(context).width;
    final double height = MediaQuery.sizeOf(context).height;
    final Orientation orientation = MediaQuery.orientationOf(context);

    final double lowerBoundWidth = beginWidth ?? double.negativeInfinity;
    final double upperBoundWidth = endWidth ?? double.infinity;

    final double lowerBoundHeight = beginHeight ?? double.negativeInfinity;
    final double upperBoundHeight = endHeight ?? double.infinity;

    final bool isWidthActive =
        width >= lowerBoundWidth && width < upperBoundWidth;

    final bool isHeightActive = (orientation == Orientation.landscape &&
            height >= lowerBoundHeight &&
            height < upperBoundHeight) ||
        orientation == Orientation.portrait;

    return isWidthActive && isHeightActive && isRightPlatform;
  }
}

/// An interface to define the conditions that distinguish between types of
/// screens.
///
/// Adaptive apps usually display differently depending on the screen type: a
/// compact layout for smaller screens, or a relaxed layout for larger screens.
/// Override this class by defining `isActive` to fetch the screen property
/// (usually `MediaQuery.of`) and return true if the condition is met.
///
/// Breakpoints do not need to be exclusive because they are tested in order
/// with the last Breakpoint active taking priority.
///
/// If the condition is only based on the screen width and/or the device type,
/// use [WidthPlatformBreakpoint] to define the [Breakpoint].
///
/// See also:
///
///  * [SlotLayout.config], which uses breakpoints to dictate the layout of the
///    screen.
abstract class Breakpoint {
  /// Returns a const [Breakpoint].
  const Breakpoint();

  /// A method that returns true based on conditions related to the context of
  /// the screen such as MediaQuery.sizeOf(context).width.
  bool isActive(BuildContext context);
}
