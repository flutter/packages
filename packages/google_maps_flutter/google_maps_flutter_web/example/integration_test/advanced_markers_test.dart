// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:google_maps_flutter_web/src/marker_clustering.dart';
import 'package:google_maps_flutter_web/src/utils.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:web/src/dom.dart' as dom;
import 'package:web/web.dart';

import 'resources/icon_image_base64.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MarkersController', () {
    late StreamController<MapEvent<Object?>> events;
    late MarkersController<gmaps.AdvancedMarkerElement,
        gmaps.AdvancedMarkerElementOptions> controller;
    late ClusterManagersController<gmaps.AdvancedMarkerElement>
        clusterManagersController;
    late gmaps.Map map;

    setUp(() {
      events = StreamController<MapEvent<Object?>>();

      clusterManagersController =
          ClusterManagersController<gmaps.AdvancedMarkerElement>(
              stream: events);
      controller = MarkersController<gmaps.AdvancedMarkerElement,
          gmaps.AdvancedMarkerElementOptions>(
        stream: events,
        clusterManagersController: clusterManagersController,
      );
      map = gmaps.Map(createDivElement());
      clusterManagersController.bindToMap(123, map);
      controller.bindToMap(123, map);
    });

    testWidgets('addMarkers', (WidgetTester tester) async {
      final Set<AdvancedMarker> markers = <AdvancedMarker>{
        const AdvancedMarker(markerId: MarkerId('1')),
        const AdvancedMarker(markerId: MarkerId('2')),
      };

      await controller.addMarkers(markers);

      expect(controller.markers.length, 2);
      expect(controller.markers, contains(const MarkerId('1')));
      expect(controller.markers, contains(const MarkerId('2')));
      expect(controller.markers, isNot(contains(const MarkerId('66'))));
    });

    testWidgets('changeMarkers', (WidgetTester tester) async {
      gmaps.AdvancedMarkerElement? marker;
      gmaps.LatLngLiteral? position;

      final Set<AdvancedMarker> markers = <AdvancedMarker>{
        const AdvancedMarker(markerId: MarkerId('1')),
      };
      await controller.addMarkers(markers);

      marker = controller.markers[const MarkerId('1')]?.marker;
      expect(marker, isNotNull);
      expect(marker!.gmpDraggable, isFalse);

      // By default, markers fall in LatLng(0, 0)
      position = marker.position! as gmaps.LatLngLiteral;
      expect(position, isNotNull);
      expect(position.lat, equals(0));
      expect(position.lng, equals(0));

      // Update the marker with draggable and position
      final Set<AdvancedMarker> updatedMarkers = <AdvancedMarker>{
        const AdvancedMarker(
          markerId: MarkerId('1'),
          draggable: true,
          position: LatLng(42, 54),
        ),
      };
      await controller.changeMarkers(updatedMarkers);
      expect(controller.markers.length, 1);

      marker = controller.markers[const MarkerId('1')]?.marker;
      expect(marker, isNotNull);
      expect(marker!.gmpDraggable, isTrue);

      position = marker.position! as gmaps.LatLngLiteral;
      expect(position, isNotNull);
      expect(position.lat, equals(42));
      expect(position.lng, equals(54));
    });

    testWidgets(
        'changeMarkers resets marker position if not passed when updating!',
        (WidgetTester tester) async {
      gmaps.AdvancedMarkerElement? marker;
      gmaps.LatLngLiteral? position;

      final Set<AdvancedMarker> markers = <AdvancedMarker>{
        const AdvancedMarker(
          markerId: MarkerId('1'),
          position: LatLng(42, 54),
        ),
      };
      await controller.addMarkers(markers);

      marker = controller.markers[const MarkerId('1')]?.marker;
      expect(marker, isNotNull);
      expect(marker!.gmpDraggable, isFalse);

      position = marker.position! as gmaps.LatLngLiteral;
      expect(position, isNotNull);
      expect(position.lat, equals(42));
      expect(position.lng, equals(54));

      // Update the marker without position
      final Set<AdvancedMarker> updatedMarkers = <AdvancedMarker>{
        const AdvancedMarker(
          markerId: MarkerId('1'),
          draggable: true,
        ),
      };
      await controller.changeMarkers(updatedMarkers);
      expect(controller.markers.length, 1);

      marker = controller.markers[const MarkerId('1')]?.marker;
      expect(marker, isNotNull);
      expect(marker!.gmpDraggable, isTrue);

      position = marker.position! as gmaps.LatLngLiteral;
      expect(position, isNotNull);
      expect(position.lat, equals(0));
      expect(position.lng, equals(0));
    });

    testWidgets('removeMarkers', (WidgetTester tester) async {
      final Set<AdvancedMarker> markers = <AdvancedMarker>{
        const AdvancedMarker(markerId: MarkerId('1')),
        const AdvancedMarker(markerId: MarkerId('2')),
        const AdvancedMarker(markerId: MarkerId('3')),
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
      final Set<AdvancedMarker> markers = <AdvancedMarker>{
        const AdvancedMarker(
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

    testWidgets('only single InfoWindow is visible',
        (WidgetTester tester) async {
      final Set<AdvancedMarker> markers = <AdvancedMarker>{
        const AdvancedMarker(
          markerId: MarkerId('1'),
          infoWindow: InfoWindow(title: 'Title', snippet: 'Snippet'),
        ),
        const AdvancedMarker(
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
      final Set<AdvancedMarker> markers = <AdvancedMarker>{
        AdvancedMarker(
          markerId: const MarkerId('1'),
          icon: AssetMapBitmap(
            'assets/red_square.png',
            imagePixelRatio: 1.0,
          ),
        ),
      };

      await controller.addMarkers(markers);

      expect(controller.markers.length, 1);
      final HTMLImageElement? icon = controller
          .markers[const MarkerId('1')]?.marker?.content as HTMLImageElement?;
      expect(icon, isNotNull);

      final String assetUrl = icon!.src;
      expect(assetUrl, endsWith('assets/red_square.png'));

      // asset size is 48x48 physical pixels
      expect(icon.style.width, '48px');
      expect(icon.style.height, '48px');
    });

    testWidgets('markers with custom asset icon and pixel ratio work',
        (WidgetTester tester) async {
      final Set<AdvancedMarker> markers = <AdvancedMarker>{
        AdvancedMarker(
          markerId: const MarkerId('1'),
          icon: AssetMapBitmap(
            'assets/red_square.png',
            imagePixelRatio: 2.0,
          ),
        ),
      };

      await controller.addMarkers(markers);

      expect(controller.markers.length, 1);
      final HTMLImageElement? icon = controller
          .markers[const MarkerId('1')]?.marker?.content as HTMLImageElement?;
      expect(icon, isNotNull);

      final String assetUrl = icon!.src;
      expect(assetUrl, endsWith('assets/red_square.png'));

      // Asset size is 48x48 physical pixels, and with pixel ratio 2.0 it
      // should be drawn with size 24x24 logical pixels.
      expect(icon.style.width, '24px');
      expect(icon.style.height, '24px');
    });

    testWidgets('markers with custom asset icon with width and height work',
        (WidgetTester tester) async {
      final Set<AdvancedMarker> markers = <AdvancedMarker>{
        AdvancedMarker(
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
      final HTMLImageElement? icon = controller
          .markers[const MarkerId('1')]?.marker?.content as HTMLImageElement?;
      expect(icon, isNotNull);

      final String assetUrl = icon!.src;
      expect(assetUrl, endsWith('assets/red_square.png'));

      // Asset size is 48x48 physical pixels,
      // and scaled to requested 64x64 size.
      expect(icon.style.width, '64px');
      expect(icon.style.height, '64px');
    });

    testWidgets('markers with missing asset icon should not set size',
        (WidgetTester tester) async {
      final Set<AdvancedMarker> markers = <AdvancedMarker>{
        AdvancedMarker(
            markerId: const MarkerId('1'),
            icon: AssetMapBitmap(
              'assets/broken_asset_name.png',
              imagePixelRatio: 2.0,
            )),
      };

      await controller.addMarkers(markers);

      expect(controller.markers.length, 1);
      final HTMLImageElement? icon = controller
          .markers[const MarkerId('1')]?.marker?.content as HTMLImageElement?;
      expect(icon, isNotNull);

      final String assetUrl = icon!.src;
      expect(assetUrl, endsWith('assets/broken_asset_name.png'));

      // For invalid assets, the size and scaledSize should be null.
      expect(icon.style.width, isEmpty);
      expect(icon.style.height, isEmpty);
    });

    testWidgets('markers with custom bitmap icon work',
        (WidgetTester tester) async {
      final Uint8List bytes = const Base64Decoder().convert(iconImageBase64);
      final Set<AdvancedMarker> markers = <AdvancedMarker>{
        AdvancedMarker(
          markerId: const MarkerId('1'),
          icon: BytesMapBitmap(
            bytes,
            imagePixelRatio: tester.view.devicePixelRatio,
          ),
        ),
      };

      await controller.addMarkers(markers);

      expect(controller.markers.length, 1);
      final HTMLImageElement? icon = controller
          .markers[const MarkerId('1')]?.marker?.content as HTMLImageElement?;
      expect(icon, isNotNull);

      final String blobUrl = icon!.src;
      expect(blobUrl, startsWith('blob:'));

      final http.Response response = await http.get(Uri.parse(blobUrl));
      expect(
        response.bodyBytes,
        bytes,
        reason:
            'Bytes from the Icon blob must match bytes used to create AdvancedMarker',
      );

      // Icon size is 16x16 pixels, this should be automatically read from the
      // bitmap and set to the icon size scaled to 8x8 using the
      // given imagePixelRatio.
      final int expectedSize = 16 ~/ tester.view.devicePixelRatio;
      expect(icon.style.width, '${expectedSize}px');
      expect(icon.style.height, '${expectedSize}px');
    });

    testWidgets('markers with custom bitmap icon and pixel ratio work',
        (WidgetTester tester) async {
      final Uint8List bytes = const Base64Decoder().convert(iconImageBase64);
      final Set<AdvancedMarker> markers = <AdvancedMarker>{
        AdvancedMarker(
          markerId: const MarkerId('1'),
          icon: BytesMapBitmap(
            bytes,
            imagePixelRatio: 1,
          ),
        ),
      };

      await controller.addMarkers(markers);

      expect(controller.markers.length, 1);
      final HTMLImageElement? icon = controller
          .markers[const MarkerId('1')]?.marker?.content as HTMLImageElement?;
      expect(icon, isNotNull);

      // Icon size is 16x16 pixels, this should be automatically read from the
      // bitmap and set to the icon size and should not be changed as
      // image pixel ratio is set to 1.0.
      expect(icon!.style.width, '16px');
      expect(icon.style.height, '16px');
    });

    testWidgets('markers with custom bitmap icon pass size to sdk',
        (WidgetTester tester) async {
      final Uint8List bytes = const Base64Decoder().convert(iconImageBase64);
      final Set<AdvancedMarker> markers = <AdvancedMarker>{
        AdvancedMarker(
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
      final HTMLImageElement? icon = controller
          .markers[const MarkerId('1')]?.marker?.content as HTMLImageElement?;
      expect(icon, isNotNull);
      expect(icon!.style.width, '20px');
      expect(icon.style.height, '30px');
    });

    testWidgets('markers created with pin config and colored glyph work',
        (WidgetTester widgetTester) async {
      final Set<AdvancedMarker> markers = <AdvancedMarker>{
        AdvancedMarker(
          markerId: const MarkerId('1'),
          icon: BitmapDescriptor.pinConfig(
            backgroundColor: const Color(0xFF00FF00),
            borderColor: const Color(0xFFFF0000),
            glyph: Glyph.color(const Color(0xFFFFFFFF)),
          ),
        ),
      };
      await controller.addMarkers(markers);
      expect(controller.markers.length, 1);

      final HTMLDivElement? icon = controller
          .markers[const MarkerId('1')]?.marker?.content as HTMLDivElement?;
      expect(icon, isNotNull);

      // Query nodes and check colors. This is a bit fragile as it depends on
      // the implementation details of the icon which is not part of the public
      // API
      final NodeList backgroundNodes =
          icon!.querySelectorAll("[class*='maps-pin-view-background']");
      final NodeList borderNodes =
          icon.querySelectorAll("[class*='maps-pin-view-border']");
      final NodeList glyphNodes =
          icon.querySelectorAll("[class*='maps-pin-view-default-glyph']");

      expect(backgroundNodes.length, 1);
      expect(borderNodes.length, 1);
      expect(glyphNodes.length, 1);

      expect(
        (backgroundNodes.item(0)! as dom.Element)
            .getAttribute('fill')
            ?.toUpperCase(),
        '#00FF00',
      );
      expect(
        (borderNodes.item(0)! as dom.Element)
            .getAttribute('fill')
            ?.toUpperCase(),
        '#FF0000',
      );
      expect(
        (glyphNodes.item(0)! as dom.Element)
            .getAttribute('fill')
            ?.toUpperCase(),
        '#FFFFFF',
      );
    });

    testWidgets('markers created with text glyph work',
        (WidgetTester widgetTester) async {
      final Set<AdvancedMarker> markers = <AdvancedMarker>{
        AdvancedMarker(
          markerId: const MarkerId('1'),
          icon: BitmapDescriptor.pinConfig(
            backgroundColor: Colors.black,
            borderColor: Colors.black,
            glyph: Glyph.text(
              'Hey',
              textColor: const Color(0xFF0000FF),
            ),
          ),
        ),
      };
      await controller.addMarkers(markers);
      expect(controller.markers.length, 1);

      final HTMLDivElement? icon = controller
          .markers[const MarkerId('1')]?.marker?.content as HTMLDivElement?;
      expect(icon, isNotNull);

      // Query pin nodes and find text element. This is a bit fragile as it
      // depends on the implementation details of the icon which is not part of
      // the public API
      dom.Element? paragraphElement;
      final NodeList paragraphs = icon!.querySelectorAll('p');
      for (int i = 0; i < paragraphs.length; i++) {
        final dom.Element? paragraph = paragraphs.item(i) as dom.Element?;
        if (paragraph?.innerHTML.toString() == 'Hey') {
          paragraphElement = paragraph;
          break;
        }
      }

      expect(paragraphElement, isNotNull);
      expect(paragraphElement!.innerHTML, 'Hey');
      expect(paragraphElement.innerHTML, 'Hey');
      expect(
        paragraphElement.getAttribute('style')?.toLowerCase(),
        contains('color: #0000ff'),
      );
    });

    testWidgets('markers created with text glyph work',
        (WidgetTester widgetTester) async {
      final Set<AdvancedMarker> markers = <AdvancedMarker>{
        AdvancedMarker(
          markerId: const MarkerId('1'),
          icon: BitmapDescriptor.pinConfig(
            backgroundColor: Colors.black,
            borderColor: Colors.black,
            glyph: Glyph.bitmap(
              await BitmapDescriptor.asset(
                const ImageConfiguration(
                  size: Size.square(12),
                ),
                'assets/red_square.png',
              ),
            ),
          ),
        ),
      };
      await controller.addMarkers(markers);
      expect(controller.markers.length, 1);

      final HTMLDivElement? icon = controller
          .markers[const MarkerId('1')]?.marker?.content as HTMLDivElement?;
      expect(icon, isNotNull);

      // Query pin nodes and find text element. This is a bit fragile as it
      // depends on the implementation details of the icon which is not part of
      // the public API
      HTMLImageElement? imgElement;
      final NodeList imgElements = icon!.querySelectorAll('img');
      for (int i = 0; i < imgElements.length; i++) {
        final dom.Element? img = imgElements.item(i) as dom.Element?;
        final String src = (img! as HTMLImageElement).src;
        if (src.endsWith('assets/red_square.png')) {
          imgElement = img as HTMLImageElement;
          break;
        }
      }

      expect(imgElement, isNotNull);
      expect(imgElement!.src, endsWith('assets/red_square.png'));
      expect(
        imgElement.getAttribute('style')?.toLowerCase(),
        contains('width: 12px; height: 12px;'),
      );
    });

    testWidgets('InfoWindow snippet can have links',
        (WidgetTester tester) async {
      final Set<AdvancedMarker> markers = <AdvancedMarker>{
        const AdvancedMarker(
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

    testWidgets('InfoWindow content is clickable', (WidgetTester tester) async {
      final Set<AdvancedMarker> markers = <AdvancedMarker>{
        const AdvancedMarker(
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
