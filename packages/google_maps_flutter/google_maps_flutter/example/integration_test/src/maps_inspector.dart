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

const double _kTestCameraZoomLevel = 10;
const double _kTestZoomByAmount = 2;
const LatLng _kTestMapCenter = LatLng(65, 25.5);
const CameraPosition _kTestCameraPosition = CameraPosition(
  target: _kTestMapCenter,
  zoom: _kTestCameraZoomLevel,
  bearing: 1.0,
  tilt: 1.0,
);
final LatLngBounds _testCameraBounds = LatLngBounds(
    northeast: const LatLng(50, -65), southwest: const LatLng(28.5, -123));
final ValueVariant<CameraUpdateType> _cameraUpdateTypeVariants =
    ValueVariant<CameraUpdateType>(CameraUpdateType.values.toSet());

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

  testWidgets(
    'testAnimateCameraWithoutDuration',
    (WidgetTester tester) async {
      final Key key = GlobalKey();
      final Completer<GoogleMapController> controllerCompleter =
          Completer<GoogleMapController>();
      final GoogleMapsInspectorPlatform inspector =
          GoogleMapsInspectorPlatform.instance!;

      /// Completer to track when the camera has come to rest.
      Completer<void>? cameraIdleCompleter;

      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          key: key,
          initialCameraPosition: kInitialCameraPosition,
          onCameraIdle: () {
            if (cameraIdleCompleter != null &&
                !cameraIdleCompleter.isCompleted) {
              cameraIdleCompleter.complete();
            }
          },
          onMapCreated: (GoogleMapController controller) {
            controllerCompleter.complete(controller);
          },
        ),
      ));

      final GoogleMapController controller = await controllerCompleter.future;

      await tester.pumpAndSettle();
      // TODO(cyanglaz): Remove this after we added `mapRendered` callback, and
      // `mapControllerCompleter.complete(controller)` above should happen in
      // `mapRendered`.
      // https://github.com/flutter/flutter/issues/54758
      await Future<void>.delayed(const Duration(seconds: 1));

      // Create completer for camera idle event.
      cameraIdleCompleter = Completer<void>();

      final CameraUpdate cameraUpdate =
          _getCameraUpdateForType(_cameraUpdateTypeVariants.currentValue!);
      await controller.animateCamera(cameraUpdate);

      // If platform supportes getting camera position, check that the camera
      // has moved as expected.
      CameraPosition? beforeFinishedPosition;
      if (inspector.supportsGettingGameraPosition()) {
        // Immediately after calling animateCamera, check that the camera hasn't
        // reached its final position. This relies on the assumption that the
        // camera move is animated and won't complete instantly.
        beforeFinishedPosition =
            await inspector.getCameraPosition(mapId: controller.mapId);

        await _checkCameraUpdateByType(
            _cameraUpdateTypeVariants.currentValue!,
            beforeFinishedPosition,
            null,
            controller,
            (Matcher matcher) => isNot(matcher));
      }

      // Wait for the animation to complete (onCameraIdle).
      expect(cameraIdleCompleter.isCompleted, isFalse);
      await cameraIdleCompleter.future;

      // If platform supportes getting camera position, check that the camera
      // has moved as expected.
      if (inspector.supportsGettingGameraPosition()) {
        // After onCameraIdle event, the camera should be at the final position.
        final CameraPosition afterFinishedPosition =
            await inspector.getCameraPosition(mapId: controller.mapId);
        await _checkCameraUpdateByType(
            _cameraUpdateTypeVariants.currentValue!,
            afterFinishedPosition,
            beforeFinishedPosition,
            controller,
            (Matcher matcher) => matcher);
      }
    },
    variant: _cameraUpdateTypeVariants,
    // TODO(stuartmorgan): Remove skip for Android platform once Maps API key is
    // available for LUCI, https://github.com/flutter/flutter/issues/131071
    skip: isAndroid,
  );

  /// Tests animating the camera with specified durations to verify timing
  /// behavior.
  ///
  /// This test checks two scenarios: short and long animation durations.
  /// It uses a midpoint duration to ensure the short animation completes in
  /// less time and the long animation takes more time than that midpoint.
  /// This ensures that the animation duration is respected by the platform and
  /// that the default camera animation duration does not affect the test
  /// results.
  testWidgets(
    'testAnimateCameraWithDuration',
    (WidgetTester tester) async {
      final Key key = GlobalKey();
      final Completer<GoogleMapController> controllerCompleter =
          Completer<GoogleMapController>();
      final GoogleMapsInspectorPlatform inspector =
          GoogleMapsInspectorPlatform.instance!;

      /// Completer to track when the camera has come to rest.
      Completer<void>? cameraIdleCompleter;

      const int shortCameraAnimationDurationMS = 200;
      const int longCameraAnimationDurationMS = 1000;

      /// Calculate the midpoint duration of the animation test, which will
      /// serve as a reference to verify that animations complete more quickly
      /// with shorter durations and more slowly with longer durations.
      const int animationDurationMiddlePoint =
          (shortCameraAnimationDurationMS + longCameraAnimationDurationMS) ~/ 2;

      // Stopwatch to measure the time taken for the animation to complete.
      final Stopwatch stopwatch = Stopwatch();

      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          key: key,
          initialCameraPosition: kInitialCameraPosition,
          onCameraIdle: () {
            if (cameraIdleCompleter != null &&
                !cameraIdleCompleter.isCompleted) {
              stopwatch.stop();
              cameraIdleCompleter.complete();
            }
          },
          onMapCreated: (GoogleMapController controller) {
            controllerCompleter.complete(controller);
          },
        ),
      ));

      final GoogleMapController controller = await controllerCompleter.future;

      await tester.pumpAndSettle();
      // TODO(cyanglaz): Remove this after we added `mapRendered` callback, and
      // `mapControllerCompleter.complete(controller)` above should happen in
      // `mapRendered`.
      // https://github.com/flutter/flutter/issues/54758
      await Future<void>.delayed(const Duration(seconds: 1));

      // Create completer for camera idle event.
      cameraIdleCompleter = Completer<void>();

      // Start stopwatch to check the time taken for the animation to complete.
      // Stopwatch is stopped on camera idle callback.
      stopwatch.reset();
      stopwatch.start();

      // First phase with shorter animation duration.
      final CameraUpdate cameraUpdateShort =
          _getCameraUpdateForType(_cameraUpdateTypeVariants.currentValue!);
      await controller.animateCamera(
        cameraUpdateShort,
        duration: const Duration(milliseconds: shortCameraAnimationDurationMS),
      );

      // Wait for the animation to complete (onCameraIdle).
      expect(cameraIdleCompleter.isCompleted, isFalse);
      await cameraIdleCompleter.future;

      // For short animation duration, check that the animation is completed
      // faster than the midpoint benchmark.
      expect(stopwatch.elapsedMilliseconds,
          lessThan(animationDurationMiddlePoint));

      // Reset camera to initial position before testing long duration.
      await controller
          .moveCamera(CameraUpdate.newCameraPosition(kInitialCameraPosition));
      await tester.pumpAndSettle();

      // Create completer for camera idle event.
      cameraIdleCompleter = Completer<void>();

      // Start stopwatch to check the time taken for the animation to complete.
      // Stopwatch is stopped on camera idle callback.
      stopwatch.reset();
      stopwatch.start();

      // Second phase with longer animation duration.
      final CameraUpdate cameraUpdateLong =
          _getCameraUpdateForType(_cameraUpdateTypeVariants.currentValue!);
      await controller.animateCamera(
        cameraUpdateLong,
        duration: const Duration(milliseconds: longCameraAnimationDurationMS),
      );

      // If platform supportes getting camera position, check that the camera
      // has moved as expected.
      CameraPosition? beforeFinishedPosition;
      if (inspector.supportsGettingGameraPosition()) {
        // Immediately after calling animateCamera, check that the camera hasn't
        // reached its final position. This relies on the assumption that the
        // camera move is animated and won't complete instantly.
        beforeFinishedPosition =
            await inspector.getCameraPosition(mapId: controller.mapId);

        await _checkCameraUpdateByType(
            _cameraUpdateTypeVariants.currentValue!,
            beforeFinishedPosition,
            null,
            controller,
            (Matcher matcher) => isNot(matcher));
      }

      // Wait for the animation to complete (onCameraIdle).
      expect(cameraIdleCompleter.isCompleted, isFalse);
      await cameraIdleCompleter.future;

      // For longer animation duration, check that the animation is completed
      // slower than the midpoint benchmark.
      expect(stopwatch.elapsedMilliseconds,
          greaterThan(animationDurationMiddlePoint));

      // If platform supportes getting camera position, check that the camera
      // has moved as expected.
      if (inspector.supportsGettingGameraPosition()) {
        // Camera should be at the final position.
        final CameraPosition afterFinishedPosition =
            await inspector.getCameraPosition(mapId: controller.mapId);
        await _checkCameraUpdateByType(
            _cameraUpdateTypeVariants.currentValue!,
            afterFinishedPosition,
            beforeFinishedPosition,
            controller,
            (Matcher matcher) => matcher);
      }
    },
    variant: _cameraUpdateTypeVariants,
    // TODO(jokerttu): Remove skip once the web implementation is available,
    // https://github.com/flutter/flutter/issues/159265
    // TODO(stuartmorgan): Remove skip for Android platform once Maps API key is
    // available for LUCI, https://github.com/flutter/flutter/issues/131071
    skip: kIsWeb || isAndroid,
  );
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

CameraUpdate _getCameraUpdateForType(CameraUpdateType type) {
  return switch (type) {
    CameraUpdateType.newCameraPosition =>
      CameraUpdate.newCameraPosition(_kTestCameraPosition),
    CameraUpdateType.newLatLng => CameraUpdate.newLatLng(_kTestMapCenter),
    CameraUpdateType.newLatLngBounds =>
      CameraUpdate.newLatLngBounds(_testCameraBounds, 0),
    CameraUpdateType.newLatLngZoom =>
      CameraUpdate.newLatLngZoom(_kTestMapCenter, _kTestCameraZoomLevel),
    CameraUpdateType.scrollBy => CameraUpdate.scrollBy(10, 10),
    CameraUpdateType.zoomBy =>
      CameraUpdate.zoomBy(_kTestZoomByAmount, const Offset(1, 1)),
    CameraUpdateType.zoomTo => CameraUpdate.zoomTo(_kTestCameraZoomLevel),
    CameraUpdateType.zoomIn => CameraUpdate.zoomIn(),
    CameraUpdateType.zoomOut => CameraUpdate.zoomOut(),
  };
}

Future<void> _checkCameraUpdateByType(
  CameraUpdateType type,
  CameraPosition currentPosition,
  CameraPosition? oldPosition,
  GoogleMapController controller,
  Matcher Function(Matcher matcher) wrapMatcher,
) async {
  // As the target might differ a bit from the expected target, a threshold is
  // used.
  const double latLngThreshold = 0.05;

  switch (type) {
    case CameraUpdateType.newCameraPosition:
      expect(currentPosition.bearing,
          wrapMatcher(equals(_kTestCameraPosition.bearing)));
      expect(
          currentPosition.zoom, wrapMatcher(equals(_kTestCameraPosition.zoom)));
      expect(
          currentPosition.tilt, wrapMatcher(equals(_kTestCameraPosition.tilt)));
      expect(
          currentPosition.target.latitude,
          wrapMatcher(
              closeTo(_kTestCameraPosition.target.latitude, latLngThreshold)));
      expect(
          currentPosition.target.longitude,
          wrapMatcher(
              closeTo(_kTestCameraPosition.target.longitude, latLngThreshold)));
    case CameraUpdateType.newLatLng:
      expect(currentPosition.target.latitude,
          wrapMatcher(closeTo(_kTestMapCenter.latitude, latLngThreshold)));
      expect(currentPosition.target.longitude,
          wrapMatcher(closeTo(_kTestMapCenter.longitude, latLngThreshold)));
    case CameraUpdateType.newLatLngBounds:
      final LatLngBounds bounds = await controller.getVisibleRegion();
      expect(
          bounds.northeast.longitude,
          wrapMatcher(
              closeTo(_testCameraBounds.northeast.longitude, latLngThreshold)));
      expect(
          bounds.southwest.longitude,
          wrapMatcher(
              closeTo(_testCameraBounds.southwest.longitude, latLngThreshold)));
    case CameraUpdateType.newLatLngZoom:
      expect(currentPosition.target.latitude,
          wrapMatcher(closeTo(_kTestMapCenter.latitude, latLngThreshold)));
      expect(currentPosition.target.longitude,
          wrapMatcher(closeTo(_kTestMapCenter.longitude, latLngThreshold)));
      expect(currentPosition.zoom, wrapMatcher(equals(_kTestCameraZoomLevel)));
    case CameraUpdateType.scrollBy:
      // For scrollBy, just check that the location has changed.
      if (oldPosition != null) {
        expect(currentPosition.target.latitude,
            isNot(equals(oldPosition.target.latitude)));
        expect(currentPosition.target.longitude,
            isNot(equals(oldPosition.target.longitude)));
      }
    case CameraUpdateType.zoomBy:
      expect(currentPosition.zoom,
          wrapMatcher(equals(kInitialZoomLevel + _kTestZoomByAmount)));
    case CameraUpdateType.zoomTo:
      expect(currentPosition.zoom, wrapMatcher(equals(_kTestCameraZoomLevel)));
    case CameraUpdateType.zoomIn:
      expect(currentPosition.zoom, wrapMatcher(equals(kInitialZoomLevel + 1)));
    case CameraUpdateType.zoomOut:
      expect(currentPosition.zoom, wrapMatcher(equals(kInitialZoomLevel - 1)));
  }
}
