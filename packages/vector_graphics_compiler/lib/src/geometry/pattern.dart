// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

import 'matrix.dart';

/// Pattern positioning and size information.
@immutable
class PatternData {
  /// Constructs new [PatternData].
  const PatternData(this.x, this.y, this.width, this.height, this.transform);

  /// The x coordinate shift of the pattern tile in px.
  final double x;

  /// The y coordinate shift of the pattern tile in px.
  final double y;

  /// The width of the pattern's viewbox in px.
  /// Values must be > = 1.
  final double width;

  /// The height of the pattern's viewbox in px.
  /// Values must be > = 1.
  final double height;

  /// The transform of the pattern generated from its children.
  final AffineMatrix transform;

  @override
  int get hashCode => Object.hash(x, y, width, height, transform);

  @override
  bool operator ==(Object other) {
    return other is PatternData &&
        other.x == x &&
        other.y == y &&
        other.width == width &&
        other.height == height &&
        other.transform == transform;
  }
}
