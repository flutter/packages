// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This code is a Dart port of the AndroidX graphics-shapes library:
// https://cs.android.com/androidx/platform/frameworks/support/+/androidx-main:graphics/graphics-shapes/

/// A geometry engine for describing rounded polygonal shapes and morphing
/// between them.
library;

export 'corner_rounding.dart' show CornerRounding;
export 'cubic.dart' show CubicBezier;
export 'features.dart' show Feature;
export 'morph.dart' show Morph;
export 'point.dart' show PointTransformer;
export 'rounded_polygon.dart' show RoundedPolygon;
