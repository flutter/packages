// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../google_maps_flutter_web.dart';

/// Type used when passing an override to the _createMap function.
@visibleForTesting
typedef DebugCreateMapFunction = gmaps.Map Function(
    HTMLElement div, gmaps.MapOptions options);

/// Type used when passing an override to the _setOptions function.
@visibleForTesting
typedef DebugSetOptionsFunction = void Function(gmaps.MapOptions options);

/// Encapsulates a [gmaps.Map], its events, and where in the DOM it's rendered.
class GoogleMapController {
  /// Initializes the GMap, and the sub-controllers related to it. Wires events.
  GoogleMapController({
    required int mapId,
    required StreamController<MapEvent<Object?>> streamController,
    required MapWidgetConfiguration widgetConfiguration,
    MapObjects mapObjects = const MapObjects(),
    MapConfiguration mapConfiguration = const MapConfiguration(),
  })  : _mapId = mapId,
        _streamController = streamController,
        _initialCameraPosition = widgetConfiguration.initialCameraPosition,
        _markers = mapObjects.markers,
        _polygons = mapObjects.polygons,
        _polylines = mapObjects.polylines,
        _circles = mapObjects.circles,
        _clusterManagers = mapObjects.clusterManagers,
        _heatmaps = mapObjects.heatmaps,
        _tileOverlays = mapObjects.tileOverlays,
        _lastMapConfiguration = mapConfiguration {
    _circlesController = CirclesController(stream: _streamController);
    _heatmapsController = HeatmapsController();
    _polygonsController = PolygonsController(stream: _streamController);
    _polylinesController = PolylinesController(stream: _streamController);
    _clusterManagersController =
        ClusterManagersController(stream: _streamController);
    _markersController = MarkersController(
        stream: _streamController,
        clusterManagersController: _clusterManagersController!);
    _tileOverlaysController = TileOverlaysController();
    _updateStylesFromConfiguration(mapConfiguration);

    // Register the view factory that will hold the `_div` that holds the map in the DOM.
    // The `_div` needs to be created outside of the ViewFactory (and cached!) so we can
    // use it to create the [gmaps.Map] in the `init()` method of this class.
    _div = createDivElement()
      ..id = _getViewType(mapId)
      ..style.width = '100%'
      ..style.height = '100%';

    ui_web.platformViewRegistry.registerViewFactory(
      _getViewType(mapId),
      (int viewId) => _div,
    );
  }

  // The internal ID of the map. Used to broadcast events, DOM IDs and everything where a unique ID is needed.
  final int _mapId;

  final CameraPosition _initialCameraPosition;
  final Set<Marker> _markers;
  final Set<Polygon> _polygons;
  final Set<Polyline> _polylines;
  final Set<Circle> _circles;
  final Set<ClusterManager> _clusterManagers;
  final Set<Heatmap> _heatmaps;
  Set<TileOverlay> _tileOverlays;

  // The configuration passed by the user, before converting to gmaps.
  // Caching this allows us to re-create the map faithfully when needed.
  MapConfiguration _lastMapConfiguration = const MapConfiguration();
  List<gmaps.MapTypeStyle> _lastStyles = const <gmaps.MapTypeStyle>[];
  // The last error resulting from providing a map style, if any.
  String? _lastStyleError;

  /// Configuration accessor for the [GoogleMapsInspectorWeb].
  ///
  /// Returns the latest value of [MapConfiguration] set by the programmer.
  ///
  /// This should only be used by an inspector instance created when a test
  /// calls [GoogleMapsPlugin.enableDebugInspection].
  MapConfiguration get configuration => _lastMapConfiguration;

  // Creates the 'viewType' for the _widget
  String _getViewType(int mapId) => 'plugins.flutter.io/google_maps_$mapId';

  // The Flutter widget that contains the rendered Map.
  HtmlElementView? _widget;
  late HTMLElement _div;

  /// The Flutter widget that will contain the rendered Map. Used for caching.
  Widget? get widget {
    if (_widget == null && !_streamController.isClosed) {
      _widget = HtmlElementView(
        viewType: _getViewType(_mapId),
      );
    }
    return _widget;
  }

  // The currently-enabled traffic layer.
  gmaps.TrafficLayer? _trafficLayer;

  /// A getter for the current traffic layer. Only for tests.
  @visibleForTesting
  gmaps.TrafficLayer? get trafficLayer => _trafficLayer;

  // The underlying GMap instance. This is the interface with the JS SDK.
  gmaps.Map? _googleMap;

  // The StreamController used by this controller and the geometry ones.
  final StreamController<MapEvent<Object?>> _streamController;

  /// The StreamController for the events of this Map. Only for integration testing.
  @visibleForTesting
  StreamController<MapEvent<Object?>> get stream => _streamController;

  /// The Stream over which this controller broadcasts events.
  Stream<MapEvent<Object?>> get events => _streamController.stream;

  // Geometry controllers, for different features of the map.
  CirclesController? _circlesController;
  HeatmapsController? _heatmapsController;
  PolygonsController? _polygonsController;
  PolylinesController? _polylinesController;
  MarkersController? _markersController;
  ClusterManagersController? _clusterManagersController;
  TileOverlaysController? _tileOverlaysController;

  // Keeps track if _attachGeometryControllers has been called or not.
  bool _controllersBoundToMap = false;

  // Keeps track if the map is moving or not.
  bool _mapIsMoving = false;

  /// The ClusterManagersController of this Map. Only for integration testing.
  @visibleForTesting
  ClusterManagersController? get clusterManagersController =>
      _clusterManagersController;

  /// Overrides certain properties to install mocks defined during testing.
  @visibleForTesting
  void debugSetOverrides({
    DebugCreateMapFunction? createMap,
    DebugSetOptionsFunction? setOptions,
    MarkersController? markers,
    CirclesController? circles,
    HeatmapsController? heatmaps,
    PolygonsController? polygons,
    PolylinesController? polylines,
    ClusterManagersController? clusterManagers,
    TileOverlaysController? tileOverlays,
  }) {
    _overrideCreateMap = createMap;
    _overrideSetOptions = setOptions;
    _markersController = markers ?? _markersController;
    _circlesController = circles ?? _circlesController;
    _heatmapsController = heatmaps ?? _heatmapsController;
    _polygonsController = polygons ?? _polygonsController;
    _polylinesController = polylines ?? _polylinesController;
    _clusterManagersController = clusterManagers ?? _clusterManagersController;
    _tileOverlaysController = tileOverlays ?? _tileOverlaysController;
  }

  DebugCreateMapFunction? _overrideCreateMap;
  DebugSetOptionsFunction? _overrideSetOptions;

  gmaps.Map _createMap(HTMLElement div, gmaps.MapOptions options) {
    if (_overrideCreateMap != null) {
      return _overrideCreateMap!(div, options);
    }
    return gmaps.Map(div, options);
  }

  /// A flag that returns true if the controller has been initialized or not.
  @visibleForTesting
  bool get isInitialized => _googleMap != null;

  /// Starts the JS Maps SDK into the target [_div] with `rawOptions`.
  ///
  /// (Also initializes the geometry/traffic layers.)
  ///
  /// The first part of this method starts the rendering of a [gmaps.Map] inside
  /// of the target [_div], with configuration from `rawOptions`. It then stores
  /// the created GMap in the [_googleMap] attribute.
  ///
  /// Not *everything* is rendered with the initial `rawOptions` configuration,
  /// geometry and traffic layers (and possibly others in the future) have their
  /// own configuration and are rendered on top of a GMap instance later. This
  /// happens in the second half of this method.
  ///
  /// This method is eagerly called from the [GoogleMapsPlugin.buildView] method
  /// so the internal [GoogleMapsController] of a Web Map initializes as soon as
  /// possible. Check [_attachMapEvents] to see how this controller notifies the
  /// plugin of it being fully ready (through the `onTilesloaded.first` event).
  ///
  /// Failure to call this method would result in the GMap not rendering at all,
  /// and most of the public methods on this class no-op'ing.
  void init() {
    gmaps.MapOptions options = _configurationAndStyleToGmapsOptions(
        _lastMapConfiguration, _lastStyles);
    // Initial position can only to be set here!
    options = _applyInitialPosition(_initialCameraPosition, options);

    // Fully disable 45 degree imagery if desired
    if (options.rotateControl == false) {
      options.tilt = 0;
    }

    // Create the map...
    final gmaps.Map map = _createMap(_div, options);
    _googleMap = map;

    _attachMapEvents(map);
    _attachGeometryControllers(map);

    _initClustering(_clusterManagers);

    // Now attach the geometry, traffic and any other layers...
    _renderInitialGeometry();
    _setTrafficLayer(map, _lastMapConfiguration.trafficEnabled ?? false);
  }

  // Funnels map gmap events into the plugin's stream controller.
  void _attachMapEvents(gmaps.Map map) {
    map.onTilesloaded.first.then((void _) {
      // Report the map as ready to go the first time the tiles load
      _streamController.add(WebMapReadyEvent(_mapId));
    });
    map.onClick.listen((gmaps.MapMouseEventOrIconMouseEvent event) {
      assert(event.latLng != null);
      _streamController.add(
        MapTapEvent(_mapId, gmLatLngToLatLng(event.latLng!)),
      );
    });
    map.onRightclick.listen((gmaps.MapMouseEvent event) {
      assert(event.latLng != null);
      _streamController.add(
        MapLongPressEvent(_mapId, gmLatLngToLatLng(event.latLng!)),
      );
    });
    map.onBoundsChanged.listen((void _) {
      if (!_mapIsMoving) {
        _mapIsMoving = true;
        _streamController.add(CameraMoveStartedEvent(_mapId));
      }
      _streamController.add(
        CameraMoveEvent(_mapId, _gmViewportToCameraPosition(map)),
      );
    });
    map.onIdle.listen((void _) {
      _mapIsMoving = false;
      _streamController.add(CameraIdleEvent(_mapId));
    });
  }

  // Binds the Geometry controllers to a map instance
  void _attachGeometryControllers(gmaps.Map map) {
    // Now we can add the initial geometry.
    // And bind the (ready) map instance to the other geometry controllers.
    //
    // These controllers are either created in the constructor of this class, or
    // overriden (for testing) by the [debugSetOverrides] method. They can't be
    // null.
    assert(_circlesController != null,
        'Cannot attach a map to a null CirclesController instance.');
    assert(_heatmapsController != null,
        'Cannot attach a map to a null HeatmapsController instance.');
    assert(_polygonsController != null,
        'Cannot attach a map to a null PolygonsController instance.');
    assert(_polylinesController != null,
        'Cannot attach a map to a null PolylinesController instance.');
    assert(_markersController != null,
        'Cannot attach a map to a null MarkersController instance.');
    assert(_clusterManagersController != null,
        'Cannot attach a map to a null ClusterManagersController instance.');
    assert(_tileOverlaysController != null,
        'Cannot attach a map to a null TileOverlaysController instance.');

    _circlesController!.bindToMap(_mapId, map);
    _heatmapsController!.bindToMap(_mapId, map);
    _polygonsController!.bindToMap(_mapId, map);
    _polylinesController!.bindToMap(_mapId, map);
    _markersController!.bindToMap(_mapId, map);
    _clusterManagersController!.bindToMap(_mapId, map);
    _tileOverlaysController!.bindToMap(_mapId, map);

    _controllersBoundToMap = true;
  }

  void _initClustering(Set<ClusterManager> clusterManagers) {
    _clusterManagersController!.addClusterManagers(clusterManagers);
  }

  // Renders the initial sets of geometry.
  void _renderInitialGeometry() {
    assert(
        _controllersBoundToMap,
        'Geometry controllers must be bound to a map before any geometry can '
        'be added to them. Ensure _attachGeometryControllers is called first.');

    // The above assert will only succeed if the controllers have been bound to a map
    // in the [_attachGeometryControllers] method, which ensures that all these
    // controllers below are *not* null.

    _markersController!.addMarkers(_markers);
    _circlesController!.addCircles(_circles);
    _heatmapsController!.addHeatmaps(_heatmaps);
    _polygonsController!.addPolygons(_polygons);
    _polylinesController!.addPolylines(_polylines);
    _tileOverlaysController!.addTileOverlays(_tileOverlays);
  }

  // Merges new options coming from the plugin into _lastConfiguration.
  //
  // Returns the updated _lastConfiguration object.
  MapConfiguration _mergeConfigurations(MapConfiguration update) {
    _lastMapConfiguration = _lastMapConfiguration.applyDiff(update);
    return _lastMapConfiguration;
  }

  // TODO(stuartmorgan): Refactor so that _lastMapConfiguration.style is the
  // source of truth for style info. Currently it's tracked and handled
  // separately since style didn't used to be part of the configuration.
  List<gmaps.MapTypeStyle> _updateStylesFromConfiguration(
      MapConfiguration update) {
    if (update.style != null) {
      // Provide async access to the error rather than throwing, to match the
      // behavior of other platforms where there's no mechanism to return errors
      // from configuration updates.
      try {
        _lastStyles = _mapStyles(update.style);
        _lastStyleError = null;
      } on MapStyleException catch (e) {
        _lastStyleError = e.cause;
      }
    }
    return _lastStyles;
  }

  /// Updates the map options from a [MapConfiguration].
  ///
  /// This method converts the map into the proper [gmaps.MapOptions].
  void updateMapConfiguration(MapConfiguration update) {
    assert(_googleMap != null, 'Cannot update options on a null map.');

    final List<gmaps.MapTypeStyle> styles =
        _updateStylesFromConfiguration(update);
    final MapConfiguration newConfiguration = _mergeConfigurations(update);
    final gmaps.MapOptions newOptions =
        _configurationAndStyleToGmapsOptions(newConfiguration, styles);

    _setOptions(newOptions);
    _setTrafficLayer(_googleMap!, newConfiguration.trafficEnabled ?? false);
  }

  /// Updates the map options with a new list of [styles].
  void updateStyles(List<gmaps.MapTypeStyle> styles) {
    _lastStyles = styles;
    _setOptions(
        _configurationAndStyleToGmapsOptions(_lastMapConfiguration, styles));
  }

  /// A getter for the current styles. Only for tests.
  @visibleForTesting
  List<gmaps.MapTypeStyle> get styles => _lastStyles;

  /// Returns the last error from setting the map's style, if any.
  String? get lastStyleError => _lastStyleError;

  // Sets new [gmaps.MapOptions] on the wrapped map.
  // ignore: use_setters_to_change_properties
  void _setOptions(gmaps.MapOptions options) {
    if (_overrideSetOptions != null) {
      return _overrideSetOptions!(options);
    }
    _googleMap?.options = options;
  }

  // Attaches/detaches a Traffic Layer on the passed `map` if `attach` is true/false.
  void _setTrafficLayer(gmaps.Map map, bool attach) {
    if (attach && _trafficLayer == null) {
      _trafficLayer = gmaps.TrafficLayer()..set('map', map);
    }
    if (!attach && _trafficLayer != null) {
      _trafficLayer!.set('map', null);
      _trafficLayer = null;
    }
  }

  // _googleMap manipulation
  // Viewport

  /// Returns the [LatLngBounds] of the current viewport.
  Future<LatLngBounds> getVisibleRegion() async {
    assert(_googleMap != null, 'Cannot get the visible region of a null map.');

    final gmaps.LatLngBounds bounds =
        await Future<gmaps.LatLngBounds?>.value(_googleMap!.bounds) ??
            _nullGmapsLatLngBounds;

    return gmLatLngBoundsTolatLngBounds(bounds);
  }

  /// Returns the [ScreenCoordinate] for a given viewport [LatLng].
  Future<ScreenCoordinate> getScreenCoordinate(LatLng latLng) async {
    assert(_googleMap != null,
        'Cannot get the screen coordinates with a null map.');

    final gmaps.Point point =
        toScreenLocation(_googleMap!, _latLngToGmLatLng(latLng));

    return ScreenCoordinate(x: point.x.toInt(), y: point.y.toInt());
  }

  /// Returns the [LatLng] for a `screenCoordinate` (in pixels) of the viewport.
  Future<LatLng> getLatLng(ScreenCoordinate screenCoordinate) async {
    assert(_googleMap != null,
        'Cannot get the lat, lng of a screen coordinate with a null map.');

    final gmaps.LatLng latLng =
        _pixelToLatLng(_googleMap!, screenCoordinate.x, screenCoordinate.y);
    return gmLatLngToLatLng(latLng);
  }

  /// Applies a `cameraUpdate` to the current viewport.
  Future<void> moveCamera(CameraUpdate cameraUpdate) async {
    assert(_googleMap != null, 'Cannot update the camera of a null map.');

    return _applyCameraUpdate(_googleMap!, cameraUpdate);
  }

  /// Returns the zoom level of the current viewport.
  Future<double> getZoomLevel() async {
    assert(_googleMap != null, 'Cannot get zoom level of a null map.');
    assert(_googleMap!.isZoomDefined(),
        'Zoom level should not be null. Is the map correctly initialized?');

    return _googleMap!.zoom.toDouble();
  }

  // Geometry manipulation

  /// Applies [CircleUpdates] to the currently managed circles.
  void updateCircles(CircleUpdates updates) {
    assert(
      _circlesController != null,
      'Cannot update circles after dispose().',
    );
    _circlesController?.addCircles(updates.circlesToAdd);
    _circlesController?.changeCircles(updates.circlesToChange);
    _circlesController?.removeCircles(updates.circleIdsToRemove);
  }

  /// Applies [HeatmapUpdates] to the currently managed heatmaps.
  void updateHeatmaps(HeatmapUpdates updates) {
    assert(
      _heatmapsController != null,
      'Cannot update heatmaps after dispose().',
    );
    _heatmapsController?.addHeatmaps(updates.heatmapsToAdd);
    _heatmapsController?.changeHeatmaps(updates.heatmapsToChange);
    _heatmapsController?.removeHeatmaps(updates.heatmapIdsToRemove);
  }

  /// Applies [PolygonUpdates] to the currently managed polygons.
  void updatePolygons(PolygonUpdates updates) {
    assert(
        _polygonsController != null, 'Cannot update polygons after dispose().');
    _polygonsController?.addPolygons(updates.polygonsToAdd);
    _polygonsController?.changePolygons(updates.polygonsToChange);
    _polygonsController?.removePolygons(updates.polygonIdsToRemove);
  }

  /// Applies [PolylineUpdates] to the currently managed lines.
  void updatePolylines(PolylineUpdates updates) {
    assert(_polylinesController != null,
        'Cannot update polylines after dispose().');
    _polylinesController?.addPolylines(updates.polylinesToAdd);
    _polylinesController?.changePolylines(updates.polylinesToChange);
    _polylinesController?.removePolylines(updates.polylineIdsToRemove);
  }

  /// Applies [MarkerUpdates] to the currently managed markers.
  Future<void> updateMarkers(MarkerUpdates updates) async {
    assert(
        _markersController != null, 'Cannot update markers after dispose().');
    await _markersController?.addMarkers(updates.markersToAdd);
    await _markersController?.changeMarkers(updates.markersToChange);
    _markersController?.removeMarkers(updates.markerIdsToRemove);
    _cleanUpBitmapConversionCaches();
  }

  /// Applies [ClusterManagerUpdates] to the currently managed cluster managers.
  void updateClusterManagers(ClusterManagerUpdates updates) {
    assert(_clusterManagersController != null,
        'Cannot update markers after dispose().');
    _clusterManagersController
        ?.addClusterManagers(updates.clusterManagersToAdd);
    _clusterManagersController
        ?.removeClusterManagers(updates.clusterManagerIdsToRemove);
  }

  /// Updates the set of [TileOverlay]s.
  void updateTileOverlays(Set<TileOverlay> newOverlays) {
    final MapsObjectUpdates<TileOverlay> updates =
        MapsObjectUpdates<TileOverlay>.from(_tileOverlays, newOverlays,
            objectName: 'tileOverlay');
    assert(_tileOverlaysController != null,
        'Cannot update tile overlays after dispose().');
    _tileOverlaysController?.addTileOverlays(updates.objectsToAdd);
    _tileOverlaysController?.changeTileOverlays(updates.objectsToChange);
    _tileOverlaysController
        ?.removeTileOverlays(updates.objectIdsToRemove.cast<TileOverlayId>());
    _tileOverlays = newOverlays;
  }

  /// Clears the tile cache associated with the given [TileOverlayId].
  void clearTileCache(TileOverlayId id) {
    _tileOverlaysController?.clearTileCache(id);
  }

  /// Shows the [InfoWindow] of the marker identified by its [MarkerId].
  void showInfoWindow(MarkerId markerId) {
    assert(_markersController != null,
        'Cannot show infowindow of marker [${markerId.value}] after dispose().');
    _markersController?.showMarkerInfoWindow(markerId);
  }

  /// Hides the [InfoWindow] of the marker identified by its [MarkerId].
  void hideInfoWindow(MarkerId markerId) {
    assert(_markersController != null,
        'Cannot hide infowindow of marker [${markerId.value}] after dispose().');
    _markersController?.hideMarkerInfoWindow(markerId);
  }

  /// Returns true if the [InfoWindow] of the marker identified by [MarkerId] is shown.
  bool isInfoWindowShown(MarkerId markerId) {
    return _markersController?.isInfoWindowShown(markerId) ?? false;
  }

  // Cleanup

  /// Disposes of this controller and its resources.
  ///
  /// You won't be able to call many of the methods on this controller after
  /// calling `dispose`!
  void dispose() {
    _widget = null;
    _googleMap = null;
    _circlesController = null;
    _heatmapsController = null;
    _polygonsController = null;
    _polylinesController = null;
    _markersController = null;
    _clusterManagersController = null;
    _tileOverlaysController = null;
    _streamController.close();
  }
}

/// A MapEvent event fired when a [mapId] on web is interactive.
class WebMapReadyEvent extends MapEvent<Object?> {
  /// Build a WebMapReady Event for the map represented by `mapId`.
  WebMapReadyEvent(int mapId) : super(mapId, null);
}
