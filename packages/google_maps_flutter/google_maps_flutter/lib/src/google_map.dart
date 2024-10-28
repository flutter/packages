// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../google_maps_flutter.dart';

/// Callback method for when the map is ready to be used.
///
/// Pass to [GoogleMap.onMapCreated] to receive a [GoogleMapController] when the
/// map is created.
typedef MapCreatedCallback = void Function(GoogleMapController controller);

// This counter is used to provide a stable "constant" initialization id
// to the buildView function, so the web implementation can use it as a
// cache key. This needs to be provided from the outside, because web
// views seem to re-render much more often that mobile platform views.
int _nextMapCreationId = 0;

/// Error thrown when an unknown map object ID is provided to a method.
class UnknownMapObjectIdError extends Error {
  /// Creates an assertion error with the provided [message].
  UnknownMapObjectIdError(this.objectType, this.objectId, [this.context]);

  /// The name of the map object whose ID is unknown.
  final String objectType;

  /// The unknown maps object ID.
  final MapsObjectId<Object> objectId;

  /// The context where the error occurred.
  final String? context;

  @override
  String toString() {
    if (context != null) {
      return 'Unknown $objectType ID "${objectId.value}" in $context';
    }
    return 'Unknown $objectType ID "${objectId.value}"';
  }
}

/// Android specific settings for [GoogleMap].
@Deprecated(
    'See https://pub.dev/packages/google_maps_flutter_android#display-mode')
class AndroidGoogleMapsFlutter {
  @Deprecated(
      'See https://pub.dev/packages/google_maps_flutter_android#display-mode')
  AndroidGoogleMapsFlutter._();

  /// Whether to render [GoogleMap] with a [AndroidViewSurface] to build the Google Maps widget.
  ///
  /// This implementation uses hybrid composition to render the Google Maps
  /// Widget on Android. This comes at the cost of some performance on Android
  /// versions below 10. See
  /// https://docs.flutter.dev/platform-integration/android/platform-views#performance for more
  /// information.
  @Deprecated(
      'See https://pub.dev/packages/google_maps_flutter_android#display-mode')
  static bool get useAndroidViewSurface {
    final GoogleMapsFlutterPlatform platform =
        GoogleMapsFlutterPlatform.instance;
    if (platform is GoogleMapsFlutterAndroid) {
      return platform.useAndroidViewSurface;
    }
    return false;
  }

  /// Set whether to render [GoogleMap] with a [AndroidViewSurface] to build the Google Maps widget.
  ///
  /// This implementation uses hybrid composition to render the Google Maps
  /// Widget on Android. This comes at the cost of some performance on Android
  /// versions below 10. See
  /// https://docs.flutter.dev/platform-integration/android/platform-views#performance for more
  /// information.
  @Deprecated(
      'See https://pub.dev/packages/google_maps_flutter_android#display-mode')
  static set useAndroidViewSurface(bool useAndroidViewSurface) {
    final GoogleMapsFlutterPlatform platform =
        GoogleMapsFlutterPlatform.instance;
    if (platform is GoogleMapsFlutterAndroid) {
      platform.useAndroidViewSurface = useAndroidViewSurface;
    }
  }
}

/// A widget which displays a map with data obtained from the Google Maps service.
class GoogleMap extends StatefulWidget {
  /// Creates a widget displaying data from Google Maps services.
  ///
  /// [AssertionError] will be thrown if [initialCameraPosition] is null;
  const GoogleMap({
    super.key,
    required this.initialCameraPosition,
    this.style,
    this.onMapCreated,
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
    this.webGestureHandling,
    this.compassEnabled = true,
    this.mapToolbarEnabled = true,
    this.cameraTargetBounds = CameraTargetBounds.unbounded,
    this.mapType = MapType.normal,
    this.minMaxZoomPreference = MinMaxZoomPreference.unbounded,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.zoomControlsEnabled = true,
    this.zoomGesturesEnabled = true,
    this.liteModeEnabled = false,
    this.tiltGesturesEnabled = true,
    this.fortyFiveDegreeImageryEnabled = false,
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = true,
    this.layoutDirection,

    /// If no padding is specified default padding will be 0.
    this.padding = EdgeInsets.zero,
    this.indoorViewEnabled = false,
    this.trafficEnabled = false,
    this.buildingsEnabled = true,
    this.markers = const <Marker>{},
    this.polygons = const <Polygon>{},
    this.polylines = const <Polyline>{},
    this.circles = const <Circle>{},
    this.clusterManagers = const <ClusterManager>{},
    this.heatmaps = const <Heatmap>{},
    this.onCameraMoveStarted,
    this.tileOverlays = const <TileOverlay>{},
    this.onCameraMove,
    this.onCameraIdle,
    this.onTap,
    this.onLongPress,
    this.cloudMapId,
  });

  /// Callback method for when the map is ready to be used.
  ///
  /// Used to receive a [GoogleMapController] for this [GoogleMap].
  final MapCreatedCallback? onMapCreated;

  /// The initial position of the map's camera.
  final CameraPosition initialCameraPosition;

  /// The style for the map.
  ///
  /// Set to null to clear any previous custom styling.
  ///
  /// If problems were detected with the [mapStyle], including un-parsable
  /// styling JSON, unrecognized feature type, unrecognized element type, or
  /// invalid styler keys, the style is left unchanged, and the error can be
  /// retrieved with [GoogleMapController.getStyleError].
  ///
  /// The style string can be generated using the
  /// [map style tool](https://mapstyle.withgoogle.com/).
  final String? style;

  /// True if the map should show a compass when rotated.
  final bool compassEnabled;

  /// True if the map should show a toolbar when you interact with the map. Android only.
  final bool mapToolbarEnabled;

  /// Geographical bounding box for the camera target.
  final CameraTargetBounds cameraTargetBounds;

  /// Type of map tiles to be rendered.
  final MapType mapType;

  /// The layout direction to use for the embedded view.
  ///
  /// If this is null, the ambient [Directionality] is used instead. If there is
  /// no ambient [Directionality], [TextDirection.ltr] is used.
  final TextDirection? layoutDirection;

  /// Preferred bounds for the camera zoom level.
  ///
  /// Actual bounds depend on map data and device.
  final MinMaxZoomPreference minMaxZoomPreference;

  /// True if the map view should respond to rotate gestures.
  final bool rotateGesturesEnabled;

  /// True if the map view should respond to scroll gestures.
  final bool scrollGesturesEnabled;

  /// True if the map view should show zoom controls. This includes two buttons
  /// to zoom in and zoom out. The default value is to show zoom controls.
  ///
  /// This is only supported on Android. And this field is silently ignored on iOS.
  final bool zoomControlsEnabled;

  /// True if the map view should respond to zoom gestures.
  final bool zoomGesturesEnabled;

  /// True if the map view should be in lite mode. Android only.
  ///
  /// See https://developers.google.com/maps/documentation/android-sdk/lite#overview_of_lite_mode for more details.
  final bool liteModeEnabled;

  /// True if the map view should respond to tilt gestures.
  final bool tiltGesturesEnabled;

  /// True if 45 degree imagery should be enabled. Web only.
  final bool fortyFiveDegreeImageryEnabled;

  /// Padding to be set on map. See https://developers.google.com/maps/documentation/android-sdk/map#map_padding for more details.
  final EdgeInsets padding;

  /// Markers to be placed on the map.
  final Set<Marker> markers;

  /// Polygons to be placed on the map.
  final Set<Polygon> polygons;

  /// Polylines to be placed on the map.
  final Set<Polyline> polylines;

  /// Circles to be placed on the map.
  final Set<Circle> circles;

  /// Heatmaps to show on the map.
  final Set<Heatmap> heatmaps;

  /// Tile overlays to be placed on the map.
  final Set<TileOverlay> tileOverlays;

  /// Cluster Managers to be initialized for the map.
  final Set<ClusterManager> clusterManagers;

  /// Called when the camera starts moving.
  ///
  /// This can be initiated by the following:
  /// 1. Non-gesture animation initiated in response to user actions.
  ///    For example: zoom buttons, my location button, or marker clicks.
  /// 2. Programmatically initiated animation.
  /// 3. Camera motion initiated in response to user gestures on the map.
  ///    For example: pan, tilt, pinch to zoom, or rotate.
  final VoidCallback? onCameraMoveStarted;

  /// Called repeatedly as the camera continues to move after an
  /// onCameraMoveStarted call.
  ///
  /// This may be called as often as once every frame and should
  /// not perform expensive operations.
  final CameraPositionCallback? onCameraMove;

  /// Called when camera movement has ended, there are no pending
  /// animations and the user has stopped interacting with the map.
  final VoidCallback? onCameraIdle;

  /// Called every time a [GoogleMap] is tapped.
  final ArgumentCallback<LatLng>? onTap;

  /// Called every time a [GoogleMap] is long pressed.
  final ArgumentCallback<LatLng>? onLongPress;

  /// True if a "My Location" layer should be shown on the map.
  ///
  /// This layer includes a location indicator at the current device location,
  /// as well as a My Location button.
  /// * The indicator is a small blue dot if the device is stationary, or a
  /// chevron if the device is moving.
  /// * The My Location button animates to focus on the user's current location
  /// if the user's location is currently known.
  ///
  /// Enabling this feature requires adding location permissions to both native
  /// platforms of your app.
  /// * On Android add either
  /// `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />`
  /// or `<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />`
  /// to your `AndroidManifest.xml` file. `ACCESS_COARSE_LOCATION` returns a
  /// location with an accuracy approximately equivalent to a city block, while
  /// `ACCESS_FINE_LOCATION` returns as precise a location as possible, although
  /// it consumes more battery power. You will also need to request these
  /// permissions during run-time. If they are not granted, the My Location
  /// feature will fail silently.
  /// * On iOS add a `NSLocationWhenInUseUsageDescription` key to your
  /// `Info.plist` file. This will automatically prompt the user for permissions
  /// when the map tries to turn on the My Location layer.
  final bool myLocationEnabled;

  /// Enables or disables the my-location button.
  ///
  /// The my-location button causes the camera to move such that the user's
  /// location is in the center of the map. If the button is enabled, it is
  /// only shown when the my-location layer is enabled.
  ///
  /// By default, the my-location button is enabled (and hence shown when the
  /// my-location layer is enabled).
  ///
  /// See also:
  ///   * [myLocationEnabled] parameter.
  final bool myLocationButtonEnabled;

  /// Enables or disables the indoor view from the map
  final bool indoorViewEnabled;

  /// Enables or disables the traffic layer of the map
  final bool trafficEnabled;

  /// Enables or disables showing 3D buildings where available
  final bool buildingsEnabled;

  /// Which gestures should be consumed by the map.
  ///
  /// It is possible for other gesture recognizers to be competing with the map on pointer
  /// events, e.g if the map is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The map will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty, the map will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  /// This setting controls how the API handles gestures on the map. Web only.
  ///
  /// See [WebGestureHandling] for more details.
  final WebGestureHandling? webGestureHandling;

  /// Identifier that's associated with a specific cloud-based map style.
  ///
  /// See https://developers.google.com/maps/documentation/get-map-id
  /// for more details.
  final String? cloudMapId;

  /// Creates a [State] for this [GoogleMap].
  @override
  State createState() => _GoogleMapState();
}

class _GoogleMapState extends State<GoogleMap> {
  final int _mapId = _nextMapCreationId++;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  Map<PolygonId, Polygon> _polygons = <PolygonId, Polygon>{};
  Map<PolylineId, Polyline> _polylines = <PolylineId, Polyline>{};
  Map<CircleId, Circle> _circles = <CircleId, Circle>{};
  Map<ClusterManagerId, ClusterManager> _clusterManagers =
      <ClusterManagerId, ClusterManager>{};
  Map<HeatmapId, Heatmap> _heatmaps = <HeatmapId, Heatmap>{};
  late MapConfiguration _mapConfiguration;

  @override
  Widget build(BuildContext context) {
    return GoogleMapsFlutterPlatform.instance.buildViewWithConfiguration(
      _mapId,
      onPlatformViewCreated,
      widgetConfiguration: MapWidgetConfiguration(
        textDirection: widget.layoutDirection ??
            Directionality.maybeOf(context) ??
            TextDirection.ltr,
        initialCameraPosition: widget.initialCameraPosition,
        gestureRecognizers: widget.gestureRecognizers,
      ),
      mapObjects: MapObjects(
        markers: widget.markers,
        polygons: widget.polygons,
        polylines: widget.polylines,
        circles: widget.circles,
        clusterManagers: widget.clusterManagers,
        heatmaps: widget.heatmaps,
      ),
      mapConfiguration: _mapConfiguration,
    );
  }

  @override
  void initState() {
    super.initState();
    _mapConfiguration = _configurationFromMapWidget(widget);
    _clusterManagers = keyByClusterManagerId(widget.clusterManagers);
    _markers = keyByMarkerId(widget.markers);
    _polygons = keyByPolygonId(widget.polygons);
    _polylines = keyByPolylineId(widget.polylines);
    _circles = keyByCircleId(widget.circles);
    _heatmaps = keyByHeatmapId(widget.heatmaps);
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  Future<void> _disposeController() async {
    final GoogleMapController controller = await _controller.future;
    controller.dispose();
  }

  @override
  void didUpdateWidget(GoogleMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateOptions();
    _updateClusterManagers();
    _updateMarkers();
    _updatePolygons();
    _updatePolylines();
    _updateCircles();
    _updateHeatmaps();
    _updateTileOverlays();
  }

  Future<void> _updateOptions() async {
    final MapConfiguration newConfig = _configurationFromMapWidget(widget);
    final MapConfiguration updates = newConfig.diffFrom(_mapConfiguration);
    if (updates.isEmpty) {
      return;
    }
    final GoogleMapController controller = await _controller.future;
    unawaited(controller._updateMapConfiguration(updates));
    _mapConfiguration = newConfig;
  }

  Future<void> _updateMarkers() async {
    final GoogleMapController controller = await _controller.future;
    unawaited(controller._updateMarkers(
        MarkerUpdates.from(_markers.values.toSet(), widget.markers)));
    _markers = keyByMarkerId(widget.markers);
  }

  Future<void> _updateClusterManagers() async {
    final GoogleMapController controller = await _controller.future;
    unawaited(controller._updateClusterManagers(ClusterManagerUpdates.from(
        _clusterManagers.values.toSet(), widget.clusterManagers)));
    _clusterManagers = keyByClusterManagerId(widget.clusterManagers);
  }

  Future<void> _updatePolygons() async {
    final GoogleMapController controller = await _controller.future;
    unawaited(controller._updatePolygons(
        PolygonUpdates.from(_polygons.values.toSet(), widget.polygons)));
    _polygons = keyByPolygonId(widget.polygons);
  }

  Future<void> _updatePolylines() async {
    final GoogleMapController controller = await _controller.future;
    unawaited(controller._updatePolylines(
        PolylineUpdates.from(_polylines.values.toSet(), widget.polylines)));
    _polylines = keyByPolylineId(widget.polylines);
  }

  Future<void> _updateCircles() async {
    final GoogleMapController controller = await _controller.future;
    unawaited(controller._updateCircles(
        CircleUpdates.from(_circles.values.toSet(), widget.circles)));
    _circles = keyByCircleId(widget.circles);
  }

  Future<void> _updateHeatmaps() async {
    final GoogleMapController controller = await _controller.future;
    unawaited(
      controller._updateHeatmaps(
        HeatmapUpdates.from(_heatmaps.values.toSet(), widget.heatmaps),
      ),
    );
    _heatmaps = keyByHeatmapId(widget.heatmaps);
  }

  Future<void> _updateTileOverlays() async {
    final GoogleMapController controller = await _controller.future;
    unawaited(controller._updateTileOverlays(widget.tileOverlays));
  }

  Future<void> onPlatformViewCreated(int id) async {
    final GoogleMapController controller = await GoogleMapController.init(
      id,
      widget.initialCameraPosition,
      this,
    );
    _controller.complete(controller);
    unawaited(_updateTileOverlays());
    final MapCreatedCallback? onMapCreated = widget.onMapCreated;
    if (onMapCreated != null) {
      onMapCreated(controller);
    }
  }

  void onMarkerTap(MarkerId markerId) {
    final Marker? marker = _markers[markerId];
    if (marker == null) {
      throw UnknownMapObjectIdError('marker', markerId, 'onTap');
    }
    final VoidCallback? onTap = marker.onTap;
    if (onTap != null) {
      onTap();
    }
  }

  void onMarkerDragStart(MarkerId markerId, LatLng position) {
    final Marker? marker = _markers[markerId];
    if (marker == null) {
      throw UnknownMapObjectIdError('marker', markerId, 'onDragStart');
    }
    final ValueChanged<LatLng>? onDragStart = marker.onDragStart;
    if (onDragStart != null) {
      onDragStart(position);
    }
  }

  void onMarkerDrag(MarkerId markerId, LatLng position) {
    final Marker? marker = _markers[markerId];
    if (marker == null) {
      throw UnknownMapObjectIdError('marker', markerId, 'onDrag');
    }
    final ValueChanged<LatLng>? onDrag = marker.onDrag;
    if (onDrag != null) {
      onDrag(position);
    }
  }

  void onMarkerDragEnd(MarkerId markerId, LatLng position) {
    final Marker? marker = _markers[markerId];
    if (marker == null) {
      throw UnknownMapObjectIdError('marker', markerId, 'onDragEnd');
    }
    final ValueChanged<LatLng>? onDragEnd = marker.onDragEnd;
    if (onDragEnd != null) {
      onDragEnd(position);
    }
  }

  void onPolygonTap(PolygonId polygonId) {
    final Polygon? polygon = _polygons[polygonId];
    if (polygon == null) {
      throw UnknownMapObjectIdError('polygon', polygonId, 'onTap');
    }
    final VoidCallback? onTap = polygon.onTap;
    if (onTap != null) {
      onTap();
    }
  }

  void onPolylineTap(PolylineId polylineId) {
    final Polyline? polyline = _polylines[polylineId];
    if (polyline == null) {
      throw UnknownMapObjectIdError('polyline', polylineId, 'onTap');
    }
    final VoidCallback? onTap = polyline.onTap;
    if (onTap != null) {
      onTap();
    }
  }

  void onCircleTap(CircleId circleId) {
    final Circle? circle = _circles[circleId];
    if (circle == null) {
      throw UnknownMapObjectIdError('marker', circleId, 'onTap');
    }
    final VoidCallback? onTap = circle.onTap;
    if (onTap != null) {
      onTap();
    }
  }

  void onInfoWindowTap(MarkerId markerId) {
    final Marker? marker = _markers[markerId];
    if (marker == null) {
      throw UnknownMapObjectIdError('marker', markerId, 'InfoWindow onTap');
    }
    final VoidCallback? onTap = marker.infoWindow.onTap;
    if (onTap != null) {
      onTap();
    }
  }

  void onTap(LatLng position) {
    final ArgumentCallback<LatLng>? onTap = widget.onTap;
    if (onTap != null) {
      onTap(position);
    }
  }

  void onLongPress(LatLng position) {
    final ArgumentCallback<LatLng>? onLongPress = widget.onLongPress;
    if (onLongPress != null) {
      onLongPress(position);
    }
  }

  void onClusterTap(Cluster cluster) {
    final ClusterManager? clusterManager =
        _clusterManagers[cluster.clusterManagerId];
    if (clusterManager == null) {
      throw UnknownMapObjectIdError(
          'clusterManager', cluster.clusterManagerId, 'onClusterTap');
    }
    final ArgumentCallback<Cluster>? onClusterTap = clusterManager.onClusterTap;
    if (onClusterTap != null) {
      onClusterTap(cluster);
    }
  }
}

/// Builds a [MapConfiguration] from the given [map].
MapConfiguration _configurationFromMapWidget(GoogleMap map) {
  assert(!map.liteModeEnabled || Platform.isAndroid);
  return MapConfiguration(
    webGestureHandling: map.webGestureHandling,
    compassEnabled: map.compassEnabled,
    mapToolbarEnabled: map.mapToolbarEnabled,
    cameraTargetBounds: map.cameraTargetBounds,
    mapType: map.mapType,
    minMaxZoomPreference: map.minMaxZoomPreference,
    rotateGesturesEnabled: map.rotateGesturesEnabled,
    scrollGesturesEnabled: map.scrollGesturesEnabled,
    tiltGesturesEnabled: map.tiltGesturesEnabled,
    fortyFiveDegreeImageryEnabled: map.fortyFiveDegreeImageryEnabled,
    trackCameraPosition: map.onCameraMove != null,
    zoomControlsEnabled: map.zoomControlsEnabled,
    zoomGesturesEnabled: map.zoomGesturesEnabled,
    liteModeEnabled: map.liteModeEnabled,
    myLocationEnabled: map.myLocationEnabled,
    myLocationButtonEnabled: map.myLocationButtonEnabled,
    padding: map.padding,
    indoorViewEnabled: map.indoorViewEnabled,
    trafficEnabled: map.trafficEnabled,
    buildingsEnabled: map.buildingsEnabled,
    cloudMapId: map.cloudMapId,
    // A null style in the widget means no style, which is expressed as '' in
    // the configuration to distinguish from no change (null).
    style: map.style ?? '',
  );
}
