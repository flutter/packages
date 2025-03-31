// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'fake_google_maps_flutter_platform.dart';

Widget _mapWithClusterManagers(Set<ClusterManager> clusterManagers) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: GoogleMap(
      initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
      clusterManagers: clusterManagers,
    ),
  );
}

void main() {
  late FakeGoogleMapsFlutterPlatform platform;

  setUp(() {
    platform = FakeGoogleMapsFlutterPlatform();
    GoogleMapsFlutterPlatform.instance = platform;
  });

  testWidgets('Initializing a cluster manager', (WidgetTester tester) async {
    const ClusterManager cm1 = ClusterManager(
      clusterManagerId: ClusterManagerId('cm_1'),
    );
    await tester.pumpWidget(_mapWithClusterManagers(<ClusterManager>{cm1}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.clusterManagerUpdates.last.clusterManagersToAdd.length, 1);

    final ClusterManager initializedHeatmap =
        map.clusterManagerUpdates.last.clusterManagersToAdd.first;
    expect(initializedHeatmap, equals(cm1));
    expect(
        map.clusterManagerUpdates.last.clusterManagerIdsToRemove.isEmpty, true);
    expect(
        map.clusterManagerUpdates.last.clusterManagersToChange.isEmpty, true);
  });

  testWidgets('Adding a cluster manager', (WidgetTester tester) async {
    const ClusterManager cm1 = ClusterManager(
      clusterManagerId: ClusterManagerId('cm_1'),
    );
    const ClusterManager cm2 = ClusterManager(
      clusterManagerId: ClusterManagerId('cm_2'),
    );

    await tester.pumpWidget(_mapWithClusterManagers(<ClusterManager>{cm1}));
    await tester
        .pumpWidget(_mapWithClusterManagers(<ClusterManager>{cm1, cm2}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.clusterManagerUpdates.last.clusterManagersToAdd.length, 1);

    final ClusterManager addedClusterManager =
        map.clusterManagerUpdates.last.clusterManagersToAdd.first;
    expect(addedClusterManager, equals(cm2));

    expect(
        map.clusterManagerUpdates.last.clusterManagerIdsToRemove.isEmpty, true);

    expect(
        map.clusterManagerUpdates.last.clusterManagersToChange.isEmpty, true);
  });

  testWidgets('Removing a cluster manager', (WidgetTester tester) async {
    const ClusterManager cm1 = ClusterManager(
      clusterManagerId: ClusterManagerId('cm_1'),
    );

    await tester.pumpWidget(_mapWithClusterManagers(<ClusterManager>{cm1}));
    await tester.pumpWidget(_mapWithClusterManagers(<ClusterManager>{}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.clusterManagerUpdates.last.clusterManagerIdsToRemove.length, 1);
    expect(map.clusterManagerUpdates.last.clusterManagerIdsToRemove.first,
        equals(cm1.clusterManagerId));

    expect(
        map.clusterManagerUpdates.last.clusterManagersToChange.isEmpty, true);
    expect(map.clusterManagerUpdates.last.clusterManagersToAdd.isEmpty, true);
  });

  // This test checks that the cluster manager is not added again or changed
  // when the data remains the same. Since [ClusterManager] does not have any
  // properties to change, it should not trigger any updates. If new properties
  // are added to [ClusterManager] in the future, this test will need to be
  // updated accordingly to check that changes are triggered.
  testWidgets('Updating a cluster manager with same data',
      (WidgetTester tester) async {
    const ClusterManager cm1 = ClusterManager(
      clusterManagerId: ClusterManagerId('cm_1'),
    );
    const ClusterManager cm2 = ClusterManager(
      clusterManagerId: ClusterManagerId('cm_1'),
    );

    await tester.pumpWidget(_mapWithClusterManagers(<ClusterManager>{cm1}));
    await tester.pumpWidget(_mapWithClusterManagers(<ClusterManager>{cm2}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    // As cluster manager does not have any properties to change,
    // it should not populate the clusterManagersToChange set.
    expect(
        map.clusterManagerUpdates.last.clusterManagersToChange.isEmpty, true);
    expect(
        map.clusterManagerUpdates.last.clusterManagerIdsToRemove.isEmpty, true);
    expect(map.clusterManagerUpdates.last.clusterManagersToAdd.isEmpty, true);
  });

  // This test checks that the cluster manager is not added again or changed
  // when the data remains the same. Since [ClusterManager] does not have any
  // properties to change, it should not trigger any updates. If new properties
  // are added to [ClusterManager] in the future, this test will need to be
  // updated accordingly to check that changes are triggered.
  testWidgets('Multi update with same data', (WidgetTester tester) async {
    ClusterManager cm1 = const ClusterManager(
      clusterManagerId: ClusterManagerId('cm_1'),
    );
    ClusterManager cm2 = const ClusterManager(
      clusterManagerId: ClusterManagerId('cm_2'),
    );
    final Set<ClusterManager> prev = <ClusterManager>{cm1, cm2};
    cm1 = const ClusterManager(
      clusterManagerId: ClusterManagerId('cm_1'),
    );
    cm2 = const ClusterManager(
      clusterManagerId: ClusterManagerId('cm_2'),
    );
    final Set<ClusterManager> cur = <ClusterManager>{cm1, cm2};

    await tester.pumpWidget(_mapWithClusterManagers(prev));
    await tester.pumpWidget(_mapWithClusterManagers(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    // As cluster manager does not have any properties to change,
    // it should not populate the clusterManagersToChange set.
    expect(map.clusterManagerUpdates.last.clusterManagersToAdd.isEmpty, true);
    expect(
        map.clusterManagerUpdates.last.clusterManagerIdsToRemove.isEmpty, true);
    expect(map.clusterManagerUpdates.last.clusterManagersToAdd.isEmpty, true);
  });

  // This test checks that the cluster manager is not added again or changed
  // when the data remains the same. Since [ClusterManager] does not have any
  // properties to change, it should not trigger any updates. If new properties
  // are added to [ClusterManager] in the future, this test will need to be
  // updated accordingly to check that changes are triggered.
  testWidgets('Partial update with same data', (WidgetTester tester) async {
    const ClusterManager cm1 = ClusterManager(
      clusterManagerId: ClusterManagerId('heatmap_1'),
    );
    const ClusterManager cm2 = ClusterManager(
      clusterManagerId: ClusterManagerId('heatmap_2'),
    );
    ClusterManager cm3 = const ClusterManager(
      clusterManagerId: ClusterManagerId('heatmap_3'),
    );
    final Set<ClusterManager> prev = <ClusterManager>{cm1, cm2, cm3};
    cm3 = const ClusterManager(
      clusterManagerId: ClusterManagerId('heatmap_3'),
    );
    final Set<ClusterManager> cur = <ClusterManager>{cm1, cm2, cm3};

    await tester.pumpWidget(_mapWithClusterManagers(prev));
    await tester.pumpWidget(_mapWithClusterManagers(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    // As cluster manager does not have any properties to change,
    // it should not populate the clusterManagersToChange set.
    expect(
        map.clusterManagerUpdates.last.clusterManagersToChange.isEmpty, true);
    expect(
        map.clusterManagerUpdates.last.clusterManagerIdsToRemove.isEmpty, true);
    expect(map.clusterManagerUpdates.last.clusterManagersToAdd.isEmpty, true);
  });
}
