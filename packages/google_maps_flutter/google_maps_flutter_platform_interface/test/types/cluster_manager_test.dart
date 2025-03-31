// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$ClusterManager', () {
    test('constructor defaults', () {
      const ClusterManager manager =
          ClusterManager(clusterManagerId: ClusterManagerId('1234'));

      expect(manager.clusterManagerId, const ClusterManagerId('1234'));
    });

    test('toJson', () {
      const ClusterManager manager =
          ClusterManager(clusterManagerId: ClusterManagerId('1234'));

      final Map<String, Object> json = manager.toJson() as Map<String, Object>;

      expect(json, <String, Object>{
        'clusterManagerId': '1234',
      });
    });
    test('clone', () {
      const ClusterManager manager =
          ClusterManager(clusterManagerId: ClusterManagerId('1234'));
      final ClusterManager clone = manager.clone();

      expect(identical(clone, manager), isFalse);
      expect(clone, equals(manager));
    });
    test('copyWith', () {
      const ClusterManager manager =
          ClusterManager(clusterManagerId: ClusterManagerId('1234'));
      final List<String> log = <String>[];

      final ClusterManager copy = manager.copyWith(
        onClusterTapParam: (Cluster cluster) {
          log.add('onTapParam');
        },
      );
      copy.onClusterTap!(Cluster(
          manager.clusterManagerId, const <MarkerId>[MarkerId('5678')],
          position: const LatLng(11.0, 22.0),
          bounds: LatLngBounds(
              southwest: const LatLng(22.0, 33.0),
              northeast: const LatLng(33.0, 88.0))));
      expect(log, contains('onTapParam'));
    });
  });
}
