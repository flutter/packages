// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'path_ops.dart';

/// Whether or not tesselation should be used.
bool get isPathOpsInitialized => false;

/// Initialize the libpathops dynamic library.
void initializeLibPathOps(String path) {}

/// Creates a path object to operate on.
class Path implements PathProxy {
  /// Creates an empty path object with the specified fill type.
  Path([this.fillType = FillType.nonZero]);

  /// Creates a copy of this path.
  factory Path.from(Path other) {
    final Path result = Path(other.fillType);
    other.replay(result);
    return result;
  }

  /// The [FillType] of this path.
  final FillType fillType;

  /// Makes the appropriate calls using [verbs] and [points] to replay this path
  /// on [proxy].
  ///
  /// Calls [PathProxy.reset] first if [reset] is true.
  void replay(PathProxy proxy, {bool reset = true}) {
    throw UnsupportedError('PathOps not supported on the web');
  }

  @override
  void close() {
    throw UnsupportedError('PathOps not supported on the web');
  }

  @override
  void cubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    throw UnsupportedError('PathOps not supported on the web');
  }

  @override
  void lineTo(double x, double y) {
    throw UnsupportedError('PathOps not supported on the web');
  }

  @override
  void moveTo(double x, double y) {
    throw UnsupportedError('PathOps not supported on the web');
  }

  @override
  void reset() {
    throw UnsupportedError('PathOps not supported on the web');
  }

  /// Applies the operation described by [op] to this path using [other].
  Path applyOp(Path other, PathOp op) {
    throw UnsupportedError('PathOps not supported on the web');
  }

  /// Retrieves PathVerbs.
  Iterable<PathVerb> get verbs {
    throw UnsupportedError('PathOps not supported on the web');
  }

  /// The list of points to use with [verbs].
  ///
  /// Each verb uses a specific number of points, specified by the
  /// [pointsPerVerb] map.
  Float32List get points {
    throw UnsupportedError('PathOps not supported on the web');
  }

  /// Releases native resources.
  ///
  /// After calling dispose, this class must not be used again.
  void dispose() {
    throw UnsupportedError('PathOps not supported on the web');
  }
}
