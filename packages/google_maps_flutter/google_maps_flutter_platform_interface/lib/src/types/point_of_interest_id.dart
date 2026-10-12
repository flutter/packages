// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show immutable;

import 'types.dart';

/// Uniquely identifies a point of interest on a [GoogleMap].
///
/// The [value] is the Google Maps place ID for the tapped point of interest.
@immutable
class PointOfInterestId extends MapsObjectId<PointOfInterestId> {
  /// Creates an immutable identifier for a point of interest.
  const PointOfInterestId(super.value);
}
