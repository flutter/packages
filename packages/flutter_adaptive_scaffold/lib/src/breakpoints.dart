// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../flutter_adaptive_scaffold.dart';

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
  static const Breakpoint standard = Breakpoint(beginWidth: -1);

  /// A window whose width is less than 600 dp and greater than 0 dp.
  static const Breakpoint small = Breakpoint.small();

  /// A window whose width is greater than 0 dp.
  static const Breakpoint smallAndUp = Breakpoint.small(andUp: true);

  /// A desktop screen whose width is less than 600 dp and greater than 0 dp.
  static const Breakpoint smallDesktop =
      Breakpoint.small(platform: Breakpoint.desktop);

  /// A mobile screen whose width is less than 600 dp and greater than 0 dp.
  static const Breakpoint smallMobile =
      Breakpoint.small(platform: Breakpoint.mobile);

  /// A window whose width is between 600 dp and 840 dp.
  static const Breakpoint medium = Breakpoint.medium();

  /// A window whose width is greater than 600 dp.
  static const Breakpoint mediumAndUp = Breakpoint.medium(andUp: true);

  /// A desktop window whose width is between 600 dp and 840 dp.
  static const Breakpoint mediumDesktop =
      Breakpoint.medium(platform: Breakpoint.desktop);

  /// A mobile window whose width is between 600 dp and 840 dp.
  static const Breakpoint mediumMobile =
      Breakpoint.medium(platform: Breakpoint.mobile);

  /// A window whose width is between 840 dp and 1200 dp.
  static const Breakpoint mediumLarge = Breakpoint.mediumLarge();

  /// A window whose width is greater than 840 dp.
  static const Breakpoint mediumLargeAndUp =
      Breakpoint.mediumLarge(andUp: true);

  /// A desktop window whose width is between 840 dp and 1200 dp.
  static const Breakpoint mediumLargeDesktop =
      Breakpoint.mediumLarge(platform: Breakpoint.desktop);

  /// A mobile window whose width is between 840 dp and 1200 dp.
  static const Breakpoint mediumLargeMobile =
      Breakpoint.mediumLarge(platform: Breakpoint.mobile);

  /// A window whose width is between 1200 dp and 1600 dp.
  static const Breakpoint large = Breakpoint.large();

  /// A window whose width is greater than 1200 dp.
  static const Breakpoint largeAndUp = Breakpoint.large(andUp: true);

  /// A desktop window whose width is between 1200 dp and 1600 dp.
  static const Breakpoint largeDesktop =
      Breakpoint.large(platform: Breakpoint.desktop);

  /// A mobile window whose width is between 1200 dp and 1600 dp.
  static const Breakpoint largeMobile =
      Breakpoint.large(platform: Breakpoint.mobile);

  /// A window whose width is greater than 1600 dp.
  static const Breakpoint extraLarge = Breakpoint.extraLarge();

  /// A desktop window whose width is greater than 1600 dp.
  static const Breakpoint extraLargeDesktop =
      Breakpoint.extraLarge(platform: Breakpoint.desktop);

  /// A mobile window whose width is greater than 1600 dp.
  static const Breakpoint extraLargeMobile =
      Breakpoint.extraLarge(platform: Breakpoint.mobile);
}

/// A class to define the conditions that distinguish between types of
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
class Breakpoint {
  /// Returns a const [Breakpoint] with the given constraints.
  const Breakpoint({
    this.beginWidth,
    this.endWidth,
    this.beginHeight,
    this.endHeight,
    this.platform,
    this.andUp = false,
  });

  /// Returns a [Breakpoint] with the given constraints for a small screen.
  const Breakpoint.small({this.andUp = false, this.platform})
      : beginWidth = 0,
        endWidth = 600,
        beginHeight = null,
        endHeight = 480;

  /// Returns a [Breakpoint] with the given constraints for a medium screen.
  const Breakpoint.medium({this.andUp = false, this.platform})
      : beginWidth = 600,
        endWidth = 840,
        beginHeight = 480,
        endHeight = 900;

  /// Returns a [Breakpoint] with the given constraints for a mediumLarge screen.
  const Breakpoint.mediumLarge({this.andUp = false, this.platform})
      : beginWidth = 840,
        endWidth = 1200,
        beginHeight = 900,
        endHeight = null;

  /// Returns a [Breakpoint] with the given constraints for a large screen.
  const Breakpoint.large({this.andUp = false, this.platform})
      : beginWidth = 1200,
        endWidth = 1600,
        beginHeight = 900,
        endHeight = null;

  /// Returns a [Breakpoint] with the given constraints for an extraLarge screen.
  const Breakpoint.extraLarge({this.andUp = false, this.platform})
      : beginWidth = 1600,
        endWidth = null,
        beginHeight = 900,
        endHeight = null;

  /// A set of [TargetPlatform]s that the [Breakpoint] will be active on desktop.
  static const Set<TargetPlatform> desktop = <TargetPlatform>{
    TargetPlatform.linux,
    TargetPlatform.macOS,
    TargetPlatform.windows
  };

  /// A set of [TargetPlatform]s that the [Breakpoint] will be active on mobile.
  static const Set<TargetPlatform> mobile = <TargetPlatform>{
    TargetPlatform.android,
    TargetPlatform.fuchsia,
    TargetPlatform.iOS,
  };

  /// When set to true, it will include any size above the set width.
  final bool andUp;

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

  /// A method that returns true based on conditions related to the context of
  /// the screen such as MediaQuery.sizeOf(context).width, MediaQuery.sizeOf(context).height
  /// and MediaQuery.orientationOf(context).
  bool isActive(BuildContext context) {
    final TargetPlatform host = Theme.of(context).platform;
    final bool isRightPlatform = platform?.contains(host) ?? true;
    final bool isDesktop = Breakpoint.desktop.contains(host);

    final double width = MediaQuery.sizeOf(context).width;
    final double height = MediaQuery.sizeOf(context).height;
    final Orientation orientation = MediaQuery.orientationOf(context);

    final double lowerBoundWidth = beginWidth ?? double.negativeInfinity;
    final double upperBoundWidth = endWidth ?? double.infinity;

    final double lowerBoundHeight = beginHeight ?? double.negativeInfinity;
    final double upperBoundHeight = endHeight ?? double.infinity;

    final bool isWidthActive = andUp
        ? width >= lowerBoundWidth
        : width >= lowerBoundWidth && width < upperBoundWidth;

    final bool isHeightActive = isDesktop ||
        orientation == Orientation.portrait ||
        (orientation == Orientation.landscape &&
            height >= lowerBoundHeight &&
            height < upperBoundHeight);

    return isWidthActive && isHeightActive && isRightPlatform;
  }

  /// Returns the currently active [Breakpoint] based on the [SlotLayout] in the
  /// context.
  static Breakpoint? maybeActiveBreakpointFromSlotLayout(BuildContext context) {
    final SlotLayout? slotLayout =
        context.findAncestorWidgetOfExactType<SlotLayout>();
    Breakpoint? fallbackBreakpoint;

    if (slotLayout != null) {
      for (final MapEntry<Breakpoint, SlotLayoutConfig?> config
          in slotLayout.config.entries) {
        if (config.key.isActive(context)) {
          if (config.key.platform != null) {
            return config.key;
          } else {
            fallbackBreakpoint ??= config.key;
          }
        }
      }
    }
    return fallbackBreakpoint;
  }

  /// Returns the default [Breakpoint] based on the [BuildContext].
  static Breakpoint defaultBreakpointOf(BuildContext context) {
    final TargetPlatform host = Theme.of(context).platform;
    final bool isDesktop = Breakpoint.desktop.contains(host);
    final bool isMobile = Breakpoint.mobile.contains(host);

    for (final Breakpoint breakpoint in <Breakpoint>[
      Breakpoints.small,
      Breakpoints.medium,
      Breakpoints.mediumLarge,
      Breakpoints.large,
      Breakpoints.extraLarge,
    ]) {
      if (breakpoint.isActive(context)) {
        if (isDesktop) {
          switch (breakpoint) {
            case Breakpoints.small:
              return Breakpoints.smallDesktop;
            case Breakpoints.medium:
              return Breakpoints.mediumDesktop;
            case Breakpoints.mediumLarge:
              return Breakpoints.mediumLargeDesktop;
            case Breakpoints.large:
              return Breakpoints.largeDesktop;
            case Breakpoints.extraLarge:
              return Breakpoints.extraLargeDesktop;
            default:
              return Breakpoints.standard;
          }
        } else if (isMobile) {
          switch (breakpoint) {
            case Breakpoints.small:
              return Breakpoints.smallMobile;
            case Breakpoints.medium:
              return Breakpoints.mediumMobile;
            case Breakpoints.mediumLarge:
              return Breakpoints.mediumLargeMobile;
            case Breakpoints.large:
              return Breakpoints.largeMobile;
            case Breakpoints.extraLarge:
              return Breakpoints.extraLargeMobile;
            default:
              return Breakpoints.standard;
          }
        } else {
          return breakpoint;
        }
      }
    }
    return Breakpoints.standard;
  }

  /// Returns the currently active [Breakpoint].
  static Breakpoint activeBreakpointOf(BuildContext context) {
    return maybeActiveBreakpointFromSlotLayout(context) ??
        defaultBreakpointOf(context);
  }
}
