// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.GroundOverlayOptions;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;

class GroundOverlayBuilder implements GroundOverlayOptionsSink {
    private final GroundOverlayOptions groundOverlayOptions;
    private boolean consumeTapEvents;

    GroundOverlayBuilder() {
      this.groundOverlayOptions = new GroundOverlayOptions();
    }

    GroundOverlayOptions build() {
      return groundOverlayOptions;
    }

    /** Update existing groundOverlayOptions with builder values */
    void update(GroundOverlayOptions groundOverlayOptionsToUpdate) {
      groundOverlayOptionsToUpdate.bearing(groundOverlayOptions.getBearing());
      groundOverlayOptionsToUpdate.anchor(groundOverlayOptions.getAnchorU(), groundOverlayOptions.getAnchorV());
      groundOverlayOptionsToUpdate.clickable(groundOverlayOptions.isClickable());
      groundOverlayOptionsToUpdate.image(groundOverlayOptions.getImage());
      groundOverlayOptionsToUpdate.position(groundOverlayOptions.getLocation(), groundOverlayOptions.getWidth(), groundOverlayOptions.getHeight());
      groundOverlayOptionsToUpdate.transparency(groundOverlayOptions.getTransparency());
      groundOverlayOptionsToUpdate.visible(groundOverlayOptions.isVisible());
      groundOverlayOptionsToUpdate.zIndex(groundOverlayOptions.getZIndex());
    }

    boolean consumeTapEvents() {
      return consumeTapEvents;
    }

    @Override
    public void setConsumeTapEvents(boolean consumeTapEvents) {
      this.consumeTapEvents = consumeTapEvents;
      groundOverlayOptions.clickable(consumeTapEvents);
    }

    @Override
    public void setVisible(boolean visible) {
      groundOverlayOptions.visible(visible);
    }

    @Override
    public void setZIndex(float zIndex) {
      groundOverlayOptions.zIndex(zIndex);
    }

    @Override
    public void setPosition(Object position, Object width, Object height, Object bounds) {
        if (height != null) {
            groundOverlayOptions.position((LatLng) position, (float) width, (float) height);
        } else {
            if (width != null) {
                groundOverlayOptions.position((LatLng) position, (float) width);
            } else {
                groundOverlayOptions.positionFromBounds((LatLngBounds) bounds);
            }
        }
    }

    @Override
    public void setIcon(BitmapDescriptor bitmapDescriptor) {
    groundOverlayOptions.image(bitmapDescriptor);
    }

    @Override
    public void setBearing(float bearing) {
      groundOverlayOptions.bearing(bearing);
    }

    @Override
    public void setTransparency(float transparency) {
      groundOverlayOptions.transparency(transparency);
    }
}