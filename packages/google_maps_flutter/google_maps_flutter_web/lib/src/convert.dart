// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../google_maps_flutter_web.dart';

// Default values for when the gmaps objects return null/undefined values.
final gmaps.LatLng _nullGmapsLatLng = gmaps.LatLng(0, 0);
final gmaps.LatLngBounds _nullGmapsLatLngBounds =
    gmaps.LatLngBounds(_nullGmapsLatLng, _nullGmapsLatLng);

// The TrustedType Policy used by this plugin. Used to sanitize InfoWindow contents.
TrustedTypePolicy? _gmapsTrustedTypePolicy;

// A cache for image size Futures to reduce redundant image fetch requests.
// This cache should be always cleaned up after marker updates are processed.
final Map<String, Future<Size?>> _bitmapSizeFutureCache =
    <String, Future<Size?>>{};

// A cache for blob URLs of bitmaps to avoid creating a new blob URL for the
// same bitmap instances. This cache should be always cleaned up after marker
// updates are processed.
final Map<int, String> _bitmapBlobUrlCache = <int, String>{};

// Converts a [Color] into a valid CSS value #RRGGBB.
String _getCssColor(Color color) {
  return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
}

// Extracts the opacity from a [Color].
double _getCssOpacity(Color color) {
  return color.opacity;
}

// Converts a [Color] into a valid CSS value rgba(R, G, B, A).
String _getCssColorWithAlpha(Color color) {
  return 'rgba(${color.red}, ${color.green}, ${color.blue}, ${(color.alpha / 255).toStringAsFixed(2)})';
}

// Converts options from the plugin into gmaps.MapOptions that can be used by the JS SDK.
// The following options are not handled here, for various reasons:
// The following are not available in web, because the map doesn't rotate there:
//   compassEnabled
//   rotateGesturesEnabled
//   tiltGesturesEnabled
// mapToolbarEnabled is unused in web, there's no "map toolbar"
// myLocationButtonEnabled Widget not available in web yet, it needs to be built on top of the maps widget
//   See: https://developers.google.com/maps/documentation/javascript/examples/control-custom
// myLocationEnabled needs to be built through `navigator.geolocation` from package:web.
//   See: https://api.dart.dev/stable/2.8.4/dart-html/Geolocation-class.html
// trafficEnabled is handled when creating the GMap object, since it needs to be added as a layer.
// trackCameraPosition is just a boolean value that indicates if the map has an onCameraMove handler.
// indoorViewEnabled seems to not have an equivalent in web
// buildingsEnabled seems to not have an equivalent in web
// padding seems to behave differently in web than mobile. You can't move UI elements in web.
gmaps.MapOptions _configurationAndStyleToGmapsOptions(
    MapConfiguration configuration, List<gmaps.MapTypeStyle> styles) {
  final gmaps.MapOptions options = gmaps.MapOptions();

  if (configuration.mapType != null) {
    options.mapTypeId = _gmapTypeIDForPluginType(configuration.mapType!);
  }

  final MinMaxZoomPreference? zoomPreference =
      configuration.minMaxZoomPreference;
  if (zoomPreference != null) {
    options
      ..minZoom = zoomPreference.minZoom
      ..maxZoom = zoomPreference.maxZoom;
  }

  if (configuration.cameraTargetBounds != null) {
    // Needs gmaps.MapOptions.restriction and gmaps.MapRestriction
    // see: https://developers.google.com/maps/documentation/javascript/reference/map#MapOptions.restriction
  }

  if (configuration.zoomControlsEnabled != null) {
    options.zoomControl = configuration.zoomControlsEnabled;
  }

  if (configuration.webGestureHandling != null) {
    options.gestureHandling = configuration.webGestureHandling!.name;
  } else if (configuration.scrollGesturesEnabled == false ||
      configuration.zoomGesturesEnabled == false) {
    // Old behavior
    options.gestureHandling = WebGestureHandling.none.name;
  } else {
    options.gestureHandling = WebGestureHandling.auto.name;
  }

  if (configuration.fortyFiveDegreeImageryEnabled != null) {
    options.rotateControl = configuration.fortyFiveDegreeImageryEnabled;
  }

  // These don't have any configuration entries, but they seem to be off in the
  // native maps.
  options.mapTypeControl = false;
  options.fullscreenControl = false;
  options.streetViewControl = false;

  // See updateMapConfiguration for why this is not using configuration.style.
  options.styles = styles;

  options.mapId = configuration.cloudMapId;

  return options;
}

gmaps.MapTypeId _gmapTypeIDForPluginType(MapType type) {
  switch (type) {
    case MapType.satellite:
      return gmaps.MapTypeId.SATELLITE;
    case MapType.terrain:
      return gmaps.MapTypeId.TERRAIN;
    case MapType.hybrid:
      return gmaps.MapTypeId.HYBRID;
    case MapType.normal:
    case MapType.none:
      return gmaps.MapTypeId.ROADMAP;
  }
  // The enum comes from a different package, which could get a new value at
  // any time, so provide a fallback that ensures this won't break when used
  // with a version that contains new values. This is deliberately outside
  // the switch rather than a `default` so that the linter will flag the
  // switch as needing an update.
  // ignore: dead_code
  return gmaps.MapTypeId.ROADMAP;
}

gmaps.MapOptions _applyInitialPosition(
  CameraPosition initialPosition,
  gmaps.MapOptions options,
) {
  // Adjust the initial position, if passed...
  options.zoom = initialPosition.zoom;
  options.center = gmaps.LatLng(
      initialPosition.target.latitude, initialPosition.target.longitude);
  return options;
}

// The keys we'd expect to see in a serialized MapTypeStyle JSON object.
final Set<String> _mapStyleKeys = <String>{
  'elementType',
  'featureType',
  'stylers',
};

// Checks if the passed in Map contains some of the _mapStyleKeys.
bool _isJsonMapStyle(Map<String, Object?> value) {
  return _mapStyleKeys.intersection(value.keys.toSet()).isNotEmpty;
}

// Converts an incoming JSON-encoded Style info, into the correct gmaps array.
List<gmaps.MapTypeStyle> _mapStyles(String? mapStyleJson) {
  List<gmaps.MapTypeStyle> styles = <gmaps.MapTypeStyle>[];
  if (mapStyleJson != null) {
    try {
      styles =
          (json.decode(mapStyleJson, reviver: (Object? key, Object? value) {
        if (value is Map && _isJsonMapStyle(value as Map<String, Object?>)) {
          List<MapStyler> stylers = <MapStyler>[];
          if (value['stylers'] != null) {
            stylers = (value['stylers']! as List<Object?>)
                .whereType<Map<String, Object?>>()
                .map(MapStyler.fromJson)
                .toList();
          }
          return gmaps.MapTypeStyle()
            ..elementType = value['elementType'] as String?
            ..featureType = value['featureType'] as String?
            ..stylers = stylers;
        }
        return value;
      }) as List<Object?>)
              .where((Object? element) => element != null)
              .cast<gmaps.MapTypeStyle>()
              .toList();
      // .toList calls are required so the JS API understands the underlying data structure.
    } on FormatException catch (e) {
      throw MapStyleException(e.message);
    }
  }
  return styles;
}

gmaps.LatLng _latLngToGmLatLng(LatLng latLng) {
  return gmaps.LatLng(latLng.latitude, latLng.longitude);
}

/// Converts [gmaps.LatLng] to [LatLng].
LatLng gmLatLngToLatLng(gmaps.LatLng latLng) {
  return LatLng(latLng.lat.toDouble(), latLng.lng.toDouble());
}

/// Converts a [gmaps.LatLngBounds] into a [LatLngBounds].
LatLngBounds gmLatLngBoundsTolatLngBounds(gmaps.LatLngBounds latLngBounds) {
  return LatLngBounds(
    southwest: gmLatLngToLatLng(latLngBounds.southWest),
    northeast: gmLatLngToLatLng(latLngBounds.northEast),
  );
}

CameraPosition _gmViewportToCameraPosition(gmaps.Map map) {
  return CameraPosition(
    target:
        gmLatLngToLatLng(map.isCenterDefined() ? map.center : _nullGmapsLatLng),
    bearing: map.isHeadingDefined() ? map.heading.toDouble() : 0,
    tilt: map.isTiltDefined() ? map.tilt.toDouble() : 0,
    zoom: map.isZoomDefined() ? map.zoom.toDouble() : 0,
  );
}

// Convert plugin objects to gmaps.Options objects
// TODO(ditman): Move to their appropriate objects, maybe make them copy constructors?
// Marker.fromMarker(anotherMarker, moreOptions);
gmaps.InfoWindowOptions? _infoWindowOptionsFromMarker(Marker marker) {
  final String markerTitle = marker.infoWindow.title ?? '';
  final String markerSnippet = marker.infoWindow.snippet ?? '';

  // If both the title and snippet of an infowindow are empty, we don't really
  // want an infowindow...
  if ((markerTitle.isEmpty) && (markerSnippet.isEmpty)) {
    return null;
  }

  // Add an outer wrapper to the contents of the infowindow, we need it to listen
  // to click events...
  final HTMLElement container = createDivElement()
    ..id = 'gmaps-marker-${marker.markerId.value}-infowindow';

  if (markerTitle.isNotEmpty) {
    final HTMLHeadingElement title =
        (document.createElement('h3') as HTMLHeadingElement)
          ..className = 'infowindow-title'
          ..innerText = markerTitle;
    container.appendChild(title);
  }
  if (markerSnippet.isNotEmpty) {
    final HTMLElement snippet = createDivElement()
      ..className = 'infowindow-snippet';

    // Firefox and Safari don't support Trusted Types yet.
    // See https://developer.mozilla.org/en-US/docs/Web/API/TrustedTypePolicyFactory#browser_compatibility
    if (window.nullableTrustedTypes != null) {
      _gmapsTrustedTypePolicy ??= window.trustedTypes.createPolicy(
        'google_maps_flutter_sanitize',
        TrustedTypePolicyOptions(
          createHTML: (String html) {
            return sanitizeHtml(html).toJS;
          }.toJS,
        ),
      );

      snippet.trustedInnerHTML =
          _gmapsTrustedTypePolicy!.createHTMLNoArgs(markerSnippet);
    } else {
      // `sanitizeHtml` is used to clean the (potential) user input from (potential)
      // XSS attacks through the contents of the marker InfoWindow.
      // See: https://pub.dev/documentation/sanitize_html/latest/sanitize_html/sanitizeHtml.html
      // See: b/159137885, b/159598165
      snippet.innerHTMLString = sanitizeHtml(markerSnippet);
    }

    container.appendChild(snippet);
  }

  return gmaps.InfoWindowOptions()
    ..content = container
    ..zIndex = marker.zIndex;
  // TODO(ditman): Compute the pixelOffset of the infoWindow, from the size of the Marker,
  // and the marker.infoWindow.anchor property.
}

// Attempts to extract a [gmaps.Size] from `iconConfig[sizeIndex]`.
gmaps.Size? _gmSizeFromIconConfig(List<Object?> iconConfig, int sizeIndex) {
  gmaps.Size? size;
  if (iconConfig.length >= sizeIndex + 1) {
    final List<Object?>? rawIconSize = iconConfig[sizeIndex] as List<Object?>?;
    if (rawIconSize != null) {
      size = gmaps.Size(
        rawIconSize[0]! as double,
        rawIconSize[1]! as double,
      );
    }
  }
  return size;
}

/// Sets the size of the Google Maps icon.
void _setIconSize({
  required Size size,
  required gmaps.Icon icon,
}) {
  final gmaps.Size gmapsSize = gmaps.Size(size.width, size.height);
  icon.size = gmapsSize;
  icon.scaledSize = gmapsSize;
}

/// Determines the appropriate size for a bitmap based on its descriptor.
///
/// This method returns the icon's size based on the provided [width] and
/// [height]. If both dimensions are null, the size is calculated using the
/// [imagePixelRatio] based on the actual size of the image fetched from the
/// [url]. If only one of the dimensions is provided, the other is calculated to
/// maintain the image's original aspect ratio.
Future<Size?> _getBitmapSize(MapBitmap mapBitmap, String url) async {
  final double? width = mapBitmap.width;
  final double? height = mapBitmap.height;
  if (width != null && height != null) {
    // If both, width and height are set, return the provided dimensions.
    return Size(width, height);
  } else {
    assert(
        url.isNotEmpty, 'URL must not be empty when calculating dimensions.');

    final Size? bitmapSize = await _bitmapSizeFutureCache.putIfAbsent(url, () {
      return _fetchBitmapSize(url);
    });

    if (bitmapSize == null) {
      // If bitmap size is null, the image is invalid,
      // and the icon size cannot be calculated.
      return null;
    }

    double targetWidth = bitmapSize.width;
    double targetHeight = bitmapSize.height;
    if (width == null && height == null) {
      // Width and height are not provided, so the imagePixelRatio is used to
      // calculate the target size.
      targetWidth /= mapBitmap.imagePixelRatio;
      targetHeight /= mapBitmap.imagePixelRatio;
    } else {
      final double aspectRatio = bitmapSize.width / bitmapSize.height;
      targetWidth = width ?? (height ?? bitmapSize.height) * aspectRatio;
      targetHeight = height ?? (width ?? bitmapSize.width) / aspectRatio;
    }

    // Return the calculated size.
    return Size(targetWidth, targetHeight);
  }
}

/// Fetches the size of the bitmap from a given URL and caches the result.
///
/// This method attempts to fetch the image size for a given [url].
Future<Size?> _fetchBitmapSize(String url) async {
  final HTMLImageElement image = HTMLImageElement()..src = url;

  // Wait for the onLoad or onError event.
  await Future.any(<Future<Event>>[image.onLoad.first, image.onError.first]);

  if (image.width == 0 || image.height == 0) {
    // Complete with null for invalid images.
    return null;
  }

  // Complete with the image size for valid images.
  return Size(image.width.toDouble(), image.height.toDouble());
}

/// Cleans up the caches used for bitmap size conversion and URL storage.
///
/// This method should be called after marker updates are processed to ensure
/// that memory usage is optimized by removing completed or outdated cache
/// entries.
void _cleanUpBitmapConversionCaches() {
  _bitmapSizeFutureCache.clear();
  _bitmapBlobUrlCache.clear();
}

// Converts a [BitmapDescriptor] into a [gmaps.Icon] that can be used in Markers.
Future<gmaps.Icon?> _gmIconFromBitmapDescriptor(
    BitmapDescriptor bitmapDescriptor) async {
  gmaps.Icon? icon;

  if (bitmapDescriptor is MapBitmap) {
    final String url = switch (bitmapDescriptor) {
      (final BytesMapBitmap bytesMapBitmap) =>
        _bitmapBlobUrlCache.putIfAbsent(bytesMapBitmap.byteData.hashCode, () {
          final Blob blob =
              Blob(<JSUint8Array>[bytesMapBitmap.byteData.toJS].toJS);
          return URL.createObjectURL(blob as JSObject);
        }),
      (final AssetMapBitmap assetMapBitmap) =>
        ui_web.assetManager.getAssetUrl(assetMapBitmap.assetName),
      _ => throw UnimplementedError(),
    };

    icon = gmaps.Icon()..url = url;

    switch (bitmapDescriptor.bitmapScaling) {
      case MapBitmapScaling.auto:
        final Size? size = await _getBitmapSize(bitmapDescriptor, url);
        if (size != null) {
          _setIconSize(size: size, icon: icon);
        }
      case MapBitmapScaling.none:
        break;
    }
    return icon;
  }

  // The following code is for the deprecated BitmapDescriptor.fromBytes
  // and BitmapDescriptor.fromAssetImage.
  final List<Object?> iconConfig = bitmapDescriptor.toJson() as List<Object?>;
  if (iconConfig[0] == 'fromAssetImage') {
    assert(iconConfig.length >= 2);
    // iconConfig[2] contains the DPIs of the screen, but that information is
    // already encoded in the iconConfig[1]
    icon = gmaps.Icon()
      ..url = ui_web.assetManager.getAssetUrl(iconConfig[1]! as String);

    final gmaps.Size? size = _gmSizeFromIconConfig(iconConfig, 3);
    if (size != null) {
      icon
        ..size = size
        ..scaledSize = size;
    }
  } else if (iconConfig[0] == 'fromBytes') {
    // Grab the bytes, and put them into a blob
    final List<int> bytes = iconConfig[1]! as List<int>;
    // Create a Blob from bytes, but let the browser figure out the encoding
    final Blob blob;

    assert(
      bytes is Uint8List,
      'The bytes for a BitmapDescriptor icon must be a Uint8List',
    );

    // TODO(ditman): Improve this conversion
    // See https://github.com/dart-lang/web/issues/180
    blob = Blob(<JSUint8Array>[(bytes as Uint8List).toJS].toJS);

    icon = gmaps.Icon()..url = URL.createObjectURL(blob as JSObject);

    final gmaps.Size? size = _gmSizeFromIconConfig(iconConfig, 2);
    if (size != null) {
      icon
        ..size = size
        ..scaledSize = size;
    }
  }
  return icon;
}

// Computes the options for a new [gmaps.Marker] from an incoming set of options
// [marker], and the existing marker registered with the map: [currentMarker].
Future<gmaps.MarkerOptions> _markerOptionsFromMarker(
  Marker marker,
  gmaps.Marker? currentMarker,
) async {
  return gmaps.MarkerOptions()
    ..position = gmaps.LatLng(
      marker.position.latitude,
      marker.position.longitude,
    )
    ..title = sanitizeHtml(marker.infoWindow.title ?? '')
    ..zIndex = marker.zIndex
    ..visible = marker.visible
    ..opacity = marker.alpha
    ..draggable = marker.draggable
    ..icon = await _gmIconFromBitmapDescriptor(marker.icon);
  // TODO(ditman): Compute anchor properly, otherwise infowindows attach to the wrong spot.
  // Flat and Rotation are not supported directly on the web.
}

gmaps.CircleOptions _circleOptionsFromCircle(Circle circle) {
  final gmaps.CircleOptions circleOptions = gmaps.CircleOptions()
    ..strokeColor = _getCssColor(circle.strokeColor)
    ..strokeOpacity = _getCssOpacity(circle.strokeColor)
    ..strokeWeight = circle.strokeWidth
    ..fillColor = _getCssColor(circle.fillColor)
    ..fillOpacity = _getCssOpacity(circle.fillColor)
    ..center = gmaps.LatLng(circle.center.latitude, circle.center.longitude)
    ..radius = circle.radius
    ..visible = circle.visible
    ..zIndex = circle.zIndex;
  return circleOptions;
}

visualization.HeatmapLayerOptions _heatmapOptionsFromHeatmap(Heatmap heatmap) {
  final Iterable<Color>? gradientColors =
      heatmap.gradient?.colors.map((HeatmapGradientColor e) => e.color);
  final visualization.HeatmapLayerOptions heatmapOptions =
      visualization.HeatmapLayerOptions()
        ..data = heatmap.data
            .map(
              (WeightedLatLng e) => visualization.WeightedLocation()
                ..location = gmaps.LatLng(e.point.latitude, e.point.longitude)
                ..weight = e.weight,
            )
            .toList()
            .toJS
        ..dissipating = heatmap.dissipating
        ..gradient = gradientColors == null
            ? null
            : <Color>[
                // Web needs a first color with 0 alpha
                gradientColors.first.withAlpha(0),
                ...gradientColors,
              ].map(_getCssColorWithAlpha).toList()
        ..maxIntensity = heatmap.maxIntensity
        ..opacity = heatmap.opacity
        ..radius = heatmap.radius.radius;
  return heatmapOptions;
}

gmaps.PolygonOptions _polygonOptionsFromPolygon(
    gmaps.Map googleMap, Polygon polygon) {
  // Convert all points to GmLatLng
  final List<gmaps.LatLng> path =
      polygon.points.map(_latLngToGmLatLng).toList();

  final bool isClockwisePolygon = _isPolygonClockwise(path);

  final List<List<gmaps.LatLng>> paths = <List<gmaps.LatLng>>[path];

  for (int i = 0; i < polygon.holes.length; i++) {
    final List<LatLng> hole = polygon.holes[i];
    final List<gmaps.LatLng> correctHole = _ensureHoleHasReverseWinding(
      hole,
      isClockwisePolygon,
      holeId: i,
      polygonId: polygon.polygonId,
    );
    paths.add(correctHole);
  }

  return gmaps.PolygonOptions()
    ..paths = paths.map((List<gmaps.LatLng> e) => e.toJS).toList().toJS
    ..strokeColor = _getCssColor(polygon.strokeColor)
    ..strokeOpacity = _getCssOpacity(polygon.strokeColor)
    ..strokeWeight = polygon.strokeWidth
    ..fillColor = _getCssColor(polygon.fillColor)
    ..fillOpacity = _getCssOpacity(polygon.fillColor)
    ..visible = polygon.visible
    ..zIndex = polygon.zIndex
    ..geodesic = polygon.geodesic;
}

List<gmaps.LatLng> _ensureHoleHasReverseWinding(
  List<LatLng> hole,
  bool polyIsClockwise, {
  required int holeId,
  required PolygonId polygonId,
}) {
  List<gmaps.LatLng> holePath = hole.map(_latLngToGmLatLng).toList();
  final bool holeIsClockwise = _isPolygonClockwise(holePath);

  if (holeIsClockwise == polyIsClockwise) {
    holePath = holePath.reversed.toList();
    if (kDebugMode) {
      print('Hole [$holeId] in Polygon [${polygonId.value}] has been reversed.'
          ' Ensure holes in polygons are "wound in the opposite direction to the outer path."'
          ' More info: https://github.com/flutter/flutter/issues/74096');
    }
  }

  return holePath;
}

/// Calculates the direction of a given Polygon
/// based on: https://stackoverflow.com/a/1165943
///
/// returns [true] if clockwise [false] if counterclockwise
///
/// This method expects that the incoming [path] is a `List` of well-formed,
/// non-null [gmaps.LatLng] objects.
///
/// Currently, this method is only called from [_polygonOptionsFromPolygon], and
/// the `path` is a transformed version of [Polygon.points] or each of the
/// [Polygon.holes], guaranteeing that `lat` and `lng` can be accessed with `!`.
bool _isPolygonClockwise(List<gmaps.LatLng> path) {
  double direction = 0.0;
  for (int i = 0; i < path.length; i++) {
    direction = direction +
        ((path[(i + 1) % path.length].lat - path[i].lat) *
            (path[(i + 1) % path.length].lng + path[i].lng));
  }
  return direction >= 0;
}

gmaps.PolylineOptions _polylineOptionsFromPolyline(
    gmaps.Map googleMap, Polyline polyline) {
  final List<gmaps.LatLng> paths =
      polyline.points.map(_latLngToGmLatLng).toList();

  return gmaps.PolylineOptions()
    ..path = paths.toJS
    ..strokeWeight = polyline.width
    ..strokeColor = _getCssColor(polyline.color)
    ..strokeOpacity = _getCssOpacity(polyline.color)
    ..visible = polyline.visible
    ..zIndex = polyline.zIndex
    ..geodesic = polyline.geodesic;
//  this.endCap = Cap.buttCap,
//  this.jointType = JointType.mitered,
//  this.patterns = const <PatternItem>[],
//  this.startCap = Cap.buttCap,
//  this.width = 10,
}

// Translates a [CameraUpdate] into operations on a [gmaps.Map].
void _applyCameraUpdate(gmaps.Map map, CameraUpdate update) {
  // Casts [value] to a JSON dictionary (string -> nullable object). [value]
  // must be a non-null JSON dictionary.
  Map<String, Object?> asJsonObject(dynamic value) {
    return (value as Map<Object?, Object?>).cast<String, Object?>();
  }

  // Casts [value] to a JSON list. [value] must be a non-null JSON list.
  List<Object?> asJsonList(dynamic value) {
    return value as List<Object?>;
  }

  final List<dynamic> json = update.toJson() as List<dynamic>;
  switch (json[0]) {
    case 'newCameraPosition':
      final Map<String, Object?> position = asJsonObject(json[1]);
      final List<Object?> latLng = asJsonList(position['target']);
      map.heading = position['bearing']! as num;
      map.zoom = position['zoom']! as num;
      map.panTo(
        gmaps.LatLng(latLng[0]! as num, latLng[1]! as num),
      );
      map.tilt = position['tilt']! as num;
    case 'newLatLng':
      final List<Object?> latLng = asJsonList(json[1]);
      map.panTo(gmaps.LatLng(latLng[0]! as num, latLng[1]! as num));
    case 'newLatLngZoom':
      final List<Object?> latLng = asJsonList(json[1]);
      map.zoom = json[2]! as num;
      map.panTo(gmaps.LatLng(latLng[0]! as num, latLng[1]! as num));
    case 'newLatLngBounds':
      final List<Object?> latLngPair = asJsonList(json[1]);
      final List<Object?> latLng1 = asJsonList(latLngPair[0]);
      final List<Object?> latLng2 = asJsonList(latLngPair[1]);
      final double padding = json[2] as double;
      map.fitBounds(
        gmaps.LatLngBounds(
          gmaps.LatLng(latLng1[0]! as num, latLng1[1]! as num),
          gmaps.LatLng(latLng2[0]! as num, latLng2[1]! as num),
        ),
        padding.toJS,
      );
    case 'scrollBy':
      map.panBy(json[1]! as num, json[2]! as num);
    case 'zoomBy':
      gmaps.LatLng? focusLatLng;
      final double zoomDelta = json[1] as double? ?? 0;
      // Web only supports integer changes...
      final int newZoomDelta =
          zoomDelta < 0 ? zoomDelta.floor() : zoomDelta.ceil();
      if (json.length == 3) {
        final List<Object?> latLng = asJsonList(json[2]);
        // With focus
        try {
          focusLatLng =
              _pixelToLatLng(map, latLng[0]! as int, latLng[1]! as int);
        } catch (e) {
          // https://github.com/a14n/dart-google-maps/issues/87
          // print('Error computing new focus LatLng. JS Error: ' + e.toString());
        }
      }
      map.zoom = (map.isZoomDefined() ? map.zoom : 0) + newZoomDelta;
      if (focusLatLng != null) {
        map.panTo(focusLatLng);
      }
    case 'zoomIn':
      map.zoom = (map.isZoomDefined() ? map.zoom : 0) + 1;
    case 'zoomOut':
      map.zoom = (map.isZoomDefined() ? map.zoom : 0) - 1;
    case 'zoomTo':
      map.zoom = json[1]! as num;
    default:
      throw UnimplementedError('Unimplemented CameraMove: ${json[0]}.');
  }
}

// original JS by: Byron Singh (https://stackoverflow.com/a/30541162)
gmaps.LatLng _pixelToLatLng(gmaps.Map map, int x, int y) {
  final gmaps.LatLngBounds? bounds = map.bounds;
  final gmaps.Projection? projection = map.projection;

  assert(
      bounds != null, 'Map Bounds required to compute LatLng of screen x/y.');
  assert(projection != null,
      'Map Projection required to compute LatLng of screen x/y');
  assert(map.isZoomDefined(),
      'Current map zoom level required to compute LatLng of screen x/y');

  final num zoom = map.zoom;

  final gmaps.LatLng ne = bounds!.northEast;
  final gmaps.LatLng sw = bounds.southWest;

  final gmaps.Point topRight = projection!.fromLatLngToPoint(ne)!;
  final gmaps.Point bottomLeft = projection.fromLatLngToPoint(sw)!;

  final int scale = 1 << (zoom.toInt()); // 2 ^ zoom

  final gmaps.Point point =
      gmaps.Point((x / scale) + bottomLeft.x, (y / scale) + topRight.y);

  return projection.fromPointToLatLng(point)!;
}
