// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_android/src/utils/cluster_manager_utils.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  test('serializeClusterManagerUpdates', () async {
    const ClusterManagerId clusterManagerId1 = ClusterManagerId('cm1');
    const ClusterManagerId clusterManagerId2 = ClusterManagerId('cm2');

    const ClusterManager clusterManager1 = ClusterManager(
      clusterManagerId: clusterManagerId1,
    );
    const ClusterManager clusterManager2 = ClusterManager(
      clusterManagerId: clusterManagerId2,
    );

    final Set<ClusterManager> clusterManagersSet1 = <ClusterManager>{};
    final Set<ClusterManager> clusterManagersSet2 = <ClusterManager>{
      clusterManager1,
      clusterManager2
    };
    final Set<ClusterManager> clusterManagersSet3 = <ClusterManager>{
      clusterManager1
    };

    final ClusterManagerUpdates clusterManagerUpdates1 =
        ClusterManagerUpdates.from(clusterManagersSet1, clusterManagersSet2);
    final Map<String, Object> serializedData1 =
        serializeClusterManagerUpdates(clusterManagerUpdates1)
            as Map<String, Object>;
    expect(serializedData1['clusterManagersToAdd'], isNotNull);
    final List<Object> clusterManagersToAdd1 =
        serializedData1['clusterManagersToAdd']! as List<Object>;
    expect(clusterManagersToAdd1.length, 2);
    expect(serializedData1['clusterManagerIdsToRemove'], isNotNull);
    final List<Object> clusterManagersToRemove1 =
        serializedData1['clusterManagerIdsToRemove']! as List<Object>;
    expect(clusterManagersToRemove1.length, 0);

    final ClusterManagerUpdates clusterManagerUpdates2 =
        ClusterManagerUpdates.from(clusterManagersSet2, clusterManagersSet3);
    serializeClusterManagerUpdates(clusterManagerUpdates2);
    final Map<String, Object> serializedData2 =
        serializeClusterManagerUpdates(clusterManagerUpdates2)
            as Map<String, Object>;
    expect(serializedData2['clusterManagersToAdd'], isNotNull);
    final List<Object> clusterManagersToAdd2 =
        serializedData2['clusterManagersToAdd']! as List<Object>;
    expect(clusterManagersToAdd2.length, 0);
    expect(serializedData1['clusterManagerIdsToRemove'], isNotNull);
    final List<Object> clusterManagersToRemove2 =
        serializedData2['clusterManagerIdsToRemove']! as List<Object>;
    expect(clusterManagersToRemove2.length, 1);
    expect(clusterManagersToRemove2.first as String, equals('cm2'));
  });
}
