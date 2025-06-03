// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GroundOverlay', () {
    const GroundOverlayId kID = GroundOverlayId('groundOverlay');
    final LatLngBounds kBounds = LatLngBounds(
      southwest: const LatLng(37.42, -122.08),
      northeast: const LatLng(37.43, -122.09),
    );
    const LatLng kPosition = LatLng(37.42, -122.08);
    final MapBitmap kMapBitmap = AssetMapBitmap(
      'assets/asset.png',
      imagePixelRatio: 1.0,
      bitmapScaling: MapBitmapScaling.none,
    );
    const Offset kAnchor = Offset(0.3, 0.7);
    const double kBearing = 45.0;
    const double kTransparency = 0.5;
    const int kZIndex = 1;
    const bool kVisible = false;
    const bool kClickable = false;
    const double kWidth = 200;
    const double kHeight = 300;
    const double kZoomLevel = 10.0;

    test('fromBounds constructor defaults', () {
      final GroundOverlay groundOverlay = GroundOverlay.fromBounds(
        groundOverlayId: kID,
        image: kMapBitmap,
        bounds: kBounds,
      );

      expect(groundOverlay.groundOverlayId, kID);
      expect(groundOverlay.bounds, kBounds);
      expect(groundOverlay.image, kMapBitmap);
      expect(groundOverlay.anchor, const Offset(0.5, 0.5));
      expect(groundOverlay.bearing, 0.0);
      expect(groundOverlay.transparency, 0.0);
      expect(groundOverlay.zIndex, 0.0);
      expect(groundOverlay.visible, true);
      expect(groundOverlay.clickable, true);
      expect(groundOverlay.onTap, null);
    });

    test('fromBounds construct with values', () {
      final GroundOverlay groundOverlay = GroundOverlay.fromBounds(
        groundOverlayId: kID,
        image: kMapBitmap,
        bounds: kBounds,
        anchor: kAnchor,
        bearing: kBearing,
        transparency: kTransparency,
        zIndex: kZIndex,
        visible: kVisible,
        clickable: kClickable,
      );

      expect(groundOverlay.groundOverlayId, kID);
      expect(groundOverlay.bounds, kBounds);
      expect(groundOverlay.image, kMapBitmap);
      expect(groundOverlay.anchor, kAnchor);
      expect(groundOverlay.bearing, kBearing);
      expect(groundOverlay.transparency, kTransparency);
      expect(groundOverlay.zIndex, kZIndex);
      expect(groundOverlay.visible, kVisible);
      expect(groundOverlay.clickable, kClickable);
    });

    test('fromPosition constructor defaults', () {
      final GroundOverlay groundOverlay = GroundOverlay.fromPosition(
        groundOverlayId: kID,
        image: kMapBitmap,
        position: kPosition,
        width: 100,
        height: 100,
      );

      expect(groundOverlay.groundOverlayId, kID);
      expect(groundOverlay.position, kPosition);
      expect(groundOverlay.image, kMapBitmap);
      expect(groundOverlay.width, 100);
      expect(groundOverlay.height, 100);
      expect(groundOverlay.anchor, const Offset(0.5, 0.5));
      expect(groundOverlay.bearing, 0.0);
      expect(groundOverlay.transparency, 0.0);
      expect(groundOverlay.zIndex, 0.0);
      expect(groundOverlay.visible, true);
      expect(groundOverlay.clickable, true);
      expect(groundOverlay.onTap, null);
    });

    test('fromPosition construct with values', () {
      final GroundOverlay groundOverlay = GroundOverlay.fromPosition(
        groundOverlayId: kID,
        image: kMapBitmap,
        position: kPosition,
        width: kWidth,
        height: kHeight,
        anchor: kAnchor,
        bearing: kBearing,
        transparency: kTransparency,
        zIndex: kZIndex,
        visible: kVisible,
        clickable: kClickable,
        zoomLevel: kZoomLevel,
      );

      expect(groundOverlay.groundOverlayId, kID);
      expect(groundOverlay.position, kPosition);
      expect(groundOverlay.image, kMapBitmap);
      expect(groundOverlay.width, kWidth);
      expect(groundOverlay.height, kHeight);
      expect(groundOverlay.anchor, kAnchor);
      expect(groundOverlay.bearing, kBearing);
      expect(groundOverlay.transparency, kTransparency);
      expect(groundOverlay.zIndex, kZIndex);
      expect(groundOverlay.visible, kVisible);
      expect(groundOverlay.clickable, kClickable);
      expect(groundOverlay.zoomLevel, kZoomLevel);
    });

    test('copyWith fromPosition', () {
      final GroundOverlay groundOverlay1 = GroundOverlay.fromPosition(
        groundOverlayId: kID,
        image: kMapBitmap,
        position: kPosition,
        width: 100,
        height: 100,
      );

      final GroundOverlay groundOverlay2 = groundOverlay1.copyWith(
        bearingParam: kBearing,
        transparencyParam: kTransparency,
        zIndexParam: kZIndex,
        visibleParam: kVisible,
        clickableParam: kClickable,
        onTapParam: () {},
      );

      expect(groundOverlay2.groundOverlayId, groundOverlay1.groundOverlayId);
      expect(groundOverlay2.image, groundOverlay1.image);
      expect(groundOverlay2.position, groundOverlay1.position);
      expect(groundOverlay2.width, groundOverlay1.width);
      expect(groundOverlay2.height, groundOverlay1.height);
      expect(groundOverlay2.anchor, groundOverlay1.anchor);
      expect(groundOverlay2.bearing, kBearing);
      expect(groundOverlay2.transparency, kTransparency);
      expect(groundOverlay2.zIndex, kZIndex);
      expect(groundOverlay2.visible, kVisible);
      expect(groundOverlay2.clickable, kClickable);
      expect(groundOverlay2.zoomLevel, groundOverlay1.zoomLevel);
    });

    test('copyWith fromBounds', () {
      final GroundOverlay groundOverlay1 = GroundOverlay.fromBounds(
        groundOverlayId: kID,
        image: kMapBitmap,
        bounds: kBounds,
      );

      final GroundOverlay groundOverlay2 = groundOverlay1.copyWith(
        bearingParam: kBearing,
        transparencyParam: kTransparency,
        zIndexParam: kZIndex,
        visibleParam: kVisible,
        clickableParam: kClickable,
        onTapParam: () {},
      );

      expect(groundOverlay2.groundOverlayId, groundOverlay1.groundOverlayId);
      expect(groundOverlay2.image, groundOverlay1.image);
      expect(groundOverlay2.position, groundOverlay1.position);
      expect(groundOverlay2.width, groundOverlay1.width);
      expect(groundOverlay2.height, groundOverlay1.height);
      expect(groundOverlay2.anchor, groundOverlay1.anchor);
      expect(groundOverlay2.bearing, kBearing);
      expect(groundOverlay2.transparency, kTransparency);
      expect(groundOverlay2.zIndex, kZIndex);
      expect(groundOverlay2.visible, kVisible);
      expect(groundOverlay2.clickable, kClickable);
      expect(groundOverlay2.zoomLevel, groundOverlay1.zoomLevel);
    });

    test('fromPosition clone', () {
      final GroundOverlay groundOverlay1 = GroundOverlay.fromPosition(
        groundOverlayId: kID,
        image: kMapBitmap,
        position: kPosition,
        width: 100,
        height: 100,
      );

      final GroundOverlay groundOverlay2 = groundOverlay1.clone();

      expect(groundOverlay2, groundOverlay1);
    });

    test('fromBounds clone', () {
      final GroundOverlay groundOverlay1 = GroundOverlay.fromBounds(
        groundOverlayId: kID,
        image: kMapBitmap,
        bounds: kBounds,
      );

      final GroundOverlay groundOverlay2 = groundOverlay1.clone();

      expect(groundOverlay2, groundOverlay1);
    });

    test('==', () {
      final GroundOverlay groundOverlayPosition1 = GroundOverlay.fromPosition(
        groundOverlayId: kID,
        image: kMapBitmap,
        position: kPosition,
        width: kWidth,
        height: kHeight,
        anchor: kAnchor,
        bearing: kBearing,
        transparency: kTransparency,
        zIndex: kZIndex,
        visible: kVisible,
        clickable: kClickable,
        zoomLevel: kZoomLevel,
      );

      final GroundOverlay groundOverlayPosition2 = GroundOverlay.fromPosition(
        groundOverlayId: kID,
        image: kMapBitmap,
        position: kPosition,
        width: kWidth,
        height: kHeight,
        anchor: kAnchor,
        bearing: kBearing,
        transparency: kTransparency,
        zIndex: kZIndex,
        visible: kVisible,
        clickable: kClickable,
        zoomLevel: kZoomLevel,
      );

      final GroundOverlay groundOverlayPosition3 = GroundOverlay.fromPosition(
        groundOverlayId: kID,
        image: kMapBitmap,
        position: kPosition,
        width: kWidth,
        height: kHeight,
        anchor: kAnchor,
        bearing: kBearing,
        transparency: kTransparency,
        zIndex: kZIndex,
        visible: kVisible,
        clickable: kClickable,
        zoomLevel: kZoomLevel + 1,
      );

      final GroundOverlay groundOverlayBounds1 = GroundOverlay.fromBounds(
        groundOverlayId: kID,
        image: kMapBitmap,
        bounds: kBounds,
        anchor: kAnchor,
        bearing: kBearing,
        transparency: kTransparency,
        zIndex: kZIndex,
        visible: kVisible,
        clickable: kClickable,
      );

      final GroundOverlay groundOverlayBounds2 = GroundOverlay.fromBounds(
        groundOverlayId: kID,
        image: kMapBitmap,
        bounds: kBounds,
        anchor: kAnchor,
        bearing: kBearing,
        transparency: kTransparency,
        zIndex: kZIndex,
        visible: kVisible,
        clickable: kClickable,
      );

      final GroundOverlay groundOverlayBounds3 = GroundOverlay.fromBounds(
        groundOverlayId: kID,
        image: kMapBitmap,
        bounds: kBounds,
        anchor: kAnchor,
        bearing: kBearing,
        transparency: kTransparency,
        zIndex: kZIndex + 1,
        visible: kVisible,
        clickable: kClickable,
      );

      expect(groundOverlayPosition1, groundOverlayPosition2);
      expect(groundOverlayPosition1, isNot(groundOverlayPosition3));
      expect(groundOverlayBounds1, groundOverlayBounds2);
      expect(groundOverlayBounds1, isNot(groundOverlayBounds3));
      expect(groundOverlayPosition1, isNot(groundOverlayBounds1));
    });

    test('hashCode', () {
      final GroundOverlay groundOverlay = GroundOverlay.fromPosition(
        groundOverlayId: kID,
        image: kMapBitmap,
        position: kPosition,
      );

      expect(groundOverlay.hashCode, groundOverlay.clone().hashCode);
    });

    test('asserts in constructor', () {
      // Transparency must be between 0.0 and 1.0.
      expect(
        () => GroundOverlay.fromBounds(
          groundOverlayId: kID,
          image: kMapBitmap,
          bounds: kBounds,
          transparency: -0.1,
        ),
        throwsAssertionError,
      );

      // Transparency must be between 0.0 and 1.0.
      expect(
        () => GroundOverlay.fromBounds(
          groundOverlayId: kID,
          image: kMapBitmap,
          bounds: kBounds,
          transparency: 1.1,
        ),
        throwsAssertionError,
      );

      // Bearing must be between 0.0 and 360.0.
      expect(
        () => GroundOverlay.fromBounds(
          groundOverlayId: kID,
          image: kMapBitmap,
          bounds: kBounds,
          bearing: -1.0,
        ),
        throwsAssertionError,
      );

      // Bearing must be between 0.0 and 360.0.
      expect(
        () => GroundOverlay.fromBounds(
          groundOverlayId: kID,
          image: kMapBitmap,
          bounds: kBounds,
          bearing: 361.0,
        ),
        throwsAssertionError,
      );

      // Height must be greater than 0.
      expect(
        () => GroundOverlay.fromPosition(
          groundOverlayId: kID,
          image: kMapBitmap,
          position: kPosition,
          width: 100,
          height: -1,
        ),
        throwsAssertionError,
      );

      // Width must be greater than 0.
      expect(
        () => GroundOverlay.fromPosition(
          groundOverlayId: kID,
          image: kMapBitmap,
          position: kPosition,
          width: -1,
          height: 100,
        ),
        throwsAssertionError,
      );

      // Image bitMapScaling must be MapBitmapScaling.none.
      expect(
        () => GroundOverlay.fromPosition(
          groundOverlayId: kID,
          image: AssetMapBitmap(
            'assets/asset.png',
            imagePixelRatio: 1.0,
            // ignore: avoid_redundant_argument_values
            bitmapScaling: MapBitmapScaling.auto,
          ),
          position: kPosition,
          width: 100,
          height: 100,
        ),
        throwsAssertionError,
      );
    });
  });
}
