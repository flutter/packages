// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;

/** Receiver of GroundOverlayOptions configuration. */
interface GroundOverlaySink {
  void setTransparency(float transparency);

  void setZIndex(float zIndex);

  void setVisible(boolean visible);

  void setAnchor(float u, float v);

  void setBearing(float bearing);

  void setClickable(boolean clickable);

  void setImage(@NonNull BitmapDescriptor imageDescriptor);

  void setPosition(@NonNull LatLng location, @NonNull Float width, @Nullable Float height);

  void setPositionFromBounds(@NonNull LatLngBounds bounds);
}
