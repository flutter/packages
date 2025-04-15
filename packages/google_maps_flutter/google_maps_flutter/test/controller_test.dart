// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'fake_google_maps_flutter_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Subscriptions are canceled on dispose',
      (WidgetTester tester) async {
    final FakeGoogleMapsFlutterPlatform platform =
        FakeGoogleMapsFlutterPlatform();

    GoogleMapsFlutterPlatform.instance = platform;

    final FakePlatformViewsController fakePlatformViewsController =
        FakePlatformViewsController();

    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform_views,
      fakePlatformViewsController.fakePlatformViewsMethodHandler,
    );

    final ValueNotifier<GoogleMapController?> controllerNotifier =
        ValueNotifier<GoogleMapController?>(null);

    final GoogleMap googleMap = GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        controllerNotifier.value = controller;
      },
      initialCameraPosition: const CameraPosition(
        target: LatLng(0, 0),
      ),
    );

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: googleMap,
    ));

    await tester.pump();

    final GoogleMapController? controller = controllerNotifier.value;

    if (controller != null) {
      expect(platform.mapEventStreamController.hasListener, true);

      await tester.pumpWidget(const Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(),
      ));

      await tester.binding.runAsync(() async {
        await tester.pump();
      });

      expect(platform.mapEventStreamController.hasListener, false);

      controllerNotifier.dispose();
    } else {
      fail('GoogleMapController not created');
    }
  });
}

class FakePlatformViewsController {
  Future<dynamic> fakePlatformViewsMethodHandler(MethodCall call) {
    switch (call.method) {
      case 'create':
        return Future<int>.value(1);
      default:
        return Future<dynamic>.value();
    }
  }
}
