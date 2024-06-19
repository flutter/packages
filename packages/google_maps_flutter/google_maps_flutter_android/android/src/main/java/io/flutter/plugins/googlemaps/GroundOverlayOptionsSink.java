// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.BitmapDescriptor;

interface GroundOverlayOptionsSink {
  void setConsumeTapEvents(boolean consumeTapEvents);

  void setVisible(boolean visible);

  void setZIndex(float zIndex);

  void setPosition(Object position, Object width, Object height, Object bounds);

  void setBitmapDescriptor(BitmapDescriptor bd);

  void setBearing(float bearing);

  void setTransparency(float transparency);
}
