// The MIT License (MIT)
//
// Copyright (c) 2008 Krasimir Tsonev
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'package:google_maps/google_maps.dart' as gmaps;

/// Returns a screen location that corresponds to a geographical coordinate ([gmaps.LatLng]).
///
/// The screen location is in pixels relative to the top left of the Map widget
/// (not of the whole screen/app).
///
/// See: https://developers.google.com/maps/documentation/android-sdk/reference/com/google/android/libraries/maps/Projection#public-point-toscreenlocation-latlng-location
gmaps.Point toScreenLocation(gmaps.Map map, gmaps.LatLng coords) {
  assert(map.bounds != null,
      'Map Bounds required to compute screen x/y of LatLng.');
  assert(map.projection != null,
      'Map Projection required to compute screen x/y of LatLng.');
  assert(map.isZoomDefined(),
      'Current map zoom level required to compute screen x/y of LatLng.');

  final gmaps.LatLngBounds bounds = map.bounds!;
  final gmaps.Projection projection = map.projection!;
  final num zoom = map.zoom;

  final gmaps.LatLng ne = bounds.northEast;
  final gmaps.LatLng sw = bounds.southWest;

  final gmaps.Point topRight = projection.fromLatLngToPoint(ne)!;
  final gmaps.Point bottomLeft = projection.fromLatLngToPoint(sw)!;

  final int scale = 1 << (zoom.toInt()); // 2 ^ zoom

  final gmaps.Point worldPoint = projection.fromLatLngToPoint(coords)!;

  return gmaps.Point(
    ((worldPoint.x - bottomLeft.x) * scale).toInt(),
    ((worldPoint.y - topRight.y) * scale).toInt(),
  );
}
