// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$GroundOverlay', () {
    test('bounds constructor defaults', () {
      final GroundOverlay groundOverlay = GroundOverlay(
        groundOverlayId: const GroundOverlayId('ABC123'),
        bounds: LatLngBounds(
          southwest: const LatLng(0.0, 0.0),
          northeast: const LatLng(1.0, 1.0),
        ),
      );

      expect(groundOverlay.bearing, equals(0.0));
      expect(groundOverlay.anchor, equals(const Offset(0.5, 0.5)));
      expect(groundOverlay.consumeTapEvents, equals(false));
      expect(groundOverlay.icon, equals(null));
      expect(groundOverlay.width, equals(null));
      expect(groundOverlay.height, equals(null));
      expect(groundOverlay.onTap, equals(null));
      expect(groundOverlay.opacity, equals(1.0));
      expect(groundOverlay.visible, equals(true));
      expect(groundOverlay.zIndex, equals(0.0));
      expect(groundOverlay.groundOverlayId,
          equals(const GroundOverlayId('ABC123')));
      expect(groundOverlay.position, equals(null));
      expect(
          groundOverlay.bounds,
          equals(LatLngBounds(
              southwest: const LatLng(0.0, 0.0),
              northeast: const LatLng(1.0, 1.0))));
    });
  });

  test('fromBounds constructor default', () {
    final GroundOverlay groundOverlay = GroundOverlay.fromBounds(
      LatLngBounds(
        southwest: const LatLng(0.0, 0.0),
        northeast: const LatLng(1.0, 1.0),
      ),
      groundOverlayId: const GroundOverlayId('ABC123'),
    );

    expect(groundOverlay.bearing, equals(0.0));
    expect(groundOverlay.anchor, equals(const Offset(0.5, 0.5)));
    expect(groundOverlay.consumeTapEvents, equals(false));
    expect(groundOverlay.icon, equals(null));
    expect(groundOverlay.width, equals(null));
    expect(groundOverlay.height, equals(null));
    expect(groundOverlay.onTap, equals(null));
    expect(groundOverlay.opacity, equals(1.0));
    expect(groundOverlay.visible, equals(true));
    expect(groundOverlay.zIndex, equals(0.0));
    expect(
        groundOverlay.groundOverlayId, equals(const GroundOverlayId('ABC123')));
    expect(groundOverlay.position, equals(null));
    expect(
        groundOverlay.bounds,
        equals(LatLngBounds(
            southwest: const LatLng(0.0, 0.0),
            northeast: const LatLng(1.0, 1.0))));
  });

  test('position constructor defaults', () {
    const GroundOverlay groundOverlay = GroundOverlay(
      groundOverlayId: GroundOverlayId('ABC123'),
      position: LatLng(0.0, 0.0),
      width: 100.0,
      height: 100.0,
    );

    expect(groundOverlay.bearing, equals(0.0));
    expect(groundOverlay.anchor, equals(const Offset(0.5, 0.5)));
    expect(groundOverlay.consumeTapEvents, equals(false));
    expect(groundOverlay.icon, equals(null));
    expect(groundOverlay.bounds, equals(null));
    expect(groundOverlay.onTap, equals(null));
    expect(groundOverlay.opacity, equals(1.0));
    expect(groundOverlay.visible, equals(true));
    expect(groundOverlay.zIndex, equals(0.0));
    expect(
        groundOverlay.groundOverlayId, equals(const GroundOverlayId('ABC123')));
    expect(groundOverlay.position, equals(const LatLng(0.0, 0.0)));
    expect(groundOverlay.width, equals(100.0));
    expect(groundOverlay.height, equals(100.0));
  });

  test('constructor opacity is >= 0.0 and <= 1.0', () {
    void initWithOpacity(double opacity) {
      GroundOverlay(
          groundOverlayId: const GroundOverlayId('ABC123'), opacity: opacity);
    }

    expect(() => initWithOpacity(-0.5), throwsAssertionError);
    expect(() => initWithOpacity(0.0), isNot(throwsAssertionError));
    expect(() => initWithOpacity(0.5), isNot(throwsAssertionError));
    expect(() => initWithOpacity(1.0), isNot(throwsAssertionError));
    expect(() => initWithOpacity(100), throwsAssertionError);
  });

  test('constructor with position and bounds', () {
    expect(
        () => GroundOverlay(
              groundOverlayId: const GroundOverlayId('ABC123'),
              position: const LatLng(0.0, 0.0),
              bounds: LatLngBounds(
                southwest: const LatLng(0.0, 0.0),
                northeast: const LatLng(1.0, 1.0),
              ),
            ),
        throwsAssertionError);
  });

  test('constructor with position and width and height null', () {
    expect(
        () => GroundOverlay(
              groundOverlayId: const GroundOverlayId('ABC123'),
              position: const LatLng(0.0, 0.0),
            ),
        throwsAssertionError);
  });

  test('constructor with position and width null', () {
    expect(
        () => GroundOverlay(
              groundOverlayId: const GroundOverlayId('ABC123'),
              position: const LatLng(0.0, 0.0),
              height: 100.0,
            ),
        throwsAssertionError);
  });

  test('constructor with bounds and width and height not null', () {
    expect(
        () => GroundOverlay(
              groundOverlayId: const GroundOverlayId('ABC123'),
              bounds: LatLngBounds(
                southwest: const LatLng(0.0, 0.0),
                northeast: const LatLng(1.0, 1.0),
              ),
              width: 100.0,
              height: 100.0,
            ),
        throwsAssertionError);
  });

  test('toJson with position, width and height', () {
    final GroundOverlay groundOverlay = GroundOverlay(
      groundOverlayId: const GroundOverlayId('ABC123'),
      consumeTapEvents: true,
      icon: BitmapDescriptor.defaultMarker,
      opacity: 0.12345,
      position: const LatLng(50, 50),
      visible: false,
      bearing: 100,
      anchor: const Offset(100, 100),
      height: 100,
      zIndex: 100,
      width: 100,
      onTap: () {},
    );

    final Map<String, Object> json =
        groundOverlay.toJson() as Map<String, Object>;

    expect(json, <String, Object>{
      'groundOverlayId': 'ABC123',
      'consumeTapEvents': true,
      'transparency': 1 - 0.12345,
      'bearing': 100.0,
      'visible': false,
      'zIndex': 100.0,
      'height': 100.0,
      'anchor': <double>[100, 100],
      'icon': BitmapDescriptor.defaultMarker.toJson(),
      'width': 100.0,
      'position': <double>[50, 50],
    });
  });

  test('toJson with bounds', () {
    final GroundOverlay groundOverlay = GroundOverlay(
      groundOverlayId: const GroundOverlayId('ABC123'),
      consumeTapEvents: true,
      icon: BitmapDescriptor.defaultMarker,
      opacity: 0.12345,
      bounds: LatLngBounds(
        southwest: const LatLng(0.0, 0.0),
        northeast: const LatLng(1.0, 1.0),
      ),
      visible: false,
      bearing: 100,
      anchor: const Offset(100, 100),
      zIndex: 100,
      onTap: () {},
    );

    final Map<String, Object> json =
        groundOverlay.toJson() as Map<String, Object>;

    expect(json, <String, Object>{
      'groundOverlayId': 'ABC123',
      'consumeTapEvents': true,
      'transparency': 1 - 0.12345,
      'bearing': 100.0,
      'visible': false,
      'zIndex': 100.0,
      'anchor': <double>[100, 100],
      'icon': BitmapDescriptor.defaultMarker.toJson(),
      'bounds': <Object>[
        <double>[0, 0],
        <double>[1, 1],
      ],
    });
  });

  test('clone', () {
    const GroundOverlay groundOverlay =
        GroundOverlay(groundOverlayId: GroundOverlayId('ABC123'));
    final GroundOverlay clone = groundOverlay.clone();

    expect(identical(clone, groundOverlay), isFalse);
    expect(clone, equals(groundOverlay));
  });

  test('copyWith from position constructor', () {
    const GroundOverlayId groundOverlayId = GroundOverlayId('ABC123');
    const GroundOverlay groundOverlay =
        GroundOverlay(groundOverlayId: groundOverlayId);

    final BitmapDescriptor testDescriptor =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
    const double testOpacityParam = 0.12345;
    const Offset testAnchorParam = Offset(100, 100);
    final bool testConsumeTapEventsParam = !groundOverlay.consumeTapEvents;
    final bool testVisibleParam = !groundOverlay.visible;
    const double testBearingParam = 100;
    const double testHeightParam = 100;
    const double testWidthParam = 100;
    const int testZIndexParam = 100;
    const LatLng testPositionParam = LatLng(50, 50);
    final List<String> log = <String>[];

    final GroundOverlay copy = groundOverlay.copyWith(
      consumeTapEventsParam: testConsumeTapEventsParam,
      iconParam: testDescriptor,
      opacityParam: testOpacityParam,
      positionParam: testPositionParam,
      visibleParam: testVisibleParam,
      bearingParam: testBearingParam,
      heightParam: testHeightParam,
      widthParam: testWidthParam,
      anchorParam: testAnchorParam,
      zIndexParam: testZIndexParam,
      onTapParam: () {
        log.add('onTapParam');
      },
    );

    expect(copy.groundOverlayId, equals(groundOverlayId));
    expect(copy.consumeTapEvents, equals(testConsumeTapEventsParam));
    expect(copy.icon, equals(testDescriptor));
    expect(copy.opacity, equals(testOpacityParam));
    expect(copy.position, equals(testPositionParam));
    expect(copy.visible, equals(testVisibleParam));
    expect(copy.bearing, equals(testBearingParam));
    expect(copy.height, equals(testHeightParam));
    expect(copy.width, equals(testWidthParam));
    expect(copy.anchor, equals(testAnchorParam));
    expect(copy.zIndex, equals(testZIndexParam));
    expect(copy.bounds, equals(null));

    copy.onTap!();
    expect(log, <String>['onTapParam']);
  });

  test('copyWith from bounds constructor', () {
    const GroundOverlayId groundOverlayId = GroundOverlayId('ABC123');
    const GroundOverlay groundOverlay =
        GroundOverlay(groundOverlayId: groundOverlayId);

    final BitmapDescriptor testDescriptor =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
    const double testOpacityParam = 0.12345;
    const Offset testAnchorParam = Offset(100, 100);
    final bool testConsumeTapEventsParam = !groundOverlay.consumeTapEvents;
    final bool testVisibleParam = !groundOverlay.visible;
    const double testBearingParam = 100;
    const int testZIndexParam = 100;
    final LatLngBounds testBoundsParam = LatLngBounds(
      southwest: const LatLng(0.0, 0.0),
      northeast: const LatLng(1.0, 1.0),
    );
    final List<String> log = <String>[];

    final GroundOverlay copy = groundOverlay.copyWith(
      consumeTapEventsParam: testConsumeTapEventsParam,
      iconParam: testDescriptor,
      opacityParam: testOpacityParam,
      boundsParam: testBoundsParam,
      visibleParam: testVisibleParam,
      bearingParam: testBearingParam,
      anchorParam: testAnchorParam,
      zIndexParam: testZIndexParam,
      onTapParam: () {
        log.add('onTapParam');
      },
    );

    expect(copy.groundOverlayId, equals(groundOverlayId));
    expect(copy.consumeTapEvents, equals(testConsumeTapEventsParam));
    expect(copy.icon, equals(testDescriptor));
    expect(copy.opacity, equals(testOpacityParam));
    expect(copy.position, equals(null));
    expect(copy.visible, equals(testVisibleParam));
    expect(copy.bearing, equals(testBearingParam));
    expect(copy.height, equals(null));
    expect(copy.width, equals(null));
    expect(copy.anchor, equals(testAnchorParam));
    expect(copy.zIndex, equals(testZIndexParam));
    expect(copy.bounds, equals(testBoundsParam));

    copy.onTap!();
    expect(log, <String>['onTapParam']);
  });
}
