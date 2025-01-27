// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Store the initial instance before any tests change it.
  final GoogleMapsFlutterPlatform initialInstance =
      GoogleMapsFlutterPlatform.instance;

  group('$GoogleMapsFlutterPlatform', () {
    test('$MethodChannelGoogleMapsFlutter() is the default instance', () {
      expect(initialInstance, isInstanceOf<MethodChannelGoogleMapsFlutter>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        GoogleMapsFlutterPlatform.instance =
            ImplementsGoogleMapsFlutterPlatform();
        // In versions of `package:plugin_platform_interface` prior to fixing
        // https://github.com/flutter/flutter/issues/109339, an attempt to
        // implement a platform interface using `implements` would sometimes
        // throw a `NoSuchMethodError` and other times throw an
        // `AssertionError`.  After the issue is fixed, an `AssertionError` will
        // always be thrown.  For the purpose of this test, we don't really care
        // what exception is thrown, so just allow any exception.
      }, throwsA(anything));
    });

    test('Can be mocked with `implements`', () {
      final GoogleMapsFlutterPlatformMock mock =
          GoogleMapsFlutterPlatformMock();
      GoogleMapsFlutterPlatform.instance = mock;
    });

    test('Can be extended', () {
      GoogleMapsFlutterPlatform.instance = ExtendsGoogleMapsFlutterPlatform();
    });

    test(
      'default implementation of `buildViewWithTextDirection` delegates to `buildView`',
      () {
        final GoogleMapsFlutterPlatform platform =
            BuildViewGoogleMapsFlutterPlatform();
        expect(
          platform.buildViewWithTextDirection(
            0,
            (_) {},
            initialCameraPosition:
                const CameraPosition(target: LatLng(0.0, 0.0)),
            textDirection: TextDirection.ltr,
          ),
          isA<Text>(),
        );
      },
    );

    test(
      'default implementation of `buildViewWithConfiguration` delegates to `buildViewWithTextDirection`',
      () {
        final GoogleMapsFlutterPlatform platform =
            BuildViewGoogleMapsFlutterPlatform();
        expect(
          platform.buildViewWithConfiguration(
            0,
            (_) {},
            widgetConfiguration: const MapWidgetConfiguration(
              initialCameraPosition: CameraPosition(target: LatLng(0.0, 0.0)),
              textDirection: TextDirection.ltr,
            ),
          ),
          isA<Text>(),
        );
      },
    );

    test(
      'updateClusterManagers() throws UnimplementedError',
      () {
        expect(
            () => BuildViewGoogleMapsFlutterPlatform().updateClusterManagers(
                ClusterManagerUpdates.from(
                  <ClusterManager>{
                    const ClusterManager(
                        clusterManagerId: ClusterManagerId('123'))
                  },
                  <ClusterManager>{
                    const ClusterManager(
                        clusterManagerId: ClusterManagerId('456'))
                  },
                ),
                mapId: 0),
            throwsUnimplementedError);
      },
    );

    test(
      'onClusterTap() throws UnimplementedError',
      () {
        expect(
            () => BuildViewGoogleMapsFlutterPlatform().onClusterTap(mapId: 0),
            throwsUnimplementedError);
      },
    );

    test(
      'default implementation of `getStyleError` returns null',
      () async {
        final GoogleMapsFlutterPlatform platform =
            BuildViewGoogleMapsFlutterPlatform();
        expect(await platform.getStyleError(mapId: 0), null);
      },
    );
  });
}

class GoogleMapsFlutterPlatformMock extends Mock
    with MockPlatformInterfaceMixin
    implements GoogleMapsFlutterPlatform {}

class ImplementsGoogleMapsFlutterPlatform extends Mock
    implements GoogleMapsFlutterPlatform {}

class ExtendsGoogleMapsFlutterPlatform extends GoogleMapsFlutterPlatform {}

class BuildViewGoogleMapsFlutterPlatform extends GoogleMapsFlutterPlatform {
  @override
  Widget buildView(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required CameraPosition initialCameraPosition,
    Set<Marker> markers = const <Marker>{},
    Set<Polygon> polygons = const <Polygon>{},
    Set<Polyline> polylines = const <Polyline>{},
    Set<Circle> circles = const <Circle>{},
    Set<TileOverlay> tileOverlays = const <TileOverlay>{},
    Set<ClusterManager> clusterManagers = const <ClusterManager>{},
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers =
        const <Factory<OneSequenceGestureRecognizer>>{},
    Map<String, dynamic> mapOptions = const <String, dynamic>{},
  }) {
    return const Text('');
  }
}
