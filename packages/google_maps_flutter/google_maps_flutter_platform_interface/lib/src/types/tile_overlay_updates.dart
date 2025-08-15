// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'types.dart';

/// Update specification for a set of [TileOverlay]s.
class TileOverlayUpdates extends MapsObjectUpdates<TileOverlay> {
  /// Computes [TileOverlayUpdates] given previous and current [TileOverlay]s.
  TileOverlayUpdates.from(super.previous, super.current)
      : super.from(objectName: 'tileOverlay');

  /// Set of TileOverlays to be added in this update.
  Set<TileOverlay> get tileOverlaysToAdd => objectsToAdd;

  /// Set of TileOverlayIds to be removed in this update.
  Set<TileOverlayId> get tileOverlayIdsToRemove =>
      objectIdsToRemove.cast<TileOverlayId>();

  /// Set of TileOverlays to be changed in this update.
  Set<TileOverlay> get tileOverlaysToChange => objectsToChange;
}
