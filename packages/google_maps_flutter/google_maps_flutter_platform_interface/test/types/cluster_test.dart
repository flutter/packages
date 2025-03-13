// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$Cluster', () {
    test('constructor', () {
      final Cluster cluster = Cluster(
        const ClusterManagerId('3456787654'),
        const <MarkerId>[MarkerId('23456')],
        position: const LatLng(55.0, 66.0),
        bounds: LatLngBounds(
          northeast: const LatLng(88.0, 22.0),
          southwest: const LatLng(11.0, 99.0),
        ),
      );

      expect(cluster.clusterManagerId.value, equals('3456787654'));
      expect(cluster.markerIds[0].value, equals('23456'));
      expect(cluster.position, equals(const LatLng(55.0, 66.0)));
      expect(
          cluster.bounds,
          LatLngBounds(
            northeast: const LatLng(88.0, 22.0),
            southwest: const LatLng(11.0, 99.0),
          ));
    });

    test('constructor markerIds length is > 0', () {
      void initWithMarkerIds(List<MarkerId> markerIds) {
        Cluster(
          const ClusterManagerId('3456787654'),
          markerIds,
          position: const LatLng(55.0, 66.0),
          bounds: LatLngBounds(
            northeast: const LatLng(88.0, 22.0),
            southwest: const LatLng(11.0, 99.0),
          ),
        );
      }

      expect(() => initWithMarkerIds(<MarkerId>[const MarkerId('12342323')]),
          isNot(throwsAssertionError));
      expect(() => initWithMarkerIds(<MarkerId>[]), throwsAssertionError);
    });
  });
}
