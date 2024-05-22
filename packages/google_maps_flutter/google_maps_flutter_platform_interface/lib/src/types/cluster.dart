// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart'
    show immutable, listEquals, objectRuntimeType;
import 'types.dart';

/// A cluster containing multiple markers.
@immutable
class Cluster {
  /// Creates a cluster with its location [LatLng], bounds [LatLngBounds],
  /// and list of [MarkerId]s in the cluster.
  const Cluster(
    this.clusterManagerId,
    this.markerIds, {
    required this.position,
    required this.bounds,
  }) : assert(markerIds.length > 0);

  /// ID of the [ClusterManager] of the cluster.
  final ClusterManagerId clusterManagerId;

  /// Cluster marker location.
  final LatLng position;

  /// The bounds containing all cluster markers.
  final LatLngBounds bounds;

  /// List of [MarkerId]s in the cluster.
  final List<MarkerId> markerIds;

  /// Returns the number of markers in the cluster.
  int get count => markerIds.length;

  @override
  String toString() =>
      '${objectRuntimeType(this, 'Cluster')}($clusterManagerId, $position, $bounds, $markerIds)';

  @override
  bool operator ==(Object other) {
    return other is Cluster &&
        other.clusterManagerId == clusterManagerId &&
        other.position == position &&
        other.bounds == bounds &&
        listEquals(other.markerIds, markerIds);
  }

  @override
  int get hashCode =>
      Object.hash(clusterManagerId, position, bounds, markerIds);
}
