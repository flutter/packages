// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static org.mockito.Mockito.any;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

import android.content.Context;
import androidx.test.core.app.ApplicationProvider;
import com.google.android.gms.maps.MapsInitializer.Renderer;
import io.flutter.plugin.common.BinaryMessenger;
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
    @SuppressWarnings("unchecked")
    Result<PlatformRendererType> result = mock(Result.class);
    googleMapInitializer.initializeWithPreferredRenderer(PlatformRendererType.LATEST, result);
    googleMapInitializer.onMapsSdkInitialized(Renderer.LATEST);
    verify(result, times(1)).success(PlatformRendererType.LATEST);
    verify(result, never()).error(any());
  }

  @SuppressWarnings("deprecation")
  @Test
  public void initializer_OnMapsSdkInitializedWithLegacyRenderer() {
    doNothing().when(googleMapInitializer).initializeWithRendererRequest(Renderer.LEGACY);
    @SuppressWarnings("unchecked")
    Result<PlatformRendererType> result = mock(Result.class);
    googleMapInitializer.initializeWithPreferredRenderer(PlatformRendererType.LEGACY, result);
    googleMapInitializer.onMapsSdkInitialized(Renderer.LEGACY);
    verify(result, times(1)).success(PlatformRendererType.LEGACY);
    verify(result, never()).error(any());
  }

  @Test
  public void initializer_onMethodCallWithNoRendererPreference() {
    doNothing().when(googleMapInitializer).initializeWithRendererRequest(null);
    @SuppressWarnings("unchecked")
    Result<PlatformRendererType> result = mock(Result.class);
    googleMapInitializer.initializeWithPreferredRenderer(null, result);
    verify(result, never()).error(any());
  }
}
