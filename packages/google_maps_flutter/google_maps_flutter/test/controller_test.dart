// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

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
      final TrackableStreamSubscription<MarkerDragEndEvent> subscription =
          TrackableStreamSubscription<MarkerDragEndEvent>();

      controller.addDebugTrackSubscription(subscription);
      expect(subscription.isCanceled, false);

      await tester.pumpWidget(const Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(),
      ));

      await tester.binding.runAsync(() async {
        await tester.pump();
      });

      expect(subscription.isCanceled, true);

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

/// A trackable implementation of [StreamSubscription] that records cancellation.
///
/// This class is used for testing purposes to verify that stream subscriptions
/// are properly cancelled when a [GoogleMapController] is disposed.
///
/// It implements the minimum functionality needed to act as a
/// [StreamSubscription] while tracking whether [cancel] has been called.
class TrackableStreamSubscription<T> implements StreamSubscription<T> {
  bool _canceled = false;

  bool get isCanceled => _canceled;

  @override
  Future<void> cancel() async {
    _canceled = true;
    return Future<void>.value();
  }

  @override
  bool get isPaused => false;

  @override
  void onData(void Function(T data)? handleData) {}

  @override
  void onDone(void Function()? handleDone) {}

  @override
  void onError(Function? handleError) {}

  @override
  void pause([Future<void>? resumeSignal]) {}

  @override
  void resume() {}

  @override
  Future<E> asFuture<E>([E? futureValue]) {
    return Future<E>.value(futureValue as E);
  }
}
