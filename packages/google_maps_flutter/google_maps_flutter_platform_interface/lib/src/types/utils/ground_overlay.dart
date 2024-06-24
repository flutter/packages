// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../types.dart';
import 'maps_object.dart';

/// Converts an [Iterable] of GroundOverlays in a Map of GroundOverlayId -> GroundOverlay.
Map<GroundOverlayId, GroundOverlay> keyByGroundOverlayId(
    Iterable<GroundOverlay> groundOverlays) {
  return keyByMapsObjectId<GroundOverlay>(groundOverlays)
      .cast<GroundOverlayId, GroundOverlay>();
}

/// Converts a Set of GroundOverlays into something serializable in JSON.
Object serializeGroundOverlaySet(Set<GroundOverlay> groundOverlays) {
  return serializeMapsObjectSet(groundOverlays);
}
