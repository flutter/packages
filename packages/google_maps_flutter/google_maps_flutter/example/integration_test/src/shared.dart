// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file contains shared definitions used across multiple test scenarios.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Initial map center
const LatLng kInitialMapCenter = LatLng(0, 0);

/// Initial zoom level
const double kInitialZoomLevel = 5;

/// Initial camera position
const CameraPosition kInitialCameraPosition =
    CameraPosition(target: kInitialMapCenter, zoom: kInitialZoomLevel);

// Dummy map ID
const String kCloudMapId = '000000000000000'; // Dummy map ID.

/// True if the test is running in an iOS device
final bool isIOS = defaultTargetPlatform == TargetPlatform.iOS;

/// True if the test is running in an Android device
final bool isAndroid =
    defaultTargetPlatform == TargetPlatform.android && !kIsWeb;

/// True if the test is running in a web browser.
const bool isWeb = kIsWeb;

/// Pumps a [map] widget in [tester] of a certain [size], then waits until it settles.
Future<void> pumpMap(WidgetTester tester, GoogleMap map,
    [Size size = const Size.square(200)]) async {
  await tester.pumpWidget(wrapMap(map, size));
  await tester.pumpAndSettle();
}

/// Wraps a [map] in a bunch of widgets so it renders in all platforms.
///
/// An optional [size] can be passed.
Widget wrapMap(GoogleMap map, [Size size = const Size.square(200)]) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox.fromSize(
          size: size,
          child: map,
        ),
      ),
    ),
  );
}
