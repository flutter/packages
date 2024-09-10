// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('toMap / fromMap', () {
    const CameraPosition cameraPosition = CameraPosition(
        target: LatLng(10.0, 15.0), bearing: 0.5, tilt: 30.0, zoom: 1.5);
    // Cast to <dynamic, dynamic> to ensure that recreating from JSON, where
    // type information will have likely been lost, still works.
    final Map<dynamic, dynamic> json =
        (cameraPosition.toMap() as Map<String, dynamic>)
            .cast<dynamic, dynamic>();
    final CameraPosition? cameraPositionFromJson = CameraPosition.fromMap(json);

    expect(cameraPosition, cameraPositionFromJson);
  });

  test('CameraUpdate.newCameraPosition', () {
    const CameraPosition cameraPosition = CameraPosition(
        target: LatLng(10.0, 15.0), bearing: 0.5, tilt: 30.0, zoom: 1.5);
    final CameraUpdate cameraUpdate =
        CameraUpdate.newCameraPosition(cameraPosition);
    expect(cameraUpdate.runtimeType, CameraUpdateNewCameraPosition);
    expect(cameraUpdate.updateType, CameraUpdateType.newCameraPosition);
    cameraUpdate as CameraUpdateNewCameraPosition;
    expect(cameraUpdate.cameraPosition, cameraPosition);
  });

  test('CameraUpdate.newLatLng', () {
    const LatLng latLng = LatLng(1.0, 2.0);
    final CameraUpdate cameraUpdate = CameraUpdate.newLatLng(latLng);
    expect(cameraUpdate.runtimeType, CameraUpdateNewLatLng);
    expect(cameraUpdate.updateType, CameraUpdateType.newLatLng);
    cameraUpdate as CameraUpdateNewLatLng;
    expect(cameraUpdate.latLng, latLng);
  });

  test('CameraUpdate.newLatLngBounds', () {
    final LatLngBounds latLngBounds = LatLngBounds(
        northeast: const LatLng(1.0, 2.0), southwest: const LatLng(-2.0, -3.0));
    const double padding = 1.0;
    final CameraUpdate cameraUpdate =
        CameraUpdate.newLatLngBounds(latLngBounds, padding);
    expect(cameraUpdate.runtimeType, CameraUpdateNewLatLngBounds);
    expect(cameraUpdate.updateType, CameraUpdateType.newLatLngBounds);
    cameraUpdate as CameraUpdateNewLatLngBounds;
    expect(cameraUpdate.bounds, latLngBounds);
    expect(cameraUpdate.padding, padding);
  });

  test('CameraUpdate.newLatLngZoom', () {
    const LatLng latLng = LatLng(1.0, 2.0);
    const double zoom = 2.0;
    final CameraUpdate cameraUpdate = CameraUpdate.newLatLngZoom(latLng, zoom);
    expect(cameraUpdate.runtimeType, CameraUpdateNewLatLngZoom);
    expect(cameraUpdate.updateType, CameraUpdateType.newLatLngZoom);
    cameraUpdate as CameraUpdateNewLatLngZoom;
    expect(cameraUpdate.latLng, latLng);
    expect(cameraUpdate.zoom, zoom);
  });

  test('CameraUpdate.scrollBy', () {
    const double dx = 2.0;
    const double dy = 5.0;
    final CameraUpdate cameraUpdate = CameraUpdate.scrollBy(dx, dy);
    expect(cameraUpdate.runtimeType, CameraUpdateScrollBy);
    expect(cameraUpdate.updateType, CameraUpdateType.scrollBy);
    cameraUpdate as CameraUpdateScrollBy;
    expect(cameraUpdate.dx, dx);
    expect(cameraUpdate.dy, dy);
  });

  test('CameraUpdate.zoomBy', () {
    const double amount = 1.5;
    const Offset focus = Offset(-1.0, -2.0);
    final CameraUpdate cameraUpdate = CameraUpdate.zoomBy(amount, focus);
    expect(cameraUpdate.runtimeType, CameraUpdateZoomBy);
    expect(cameraUpdate.updateType, CameraUpdateType.zoomBy);
    cameraUpdate as CameraUpdateZoomBy;
    expect(cameraUpdate.amount, amount);
    expect(cameraUpdate.focus, focus);
  });

  test('CameraUpdate.zoomIn', () {
    final CameraUpdate cameraUpdate = CameraUpdate.zoomIn();
    expect(cameraUpdate.runtimeType, CameraUpdateZoomIn);
    expect(cameraUpdate.updateType, CameraUpdateType.zoomIn);
  });

  test('CameraUpdate.zoomOut', () {
    final CameraUpdate cameraUpdate = CameraUpdate.zoomOut();
    expect(cameraUpdate.runtimeType, CameraUpdateZoomOut);
    expect(cameraUpdate.updateType, CameraUpdateType.zoomOut);
  });
}
