// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Do not edit by hand. The code is generated from data in the Material
// Design token database by the script:
//   packages/material_ui/tool/gen_defaults/bin/gen_defaults.dart.
part of '../motion.dart';

/// The set of springs in the Material specification.
///
/// Material 3 Expressive motion uses springs, grouped into two motion schemes.
/// The standard scheme eases into place with minimal bounce, and suits more
/// utilitarian products. The expressive scheme overshoots and bounces into
/// place, and suits hero moments and key interactions.
///
/// Each scheme has springs for two types of motion, in three speeds: default,
/// fast, and slow.
///
/// * Spatial springs animate movement, such as position, size, rotation, and
///   corner radius.
/// * Effects springs animate properties that shouldn't overshoot, such as
///   color and opacity.
///
/// Most motion should use the default speed. Smaller elements can use the fast
/// speed, and larger elements can use the slow speed. Material components use
/// the fast spatial and fast effects springs of the selected scheme.
///
/// Material spring tokens do not include mass. These constants use unit mass
/// to convert Material's damping ratio and stiffness tokens to Flutter's
/// [SpringDescription]. Use them with a `SpringSimulation`, for example through
/// [AnimationController.animateWith].
///
/// See also:
///
/// * [Durations] and [Easing], which are the Material tokens for curve-based
///   animations.
/// * [M3 guidelines: How motion works](https://m3.material.io/styles/motion/overview/how-it-works)
/// * [M3 guidelines: Spring tokens](https://m3.material.io/styles/motion/overview/specs)
abstract final class Springs {
  /// The standard default spatial spring in the Material specification.
  ///
  /// It has a stiffness of 700.0 and a damping ratio of 0.9.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Spring tokens](https://m3.material.io/styles/motion/overview/specs)
  static const SpringDescription standardDefaultSpatial = SpringDescription(
    mass: 1.0,
    stiffness: 700.0,
    damping: 47.62352359916263,
  );

  /// The standard fast spatial spring in the Material specification.
  ///
  /// It has a stiffness of 1400.0 and a damping ratio of 0.9.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Spring tokens](https://m3.material.io/styles/motion/overview/specs)
  static const SpringDescription standardFastSpatial = SpringDescription(
    mass: 1.0,
    stiffness: 1400.0,
    damping: 67.34983296193096,
  );

  /// The standard slow spatial spring in the Material specification.
  ///
  /// It has a stiffness of 300.0 and a damping ratio of 0.9.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Spring tokens](https://m3.material.io/styles/motion/overview/specs)
  static const SpringDescription standardSlowSpatial = SpringDescription(
    mass: 1.0,
    stiffness: 300.0,
    damping: 31.176914536239796,
  );

  /// The standard default effects spring in the Material specification.
  ///
  /// It has a stiffness of 1600.0 and a damping ratio of 1.0.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Spring tokens](https://m3.material.io/styles/motion/overview/specs)
  static const SpringDescription standardDefaultEffects = SpringDescription(
    mass: 1.0,
    stiffness: 1600.0,
    damping: 80.0,
  );

  /// The standard fast effects spring in the Material specification.
  ///
  /// It has a stiffness of 3800.0 and a damping ratio of 1.0.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Spring tokens](https://m3.material.io/styles/motion/overview/specs)
  static const SpringDescription standardFastEffects = SpringDescription(
    mass: 1.0,
    stiffness: 3800.0,
    damping: 123.28828005937953,
  );

  /// The standard slow effects spring in the Material specification.
  ///
  /// It has a stiffness of 800.0 and a damping ratio of 1.0.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Spring tokens](https://m3.material.io/styles/motion/overview/specs)
  static const SpringDescription standardSlowEffects = SpringDescription(
    mass: 1.0,
    stiffness: 800.0,
    damping: 56.568542494923804,
  );

  /// The expressive default spatial spring in the Material specification.
  ///
  /// It has a stiffness of 380.0 and a damping ratio of 0.8.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Spring tokens](https://m3.material.io/styles/motion/overview/specs)
  static const SpringDescription expressiveDefaultSpatial = SpringDescription(
    mass: 1.0,
    stiffness: 380.0,
    damping: 31.189741903388683,
  );

  /// The expressive fast spatial spring in the Material specification.
  ///
  /// It has a stiffness of 800.0 and a damping ratio of 0.6.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Spring tokens](https://m3.material.io/styles/motion/overview/specs)
  static const SpringDescription expressiveFastSpatial = SpringDescription(
    mass: 1.0,
    stiffness: 800.0,
    damping: 33.94112549695428,
  );

  /// The expressive slow spatial spring in the Material specification.
  ///
  /// It has a stiffness of 200.0 and a damping ratio of 0.8.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Spring tokens](https://m3.material.io/styles/motion/overview/specs)
  static const SpringDescription expressiveSlowSpatial = SpringDescription(
    mass: 1.0,
    stiffness: 200.0,
    damping: 22.627416997969522,
  );

  /// The expressive default effects spring in the Material specification.
  ///
  /// It has a stiffness of 1600.0 and a damping ratio of 1.0.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Spring tokens](https://m3.material.io/styles/motion/overview/specs)
  static const SpringDescription expressiveDefaultEffects = SpringDescription(
    mass: 1.0,
    stiffness: 1600.0,
    damping: 80.0,
  );

  /// The expressive fast effects spring in the Material specification.
  ///
  /// It has a stiffness of 3800.0 and a damping ratio of 1.0.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Spring tokens](https://m3.material.io/styles/motion/overview/specs)
  static const SpringDescription expressiveFastEffects = SpringDescription(
    mass: 1.0,
    stiffness: 3800.0,
    damping: 123.28828005937953,
  );

  /// The expressive slow effects spring in the Material specification.
  ///
  /// It has a stiffness of 800.0 and a damping ratio of 1.0.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Spring tokens](https://m3.material.io/styles/motion/overview/specs)
  static const SpringDescription expressiveSlowEffects = SpringDescription(
    mass: 1.0,
    stiffness: 800.0,
    damping: 56.568542494923804,
  );
}
