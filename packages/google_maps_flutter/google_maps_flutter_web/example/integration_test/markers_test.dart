// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:google_maps_flutter_web/src/marker_clustering.dart';
// ignore: implementation_imports
import 'package:google_maps_flutter_web/src/utils.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:web/web.dart';

import 'resources/icon_image_base64.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MarkersController', () {
    late StreamController<MapEvent<Object?>> events;
    late MarkersController controller;
    late ClusterManagersController clusterManagersController;
    late gmaps.Map map;

    setUp(() {
      events = StreamController<MapEvent<Object?>>();

      clusterManagersController = ClusterManagersController(stream: events);
      controller = MarkersController(
          stream: events, clusterManagersController: clusterManagersController);
      map = gmaps.Map(createDivElement());
      clusterManagersController.bindToMap(123, map);
      controller.bindToMap(123, map);
    });

    testWidgets('addMarkers', (WidgetTester tester) async {
      final Set<Marker> markers = <Marker>{
        const Marker(markerId: MarkerId('1')),
        const Marker(markerId: MarkerId('2')),
      };

      await controller.addMarkers(markers);

      expect(controller.markers.length, 2);
      expect(controller.markers, contains(const MarkerId('1')));
      expect(controller.markers, contains(const MarkerId('2')));
      expect(controller.markers, isNot(contains(const MarkerId('66'))));
    });

    testWidgets('changeMarkers', (WidgetTester tester) async {
      gmaps.Marker? marker;
      gmaps.LatLng? position;

      final Set<Marker> markers = <Marker>{
        const Marker(markerId: MarkerId('1')),
      };
      await controller.addMarkers(markers);

      marker = controller.markers[const MarkerId('1')]?.marker;
      expect(marker, isNotNull);
      expect(marker!.draggable, isFalse);

      // By default, markers fall in LatLng(0, 0)
      position = marker.position;
      expect(position, isNotNull);
      expect(position!.lat, equals(0));
      expect(position.lng, equals(0));

      // Update the marker with draggable and position
      final Set<Marker> updatedMarkers = <Marker>{
        const Marker(
          markerId: MarkerId('1'),
          draggable: true,
          position: LatLng(42, 54),
        ),
      };
      await controller.changeMarkers(updatedMarkers);
      expect(controller.markers.length, 1);

      marker = controller.markers[const MarkerId('1')]?.marker;
      expect(marker, isNotNull);
      expect(marker!.draggable, isTrue);

      position = marker.position;
      expect(position, isNotNull);
      expect(position!.lat, equals(42));
      expect(position.lng, equals(54));
    });

    testWidgets(
        'changeMarkers resets marker position if not passed when updating!',
        (WidgetTester tester) async {
      gmaps.Marker? marker;
      gmaps.LatLng? position;

      final Set<Marker> markers = <Marker>{
        const Marker(
          markerId: MarkerId('1'),
          position: LatLng(42, 54),
        ),
      };
      await controller.addMarkers(markers);

      marker = controller.markers[const MarkerId('1')]?.marker;
      expect(marker, isNotNull);
      expect(marker!.draggable, isFalse);

      position = marker.position;
      expect(position, isNotNull);
      expect(position!.lat, equals(42));
      expect(position.lng, equals(54));

      // Update the marker without position
      final Set<Marker> updatedMarkers = <Marker>{
        const Marker(
          markerId: MarkerId('1'),
          draggable: true,
        ),
      };
      await controller.changeMarkers(updatedMarkers);
      expect(controller.markers.length, 1);

      marker = controller.markers[const MarkerId('1')]?.marker;
      expect(marker, isNotNull);
      expect(marker!.draggable, isTrue);

      position = marker.position;
      expect(position, isNotNull);
      expect(position!.lat, equals(0));
      expect(position.lng, equals(0));
    });

    testWidgets('removeMarkers', (WidgetTester tester) async {
      final Set<Marker> markers = <Marker>{
        const Marker(markerId: MarkerId('1')),
        const Marker(markerId: MarkerId('2')),
        const Marker(markerId: MarkerId('3')),
      };

      await controller.addMarkers(markers);

      expect(controller.markers.length, 3);

      // Remove some markers...
      final Set<MarkerId> markerIdsToRemove = <MarkerId>{
        const MarkerId('1'),
        const MarkerId('3'),
      };

      controller.removeMarkers(markerIdsToRemove);

      expect(controller.markers.length, 1);
      expect(controller.markers, isNot(contains(const MarkerId('1'))));
      expect(controller.markers, contains(const MarkerId('2')));
      expect(controller.markers, isNot(contains(const MarkerId('3'))));
    });

    testWidgets('InfoWindow show/hide', (WidgetTester tester) async {
      final Set<Marker> markers = <Marker>{
        const Marker(
          markerId: MarkerId('1'),
          infoWindow: InfoWindow(title: 'Title', snippet: 'Snippet'),
        ),
      };

      await controller.addMarkers(markers);

      expect(controller.markers[const MarkerId('1')]?.infoWindowShown, isFalse);

      controller.showMarkerInfoWindow(const MarkerId('1'));

      expect(controller.markers[const MarkerId('1')]?.infoWindowShown, isTrue);

      controller.hideMarkerInfoWindow(const MarkerId('1'));

      expect(controller.markers[const MarkerId('1')]?.infoWindowShown, isFalse);
    });

    // https://github.com/flutter/flutter/issues/67380
    testWidgets('only single InfoWindow is visible',
        (WidgetTester tester) async {
      final Set<Marker> markers = <Marker>{
        const Marker(
          markerId: MarkerId('1'),
          infoWindow: InfoWindow(title: 'Title', snippet: 'Snippet'),
        ),
        const Marker(
          markerId: MarkerId('2'),
          infoWindow: InfoWindow(title: 'Title', snippet: 'Snippet'),
        ),
      };
      await controller.addMarkers(markers);

      expect(controller.markers[const MarkerId('1')]?.infoWindowShown, isFalse);
      expect(controller.markers[const MarkerId('2')]?.infoWindowShown, isFalse);

      controller.showMarkerInfoWindow(const MarkerId('1'));

      expect(controller.markers[const MarkerId('1')]?.infoWindowShown, isTrue);
      expect(controller.markers[const MarkerId('2')]?.infoWindowShown, isFalse);

      controller.showMarkerInfoWindow(const MarkerId('2'));

      expect(controller.markers[const MarkerId('1')]?.infoWindowShown, isFalse);
      expect(controller.markers[const MarkerId('2')]?.infoWindowShown, isTrue);
    });

    testWidgets('markers with custom asset icon work',
        (WidgetTester tester) async {
      final Set<Marker> markers = <Marker>{
        Marker(
            markerId: const MarkerId('1'),
            icon: AssetMapBitmap(
              'assets/red_square.png',
              imagePixelRatio: 1.0,
            )),
      };

      await controller.addMarkers(markers);

      expect(controller.markers.length, 1);
      final gmaps.Icon? icon =
          controller.markers[const MarkerId('1')]?.marker?.icon as gmaps.Icon?;
      expect(icon, isNotNull);

      final String assetUrl = icon!.url;
      expect(assetUrl, startsWith('assets'));

      final gmaps.Size size = icon.size!;
      final gmaps.Size scaledSize = icon.scaledSize!;

      // asset size is 48x48 physical pixels
      expect(size.width, 48);
      expect(size.height, 48);
      expect(scaledSize.width, 48);
      expect(scaledSize.height, 48);
    });

    testWidgets('markers with custom asset icon and pixelratio work',
        (WidgetTester tester) async {
      final Set<Marker> markers = <Marker>{
        Marker(
            markerId: const MarkerId('1'),
            icon: AssetMapBitmap(
              'assets/red_square.png',
              imagePixelRatio: 2.0,
            )),
      };

      await controller.addMarkers(markers);

      expect(controller.markers.length, 1);
      final gmaps.Icon? icon =
          controller.markers[const MarkerId('1')]?.marker?.icon as gmaps.Icon?;
      expect(icon, isNotNull);

      final String assetUrl = icon!.url;
      expect(assetUrl, startsWith('assets'));

      final gmaps.Size size = icon.size!;
      final gmaps.Size scaledSize = icon.scaledSize!;

      // Asset size is 48x48 physical pixels, and with pixel ratio 2.0 it
      // should be drawn with size 24x24 logical pixels.
      expect(size.width, 24);
      expect(size.height, 24);
      expect(scaledSize.width, 24);
      expect(scaledSize.height, 24);
    });
    testWidgets('markers with custom asset icon with width and height work',
        (WidgetTester tester) async {
      final Set<Marker> markers = <Marker>{
        Marker(
            markerId: const MarkerId('1'),
            icon: AssetMapBitmap(
              'assets/red_square.png',
              imagePixelRatio: 2.0,
              width: 64,
              height: 64,
            )),
      };

      await controller.addMarkers(markers);

      expect(controller.markers.length, 1);
      final gmaps.Icon? icon =
          controller.markers[const MarkerId('1')]?.marker?.icon as gmaps.Icon?;
      expect(icon, isNotNull);

      final String assetUrl = icon!.url;
      expect(assetUrl, startsWith('assets'));

      final gmaps.Size size = icon.size!;
      final gmaps.Size scaledSize = icon.scaledSize!;

      // Asset size is 48x48 physical pixels,
      // and scaled to requested 64x64 size.
      expect(size.width, 64);
      expect(size.height, 64);
      expect(scaledSize.width, 64);
      expect(scaledSize.height, 64);
    });

    testWidgets('markers with missing asset icon should not set size',
        (WidgetTester tester) async {
      final Set<Marker> markers = <Marker>{
        Marker(
            markerId: const MarkerId('1'),
            icon: AssetMapBitmap(
              'assets/broken_asset_name.png',
              imagePixelRatio: 2.0,
            )),
      };

      await controller.addMarkers(markers);

      expect(controller.markers.length, 1);
      final gmaps.Icon? icon =
          controller.markers[const MarkerId('1')]?.marker?.icon as gmaps.Icon?;
      expect(icon, isNotNull);

      final String assetUrl = icon!.url;
      expect(assetUrl, startsWith('assets'));

      // For invalid assets, the size and scaledSize should be null.
      expect(icon.size, null);
      expect(icon.scaledSize, null);
    });

    // https://github.com/flutter/flutter/issues/66622
    testWidgets('markers with custom bitmap icon work',
        (WidgetTester tester) async {
      final Uint8List bytes = const Base64Decoder().convert(iconImageBase64);
      final Set<Marker> markers = <Marker>{
        Marker(
          markerId: const MarkerId('1'),
          icon: BytesMapBitmap(
            bytes,
            imagePixelRatio: tester.view.devicePixelRatio,
          ),
        ),
      };

      await controller.addMarkers(markers);

      expect(controller.markers.length, 1);
      final gmaps.Icon? icon =
          controller.markers[const MarkerId('1')]?.marker?.icon as gmaps.Icon?;
      expect(icon, isNotNull);

      final String blobUrl = icon!.url;
      expect(blobUrl, startsWith('blob:'));

      final http.Response response = await http.get(Uri.parse(blobUrl));
      expect(response.bodyBytes, bytes,
          reason:
              'Bytes from the Icon blob must match bytes used to create Marker');

      final gmaps.Size size = icon.size!;
      final gmaps.Size scaledSize = icon.scaledSize!;

      // Icon size is 16x16 pixels, this should be automatically read from the
      // bitmap and set to the icon size scaled to 8x8 using the
      // given imagePixelRatio.
      final int expectedSize = 16 ~/ tester.view.devicePixelRatio;
      expect(size.width, expectedSize);
      expect(size.height, expectedSize);
      expect(scaledSize.width, expectedSize);
      expect(scaledSize.height, expectedSize);
    });

    testWidgets('markers with custom bitmap icon and pixelratio work',
        (WidgetTester tester) async {
      final Uint8List bytes = const Base64Decoder().convert(iconImageBase64);
      final Set<Marker> markers = <Marker>{
        Marker(
          markerId: const MarkerId('1'),
          icon: BytesMapBitmap(
            bytes,
            imagePixelRatio: 1,
          ),
        ),
      };

      await controller.addMarkers(markers);

      expect(controller.markers.length, 1);
      final gmaps.Icon? icon =
          controller.markers[const MarkerId('1')]?.marker?.icon as gmaps.Icon?;
      expect(icon, isNotNull);

      final gmaps.Size size = icon!.size!;
      final gmaps.Size scaledSize = icon.scaledSize!;

      // Icon size is 16x16 pixels, this should be automatically read from the
      // bitmap and set to the icon size and should not be changed as
      // image pixel ratio is set to 1.0.
      expect(size.width, 16);
      expect(size.height, 16);
      expect(scaledSize.width, 16);
      expect(scaledSize.height, 16);
    });

    // https://github.com/flutter/flutter/issues/73789
    testWidgets('markers with custom bitmap icon pass size to sdk',
        (WidgetTester tester) async {
      final Uint8List bytes = const Base64Decoder().convert(iconImageBase64);
      final Set<Marker> markers = <Marker>{
        Marker(
          markerId: const MarkerId('1'),
          icon: BytesMapBitmap(
            bytes,
            width: 20,
            height: 30,
          ),
        ),
      };

      await controller.addMarkers(markers);

      expect(controller.markers.length, 1);
      final gmaps.Icon? icon =
          controller.markers[const MarkerId('1')]?.marker?.icon as gmaps.Icon?;
      expect(icon, isNotNull);

      final gmaps.Size size = icon!.size!;
      final gmaps.Size scaledSize = icon.scaledSize!;

      expect(size.width, 20);
      expect(size.height, 30);
      expect(scaledSize.width, 20);
      expect(scaledSize.height, 30);
    });

    // https://github.com/flutter/flutter/issues/67854
    testWidgets('InfoWindow snippet can have links',
        (WidgetTester tester) async {
      final Set<Marker> markers = <Marker>{
        const Marker(
          markerId: MarkerId('1'),
          infoWindow: InfoWindow(
            title: 'title for test',
            snippet: '<a href="https://www.google.com">Go to Google >>></a>',
          ),
        ),
      };

      await controller.addMarkers(markers);

      expect(controller.markers.length, 1);
      final HTMLElement? content = controller
          .markers[const MarkerId('1')]?.infoWindow?.content as HTMLElement?;
      expect(content, isNotNull);

      final String innerHtml = (content!.innerHTML as JSString).toDart;
      expect(innerHtml, contains('title for test'));
      expect(
          innerHtml,
          contains(
            '<a href="https://www.google.com">Go to Google &gt;&gt;&gt;</a>',
          ));
    });

    // https://github.com/flutter/flutter/issues/67289
    testWidgets('InfoWindow content is clickable', (WidgetTester tester) async {
      final Set<Marker> markers = <Marker>{
        const Marker(
          markerId: MarkerId('1'),
          infoWindow: InfoWindow(
            title: 'title for test',
            snippet: 'some snippet',
          ),
        ),
      };

      await controller.addMarkers(markers);

      expect(controller.markers.length, 1);
      final HTMLElement? content = controller
          .markers[const MarkerId('1')]?.infoWindow?.content as HTMLElement?;

      content?.click();

      final MapEvent<Object?> event = await events.stream.first;

      expect(event, isA<InfoWindowTapEvent>());
      expect((event as InfoWindowTapEvent).value, equals(const MarkerId('1')));
    });
  });
}
