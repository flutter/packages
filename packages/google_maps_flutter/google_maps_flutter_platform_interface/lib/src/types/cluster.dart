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
  /// list of [MarkerId]s in the cluster, and optional non-countable markers.
  const Cluster(
    this.clusterManagerId,
    this.markerIds, {
    required this.position,
    required this.bounds,
    this.nonCountableMarkerIds = const [],
  }) : assert(markerIds.length > 0);

  /// ID of the [ClusterManager] of the cluster.
  final ClusterManagerId clusterManagerId;

  /// Cluster marker location.
  final LatLng position;

  /// The bounds containing all cluster markers.
  final LatLngBounds bounds;

  /// List of [MarkerId]s in the cluster.
  final List<MarkerId> markerIds;

  /// List of [MarkerId]s that should not be counted.
  final List<MarkerId> nonCountableMarkerIds;

  /// Returns the number of markers in the cluster, excluding non-countable markers.
  int get count => markerIds.length - nonCountableMarkerIds.length;

  /// Returns the total number of markers (including non-countable markers).
  int get totalMarkers => markerIds.length;

  @override
  String toString() =>
      '${objectRuntimeType(this, 'Cluster')}($clusterManagerId, $position, $bounds, $markerIds, $nonCountableMarkerIds)';

  @override
  bool operator ==(Object other) {
    return other is Cluster &&
        other.clusterManagerId == clusterManagerId &&
        other.position == position &&
        other.bounds == bounds &&
        listEquals(other.markerIds, markerIds) &&
        listEquals(other.nonCountableMarkerIds, nonCountableMarkerIds);
  }

  @override
  int get hashCode =>
      Object.hash(clusterManagerId, position, bounds, markerIds, nonCountableMarkerIds);
}
