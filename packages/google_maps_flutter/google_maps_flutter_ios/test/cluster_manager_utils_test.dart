// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_ios/src/utils/cluster_manager.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('serializeClusterManager', () async {
    const ClusterManager manager =
        ClusterManager(clusterManagerId: ClusterManagerId('1234'));
    final Object json = serializeClusterManager(manager);

    expect(json, <String, Object>{
      'clusterManagerId': '1234',
    });
  });

  test('serializeClusterManagerSet', () async {
    const ClusterManager manager =
        ClusterManager(clusterManagerId: ClusterManagerId('1234'));
    const ClusterManager manager2 =
        ClusterManager(clusterManagerId: ClusterManagerId('5678'));
    const ClusterManager manager3 =
        ClusterManager(clusterManagerId: ClusterManagerId('9012'));
    final Object json = serializeClusterManagerSet(
        <ClusterManager>{manager, manager2, manager3});

    expect(json, <Object>[
      <String, Object>{
        'clusterManagerId': '1234',
      },
      <String, Object>{
        'clusterManagerId': '5678',
      },
      <String, Object>{
        'clusterManagerId': '9012',
      }
    ]);
  });
}
