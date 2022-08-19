// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../../src/svg/resolver.dart';
import 'matrix.dart';

/// Pattern information for encoding.
class PatternData {
  /// Constructs new [PatternData].
  PatternData(this.x, this.y, this.width, this.height, this.transform);

  /// The x coordinate shift of the pattern tile in px.
  double x;

  /// The y coordinate shift of the pattern tile in px.
  double y;

  /// The width of the pattern's viewbox in px.
  /// Values must be > = 1.
  double width;

  /// The height of the pattern's viewbox in px.
  /// Values must be > = 1.
  double height;

  /// The transform of the pattern generated from its children.
  AffineMatrix transform;

  /// Creates a [PatternData] object from a [ResolvedPatternNode].
  static PatternData fromNode(ResolvedPatternNode patternNode) {
    return PatternData(patternNode.x!, patternNode.y!, patternNode.width,
        patternNode.height, patternNode.transform);
  }
}
