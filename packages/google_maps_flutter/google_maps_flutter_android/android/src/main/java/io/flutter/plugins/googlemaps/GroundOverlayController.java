// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.GroundOverlay;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;

/** Controller of a single Ground Overlay on the map. */
class GroundOverlayController implements GroundOverlayOptionsSink {
  private final GroundOverlay groundOverlay;
  private final String googleMapsGroundOverlayId;
  private boolean consumeTapEvents;

  GroundOverlayController(GroundOverlay groundOverlay, boolean consumeTapEvents) {
      this.groundOverlay = groundOverlay;
      this.consumeTapEvents = consumeTapEvents;
      this.googleMapsGroundOverlayId = groundOverlay.getId();
  }

  void remove() {
    groundOverlay.remove();
  }

  @Override
  public void setConsumeTapEvents(boolean consumeTapEvents) {
    this.consumeTapEvents = consumeTapEvents;
  }

  @Override
  public void setVisible(boolean visible) {
    groundOverlay.setVisible(visible);
  }

  @Override
  public void setZIndex(float zIndex) {
    groundOverlay.setZIndex(zIndex);
  }

  @Override
  public void setPosition(Object position, Object width, Object height, Object bounds) {
    if (height != null && width != null) {
      groundOverlay.setDimensions((float) width, (float) height);
    } else {
      if (width != null) {
        groundOverlay.setDimensions((float) width);
      }
    }
    if (position != null) {
      groundOverlay.setPosition((LatLng) position);
    }
    if (bounds != null) {
      groundOverlay.setPositionFromBounds((LatLngBounds) bounds);
    }
  }

  @Override
  public void setIcon(BitmapDescriptor bitmapDescriptor) {
    groundOverlay.setImage(bitmapDescriptor);
  }

  @Override
  public void setBearing(float bearing) {
    groundOverlay.setBearing(bearing);
  }

  @Override
  public void setTransparency(float transparency) {
    groundOverlay.setTransparency(transparency);
  }

  String getGoogleMapsGroundOverlayId() {
    return googleMapsGroundOverlayId;
  }

  boolean consumeTapEvents() {
    return consumeTapEvents;
  }
}