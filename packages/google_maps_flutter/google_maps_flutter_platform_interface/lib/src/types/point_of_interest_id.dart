// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show immutable, objectRuntimeType;

/// Uniquely identifies a point of interest on a [GoogleMap].
///
/// The [value] is the Google Maps place ID for the tapped point of interest.
@immutable
class PointOfInterestId {
  /// Creates an immutable identifier for a point of interest.
  const PointOfInterestId(this.value);

  /// The Google Maps place ID for the point of interest.
  final String value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is PointOfInterestId && value == other.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return '${objectRuntimeType(this, 'PointOfInterestId')}($value)';
  }
}
