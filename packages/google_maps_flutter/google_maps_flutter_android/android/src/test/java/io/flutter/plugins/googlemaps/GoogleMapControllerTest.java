// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

import android.content.Context;
import android.os.Build;
import androidx.activity.ComponentActivity;
import androidx.test.core.app.ApplicationProvider;
import com.google.android.gms.maps.GoogleMap;
import io.flutter.plugin.common.BinaryMessenger;
import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.robolectric.Robolectric;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
@Config(sdk = Build.VERSION_CODES.P)
public class GoogleMapControllerTest {

  private Context context;
  private ComponentActivity activity;
  private GoogleMapController googleMapController;

  AutoCloseable mockCloseable;
  @Mock BinaryMessenger mockMessenger;
  @Mock GoogleMap mockGoogleMap;

  @Before
  public void before() {
    mockCloseable = MockitoAnnotations.openMocks(this);
    context = ApplicationProvider.getApplicationContext();
    setUpActivityLegacy();
    googleMapController =
        new GoogleMapController(0, context, mockMessenger, activity::getLifecycle, null);
    googleMapController.init();
  }

  // TODO(stuartmorgan): Update this to a non-deprecated test API.
  // See https://github.com/flutter/flutter/issues/122102
  @SuppressWarnings("deprecation")
  private void setUpActivityLegacy() {
    activity = Robolectric.setupActivity(ComponentActivity.class);
  }

  @After
  public void tearDown() throws Exception {
    mockCloseable.close();
  }

  @Test
  public void DisposeReleaseTheMap() throws InterruptedException {
    googleMapController.onMapReady(mockGoogleMap);
    assertTrue(googleMapController != null);
    googleMapController.dispose();
    assertNull(googleMapController.getView());
  }

  @Test
  public void OnDestroyReleaseTheMap() throws InterruptedException {
    googleMapController.onMapReady(mockGoogleMap);
    assertTrue(googleMapController != null);
    googleMapController.onDestroy(activity);
    assertNull(googleMapController.getView());
  }

  @Test
  public void OnMapReadySetsPaddingIfInitialPaddingIsThere() {
    float padding = 10f;
    int paddingWithDensity = (int) (padding * googleMapController.density);
    googleMapController.setInitialPadding(padding, padding, padding, padding);
    googleMapController.onMapReady(mockGoogleMap);
    verify(mockGoogleMap, times(1))
        .setPadding(paddingWithDensity, paddingWithDensity, paddingWithDensity, paddingWithDensity);
  }

  @Test
  public void SetPaddingStoresThePaddingValuesInInInitialPaddingWhenGoogleMapIsNull() {
    assertNull(googleMapController.initialPadding);
    googleMapController.setPadding(0f, 0f, 0f, 0f);
    assertNotNull(googleMapController.initialPadding);
    Assert.assertEquals(4, googleMapController.initialPadding.size());
  }
}
