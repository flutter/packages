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

  group('GoogleMap widget', () {
    testWidgets('Subscriptions are canceled on dispose',
        (WidgetTester tester) async {
      GoogleMapsFlutterPlatform.instance = FakeGoogleMapsFlutterPlatform();

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
        expect(controller.streamSubscriptionsState, isNotEmpty);

        controller.streamSubscriptionsState.forEach((_, bool isCanceled) {
          expect(isCanceled, isFalse);
        });

        await tester.pumpWidget(const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(),
        ));

        await tester.binding.runAsync(() async {
          await tester.pump();
        });

        controller.streamSubscriptionsState.forEach((_, bool isCanceled) {
          expect(isCanceled, isTrue);
        });
      } else {
        fail('GoogleMapController not created');
      }
    });
  });
}

class FakePlatformViewsController {
  Future<dynamic> fakePlatformViewsMethodHandler(MethodCall call) {
    switch (call.method) {
      case 'create':
        return Future<int>.value(1);
      default:
        return Future<dynamic>.value(null);
    }
  }
}
