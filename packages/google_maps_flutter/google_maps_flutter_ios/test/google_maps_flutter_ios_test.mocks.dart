// Mocks generated by Mockito 5.4.4 from annotations
// in google_maps_flutter_ios/test/google_maps_flutter_ios_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;
import 'dart:typed_data' as _i5;

import 'package:google_maps_flutter_ios/src/messages.g.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakePlatformPoint_0 extends _i1.SmartFake implements _i2.PlatformPoint {
  _FakePlatformPoint_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakePlatformLatLng_1 extends _i1.SmartFake
    implements _i2.PlatformLatLng {
  _FakePlatformLatLng_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakePlatformLatLngBounds_2 extends _i1.SmartFake
    implements _i2.PlatformLatLngBounds {
  _FakePlatformLatLngBounds_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [MapsApi].
///
/// See the documentation for Mockito's code generation for more information.
class MockMapsApi extends _i1.Mock implements _i2.MapsApi {
  @override
  String get pigeonVar_messageChannelSuffix => (super.noSuchMethod(
        Invocation.getter(#pigeonVar_messageChannelSuffix),
        returnValue: _i3.dummyValue<String>(
          this,
          Invocation.getter(#pigeonVar_messageChannelSuffix),
        ),
        returnValueForMissingStub: _i3.dummyValue<String>(
          this,
          Invocation.getter(#pigeonVar_messageChannelSuffix),
        ),
      ) as String);

  @override
  _i4.Future<void> waitForMap() => (super.noSuchMethod(
        Invocation.method(
          #waitForMap,
          [],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> updateMapConfiguration(
          _i2.PlatformMapConfiguration? configuration) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateMapConfiguration,
          [configuration],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> updateCircles(
    List<_i2.PlatformCircle>? toAdd,
    List<_i2.PlatformCircle>? toChange,
    List<String>? idsToRemove,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateCircles,
          [
            toAdd,
            toChange,
            idsToRemove,
          ],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> updateHeatmaps(
    List<_i2.PlatformHeatmap>? toAdd,
    List<_i2.PlatformHeatmap>? toChange,
    List<String>? idsToRemove,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateHeatmaps,
          [
            toAdd,
            toChange,
            idsToRemove,
          ],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> updateClusterManagers(
    List<_i2.PlatformClusterManager>? toAdd,
    List<String>? idsToRemove,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateClusterManagers,
          [
            toAdd,
            idsToRemove,
          ],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> updateMarkers(
    List<_i2.PlatformMarker>? toAdd,
    List<_i2.PlatformMarker>? toChange,
    List<String>? idsToRemove,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateMarkers,
          [
            toAdd,
            toChange,
            idsToRemove,
          ],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> updatePolygons(
    List<_i2.PlatformPolygon>? toAdd,
    List<_i2.PlatformPolygon>? toChange,
    List<String>? idsToRemove,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updatePolygons,
          [
            toAdd,
            toChange,
            idsToRemove,
          ],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> updatePolylines(
    List<_i2.PlatformPolyline>? toAdd,
    List<_i2.PlatformPolyline>? toChange,
    List<String>? idsToRemove,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updatePolylines,
          [
            toAdd,
            toChange,
            idsToRemove,
          ],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> updateTileOverlays(
    List<_i2.PlatformTileOverlay>? toAdd,
    List<_i2.PlatformTileOverlay>? toChange,
    List<String>? idsToRemove,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateTileOverlays,
          [
            toAdd,
            toChange,
            idsToRemove,
          ],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<_i2.PlatformPoint> getScreenCoordinate(
          _i2.PlatformLatLng? latLng) =>
      (super.noSuchMethod(
        Invocation.method(
          #getScreenCoordinate,
          [latLng],
        ),
        returnValue: _i4.Future<_i2.PlatformPoint>.value(_FakePlatformPoint_0(
          this,
          Invocation.method(
            #getScreenCoordinate,
            [latLng],
          ),
        )),
        returnValueForMissingStub:
            _i4.Future<_i2.PlatformPoint>.value(_FakePlatformPoint_0(
          this,
          Invocation.method(
            #getScreenCoordinate,
            [latLng],
          ),
        )),
      ) as _i4.Future<_i2.PlatformPoint>);

  @override
  _i4.Future<_i2.PlatformLatLng> getLatLng(
          _i2.PlatformPoint? screenCoordinate) =>
      (super.noSuchMethod(
        Invocation.method(
          #getLatLng,
          [screenCoordinate],
        ),
        returnValue: _i4.Future<_i2.PlatformLatLng>.value(_FakePlatformLatLng_1(
          this,
          Invocation.method(
            #getLatLng,
            [screenCoordinate],
          ),
        )),
        returnValueForMissingStub:
            _i4.Future<_i2.PlatformLatLng>.value(_FakePlatformLatLng_1(
          this,
          Invocation.method(
            #getLatLng,
            [screenCoordinate],
          ),
        )),
      ) as _i4.Future<_i2.PlatformLatLng>);

  @override
  _i4.Future<_i2.PlatformLatLngBounds> getVisibleRegion() =>
      (super.noSuchMethod(
        Invocation.method(
          #getVisibleRegion,
          [],
        ),
        returnValue: _i4.Future<_i2.PlatformLatLngBounds>.value(
            _FakePlatformLatLngBounds_2(
          this,
          Invocation.method(
            #getVisibleRegion,
            [],
          ),
        )),
        returnValueForMissingStub: _i4.Future<_i2.PlatformLatLngBounds>.value(
            _FakePlatformLatLngBounds_2(
          this,
          Invocation.method(
            #getVisibleRegion,
            [],
          ),
        )),
      ) as _i4.Future<_i2.PlatformLatLngBounds>);

  @override
  _i4.Future<void> moveCamera(_i2.PlatformCameraUpdate? cameraUpdate) =>
      (super.noSuchMethod(
        Invocation.method(
          #moveCamera,
          [cameraUpdate],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> animateCamera(_i2.PlatformCameraUpdate? cameraUpdate) =>
      (super.noSuchMethod(
        Invocation.method(
          #animateCamera,
          [cameraUpdate],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<double> getZoomLevel() => (super.noSuchMethod(
        Invocation.method(
          #getZoomLevel,
          [],
        ),
        returnValue: _i4.Future<double>.value(0.0),
        returnValueForMissingStub: _i4.Future<double>.value(0.0),
      ) as _i4.Future<double>);

  @override
  _i4.Future<void> showInfoWindow(String? markerId) => (super.noSuchMethod(
        Invocation.method(
          #showInfoWindow,
          [markerId],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> hideInfoWindow(String? markerId) => (super.noSuchMethod(
        Invocation.method(
          #hideInfoWindow,
          [markerId],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<bool> isInfoWindowShown(String? markerId) => (super.noSuchMethod(
        Invocation.method(
          #isInfoWindowShown,
          [markerId],
        ),
        returnValue: _i4.Future<bool>.value(false),
        returnValueForMissingStub: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  _i4.Future<String?> setStyle(String? style) => (super.noSuchMethod(
        Invocation.method(
          #setStyle,
          [style],
        ),
        returnValue: _i4.Future<String?>.value(),
        returnValueForMissingStub: _i4.Future<String?>.value(),
      ) as _i4.Future<String?>);

  @override
  _i4.Future<String?> getLastStyleError() => (super.noSuchMethod(
        Invocation.method(
          #getLastStyleError,
          [],
        ),
        returnValue: _i4.Future<String?>.value(),
        returnValueForMissingStub: _i4.Future<String?>.value(),
      ) as _i4.Future<String?>);

  @override
  _i4.Future<void> clearTileCache(String? tileOverlayId) => (super.noSuchMethod(
        Invocation.method(
          #clearTileCache,
          [tileOverlayId],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<_i5.Uint8List?> takeSnapshot() => (super.noSuchMethod(
        Invocation.method(
          #takeSnapshot,
          [],
        ),
        returnValue: _i4.Future<_i5.Uint8List?>.value(),
        returnValueForMissingStub: _i4.Future<_i5.Uint8List?>.value(),
      ) as _i4.Future<_i5.Uint8List?>);
}
