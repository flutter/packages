// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

const List<TargetPlatform> _desktop = <TargetPlatform>[
  TargetPlatform.fuchsia,
  TargetPlatform.linux,
  TargetPlatform.macOS,
  TargetPlatform.windows
];
const List<TargetPlatform> _mobile = <TargetPlatform>[
  TargetPlatform.iOS,
  TargetPlatform.android
];

/// A group of standard breakpoints built according to the material
/// specifications for screen width size.
class Breakpoints {
  /// This is a standard breakpoint that can be used as a fallthrough in the
  /// case that no other breakpoint is active.
  ///
  /// It is active from a width of -1 dp to infinity.
  static const Breakpoint standard = WidthPlatformBreakpoint(begin: -1);

  /// This is the defined small breakpoint. Commonly used to indicate mobile but
  /// this breakpoint does not rely on platform.
  ///
  /// It is active from a width of 0 to 600 dp.
  static const Breakpoint small = WidthPlatformBreakpoint(begin: 0, end: 600);

  /// This is the defined smallAndUp breakpoint. Starts from small and is open
  /// ended to include everything onwards
  ///
  /// It is active from a width of 0 dp to infinity.
  static const Breakpoint smallAndUp = WidthPlatformBreakpoint(begin: 0);

  /// This is the defined small desktop breakpoint.
  ///
  /// It is active from a width of 0 to 600 dp and only on desktop devices.
  static const Breakpoint smallDesktop =
      WidthPlatformBreakpoint(begin: 0, end: 600, platform: _desktop);

  /// This is the defined small mobile breakpoint.
  ///
  /// It is active from a width of 0 to 600 dp and only on mobile devices.
  static const Breakpoint smallMobile =
      WidthPlatformBreakpoint(begin: 0, end: 600, platform: _mobile);

  /// This is the defined medium breakpoint. Commonly used to indicate a tablet
  /// but this breakpoint does not rely on platform.
  ///
  /// It is active from a width of 600 to 840 dp.
  static const Breakpoint medium =
      WidthPlatformBreakpoint(begin: 600, end: 840);

  /// This is the defined mediumAndUp breakpoint. Starts from small and is open
  /// ended to include everything onwards
  ///
  /// It is active from a width of 600 dp to infinity.
  static const Breakpoint mediumAndUp = WidthPlatformBreakpoint(begin: 600);

  /// This is the defined medium desktop breakpoint.
  ///
  /// It is active from a width of 600 to 840 dp and only on desktop devices.
  static const Breakpoint mediumDesktop =
      WidthPlatformBreakpoint(begin: 600, end: 840, platform: _desktop);

  /// This is the defined medium mobile breakpoint.
  ///
  /// It is active from a width of 600 to 840 dp and only on mobile devices.
  static const Breakpoint mediumMobile =
      WidthPlatformBreakpoint(begin: 600, end: 840, platform: _mobile);

  /// This is the defined large breakpoint. Commonly used to indicate a large
  /// screen desktop but this breakpoint does not rely on platform.
  ///
  /// It is active from a width of 840 dp to infinity.
  static const Breakpoint large = WidthPlatformBreakpoint(begin: 840);

  /// This is the defined large desktop breakpoint.
  ///
  /// It is active from a width of 840 dp to infinity and only on desktop
  /// devices.
  static const Breakpoint largeDesktop =
      WidthPlatformBreakpoint(begin: 840, platform: _desktop);

  /// This is the defined large mobile breakpoint.
  ///
  /// It is active from a width of 840 dp to infinity and only on mobile
  /// devices.
  static const Breakpoint largeMobile =
      WidthPlatformBreakpoint(begin: 840, platform: _mobile);
}

/// A class that can be used to generate [Breakpoint]s that depend on the screen
/// width and the platform quickly.
class WidthPlatformBreakpoint extends Breakpoint {
  /// Returns a [Breakpoint] with the given constraints.
  const WidthPlatformBreakpoint({this.begin, this.end, this.platform});

  /// The beginning width dp value. If left null then the [Breakpoint] will have
  /// no lower bound.
  final double? begin;

  /// The end width dp value. If left null then the [Breakpoint] will have
  /// no upper bound.
  final double? end;

  /// A list of [TargetPlatform]s that the [Breakpoint] will be active on. If
  /// left null then it will be active on all platforms.
  final List<TargetPlatform>? platform;

  @override
  bool isActive(BuildContext context) {
    bool size = false;
    final bool isRightPlatform =
        platform?.contains(Theme.of(context).platform) ?? true;
    if (begin != null && end != null) {
      size = MediaQuery.of(context).size.width >= begin! &&
          MediaQuery.of(context).size.width < end!;
    } else if (begin != null && end == null) {
      size = MediaQuery.of(context).size.width >= begin!;
    } else if (begin == null && end != null) {
      size = MediaQuery.of(context).size.width < end!;
    }
    return size && isRightPlatform;
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
/// Typically, it is not needed to keep breakpoints exclusive between each
/// other, since they are tested one by one with a pre-defined priority.
///
/// If the condition is only based on the screen width and/or the device type,
/// use [WidthPlatformBreakpoint] to define the [Breakpoint].
///
/// See also:
///
///  * [SlotLayout.config], which uses breakpoints.
abstract class Breakpoint {
  /// Returns a [Breakpoint].
  const Breakpoint();

  /// A method that returns whether the breakpoint is active under some
  /// conditions related to the [BuildContext] of the screen.
  bool isActive(BuildContext context);
}
