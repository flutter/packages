// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show GoogleMapController;
import 'package:web/web.dart' as web;

/// How long a map may take to report itself ready before the test fails.
///
/// Integration tests have no default timeout, so a map that never becomes
/// ready would otherwise hang until the driver gives up, reporting an opaque
/// `DriverError` with no test output.
/// See https://github.com/flutter/flutter/issues/193452.
const Duration mapReadyTimeout = Duration(seconds: 30);

int _nextMapId = 0;

/// Returns a unique map id for each test controller.
///
/// Every `GoogleMapController` registers a platform view factory keyed by its
/// map id, and only the first registration for a given view type takes effect,
/// so reusing a map id across tests causes `controller.widget` to render the
/// first controller's `<div>`.
int getNextMapId() => _nextMapId++;

/// Pumps the widget returned by [build] and returns the controller of the
/// `GoogleMap` inside it.
///
/// [build] must forward [onMapCreated] to the `GoogleMap` it creates.
Future<GoogleMapController> pumpMap(
  WidgetTester tester,
  Widget Function(void Function(GoogleMapController) onMapCreated) build,
) async {
  final completer = Completer<GoogleMapController>();
  await tester.pumpWidget(build(completer.complete));
  // This is needed to kick-off the rendering of the JS Map flutter widget.
  await tester.pump();
  return awaitMapReady(completer.future);
}

/// Same as [pumpMap], for tests that build the map through the platform
/// interface and only need its map id.
///
/// [build] must forward [onPlatformViewCreated] to the platform view it creates.
Future<int> pumpPlatformMap(
  WidgetTester tester,
  Widget Function(void Function(int mapId) onPlatformViewCreated) build,
) async {
  final completer = Completer<int>();
  await tester.pumpWidget(build(completer.complete));
  await tester.pump();
  return awaitMapReady(completer.future);
}

/// Bounds a map-ready [future] by [mapReadyTimeout].
///
/// On timeout, the error describes the state of the Maps SDK and of every map
/// `<div>` in the document, so a hang on CI can be diagnosed from the driver
/// log alone (the `web-server` device forwards no console output).
Future<T> awaitMapReady<T>(Future<T> future) {
  return future.timeout(
    mapReadyTimeout,
    onTimeout: () => throw TimeoutException(_describeMapState()),
  );
}

String _describeMapState() {
  final web.NodeList divs = web.document.querySelectorAll(
    'div[id^="plugins.flutter.io/google_maps_"]',
  );
  final buffer = StringBuffer(
    'The map never reported being ready. '
    'google.maps loaded: ${globalContext.has('google')}; '
    'markerClusterer loaded: ${globalContext.has('markerClusterer')}; '
    'map divs: ${divs.length}',
  );
  for (var i = 0; i < divs.length; i++) {
    final div = divs.item(i)! as web.HTMLElement;
    buffer.write(
      '\n  ${div.id}: connected=${div.isConnected} '
      'size=${div.offsetWidth}x${div.offsetHeight} '
      'rendered=${div.querySelector('.gm-style') != null}',
    );
  }
  return buffer.toString();
}
