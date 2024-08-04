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
  static const Breakpoint standard = WidthPlatformBreakpoint(begin: -1);

  /// A window whose width is less than 600 dp and greater than 0 dp.
  static const Breakpoint small = WidthPlatformBreakpoint(
    begin: 0,
    end: 600,
    bottom: 480,
  );

  /// A window whose width is greater than 0 dp.
  static const Breakpoint smallAndUp = WidthPlatformBreakpoint(
    begin: 0,
    bottom: 480,
  );

  /// A desktop screen whose width is less than 600 dp and greater than 0 dp.
  static const Breakpoint smallDesktop = WidthPlatformBreakpoint(
    begin: 0,
    end: 600,
    bottom: 480,
    platform: _desktop,
  );

  /// A mobile screen whose width is less than 600 dp and greater than 0 dp.
  static const Breakpoint smallMobile = WidthPlatformBreakpoint(
    begin: 0,
    end: 600,
    bottom: 480,
    platform: _mobile,
  );

  /// A window whose width is between 600 dp and 840 dp.
  static const Breakpoint medium = WidthPlatformBreakpoint(
    begin: 600,
    end: 840,
    top: 480,
    bottom: 900,
  );

  /// A window whose width is greater than 600 dp.
  static const Breakpoint mediumAndUp = WidthPlatformBreakpoint(
    begin: 600,
    top: 480,
    bottom: 900,
  );

  /// A desktop window whose width is between 600 dp and 840 dp.
  static const Breakpoint mediumDesktop = WidthPlatformBreakpoint(
    begin: 600,
    end: 840,
    top: 480,
    bottom: 900,
    platform: _desktop,
  );

  /// A mobile window whose width is between 600 dp and 840 dp.
  static const Breakpoint mediumMobile = WidthPlatformBreakpoint(
    begin: 600,
    end: 840,
    top: 480,
    bottom: 900,
    platform: _mobile,
  );

  /// A window whose width is between 840 dp and 1200 dp.
  static const Breakpoint expanded = WidthPlatformBreakpoint(
    begin: 840,
    end: 1200,
    top: 900,
  );

  /// A window whose width is greater than 840 dp.
  static const Breakpoint expandedAndUp = WidthPlatformBreakpoint(
    begin: 840,
    top: 900,
  );

  /// A desktop window whose width is between 840 dp and 1200 dp.
  static const Breakpoint expandedDesktop = WidthPlatformBreakpoint(
    begin: 840,
    end: 1200,
    top: 900,
    platform: _desktop,
  );

  /// A mobile window whose width is between 840 dp and 1200 dp.
  static const Breakpoint expandedMobile = WidthPlatformBreakpoint(
    begin: 840,
    end: 1200,
    top: 900,
    platform: _mobile,
  );

  /// A window whose width is between 1200 dp and 1600 dp.
  static const Breakpoint large = WidthPlatformBreakpoint(
    begin: 1200,
    end: 1600,
    top: 900,
  );

  /// A window whose width is greater than 1200 dp.
  static const Breakpoint largeAndUp = WidthPlatformBreakpoint(
    begin: 1200,
    top: 900,
  );

  /// A desktop window whose width is between 1200 dp and 1600 dp.
  static const Breakpoint largeDesktop = WidthPlatformBreakpoint(
    begin: 1200,
    end: 1600,
    top: 900,
    platform: _desktop,
  );

  /// A mobile window whose width is between 1200 dp and 1600 dp.
  static const Breakpoint largeMobile = WidthPlatformBreakpoint(
    begin: 1200,
    end: 1600,
    top: 900,
    platform: _mobile,
  );

  /// A window whose width is greater than 1600 dp.
  static const Breakpoint extraLarge = WidthPlatformBreakpoint(
    begin: 1600,
    top: 900,
  );

  /// A desktop window whose width is greater than 1600 dp.
  static const Breakpoint extraLargeDesktop =
      WidthPlatformBreakpoint(begin: 1600, top: 900, platform: _desktop);

  /// A mobile window whose width is greater than 1600 dp.
  static const Breakpoint extraLargeMobile = WidthPlatformBreakpoint(
    begin: 1600,
    top: 900,
    platform: _mobile,
  );
}

/// A class that can be used to quickly generate [Breakpoint]s that depend on
/// the screen width and the platform.
class WidthPlatformBreakpoint extends Breakpoint {
  /// Returns a const [Breakpoint] with the given constraints.
  const WidthPlatformBreakpoint({
    this.begin,
    this.end,
    this.top,
    this.bottom,
    this.platform,
  });

  /// The beginning width dp value. If left null then the [Breakpoint] will have
  /// no lower bound.
  final double? begin;

  /// The end width dp value. If left null then the [Breakpoint] will have no
  /// upper bound.
  final double? end;

  /// The beginning height dp value. If left null then the [Breakpoint] will have
  /// no lower bound.
  final double? top;

  /// The end height dp value. If left null then the [Breakpoint] will have no
  /// upper bound.
  final double? bottom;

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

    final double lowerBoundWidth = begin ?? double.negativeInfinity;
    final double upperBoundWidth = end ?? double.infinity;

    final double lowerBoundHeight = orientation == Orientation.landscape
        ? top ?? double.negativeInfinity
        : double.negativeInfinity;
    final double upperBoundHeight = orientation == Orientation.landscape
        ? bottom ?? double.infinity
        : double.infinity;

    return width >= lowerBoundWidth &&
        width < upperBoundWidth &&
        height >= lowerBoundHeight &&
        height < upperBoundHeight &&
        isRightPlatform;
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
