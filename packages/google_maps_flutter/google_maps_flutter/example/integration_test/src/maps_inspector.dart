// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:integration_test/integration_test.dart';

import 'shared.dart';

/// Integration Tests that use the [GoogleMapsInspectorPlatform].
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  runTests();
}

void runTests() {
  GoogleMapsFlutterPlatform.instance.enableDebugInspection();

  final GoogleMapsInspectorPlatform inspector =
      GoogleMapsInspectorPlatform.instance!;

  testWidgets('testCompassToggle', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<int> mapIdCompleter = Completer<int>();
    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        compassEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          mapIdCompleter.complete(controller.mapId);
        },
      ),
    );
    final int mapId = await mapIdCompleter.future;

    bool compassEnabled = await inspector.isCompassEnabled(mapId: mapId);
    expect(compassEnabled, false);

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          fail('OnMapCreated should get called only once.');
        },
      ),
    );

    compassEnabled = await inspector.isCompassEnabled(mapId: mapId);
    expect(compassEnabled, !kIsWeb);
  });

  testWidgets('testMapToolbarToggle', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<int> mapIdCompleter = Completer<int>();

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        mapToolbarEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          mapIdCompleter.complete(controller.mapId);
        },
      ),
    );
    final int mapId = await mapIdCompleter.future;

    bool mapToolbarEnabled = await inspector.isMapToolbarEnabled(mapId: mapId);
    expect(mapToolbarEnabled, false);

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          fail('OnMapCreated should get called only once.');
        },
      ),
    );

    mapToolbarEnabled = await inspector.isMapToolbarEnabled(mapId: mapId);
    expect(mapToolbarEnabled, isAndroid);
  });

  testWidgets('updateMinMaxZoomLevels', (WidgetTester tester) async {
    // The behaviors of setting min max zoom level on iOS and Android are different.
    // On iOS, when we get the min or max zoom level after setting the preference, the
    // min and max will be exactly the same as the value we set; on Android however,
    // the values we get do not equal to the value we set.
    //
    // Also, when we call zoomTo to set the zoom, on Android, it usually
    // honors the preferences that we set and the zoom cannot pass beyond the boundary.
    // On iOS, on the other hand, zoomTo seems to override the preferences.
    //
    // Thus we test iOS and Android a little differently here.
    final Key key = GlobalKey();
    final Completer<GoogleMapController> controllerCompleter =
        Completer<GoogleMapController>();

    const MinMaxZoomPreference initialZoomLevel = MinMaxZoomPreference(4, 8);
    const MinMaxZoomPreference finalZoomLevel = MinMaxZoomPreference(6, 10);

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        minMaxZoomPreference: initialZoomLevel,
        onMapCreated: (GoogleMapController c) async {
          controllerCompleter.complete(c);
        },
      ),
    );

    final GoogleMapController controller = await controllerCompleter.future;

    if (isIOS) {
      final MinMaxZoomPreference zoomLevel =
          await inspector.getMinMaxZoomLevels(mapId: controller.mapId);
      expect(zoomLevel, equals(initialZoomLevel));
    } else if (isAndroid) {
      await controller.moveCamera(CameraUpdate.zoomTo(15));
      await tester.pumpAndSettle();
      double? zoomLevel = await controller.getZoomLevel();
      expect(zoomLevel, equals(initialZoomLevel.maxZoom));

      await controller.moveCamera(CameraUpdate.zoomTo(1));
      await tester.pumpAndSettle();
      zoomLevel = await controller.getZoomLevel();
      expect(zoomLevel, equals(initialZoomLevel.minZoom));
    }

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        minMaxZoomPreference: finalZoomLevel,
        onMapCreated: (GoogleMapController controller) {
          fail('OnMapCreated should get called only once.');
        },
      ),
    );

    if (isIOS) {
      final MinMaxZoomPreference zoomLevel =
          await inspector.getMinMaxZoomLevels(mapId: controller.mapId);
      expect(zoomLevel, equals(finalZoomLevel));
    } else {
      await controller.moveCamera(CameraUpdate.zoomTo(15));
      await tester.pumpAndSettle();
      double? zoomLevel = await controller.getZoomLevel();
      expect(zoomLevel, equals(finalZoomLevel.maxZoom));

      await controller.moveCamera(CameraUpdate.zoomTo(1));
      await tester.pumpAndSettle();
      zoomLevel = await controller.getZoomLevel();
      expect(zoomLevel, equals(finalZoomLevel.minZoom));
    }
  });

  testWidgets('testZoomGesturesEnabled', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<int> mapIdCompleter = Completer<int>();

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        zoomGesturesEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          mapIdCompleter.complete(controller.mapId);
        },
      ),
    );
    final int mapId = await mapIdCompleter.future;

    bool zoomGesturesEnabled =
        await inspector.areZoomGesturesEnabled(mapId: mapId);
    expect(zoomGesturesEnabled, false);

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          fail('OnMapCreated should get called only once.');
        },
      ),
    );

    zoomGesturesEnabled = await inspector.areZoomGesturesEnabled(mapId: mapId);
    expect(zoomGesturesEnabled, true);
  });

  testWidgets('testZoomControlsEnabled', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<int> mapIdCompleter = Completer<int>();

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          mapIdCompleter.complete(controller.mapId);
        },
      ),
    );
    final int mapId = await mapIdCompleter.future;

    bool zoomControlsEnabled =
        await inspector.areZoomControlsEnabled(mapId: mapId);
    expect(zoomControlsEnabled, !isIOS);

    /// Zoom Controls functionality is not available on iOS at the moment.
    if (!isIOS) {
      await pumpMap(
        tester,
        GoogleMap(
          key: key,
          initialCameraPosition: kInitialCameraPosition,
          zoomControlsEnabled: false,
          onMapCreated: (GoogleMapController controller) {
            fail('OnMapCreated should get called only once.');
          },
        ),
      );

      zoomControlsEnabled =
          await inspector.areZoomControlsEnabled(mapId: mapId);
      expect(zoomControlsEnabled, false);
    }
  });

  testWidgets('testLiteModeEnabled', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<int> mapIdCompleter = Completer<int>();

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          mapIdCompleter.complete(controller.mapId);
        },
      ),
    );
    final int mapId = await mapIdCompleter.future;

    bool liteModeEnabled = await inspector.isLiteModeEnabled(mapId: mapId);
    expect(liteModeEnabled, false);

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        liteModeEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          fail('OnMapCreated should get called only once.');
        },
      ),
    );

    liteModeEnabled = await inspector.isLiteModeEnabled(mapId: mapId);
    expect(liteModeEnabled, true);
  }, skip: !isAndroid);

  testWidgets('testRotateGesturesEnabled', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<int> mapIdCompleter = Completer<int>();

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        rotateGesturesEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          mapIdCompleter.complete(controller.mapId);
        },
      ),
    );
    final int mapId = await mapIdCompleter.future;

    bool rotateGesturesEnabled =
        await inspector.areRotateGesturesEnabled(mapId: mapId);
    expect(rotateGesturesEnabled, false);

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          fail('OnMapCreated should get called only once.');
        },
      ),
    );

    rotateGesturesEnabled =
        await inspector.areRotateGesturesEnabled(mapId: mapId);
    expect(rotateGesturesEnabled, !isWeb);
  });

  testWidgets('testTiltGesturesEnabled', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<int> mapIdCompleter = Completer<int>();

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        tiltGesturesEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          mapIdCompleter.complete(controller.mapId);
        },
      ),
    );
    final int mapId = await mapIdCompleter.future;

    bool tiltGesturesEnabled =
        await inspector.areTiltGesturesEnabled(mapId: mapId);
    expect(tiltGesturesEnabled, false);

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          fail('OnMapCreated should get called only once.');
        },
      ),
    );

    tiltGesturesEnabled = await inspector.areTiltGesturesEnabled(mapId: mapId);
    expect(tiltGesturesEnabled, !isWeb);
  });

  testWidgets('testScrollGesturesEnabled', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<int> mapIdCompleter = Completer<int>();

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        scrollGesturesEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          mapIdCompleter.complete(controller.mapId);
        },
      ),
    );
    final int mapId = await mapIdCompleter.future;

    bool scrollGesturesEnabled =
        await inspector.areScrollGesturesEnabled(mapId: mapId);
    expect(scrollGesturesEnabled, false);

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          fail('OnMapCreated should get called only once.');
        },
      ),
    );

    scrollGesturesEnabled =
        await inspector.areScrollGesturesEnabled(mapId: mapId);
    expect(scrollGesturesEnabled, true);
  });

  testWidgets('testTraffic', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<int> mapIdCompleter = Completer<int>();

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        trafficEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          mapIdCompleter.complete(controller.mapId);
        },
      ),
    );
    final int mapId = await mapIdCompleter.future;

    bool isTrafficEnabled = await inspector.isTrafficEnabled(mapId: mapId);
    expect(isTrafficEnabled, true);

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          fail('OnMapCreated should get called only once.');
        },
      ),
    );

    isTrafficEnabled = await inspector.isTrafficEnabled(mapId: mapId);
    expect(isTrafficEnabled, false);
  });

  testWidgets('testBuildings', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<int> mapIdCompleter = Completer<int>();

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          mapIdCompleter.complete(controller.mapId);
        },
      ),
    );
    final int mapId = await mapIdCompleter.future;

    final bool isBuildingsEnabled =
        await inspector.areBuildingsEnabled(mapId: mapId);
    expect(isBuildingsEnabled, !isWeb);
  });

  // Location button tests are skipped in Android because we don't have location permission to test.
  // Location button tests are skipped in Web because the functionality is not implemented.
  group('MyLocationButton', () {
    testWidgets('testMyLocationButtonToggle', (WidgetTester tester) async {
      final Key key = GlobalKey();
      final Completer<int> mapIdCompleter = Completer<int>();

      await pumpMap(
        tester,
        GoogleMap(
          key: key,
          initialCameraPosition: kInitialCameraPosition,
          onMapCreated: (GoogleMapController controller) {
            mapIdCompleter.complete(controller.mapId);
          },
        ),
      );
      final int mapId = await mapIdCompleter.future;

      bool myLocationButtonEnabled =
          await inspector.isMyLocationButtonEnabled(mapId: mapId);
      expect(myLocationButtonEnabled, true);

      await pumpMap(
        tester,
        GoogleMap(
          key: key,
          initialCameraPosition: kInitialCameraPosition,
          myLocationButtonEnabled: false,
          onMapCreated: (GoogleMapController controller) {
            fail('OnMapCreated should get called only once.');
          },
        ),
      );

      myLocationButtonEnabled =
          await inspector.isMyLocationButtonEnabled(mapId: mapId);
      expect(myLocationButtonEnabled, false);
    });

    testWidgets('testMyLocationButton initial value false',
        (WidgetTester tester) async {
      final Key key = GlobalKey();
      final Completer<int> mapIdCompleter = Completer<int>();

      await pumpMap(
        tester,
        GoogleMap(
          key: key,
          initialCameraPosition: kInitialCameraPosition,
          myLocationButtonEnabled: false,
          onMapCreated: (GoogleMapController controller) {
            mapIdCompleter.complete(controller.mapId);
          },
        ),
      );
      final int mapId = await mapIdCompleter.future;

      final bool myLocationButtonEnabled =
          await inspector.isMyLocationButtonEnabled(mapId: mapId);
      expect(myLocationButtonEnabled, false);
    });

    testWidgets('testMyLocationButton initial value true',
        (WidgetTester tester) async {
      final Key key = GlobalKey();
      final Completer<int> mapIdCompleter = Completer<int>();

      await pumpMap(
        tester,
        GoogleMap(
          key: key,
          initialCameraPosition: kInitialCameraPosition,
          onMapCreated: (GoogleMapController controller) {
            mapIdCompleter.complete(controller.mapId);
          },
        ),
      );
      final int mapId = await mapIdCompleter.future;

      final bool myLocationButtonEnabled =
          await inspector.isMyLocationButtonEnabled(mapId: mapId);
      expect(myLocationButtonEnabled, true);
    });
  }, skip: !isIOS);

  testWidgets('marker clustering', (WidgetTester tester) async {
    final Key key = GlobalKey();
    const int clusterManagersAmount = 2;
    const int markersPerClusterManager = 5;
    final Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
    final Set<ClusterManager> clusterManagers = <ClusterManager>{};

    for (int i = 0; i < clusterManagersAmount; i++) {
      final ClusterManagerId clusterManagerId =
          ClusterManagerId('cluster_manager_$i');
      final ClusterManager clusterManager =
          ClusterManager(clusterManagerId: clusterManagerId);
      clusterManagers.add(clusterManager);
    }

    for (final ClusterManager cm in clusterManagers) {
      for (int i = 0; i < markersPerClusterManager; i++) {
        final MarkerId markerId =
            MarkerId('${cm.clusterManagerId.value}_marker_$i');
        final Marker marker = Marker(
            markerId: markerId,
            clusterManagerId: cm.clusterManagerId,
            position: LatLng(
                kInitialMapCenter.latitude + i, kInitialMapCenter.longitude));
        markers[markerId] = marker;
      }
    }

    final Completer<GoogleMapController> controllerCompleter =
        Completer<GoogleMapController>();

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        clusterManagers: clusterManagers,
        markers: Set<Marker>.of(markers.values),
        onMapCreated: (GoogleMapController googleMapController) {
          controllerCompleter.complete(googleMapController);
        },
      ),
    );

    final GoogleMapController controller = await controllerCompleter.future;

    final GoogleMapsInspectorPlatform inspector =
        GoogleMapsInspectorPlatform.instance!;

    for (final ClusterManager cm in clusterManagers) {
      final List<Cluster> clusters = await inspector.getClusters(
          mapId: controller.mapId, clusterManagerId: cm.clusterManagerId);
      final int markersAmountForClusterManager = clusters
          .map<int>((Cluster cluster) => cluster.count)
          .reduce((int value, int element) => value + element);
      expect(markersAmountForClusterManager, markersPerClusterManager);
    }

    // Remove markers from clusterManagers and test that clusterManagers are empty.
    for (final MapEntry<MarkerId, Marker> entry in markers.entries) {
      markers[entry.key] = _copyMarkerWithClusterManagerId(entry.value, null);
    }

    await pumpMap(
      tester,
      GoogleMap(
          key: key,
          initialCameraPosition: kInitialCameraPosition,
          clusterManagers: clusterManagers,
          markers: Set<Marker>.of(markers.values)),
    );

    for (final ClusterManager cm in clusterManagers) {
      final List<Cluster> clusters = await inspector.getClusters(
          mapId: controller.mapId, clusterManagerId: cm.clusterManagerId);
      expect(clusters.length, 0);
    }
  });
}

Marker _copyMarkerWithClusterManagerId(
    Marker marker, ClusterManagerId? clusterManagerId) {
  return Marker(
    markerId: marker.markerId,
    alpha: marker.alpha,
    anchor: marker.anchor,
    consumeTapEvents: marker.consumeTapEvents,
    draggable: marker.draggable,
    flat: marker.flat,
    icon: marker.icon,
    infoWindow: marker.infoWindow,
    position: marker.position,
    rotation: marker.rotation,
    visible: marker.visible,
    zIndex: marker.zIndex,
    onTap: marker.onTap,
    onDragStart: marker.onDragStart,
    onDrag: marker.onDrag,
    onDragEnd: marker.onDragEnd,
    clusterManagerId: clusterManagerId,
  );
}
