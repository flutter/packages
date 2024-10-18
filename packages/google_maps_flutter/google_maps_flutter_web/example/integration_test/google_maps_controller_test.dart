// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
// ignore: implementation_imports
import 'package:google_maps_flutter_web/src/utils.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'google_maps_controller_test.mocks.dart';

// This value is used when comparing long~num, like
// LatLng values.
const String _kCloudMapId = '000000000000000'; // Dummy map ID.

gmaps.Map mapShim() => throw UnimplementedError();

@GenerateNiceMocks(<MockSpec<dynamic>>[
  MockSpec<CirclesController>(
    fallbackGenerators: <Symbol, Function>{#googleMap: mapShim},
  ),
  MockSpec<HeatmapsController>(
    fallbackGenerators: <Symbol, Function>{#googleMap: mapShim},
  ),
  MockSpec<PolygonsController>(
    fallbackGenerators: <Symbol, Function>{#googleMap: mapShim},
  ),
  MockSpec<PolylinesController>(
    fallbackGenerators: <Symbol, Function>{#googleMap: mapShim},
  ),
  MockSpec<MarkersController<dynamic, dynamic>>(
    fallbackGenerators: <Symbol, Function>{#googleMap: mapShim},
  ),
  MockSpec<TileOverlaysController>(
    fallbackGenerators: <Symbol, Function>{#googleMap: mapShim},
  ),
])

/// Test Google Map Controller
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('GoogleMapController', () {
    const int mapId = 33930;
    late GoogleMapController controller;
    late StreamController<MapEvent<Object?>> stream;

    // Creates a controller with the default mapId and stream controller, and any `options` needed.
    GoogleMapController createController({
      CameraPosition initialCameraPosition =
          const CameraPosition(target: LatLng(0, 0)),
      MapObjects mapObjects = const MapObjects(),
      MapConfiguration mapConfiguration = const MapConfiguration(),
    }) {
      return GoogleMapController(
        mapId: mapId,
        streamController: stream,
        widgetConfiguration: MapWidgetConfiguration(
          initialCameraPosition: initialCameraPosition,
          textDirection: TextDirection.ltr,
          markerType: MarkerType.marker,
        ),
        mapObjects: mapObjects,
        mapConfiguration: mapConfiguration,
      );
    }

    setUp(() {
      stream = StreamController<MapEvent<Object?>>.broadcast();
    });

    group('construct/dispose', () {
      setUp(() {
        controller = createController();
      });

      testWidgets('constructor creates widget', (WidgetTester tester) async {
        expect(controller.widget, isNotNull);
        expect(controller.widget, isA<HtmlElementView>());
        expect((controller.widget! as HtmlElementView).viewType,
            endsWith('$mapId'));
      });

      testWidgets('widget is cached when reused', (WidgetTester tester) async {
        final Widget? first = controller.widget;
        final Widget? again = controller.widget;
        expect(identical(first, again), isTrue);
      });

      group('dispose', () {
        testWidgets('closes the stream and removes the widget',
            (WidgetTester tester) async {
          controller.dispose();

          expect(stream.isClosed, isTrue);
          expect(controller.widget, isNull);
        });

        testWidgets('cannot call getVisibleRegion after dispose',
            (WidgetTester tester) async {
          controller.dispose();

          expect(() async {
            await controller.getVisibleRegion();
          }, throwsAssertionError);
        });

        testWidgets('cannot call getScreenCoordinate after dispose',
            (WidgetTester tester) async {
          controller.dispose();

          expect(() async {
            await controller.getScreenCoordinate(
              const LatLng(43.3072465, -5.6918241),
            );
          }, throwsAssertionError);
        });

        testWidgets('cannot call getLatLng after dispose',
            (WidgetTester tester) async {
          controller.dispose();

          expect(() async {
            await controller.getLatLng(
              const ScreenCoordinate(x: 640, y: 480),
            );
          }, throwsAssertionError);
        });

        testWidgets('cannot call moveCamera after dispose',
            (WidgetTester tester) async {
          controller.dispose();

          expect(() async {
            await controller.moveCamera(CameraUpdate.zoomIn());
          }, throwsAssertionError);
        });

        testWidgets('cannot call getZoomLevel after dispose',
            (WidgetTester tester) async {
          controller.dispose();

          expect(() async {
            await controller.getZoomLevel();
          }, throwsAssertionError);
        });

        testWidgets('cannot updateCircles after dispose',
            (WidgetTester tester) async {
          controller.dispose();

          expect(() {
            controller.updateCircles(
              CircleUpdates.from(
                const <Circle>{},
                const <Circle>{},
              ),
            );
          }, throwsAssertionError);
        });

        testWidgets('cannot updateHeatmaps after dispose',
            (WidgetTester tester) async {
          controller.dispose();

          expect(() {
            controller.updateHeatmaps(
              HeatmapUpdates.from(
                const <Heatmap>{},
                const <Heatmap>{},
              ),
            );
          }, throwsAssertionError);
        });

        testWidgets('cannot updatePolygons after dispose',
            (WidgetTester tester) async {
          controller.dispose();

          expect(() {
            controller.updatePolygons(
              PolygonUpdates.from(
                const <Polygon>{},
                const <Polygon>{},
              ),
            );
          }, throwsAssertionError);
        });

        testWidgets('cannot updatePolylines after dispose',
            (WidgetTester tester) async {
          controller.dispose();

          expect(() {
            controller.updatePolylines(
              PolylineUpdates.from(
                const <Polyline>{},
                const <Polyline>{},
              ),
            );
          }, throwsAssertionError);
        });

        testWidgets('cannot updateMarkers after dispose',
            (WidgetTester tester) async {
          controller.dispose();

          await expectLater(
              controller.updateMarkers(MarkerUpdates.from(
                const <Marker>{},
                const <Marker>{},
              )),
              throwsAssertionError);

          expect(() {
            controller.showInfoWindow(const MarkerId('any'));
          }, throwsAssertionError);

          expect(() {
            controller.hideInfoWindow(const MarkerId('any'));
          }, throwsAssertionError);
        });

        testWidgets('cannot updateTileOverlays after dispose',
            (WidgetTester tester) async {
          controller.dispose();

          expect(() {
            controller.updateTileOverlays(const <TileOverlay>{});
          }, throwsAssertionError);
        });

        testWidgets('isInfoWindowShown defaults to false',
            (WidgetTester tester) async {
          controller.dispose();

          expect(controller.isInfoWindowShown(const MarkerId('any')), false);
        });
      });
    });

    group('init', () {
      late MockCirclesController circles;
      late MockHeatmapsController heatmaps;
      late MockMarkersController markers;
      late MockPolygonsController polygons;
      late MockPolylinesController polylines;
      late MockTileOverlaysController tileOverlays;
      late gmaps.Map map;

      setUp(() {
        circles = MockCirclesController();
        heatmaps = MockHeatmapsController();
        markers = MockMarkersController();
        polygons = MockPolygonsController();
        polylines = MockPolylinesController();
        tileOverlays = MockTileOverlaysController();
        map = gmaps.Map(createDivElement());
      });

      testWidgets('listens to map events', (WidgetTester tester) async {
        controller = createController()
          ..debugSetOverrides(
            createMap: (_, __) => map,
            circles: circles,
            heatmaps: heatmaps,
            markers: markers,
            polygons: polygons,
            polylines: polylines,
          )
          ..init();

        // Trigger events on the map, and verify they've been broadcast to the stream
        final Stream<MapEvent<Object?>> capturedEvents = stream.stream.take(5);

        gmaps.event.trigger(
          map,
          'click',
          gmaps.MapMouseEvent()..latLng = gmaps.LatLng(0, 0),
        );
        gmaps.event.trigger(
          map,
          'rightclick',
          gmaps.MapMouseEvent()..latLng = gmaps.LatLng(0, 0),
        );
        // The following line causes 2 events
        gmaps.event.trigger(map, 'bounds_changed');
        gmaps.event.trigger(map, 'idle');

        final List<MapEvent<Object?>> events = await capturedEvents.toList();

        expect(events[0], isA<MapTapEvent>());
        expect(events[1], isA<MapLongPressEvent>());
        expect(events[2], isA<CameraMoveStartedEvent>());
        expect(events[3], isA<CameraMoveEvent>());
        expect(events[4], isA<CameraIdleEvent>());
      });

      testWidgets("binds geometry controllers to map's",
          (WidgetTester tester) async {
        controller = createController()
          ..debugSetOverrides(
            createMap: (_, __) => map,
            circles: circles,
            heatmaps: heatmaps,
            markers: markers,
            polygons: polygons,
            polylines: polylines,
            tileOverlays: tileOverlays,
          )
          ..init();

        verify(circles.bindToMap(mapId, map));
        verify(heatmaps.bindToMap(mapId, map));
        verify(markers.bindToMap(mapId, map));
        verify(polygons.bindToMap(mapId, map));
        verify(polylines.bindToMap(mapId, map));
        verify(tileOverlays.bindToMap(mapId, map));
      });

      testWidgets('renders initial geometry', (WidgetTester tester) async {
        final MapObjects mapObjects = MapObjects(circles: <Circle>{
          const Circle(
            circleId: CircleId('circle-1'),
            zIndex: 1234,
          ),
        }, heatmaps: <Heatmap>{
          const Heatmap(
            heatmapId: HeatmapId('heatmap-1'),
            data: <WeightedLatLng>[
              WeightedLatLng(LatLng(43.355114, -5.851333)),
              WeightedLatLng(LatLng(43.354797, -5.851860)),
              WeightedLatLng(LatLng(43.354469, -5.851318)),
              WeightedLatLng(LatLng(43.354762, -5.850824)),
            ],
            radius: HeatmapRadius.fromPixels(20),
          ),
        }, markers: <Marker>{
          const Marker(
            markerId: MarkerId('marker-1'),
            infoWindow: InfoWindow(
              title: 'title for test',
              snippet: 'snippet for test',
            ),
          ),
        }, polygons: <Polygon>{
          const Polygon(polygonId: PolygonId('polygon-1'), points: <LatLng>[
            LatLng(43.355114, -5.851333),
            LatLng(43.354797, -5.851860),
            LatLng(43.354469, -5.851318),
            LatLng(43.354762, -5.850824),
          ]),
          const Polygon(
            polygonId: PolygonId('polygon-2-with-holes'),
            points: <LatLng>[
              LatLng(43.355114, -5.851333),
              LatLng(43.354797, -5.851860),
              LatLng(43.354469, -5.851318),
              LatLng(43.354762, -5.850824),
            ],
            holes: <List<LatLng>>[
              <LatLng>[
                LatLng(41.354797, -6.851860),
                LatLng(41.354469, -6.851318),
                LatLng(41.354762, -6.850824),
              ]
            ],
          ),
        }, polylines: <Polyline>{
          const Polyline(polylineId: PolylineId('polyline-1'), points: <LatLng>[
            LatLng(43.355114, -5.851333),
            LatLng(43.354797, -5.851860),
            LatLng(43.354469, -5.851318),
            LatLng(43.354762, -5.850824),
          ])
        }, tileOverlays: <TileOverlay>{
          const TileOverlay(tileOverlayId: TileOverlayId('overlay-1'))
        });

        controller = createController(mapObjects: mapObjects)
          ..debugSetOverrides(
            circles: circles,
            heatmaps: heatmaps,
            markers: markers,
            polygons: polygons,
            polylines: polylines,
            tileOverlays: tileOverlays,
          )
          ..init();

        verify(circles.addCircles(mapObjects.circles));
        verify(heatmaps.addHeatmaps(mapObjects.heatmaps));
        verify(markers.addMarkers(mapObjects.markers));
        verify(polygons.addPolygons(mapObjects.polygons));
        verify(polylines.addPolylines(mapObjects.polylines));
        verify(tileOverlays.addTileOverlays(mapObjects.tileOverlays));
      });

      group('Initialization options', () {
        testWidgets('translates initial options', (WidgetTester tester) async {
          gmaps.MapOptions? capturedOptions;
          controller = createController(
              mapConfiguration: const MapConfiguration(
            mapType: MapType.satellite,
            zoomControlsEnabled: true,
            mapId: _kCloudMapId,
            fortyFiveDegreeImageryEnabled: false,
          ));
          controller.debugSetOverrides(
              createMap: (_, gmaps.MapOptions options) {
            capturedOptions = options;
            return map;
          });

          controller.init();

          expect(capturedOptions, isNotNull);
          expect(capturedOptions!.mapTypeId, gmaps.MapTypeId.SATELLITE);
          expect(capturedOptions!.zoomControl, true);
          expect(capturedOptions!.mapId, _kCloudMapId);
          expect(capturedOptions!.gestureHandling, 'auto',
              reason:
                  'by default the map handles zoom/pan gestures internally');
          expect(capturedOptions!.rotateControl, false);
          expect(capturedOptions!.tilt, 0);
        });

        testWidgets('translates fortyFiveDegreeImageryEnabled option',
            (WidgetTester tester) async {
          gmaps.MapOptions? capturedOptions;
          controller = createController(
              mapConfiguration: const MapConfiguration(
            scrollGesturesEnabled: false,
            fortyFiveDegreeImageryEnabled: true,
          ));
          controller.debugSetOverrides(
              createMap: (_, gmaps.MapOptions options) {
            capturedOptions = options;
            return map;
          });

          controller.init();

          expect(capturedOptions, isNotNull);
          expect(capturedOptions!.rotateControl, true);
          expect(capturedOptions!.tilt, isNull);
        });

        testWidgets('translates webGestureHandling option',
            (WidgetTester tester) async {
          gmaps.MapOptions? capturedOptions;
          controller = createController(
              mapConfiguration: const MapConfiguration(
            zoomGesturesEnabled: false,
            webGestureHandling: WebGestureHandling.greedy,
          ));
          controller.debugSetOverrides(
              createMap: (_, gmaps.MapOptions options) {
            capturedOptions = options;
            return map;
          });

          controller.init();

          expect(capturedOptions, isNotNull);
          expect(capturedOptions!.gestureHandling, 'greedy');
        });

        testWidgets('sets initial position when passed',
            (WidgetTester tester) async {
          gmaps.MapOptions? capturedOptions;
          controller = createController(
            initialCameraPosition: const CameraPosition(
              target: LatLng(43.308, -5.6910),
              zoom: 12,
            ),
          )
            ..debugSetOverrides(createMap: (_, gmaps.MapOptions options) {
              capturedOptions = options;
              return map;
            })
            ..init();

          expect(capturedOptions, isNotNull);
          expect(capturedOptions!.zoom, 12);
          expect(capturedOptions!.center, isNotNull);
        });

        testWidgets('translates style option', (WidgetTester tester) async {
          gmaps.MapOptions? capturedOptions;
          const String style = '''
[{
  "featureType": "poi.park",
  "elementType": "labels.text.fill",
  "stylers": [{"color": "#6b9a76"}]
}]''';
          controller = createController(
              mapConfiguration: const MapConfiguration(style: style));
          controller.debugSetOverrides(
              createMap: (_, gmaps.MapOptions options) {
            capturedOptions = options;
            return map;
          });

          controller.init();

          expect(capturedOptions, isNotNull);
          expect(capturedOptions!.styles?.length, 1);
        });

        testWidgets('stores style errors for later querying',
            (WidgetTester tester) async {
          gmaps.MapOptions? capturedOptions;
          controller = createController(
              mapConfiguration: const MapConfiguration(
                  style: '[[invalid style', zoomControlsEnabled: true));
          controller.debugSetOverrides(
              createMap: (_, gmaps.MapOptions options) {
            capturedOptions = options;
            return map;
          });

          controller.init();

          expect(controller.lastStyleError, isNotNull);
          // Style failures should not prevent other options from being set.
          expect(capturedOptions, isNotNull);
          expect(capturedOptions!.zoomControl, true);
        });

        testWidgets('setting invalid style leaves previous style',
            (WidgetTester tester) async {
          gmaps.MapOptions? initialCapturedOptions;
          gmaps.MapOptions? updatedCapturedOptions;
          const String style = '''
[{
  "featureType": "poi.park",
  "elementType": "labels.text.fill",
  "stylers": [{"color": "#6b9a76"}]
}]''';
          controller = createController(
              mapConfiguration: const MapConfiguration(style: style));
          controller.debugSetOverrides(
            createMap: (_, gmaps.MapOptions options) {
              initialCapturedOptions = options;
              return map;
            },
            setOptions: (gmaps.MapOptions options) {
              updatedCapturedOptions = options;
            },
          );

          controller.init();
          controller.updateMapConfiguration(
              const MapConfiguration(style: '[[invalid style'));

          expect(initialCapturedOptions, isNotNull);
          expect(initialCapturedOptions!.styles?.length, 1);
          // The styles should not have changed.
          expect(
              updatedCapturedOptions!.styles, initialCapturedOptions!.styles);
        });
      });

      group('Traffic Layer', () {
        testWidgets('by default is disabled', (WidgetTester tester) async {
          controller = createController()..init();
          expect(controller.trafficLayer, isNull);
        });

        testWidgets('initializes with traffic layer',
            (WidgetTester tester) async {
          controller = createController(
              mapConfiguration: const MapConfiguration(
            trafficEnabled: true,
          ))
            ..debugSetOverrides(createMap: (_, __) => map)
            ..init();
          expect(controller.trafficLayer, isNotNull);
        });
      });
    });

    // These are the methods that are delegated to the gmaps.Map object, that we can mock...
    group('Map control methods', () {
      late gmaps.Map map;

      setUp(() {
        map = gmaps.Map(
          createDivElement(),
          gmaps.MapOptions()
            ..zoom = 10
            ..center = gmaps.LatLng(0, 0),
        );
        controller = createController()
          ..debugSetOverrides(createMap: (_, __) => map)
          ..init();
      });

      group('updateMapConfiguration', () {
        testWidgets('can update `options`', (WidgetTester tester) async {
          controller.updateMapConfiguration(const MapConfiguration(
            mapType: MapType.satellite,
          ));

          expect(map.mapTypeId, gmaps.MapTypeId.SATELLITE);
        });

        testWidgets('can turn on/off traffic', (WidgetTester tester) async {
          expect(controller.trafficLayer, isNull);

          controller.updateMapConfiguration(const MapConfiguration(
            trafficEnabled: true,
          ));

          expect(controller.trafficLayer, isNotNull);

          controller.updateMapConfiguration(const MapConfiguration(
            trafficEnabled: false,
          ));

          expect(controller.trafficLayer, isNull);
        });

        testWidgets('can update style', (WidgetTester tester) async {
          const String style = '''
[{
  "featureType": "poi.park",
  "elementType": "labels.text.fill",
  "stylers": [{"color": "#6b9a76"}]
}]''';
          controller
              .updateMapConfiguration(const MapConfiguration(style: style));

          expect(controller.styles.length, 1);
        });

        testWidgets('can update style', (WidgetTester tester) async {
          controller.updateMapConfiguration(
              const MapConfiguration(style: '[[[invalid style'));

          expect(controller.styles, isEmpty);
          expect(controller.lastStyleError, isNotNull);
        });
      });

      group('viewport getters', () {
        testWidgets('getVisibleRegion', (WidgetTester tester) async {
          final gmaps.LatLng gmCenter = map.center;
          final LatLng center =
              LatLng(gmCenter.lat.toDouble(), gmCenter.lng.toDouble());

          final LatLngBounds bounds = await controller.getVisibleRegion();

          expect(bounds.contains(center), isTrue,
              reason:
                  'The computed visible region must contain the center of the created map.');
        });

        testWidgets('getZoomLevel', (WidgetTester tester) async {
          expect(await controller.getZoomLevel(), map.zoom);
        });
      });

      group('moveCamera', () {
        // Tested in projection_test.dart
      });

      group('map.projection methods', () {
        // Tested in projection_test.dart
      });
    });

    // These are the methods that get forwarded to other controllers, so we just verify calls.
    group('Pass-through methods', () {
      testWidgets('updateCircles', (WidgetTester tester) async {
        final MockCirclesController mock = MockCirclesController();
        controller = createController()..debugSetOverrides(circles: mock);

        final Set<Circle> previous = <Circle>{
          const Circle(circleId: CircleId('to-be-updated')),
          const Circle(circleId: CircleId('to-be-removed')),
        };

        final Set<Circle> current = <Circle>{
          const Circle(circleId: CircleId('to-be-updated'), visible: false),
          const Circle(circleId: CircleId('to-be-added')),
        };

        controller.updateCircles(CircleUpdates.from(previous, current));

        verify(mock.removeCircles(<CircleId>{
          const CircleId('to-be-removed'),
        }));
        verify(mock.addCircles(<Circle>{
          const Circle(circleId: CircleId('to-be-added')),
        }));
        verify(mock.changeCircles(<Circle>{
          const Circle(circleId: CircleId('to-be-updated'), visible: false),
        }));
      });

      testWidgets('updateHeatmaps', (WidgetTester tester) async {
        final MockHeatmapsController mock = MockHeatmapsController();
        controller.debugSetOverrides(heatmaps: mock);

        const List<WeightedLatLng> heatmapPoints = <WeightedLatLng>[
          WeightedLatLng(LatLng(37.782, -122.447)),
          WeightedLatLng(LatLng(37.782, -122.445)),
          WeightedLatLng(LatLng(37.782, -122.443)),
          WeightedLatLng(LatLng(37.782, -122.441)),
          WeightedLatLng(LatLng(37.782, -122.439)),
          WeightedLatLng(LatLng(37.782, -122.437)),
          WeightedLatLng(LatLng(37.782, -122.435)),
          WeightedLatLng(LatLng(37.785, -122.447)),
          WeightedLatLng(LatLng(37.785, -122.445)),
          WeightedLatLng(LatLng(37.785, -122.443)),
          WeightedLatLng(LatLng(37.785, -122.441)),
          WeightedLatLng(LatLng(37.785, -122.439)),
          WeightedLatLng(LatLng(37.785, -122.437)),
          WeightedLatLng(LatLng(37.785, -122.435))
        ];

        final Set<Heatmap> previous = <Heatmap>{
          const Heatmap(
            heatmapId: HeatmapId('to-be-updated'),
            data: heatmapPoints,
            radius: HeatmapRadius.fromPixels(20),
          ),
          const Heatmap(
            heatmapId: HeatmapId('to-be-removed'),
            data: heatmapPoints,
            radius: HeatmapRadius.fromPixels(20),
          ),
        };

        final Set<Heatmap> current = <Heatmap>{
          const Heatmap(
            heatmapId: HeatmapId('to-be-updated'),
            data: heatmapPoints,
            dissipating: false,
            radius: HeatmapRadius.fromPixels(20),
          ),
          const Heatmap(
            heatmapId: HeatmapId('to-be-added'),
            data: heatmapPoints,
            radius: HeatmapRadius.fromPixels(20),
          ),
        };

        controller.updateHeatmaps(HeatmapUpdates.from(previous, current));

        verify(mock.removeHeatmaps(<HeatmapId>{
          const HeatmapId('to-be-removed'),
        }));
        verify(mock.addHeatmaps(<Heatmap>{
          const Heatmap(
            heatmapId: HeatmapId('to-be-added'),
            data: heatmapPoints,
            radius: HeatmapRadius.fromPixels(20),
          ),
        }));
        verify(mock.changeHeatmaps(<Heatmap>{
          const Heatmap(
            heatmapId: HeatmapId('to-be-updated'),
            data: heatmapPoints,
            dissipating: false,
            radius: HeatmapRadius.fromPixels(20),
          ),
        }));
      });

      testWidgets('updateMarkers', (WidgetTester tester) async {
        final MockMarkersController mock = MockMarkersController();
        controller = createController()..debugSetOverrides(markers: mock);

        final Set<Marker> previous = <Marker>{
          const Marker(markerId: MarkerId('to-be-updated')),
          const Marker(markerId: MarkerId('to-be-removed')),
        };

        final Set<Marker> current = <Marker>{
          const Marker(markerId: MarkerId('to-be-updated'), visible: false),
          const Marker(markerId: MarkerId('to-be-added')),
        };

        await controller.updateMarkers(MarkerUpdates.from(previous, current));

        verify(mock.removeMarkers(<MarkerId>{
          const MarkerId('to-be-removed'),
        }));
        verify(mock.addMarkers(<Marker>{
          const Marker(markerId: MarkerId('to-be-added')),
        }));
        verify(mock.changeMarkers(<Marker>{
          const Marker(markerId: MarkerId('to-be-updated'), visible: false),
        }));
      });

      testWidgets('updatePolygons', (WidgetTester tester) async {
        final MockPolygonsController mock = MockPolygonsController();
        controller = createController()..debugSetOverrides(polygons: mock);

        final Set<Polygon> previous = <Polygon>{
          const Polygon(polygonId: PolygonId('to-be-updated')),
          const Polygon(polygonId: PolygonId('to-be-removed')),
        };

        final Set<Polygon> current = <Polygon>{
          const Polygon(polygonId: PolygonId('to-be-updated'), visible: false),
          const Polygon(polygonId: PolygonId('to-be-added')),
        };

        controller.updatePolygons(PolygonUpdates.from(previous, current));

        verify(mock.removePolygons(<PolygonId>{
          const PolygonId('to-be-removed'),
        }));
        verify(mock.addPolygons(<Polygon>{
          const Polygon(polygonId: PolygonId('to-be-added')),
        }));
        verify(mock.changePolygons(<Polygon>{
          const Polygon(polygonId: PolygonId('to-be-updated'), visible: false),
        }));
      });

      testWidgets('updatePolylines', (WidgetTester tester) async {
        final MockPolylinesController mock = MockPolylinesController();
        controller = createController()..debugSetOverrides(polylines: mock);

        final Set<Polyline> previous = <Polyline>{
          const Polyline(polylineId: PolylineId('to-be-updated')),
          const Polyline(polylineId: PolylineId('to-be-removed')),
        };

        final Set<Polyline> current = <Polyline>{
          const Polyline(
            polylineId: PolylineId('to-be-updated'),
            visible: false,
          ),
          const Polyline(polylineId: PolylineId('to-be-added')),
        };

        controller.updatePolylines(PolylineUpdates.from(previous, current));

        verify(mock.removePolylines(<PolylineId>{
          const PolylineId('to-be-removed'),
        }));
        verify(mock.addPolylines(<Polyline>{
          const Polyline(polylineId: PolylineId('to-be-added')),
        }));
        verify(mock.changePolylines(<Polyline>{
          const Polyline(
            polylineId: PolylineId('to-be-updated'),
            visible: false,
          ),
        }));
      });

      testWidgets('updateTileOverlays', (WidgetTester tester) async {
        final MockTileOverlaysController mock = MockTileOverlaysController();
        controller = createController(
            mapObjects: MapObjects(tileOverlays: <TileOverlay>{
          const TileOverlay(tileOverlayId: TileOverlayId('to-be-updated')),
          const TileOverlay(tileOverlayId: TileOverlayId('to-be-removed')),
        }))
          ..debugSetOverrides(tileOverlays: mock);

        controller.updateTileOverlays(<TileOverlay>{
          const TileOverlay(
              tileOverlayId: TileOverlayId('to-be-updated'), visible: false),
          const TileOverlay(tileOverlayId: TileOverlayId('to-be-added')),
        });

        verify(mock.removeTileOverlays(<TileOverlayId>{
          const TileOverlayId('to-be-removed'),
        }));
        verify(mock.addTileOverlays(<TileOverlay>{
          const TileOverlay(tileOverlayId: TileOverlayId('to-be-added')),
        }));
        verify(mock.changeTileOverlays(<TileOverlay>{
          const TileOverlay(
              tileOverlayId: TileOverlayId('to-be-updated'), visible: false),
        }));
      });

      testWidgets('infoWindow visibility', (WidgetTester tester) async {
        final MockMarkersController mock = MockMarkersController();
        const MarkerId markerId = MarkerId('marker-with-infowindow');
        when(mock.isInfoWindowShown(markerId)).thenReturn(true);
        controller = createController()..debugSetOverrides(markers: mock);

        controller.showInfoWindow(markerId);

        verify(mock.showMarkerInfoWindow(markerId));

        controller.hideInfoWindow(markerId);

        verify(mock.hideMarkerInfoWindow(markerId));

        controller.isInfoWindowShown(markerId);

        verify(mock.isInfoWindowShown(markerId));
      });
    });
  });
}
