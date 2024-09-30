// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show immutable;

/// Enumeration of types of pattern items.
enum PatternItemType {
  /// A dot used in the stroke pattern for a [Polyline].
  dot,

  /// A dash used in the stroke pattern for a [Polyline].
  dash,

  /// A gap used in the stroke pattern for a [Polyline].
  gap,
}

String _patternItemTypeToJson(PatternItemType itemType) => switch (itemType) {
      PatternItemType.dot => 'dot',
      PatternItemType.dash => 'dash',
      PatternItemType.gap => 'gap',
    };

/// Item used in the stroke pattern for a Polyline.
@immutable
class PatternItem {
  const PatternItem._(this.patternItemType, [this.length]);

  /// A dot used in the stroke pattern for a [Polyline].
  static const PatternItem dot = PatternItem._(PatternItemType.dot);

  /// A dash used in the stroke pattern for a [Polyline].
  ///
  /// [length] has to be non-negative.
  static PatternItem dash(double length) {
    assert(length >= 0.0);
    return PatternItem._(PatternItemType.dash, length);
  }

  /// A gap used in the stroke pattern for a [Polyline].
  ///
  /// [length] has to be non-negative.
  static PatternItem gap(double length) {
    assert(length >= 0.0);
    return PatternItem._(PatternItemType.gap, length);
  }

  /// The type of rendering used for an item in a pattern.
  final PatternItemType patternItemType;

  /// The length in pixels of a dash or gap.
  final double? length;

  /// Converts this object to something serializable in JSON.
  Object toJson() => <Object>[
        _patternItemTypeToJson(patternItemType),
        if (length != null) length!
      ];
}
