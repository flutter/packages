// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '_tessellator_unsupported.dart'
    if (dart.library.ffi) '_tessellator_ffi.dart' as impl;
import 'node.dart';
import 'visitor.dart';

/// Whether or not tesselation should be used.
bool get isTesselatorInitialized => impl.isTesselatorInitialized;

/// Initialize the libtesselator dynamic library.
///
/// This method must be called before [VerticesBuilder] can be used or
/// constructed.
void initializeLibTesselator(String path) => impl.initializeLibTesselator(path);

/// Information about how to approximate points on a curved path segment.
///
/// In particular, the values in this object control how many vertices to
/// generate when approximating curves, and what tolerances to use when
/// calculating the sharpness of curves.
///
/// Used by [VerticesBuilder.tessellate].
class SmoothingApproximation {
  /// Creates a new smoothing approximation instance with default values.
  const SmoothingApproximation({
    this.scale = 1.0,
    this.angleTolerance = 0.0,
    this.cuspLimit = 0.0,
  });

  /// The scaling coefficient to use when translating to screen coordinates.
  ///
  /// Values approaching 0.0 will generate smoother looking curves with a
  /// greater number of vertices, and will be more expensive to calculate.
  final double scale;

  /// The tolerance value in radians for calculating sharp angles.
  ///
  /// Values approaching 0.0 will provide more accurate approximation of sharp
  /// turns. A 0.0 vlaue means angle conditions are not considered at all.
  final double angleTolerance;

  /// An angle in radians at which to introduce bevel cuts.
  ///
  /// Values greater than zero will restirct the sharpness of bevel cuts on
  /// turns.
  final double cuspLimit;
}

/// A visitor that replaces fill paths with tesselated vertices.
abstract class Tessellator extends Visitor<Node, void> {
  /// Create a new [Tessellator] visitor.
  factory Tessellator() = impl.Tessellator;
}
