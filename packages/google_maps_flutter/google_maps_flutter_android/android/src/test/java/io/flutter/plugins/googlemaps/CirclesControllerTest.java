// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.google.android.gms.internal.maps.zzl;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.Circle;
import com.google.android.gms.maps.model.CircleOptions;
import java.util.Collections;
import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

public class CirclesControllerTest {
  @Mock GoogleMap mockGoogleMap;
  AutoCloseable mockCloseable;

  @Before
  public void setUp() {
    mockCloseable = MockitoAnnotations.openMocks(this);
  }

  @After
  public void tearDown() throws Exception {
    mockCloseable.close();
  }

  @Test
  public void controller_changeCircles_updatesExistingCircle() {
    final zzl z = mock(zzl.class);
    final Circle circle = spy(new Circle(z));
    when(mockGoogleMap.addCircle(any(CircleOptions.class))).thenReturn(circle);

    final CirclesController controller = new CirclesController(null, 1.0f);
    controller.setGoogleMap(mockGoogleMap);

    final String id = "a_circle";

    final Messages.PlatformCircle.Builder builder = new Messages.PlatformCircle.Builder();
    builder
        .setCircleId(id)
        .setConsumeTapEvents(false)
        .setFillColor(0L)
        .setCenter(new Messages.PlatformLatLng.Builder().setLatitude(0.0).setLongitude(0.0).build())
        .setRadius(1.0)
        .setStrokeColor(0L)
        .setStrokeWidth(1L)
        .setVisible(true)
        .setZIndex(0.0);

    controller.addCircles(Collections.singletonList(builder.build()));
    // There should be exactly one circle.
    Assert.assertEquals(1, controller.circleIdToController.size());

    builder.setConsumeTapEvents(true);
    controller.changeCircles(Collections.singletonList(builder.build()));
    // There should still only be one circle, and it should be updated.
    Assert.assertEquals(1, controller.circleIdToController.size());
    verify(circle, times(1)).setClickable(true);
  }
}
