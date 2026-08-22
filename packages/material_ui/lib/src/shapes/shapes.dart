// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This code is a Dart port of the AndroidX graphics-shapes library:
// https://cs.android.com/androidx/platform/frameworks/support/+/androidx-main:graphics/graphics-shapes/

/// A geometry engine for describing rounded polygonal shapes and morphing
/// between them.
library;

import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math_64.dart';

part 'corner_rounding.dart';
part 'cubic.dart';
part 'feature_mapping.dart';
part 'features.dart';
part 'float_mapping.dart';
part 'morph.dart';
part 'point.dart';
part 'polygon_measure.dart';
part 'rounded_polygon.dart';
part 'utils.dart';
