// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.Cap;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.PatternItem;
import java.util.List;

/** Receiver of Polyline configuration options. */
interface PolylineOptionsSink {

  void setConsumeTapEvents(boolean consumetapEvents);

  void setColor(int color);

  void setEndCap(Cap endCap);

  void setGeodesic(boolean geodesic);

  void setJointType(int jointType);

  void setPattern(List<PatternItem> pattern);

  void setPoints(List<LatLng> points);

  void setStartCap(Cap startCap);

  void setVisible(boolean visible);

  void setWidth(float width);

  void setZIndex(float zIndex);
}
