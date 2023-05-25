// Mocks generated by Mockito 5.4.0 from annotations
// in google_maps_flutter_web_integration_tests/integration_test/google_maps_plugin_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:google_maps/google_maps.dart' as _i5;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart'
    as _i2;
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart' as _i4;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeMapConfiguration_0 extends _i1.SmartFake
    implements _i2.MapConfiguration {
  _FakeMapConfiguration_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeStreamController_1<T> extends _i1.SmartFake
    implements _i3.StreamController<T> {
  _FakeStreamController_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeLatLngBounds_2 extends _i1.SmartFake implements _i2.LatLngBounds {
  _FakeLatLngBounds_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeScreenCoordinate_3 extends _i1.SmartFake
    implements _i2.ScreenCoordinate {
  _FakeScreenCoordinate_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeLatLng_4 extends _i1.SmartFake implements _i2.LatLng {
  _FakeLatLng_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [GoogleMapController].
///
/// See the documentation for Mockito's code generation for more information.
class MockGoogleMapController extends _i1.Mock
    implements _i4.GoogleMapController {
  @override
  _i2.MapConfiguration get configuration => (super.noSuchMethod(
        Invocation.getter(#configuration),
        returnValue: _FakeMapConfiguration_0(
          this,
          Invocation.getter(#configuration),
        ),
        returnValueForMissingStub: _FakeMapConfiguration_0(
          this,
          Invocation.getter(#configuration),
        ),
      ) as _i2.MapConfiguration);
  @override
  _i3.StreamController<_i2.MapEvent<Object?>> get stream => (super.noSuchMethod(
        Invocation.getter(#stream),
        returnValue: _FakeStreamController_1<_i2.MapEvent<Object?>>(
          this,
          Invocation.getter(#stream),
        ),
        returnValueForMissingStub:
            _FakeStreamController_1<_i2.MapEvent<Object?>>(
          this,
          Invocation.getter(#stream),
        ),
      ) as _i3.StreamController<_i2.MapEvent<Object?>>);
  @override
  _i3.Stream<_i2.MapEvent<Object?>> get events => (super.noSuchMethod(
        Invocation.getter(#events),
        returnValue: _i3.Stream<_i2.MapEvent<Object?>>.empty(),
        returnValueForMissingStub: _i3.Stream<_i2.MapEvent<Object?>>.empty(),
      ) as _i3.Stream<_i2.MapEvent<Object?>>);
  @override
  bool get isInitialized => (super.noSuchMethod(
        Invocation.getter(#isInitialized),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);
  @override
  void debugSetOverrides({
    _i4.DebugCreateMapFunction? createMap,
    _i4.MarkersController? markers,
    _i4.CirclesController? circles,
    _i4.PolygonsController? polygons,
    _i4.PolylinesController? polylines,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #debugSetOverrides,
          [],
          {
            #createMap: createMap,
            #markers: markers,
            #circles: circles,
            #polygons: polygons,
            #polylines: polylines,
          },
        ),
        returnValueForMissingStub: null,
      );
  @override
  void init() => super.noSuchMethod(
        Invocation.method(
          #init,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void updateMapConfiguration(_i2.MapConfiguration? update) =>
      super.noSuchMethod(
        Invocation.method(
          #updateMapConfiguration,
          [update],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void updateStyles(List<_i5.MapTypeStyle>? styles) => super.noSuchMethod(
        Invocation.method(
          #updateStyles,
          [styles],
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i3.Future<_i2.LatLngBounds> getVisibleRegion() => (super.noSuchMethod(
        Invocation.method(
          #getVisibleRegion,
          [],
        ),
        returnValue: _i3.Future<_i2.LatLngBounds>.value(_FakeLatLngBounds_2(
          this,
          Invocation.method(
            #getVisibleRegion,
            [],
          ),
        )),
        returnValueForMissingStub:
            _i3.Future<_i2.LatLngBounds>.value(_FakeLatLngBounds_2(
          this,
          Invocation.method(
            #getVisibleRegion,
            [],
          ),
        )),
      ) as _i3.Future<_i2.LatLngBounds>);
  @override
  _i3.Future<_i2.ScreenCoordinate> getScreenCoordinate(_i2.LatLng? latLng) =>
      (super.noSuchMethod(
        Invocation.method(
          #getScreenCoordinate,
          [latLng],
        ),
        returnValue:
            _i3.Future<_i2.ScreenCoordinate>.value(_FakeScreenCoordinate_3(
          this,
          Invocation.method(
            #getScreenCoordinate,
            [latLng],
          ),
        )),
        returnValueForMissingStub:
            _i3.Future<_i2.ScreenCoordinate>.value(_FakeScreenCoordinate_3(
          this,
          Invocation.method(
            #getScreenCoordinate,
            [latLng],
          ),
        )),
      ) as _i3.Future<_i2.ScreenCoordinate>);
  @override
  _i3.Future<_i2.LatLng> getLatLng(_i2.ScreenCoordinate? screenCoordinate) =>
      (super.noSuchMethod(
        Invocation.method(
          #getLatLng,
          [screenCoordinate],
        ),
        returnValue: _i3.Future<_i2.LatLng>.value(_FakeLatLng_4(
          this,
          Invocation.method(
            #getLatLng,
            [screenCoordinate],
          ),
        )),
        returnValueForMissingStub: _i3.Future<_i2.LatLng>.value(_FakeLatLng_4(
          this,
          Invocation.method(
            #getLatLng,
            [screenCoordinate],
          ),
        )),
      ) as _i3.Future<_i2.LatLng>);
  @override
  _i3.Future<void> moveCamera(_i2.CameraUpdate? cameraUpdate) =>
      (super.noSuchMethod(
        Invocation.method(
          #moveCamera,
          [cameraUpdate],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Future<double> getZoomLevel() => (super.noSuchMethod(
        Invocation.method(
          #getZoomLevel,
          [],
        ),
        returnValue: _i3.Future<double>.value(0.0),
        returnValueForMissingStub: _i3.Future<double>.value(0.0),
      ) as _i3.Future<double>);
  @override
  void updateCircles(_i2.CircleUpdates? updates) => super.noSuchMethod(
        Invocation.method(
          #updateCircles,
          [updates],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void updatePolygons(_i2.PolygonUpdates? updates) => super.noSuchMethod(
        Invocation.method(
          #updatePolygons,
          [updates],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void updatePolylines(_i2.PolylineUpdates? updates) => super.noSuchMethod(
        Invocation.method(
          #updatePolylines,
          [updates],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void updateMarkers(_i2.MarkerUpdates? updates) => super.noSuchMethod(
        Invocation.method(
          #updateMarkers,
          [updates],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void showInfoWindow(_i2.MarkerId? markerId) => super.noSuchMethod(
        Invocation.method(
          #showInfoWindow,
          [markerId],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void hideInfoWindow(_i2.MarkerId? markerId) => super.noSuchMethod(
        Invocation.method(
          #hideInfoWindow,
          [markerId],
        ),
        returnValueForMissingStub: null,
      );
  @override
  bool isInfoWindowShown(_i2.MarkerId? markerId) => (super.noSuchMethod(
        Invocation.method(
          #isInfoWindowShown,
          [markerId],
        ),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);
  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );
}
