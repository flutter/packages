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
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
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
    final Map<String, Object> circleJson = new HashMap<>();
    circleJson.put("circleId", id);
    circleJson.put("consumeTapEvents", false);
    circleJson.put("fillColor", 0);
    circleJson.put("center", Arrays.asList(0.0, 0.0));
    circleJson.put("radius", 1.0);
    circleJson.put("strokeColor", 0);
    circleJson.put("strokeWidth", 1.0);
    circleJson.put("visible", true);
    circleJson.put("zIndex", 0);

    controller.addCircles(
        Collections.singletonList(
            new Messages.PlatformCircle.Builder().setJson(circleJson).build()));
    // There should be exactly one circle.
    Assert.assertEquals(1, controller.circleIdToController.size());

    circleJson.put("consumeTapEvents", true);
    controller.changeCircles(
        Collections.singletonList(
            new Messages.PlatformCircle.Builder().setJson(circleJson).build()));
    // There should still only be one circle, and it should be updated.
    Assert.assertEquals(1, controller.circleIdToController.size());
    verify(circle, times(1)).setClickable(true);
  }
}
