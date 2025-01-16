// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Copied from flutter/engine repository: https://github.com/flutter/engine/tree/main/tools/path_ops
// NOTE: For now, this copy and flutter/engine copy should be kept in sync.

import '_path_ops_unsupported.dart' if (dart.library.ffi) '_path_ops_ffi.dart'
    as impl;
export '_path_ops_unsupported.dart' if (dart.library.ffi) '_path_ops_ffi.dart';

// ignore_for_file: camel_case_types, non_constant_identifier_names

/// Initialize the libpathops dynamic library.
void initializeLibPathOps(String path) => impl.initializeLibPathOps(path);

/// Determines the winding rule that decides how the interior of a Path is
/// calculated.
///
/// This enum is used by the [Path] constructor
// must match ordering in //third_party/skia/include/core/SkPathTypes.h
enum FillType {
  /// The interior is defined by a non-zero sum of signed edge crossings.
  nonZero,

  /// The interior is defined by an odd number of edge crossings.
  evenOdd,
}

/// A set of operations applied to two paths.
// Sync with //third_party/skia/include/pathops/SkPathOps.h
enum PathOp {
  /// Subtracts the second path from the first.
  difference,

  /// Creates a new path representing the intersection of the first and second.
  intersect,

  /// Creates a new path representing the union of the first and second
  /// (includive-or).
  union,

  /// Creates a new path representing the exclusive-or of two paths.
  xor,

  /// Creates a new path that subtracts the first path from the second.s
  reversedDifference,
}

/// The commands used in a [Path] object.
///
/// This enumeration is a subset of the commands that SkPath supports.
// Sync with //third_party/skia/include/core/SkPathTypes.h
enum PathVerb {
  /// Picks up the pen and moves it without drawing. Uses two point values.
  moveTo,

  /// A straight line from the current point to the specified point.
  lineTo,

  /// A quadratic bezier curve from the current point.
  ///
  /// The next two points are the control point. The next two points after
  /// that are the target point.
  quadTo,

  /// A cubic bezier curve from the current point.
  ///
  /// The next two points are used as the first control point. The next two
  /// points form the second control point. The next two points form the
  /// target point.
  cubicTo,

  /// A straight line from the current point to the last [moveTo] point.
  close,
}

/// A proxy class for [Path.replay].
///
/// Allows implementations to easily inspect the contents of a [Path].
abstract class PathProxy {
  /// Picks up the pen and moves to absolute coordinates x,y.
  void moveTo(double x, double y);

  /// Draws a straight line from the current point to absolute coordinates x,y.
  void lineTo(double x, double y);

  /// Creates a cubic Bezier curve from the current point to point x3,y3 using
  /// x1,y1 as the first control point and x2,y2 as the second.
  void cubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3);

  /// Draws a straight line from the current point to the last [moveTo] point.
  void close();

  /// Called by [Path.replay] to indicate that a new path is being played.
  void reset() {}
}

/// A path proxy that can print the SVG path-data representation of this path.
class SvgPathProxy implements PathProxy {
  final StringBuffer _buffer = StringBuffer();

  @override
  void reset() {
    _buffer.clear();
  }

  @override
  void close() {
    _buffer.write('Z');
  }

  @override
  void cubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    _buffer.write('C$x1,$y1 $x2,$y2 $x3,$y3');
  }

  @override
  void lineTo(double x, double y) {
    _buffer.write('L$x,$y');
  }

  @override
  void moveTo(double x, double y) {
    _buffer.write('M$x,$y');
  }

  @override
  String toString() => _buffer.toString();
}
