// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static junit.framework.TestCase.assertEquals;

import com.google.android.gms.maps.model.GroundOverlayOptions;
import org.junit.Test;

public class GroundOverlayBuilderTest {
  @Test
  public void setConsumeTapEvents_True_SetsClickableTrue() {
    GroundOverlayBuilder builder = new GroundOverlayBuilder();
    builder.setConsumeTapEvents(true);

    GroundOverlayOptions options = builder.build();
    assertTrue(options.isClickable());
  }

  @Test
  public void setVisible_True_SetsVisibleTrue() {
    GroundOverlayBuilder builder = new GroundOverlayBuilder();
    builder.setVisible(true);

    GroundOverlayOptions options = builder.build();
    assertTrue(options.isVisible());
  }

  @Test
  public void setZIndex_SetsCorrectZIndex() {
    GroundOverlayBuilder builder = new GroundOverlayBuilder();
    float zIndex = 5.0f;
    builder.setZIndex(zIndex);

    GroundOverlayOptions options = builder.build();
    assertEquals(zIndex, options.getZIndex());
  }

  @Test
  public void setPosition_WithLatLngWidthHeight_SetsCorrectPositionAndDimensions() {
    GroundOverlayBuilder builder = new GroundOverlayBuilder();
    LatLng position = new LatLng(10, 20);
    float width = 100.0f;
    float height = 50.0f;
    builder.setPosition(position, width, height, null);

    GroundOverlayOptions options = builder.build();
    assertEquals(position, options.getLocation());
    assertEquals(width, options.getWidth());
    assertEquals(height, options.getHeight());
  }

  @Test
  public void setIcon_SetsCorrectIcon() {
    GroundOverlayBuilder builder = new GroundOverlayBuilder();
    BitmapDescriptor icon = BitmapDescriptorFactory.defaultMarker();
    builder.setIcon(icon);

    GroundOverlayOptions options = builder.build();
    assertEquals(icon, options.getImage());
  }

  @Test
  public void setBearing_SetsCorrectBearing() {
    GroundOverlayBuilder builder = new GroundOverlayBuilder();
    float bearing = 45.0f;
    builder.setBearing(bearing);

    GroundOverlayOptions options = builder.build();
    assertEquals(bearing, options.getBearing());
  }

  @Test
  public void setAnchor_SetsCorrectAnchor() {
    GroundOverlayBuilder builder = new GroundOverlayBuilder();
    float u = 0.5f;
    float v = 0.5f;
    builder.setAnchor(u, v);

    GroundOverlayOptions options = builder.build();
    assertEquals(u, options.getAnchorU());
    assertEquals(v, options.getAnchorV());
  }

  @Test
  public void setTransparency_SetsCorrectTransparency() {
    GroundOverlayBuilder builder = new GroundOverlayBuilder();
    float transparency = 0.5f;
    builder.setTransparency(transparency);

    GroundOverlayOptions options = builder.build();
    assertEquals(transparency, options.getTransparency());
  }
}