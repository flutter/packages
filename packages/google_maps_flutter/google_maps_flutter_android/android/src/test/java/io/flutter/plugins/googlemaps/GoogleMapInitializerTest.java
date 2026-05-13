// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.spy;

import android.content.Context;
import androidx.test.core.app.ApplicationProvider;
import com.google.android.gms.maps.MapsInitializer.Renderer;
import io.flutter.plugin.common.BinaryMessenger;
import kotlin.Unit;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class GoogleMapInitializerTest {
  private GoogleMapInitializer googleMapInitializer;

  @Mock BinaryMessenger mockMessenger;

  @Before
  public void before() {
    MockitoAnnotations.openMocks(this);
    Context context = ApplicationProvider.getApplicationContext();
    googleMapInitializer = spy(new GoogleMapInitializer(context, mockMessenger));
  }

  @Test
  public void initializer_OnMapsSdkInitializedWithLatestRenderer() {
    doNothing().when(googleMapInitializer).initializeWithRendererRequest(Renderer.LATEST);
    final Boolean[] callbackCalled = new Boolean[1];
    googleMapInitializer.initializeWithPreferredRenderer(
        PlatformRendererType.LATEST,
        ResultCompat.asCompatCallback(
            result -> {
              callbackCalled[0] = true;
              PlatformRendererType type = result.getOrNull();
              assertEquals(PlatformRendererType.LATEST, type);
              return Unit.INSTANCE;
            }));
    googleMapInitializer.onMapsSdkInitialized(Renderer.LATEST);

    assertTrue(callbackCalled[0]);
  }

  @SuppressWarnings("deprecation")
  @Test
  public void initializer_OnMapsSdkInitializedWithLegacyRenderer() {
    doNothing().when(googleMapInitializer).initializeWithRendererRequest(Renderer.LEGACY);
    final Boolean[] callbackCalled = new Boolean[1];
    googleMapInitializer.initializeWithPreferredRenderer(
        PlatformRendererType.LEGACY,
        ResultCompat.asCompatCallback(
            result -> {
              callbackCalled[0] = true;
              PlatformRendererType type = result.getOrNull();
              assertEquals(PlatformRendererType.LEGACY, type);
              return Unit.INSTANCE;
            }));
    googleMapInitializer.onMapsSdkInitialized(Renderer.LEGACY);

    assertTrue(callbackCalled[0]);
  }

  @Test
  public void initializer_onMethodCallWithNoRendererPreference() {
    doNothing().when(googleMapInitializer).initializeWithRendererRequest(null);
    final Boolean[] callbackCalled = new Boolean[1];
    googleMapInitializer.initializeWithPreferredRenderer(
        null,
        ResultCompat.asCompatCallback(
            result -> {
              callbackCalled[0] = true;
              Throwable error = result.exceptionOrNull();
              assertNull(error);
              return Unit.INSTANCE;
            }));
    googleMapInitializer.onMapsSdkInitialized(Renderer.LATEST);

    assertTrue(callbackCalled[0]);
  }
}
