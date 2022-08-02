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
///
/// These are directly used in [AdaptiveScaffold] and can be used as
/// [Breakpoint]s within [SlotLayout]. Anywhere that takes a [Breakpoint] can
/// take these values.
class Breakpoints {
  /// This is a standard breakpoint that can be used as a fallthrough in the
  /// case that no other breakpoint is active.
  ///
  /// It is active from a width of -1 dp to infinity.
  static const Breakpoint standard = _Breakpoint(begin: -1);

  /// This is the defined small breakpoint. Commonly used to indicate mobile but
  /// this breakpoint does not rely on platform.
  ///
  /// It is active from a width of 0 to 600 dp.
  static const Breakpoint small = _Breakpoint(begin: 0, end: 600);

  /// This is the defined small desktop breakpoint.
  ///
  /// It is active from a width of 0 to 600 dp and only on desktop devices.
  static const Breakpoint smallDesktop =
      _Breakpoint(begin: 0, end: 600, platform: _desktop);

  /// This is the defined small mobile breakpoint.
  ///
  /// It is active from a width of 0 to 600 dp and only on mobile devices.
  static const Breakpoint smallMobile =
      _Breakpoint(begin: 0, end: 600, platform: _mobile);

  /// This is the defined medium breakpoint. Commonly used to indicate a tablet
  /// but this breakpoint does not rely on platform.
  ///
  /// It is active from a width of 600 to 840 dp.
  static const Breakpoint medium = _Breakpoint(begin: 600, end: 840);

  /// This is the defined medium desktop breakpoint.
  ///
  /// It is active from a width of 600 to 840 dp and only on desktop devices.
  static const Breakpoint mediumDesktop =
      _Breakpoint(begin: 600, end: 840, platform: _desktop);

  /// This is the defined medium mobile breakpoint.
  ///
  /// It is active from a width of 600 to 840 dp and only on mobile devices.
  static const Breakpoint mediumMobile =
      _Breakpoint(begin: 600, end: 840, platform: _mobile);

  /// This is the defined large breakpoint. Commonly used to indicate a large
  /// screen desktop but this breakpoint does not rely on platform.
  ///
  /// It is active from a width of 840 dp to infinity.
  static const Breakpoint large = _Breakpoint(begin: 840);

  /// This is the defined large desktop breakpoint.
  ///
  /// It is active from a width of 840 dp to infinity and only on desktop
  /// devices.
  static const Breakpoint largeDesktop =
      _Breakpoint(begin: 840, platform: _desktop);

  /// This is the defined large mobile breakpoint.
  ///
  /// It is active from a width of 840 dp to infinity and only on mobile
  /// devices.
  static const Breakpoint largeMobile =
      _Breakpoint(begin: 840, platform: _mobile);
}

class _Breakpoint extends Breakpoint {
  const _Breakpoint({this.begin, this.end, this.platform});
  final double? begin;
  final double? end;
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

/// A class to indicate whether a given number of conditions based on the
/// current [BuildContext] are met or not. This class can really be used for
/// wide variety of purposes but the typical use is within [SlotLayout] and
/// [AdaptiveScaffold].
abstract class Breakpoint {
  /// Returns a [Breakpoint].
  const Breakpoint();

  /// A method that returns whether the breakpoint is active under some
  /// conditions related to the [BuildContext] of the screen.
  bool isActive(BuildContext context);
}
