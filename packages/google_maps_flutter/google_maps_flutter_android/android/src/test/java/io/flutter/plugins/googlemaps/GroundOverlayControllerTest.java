// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.os.Build;
import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.GroundOverlay;
import com.google.android.gms.maps.model.LatLng;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
@Config(sdk = Build.VERSION_CODES.P)
public class GroundOverlayControllerTest {
  @Mock
  private GroundOverlay mockGroundOverlay;

  private GroundOverlayController groundOverlayController;

  @Before
  public void setUp() {
    MockitoAnnotations.initMocks(this);
    groundOverlayController = new GroundOverlayController(mockGroundOverlay, false);
  }

  @Test
  public void setConsumeTapEvents_true() {
    groundOverlayController.setConsumeTapEvents(true);
    verify(mockGroundOverlay).setClickable(true);
  }

  @Test
  public void setVisible_true() {
    groundOverlayController.setVisible(true);
    verify(mockGroundOverlay).setVisible(true);
  }

  @Test
  public void setZIndex() {
    float zIndex = 1.0f;
    groundOverlayController.setZIndex(zIndex);
    verify(mockGroundOverlay).setZIndex(zIndex);
  }

  @Test
  public void setPosition_withLatLng() {
    LatLng position = new LatLng(10, 20);
    float width = 30.0f;
    float height = 40.0f;
    groundOverlayController.setPosition(position, width, height, null);
    verify(mockGroundOverlay).setPosition(position);
    verify(mockGroundOverlay).setDimensions(width, height);
  }

  @Test
  public void setIcon() {
    BitmapDescriptor icon = mock(BitmapDescriptor.class);
    groundOverlayController.setIcon(icon);
    verify(mockGroundOverlay).setImage(icon);
  }

  @Test
  public void setBearing() {
    float bearing = 45.0f;
    groundOverlayController.setBearing(bearing);
    verify(mockGroundOverlay).setBearing(bearing);
  }

  @Test
  public void setTransparency() {
    float transparency = 0.5f;
    groundOverlayController.setTransparency(transparency);
    verify(mockGroundOverlay).setTransparency(transparency);
  }

  @Test
  public void getGoogleMapsGroundOverlayId() {
    String expectedId = "groundOverlayId";
    when(mockGroundOverlay.getId()).thenReturn(expectedId);
    String actualId = groundOverlayController.getGoogleMapsGroundOverlayId();
    assertEquals(expectedId, actualId);
  }

  @Test
  public void consumeTapEvents() {
    boolean expectedValue = true;
    groundOverlayController.setConsumeTapEvents(expectedValue);
    boolean actualValue = groundOverlayController.consumeTapEvents();
    assertEquals(expectedValue, actualValue);
  }
}