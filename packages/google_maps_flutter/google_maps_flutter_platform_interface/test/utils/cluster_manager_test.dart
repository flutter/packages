// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/src/types/types.dart';

void main() {
  group('keyByClusterManagerId', () {
    test('returns a Map keyed by clusterManagerId', () {
      const ClusterManagerId id1 = ClusterManagerId('id1');
      const ClusterManagerId id2 = ClusterManagerId('id2');
      const ClusterManagerId id3 = ClusterManagerId('id3');

      final List<ClusterManager> clusterManagers = <ClusterManager>[
        const ClusterManager(clusterManagerId: id1),
        const ClusterManager(clusterManagerId: id2),
        const ClusterManager(clusterManagerId: id3),
      ];

      final Map<ClusterManagerId, ClusterManager> result =
          keyByClusterManagerId(clusterManagers);

      expect(result, isA<Map<ClusterManagerId, ClusterManager>>());
      expect(result[id1], equals(clusterManagers[0]));
      expect(result[id2], equals(clusterManagers[1]));
      expect(result[id3], equals(clusterManagers[2]));
    });
  });
}
