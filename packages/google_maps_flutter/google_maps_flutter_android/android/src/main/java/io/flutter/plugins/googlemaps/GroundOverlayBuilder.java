// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import androidx.annotation.Nullable;
import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.GroundOverlayOptions;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;

class GroundOverlayBuilder implements GroundOverlaySink {

  private final GroundOverlayOptions groundOverlayOptions;

  GroundOverlayBuilder() {
    this.groundOverlayOptions = new GroundOverlayOptions();
  }

  GroundOverlayOptions build() {
    return groundOverlayOptions;
  }

  @Override
  public void setTransparency(float transparency) {
    groundOverlayOptions.transparency(transparency);
  }

  @Override
  public void setZIndex(float zIndex) {
    groundOverlayOptions.zIndex(zIndex);
  }

  @Override
  public void setVisible(boolean visible) {
    groundOverlayOptions.visible(visible);
  }

  @Override
  public void setAnchor(float u, float v) {
    groundOverlayOptions.anchor(u, v);
  }

  @Override
  public void setBearing(float bearing) {
    groundOverlayOptions.bearing(bearing);
  }

  @Override
  public void setClickable(boolean clickable) {
    groundOverlayOptions.clickable(clickable);
  }

  @Override
  public void setPosition(LatLng location, Float width, @Nullable Float height) {
    if (location != null && width != null) {
      if (height != null) {
        groundOverlayOptions.position(location, width, height);
      } else {
        groundOverlayOptions.position(location, width);
      }
    } else {
      throw new IllegalArgumentException(
          "Position and width must be provided, height is optional.");
    }
  }

  @Override
  public void setPositionFromBounds(LatLngBounds bounds) {
    if (bounds != null) {
      groundOverlayOptions.positionFromBounds(bounds);
    } else {
      throw new IllegalArgumentException("Bounds must be provided.");
    }
  }

  @Override
  public void setImage(BitmapDescriptor image) {
    groundOverlayOptions.image(image);
  }
}
