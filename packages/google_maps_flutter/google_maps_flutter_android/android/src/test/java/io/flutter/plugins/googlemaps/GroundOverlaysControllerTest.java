// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.when;

import android.content.Context;
import android.content.res.AssetManager;
import android.util.Base64;
import androidx.annotation.NonNull;
import androidx.test.core.app.ApplicationProvider;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.GroundOverlay;
import com.google.android.gms.maps.model.GroundOverlayOptions;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.googlemaps.Convert.BitmapDescriptorFactoryWrapper;
import java.util.Collections;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class GroundOverlaysControllerTest {
  @Mock private BitmapDescriptorFactoryWrapper bitmapDescriptorFactoryWrapper;
  @Mock private BitmapDescriptor mockBitmapDescriptor;

  AutoCloseable mockCloseable;

  private GroundOverlaysController controller;
  private GoogleMap googleMap;

  // A 1x1 pixel (#8080ff) PNG image encoded in base64
  private final String base64Image = TestImageUtils.generateBase64Image();

  @NonNull
  private Messages.PlatformGroundOverlay.Builder defaultGroundOverlayBuilder() {
    byte[] bmpData = Base64.decode(base64Image, Base64.DEFAULT);

    return new Messages.PlatformGroundOverlay.Builder()
        .setImage(
            new Messages.PlatformBitmap.Builder()
                .setBitmap(
                    new Messages.PlatformBitmapBytesMap.Builder()
                        .setBitmapScaling(Messages.PlatformMapBitmapScaling.AUTO)
                        .setImagePixelRatio(2.0)
                        .setByteData(bmpData)
                        .setWidth(100.0)
                        .build())
                .build())
        .setBearing(1.0)
        .setZIndex(1L)
        .setVisible(true)
        .setTransparency(1.0)
        .setClickable(true);
  }

  @Before
  public void setUp() {
    mockCloseable = MockitoAnnotations.openMocks(this);
    Context context = ApplicationProvider.getApplicationContext();
    AssetManager assetManager = context.getAssets();
    Messages.MapsCallbackApi flutterApi =
        spy(new Messages.MapsCallbackApi(mock(BinaryMessenger.class)));
    controller =
        spy(
            new GroundOverlaysController(
                flutterApi, assetManager, 1.0f, bitmapDescriptorFactoryWrapper));
    googleMap = mock(GoogleMap.class);
    controller.setGoogleMap(googleMap);
    when(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor);
  }

  @After
  public void tearDown() throws Exception {
    mockCloseable.close();
  }

  @Test
  public void controller_AddChangeAndRemoveGroundOverlay() {
    final GroundOverlay groundOverlay = mock(GroundOverlay.class);
    final String googleGroundOverlayId = "abc123";
    final float transparency = 0.1f;

    when(groundOverlay.getId()).thenReturn(googleGroundOverlayId);
    when(googleMap.addGroundOverlay(any(GroundOverlayOptions.class))).thenReturn(groundOverlay);

    controller.addGroundOverlays(
        Collections.singletonList(
            defaultGroundOverlayBuilder()
                .setGroundOverlayId(googleGroundOverlayId)
                .setTransparency((double) transparency)
                .build()));
    Mockito.verify(googleMap, times(1))
        .addGroundOverlay(Mockito.argThat(argument -> argument.getTransparency() == transparency));

    final float newTransparency = 0.2f;
    controller.changeGroundOverlays(
        Collections.singletonList(
            defaultGroundOverlayBuilder()
                .setGroundOverlayId(googleGroundOverlayId)
                .setTransparency((double) newTransparency)
                .build()));
    Mockito.verify(groundOverlay, times(1)).setTransparency(newTransparency);

    controller.removeGroundOverlays(Collections.singletonList(googleGroundOverlayId));

    Mockito.verify(groundOverlay, times(1)).remove();
  }
}
