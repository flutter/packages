// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'fake_google_maps_flutter_platform.dart';

void main() {
  late FakeGoogleMapsFlutterPlatform platform;

  setUp(() {
    platform = FakeGoogleMapsFlutterPlatform();
    GoogleMapsFlutterPlatform.instance = platform;
  });

  testWidgets('Can animate camera with duration', (WidgetTester tester) async {
    final Completer<GoogleMapController> controllerCompleter =
        Completer<GoogleMapController>();
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
        onMapCreated: (GoogleMapController controller) {
          controllerCompleter.complete(controller);
        },
      ),
    ));
    final GoogleMapController controller = await controllerCompleter.future;
    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.animateCameraConfiguration, isNull);

    final CameraUpdate newCameraUpdate =
        CameraUpdate.newLatLng(const LatLng(20.0, 25.0));
    const Duration updateDuration = Duration(seconds: 10);

    await controller.animateCamera(
      newCameraUpdate,
      duration: updateDuration,
    );

    expect(map.animateCameraConfiguration, isNotNull);
    expect(map.animateCameraConfiguration!.cameraUpdate, newCameraUpdate);
    expect(map.animateCameraConfiguration!.configuration?.duration,
        updateDuration);

    /// Tests that the camera update respects the default behavior when the
    /// duration is null.
    await controller.animateCamera(
      newCameraUpdate,
    );
    expect(map.animateCameraConfiguration!.configuration?.duration, isNull);
  });
}
