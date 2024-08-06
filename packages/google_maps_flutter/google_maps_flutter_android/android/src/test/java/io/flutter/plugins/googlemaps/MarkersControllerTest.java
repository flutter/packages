// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.when;

import android.content.Context;
import android.content.res.AssetManager;
import android.os.Build;
import androidx.test.core.app.ApplicationProvider;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.maps.android.collections.MarkerManager;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.googlemaps.Messages.MapsCallbackApi;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
@Config(sdk = Build.VERSION_CODES.P)
public class MarkersControllerTest {
  private Context context;
  private MapsCallbackApi flutterApi;
  private ClusterManagersController clusterManagersController;
  private MarkersController controller;
  private GoogleMap googleMap;
  private MarkerManager markerManager;
  private MarkerManager.Collection markerCollection;
  private AssetManager assetManager;
  private final float density = 1;

  @Before
  public void setUp() {
    MockitoAnnotations.openMocks(this);
    assetManager = ApplicationProvider.getApplicationContext().getAssets();
    context = ApplicationProvider.getApplicationContext();
    flutterApi = spy(new MapsCallbackApi(mock(BinaryMessenger.class)));
    clusterManagersController = spy(new ClusterManagersController(flutterApi, context));
    controller =
        new MarkersController(flutterApi, clusterManagersController, assetManager, density);
    googleMap = mock(GoogleMap.class);
    markerManager = new MarkerManager(googleMap);
    markerCollection = markerManager.newCollection();
    controller.setCollection(markerCollection);
    clusterManagersController.init(googleMap, markerManager);
  }

  @Test
  public void controller_OnMarkerDragStart() {
    final Marker marker = mock(Marker.class);

    final String googleMarkerId = "abc123";

    when(marker.getId()).thenReturn(googleMarkerId);
    when(googleMap.addMarker(any(MarkerOptions.class))).thenReturn(marker);

    final LatLng latLng = new LatLng(1.1, 2.2);

    final List<Messages.PlatformMarker> markers = Collections.singletonList(new Messages.PlatformMarker.Builder().setMarkerId(googleMarkerId).build());
    controller.addMarkers(markers);
    controller.onMarkerDragStart(googleMarkerId, latLng);

    Mockito.verify(flutterApi)
        .onMarkerDragStart(eq(googleMarkerId), eq(Convert.latLngToPigeon(latLng)), any());
  }

  @Test
  public void controller_OnMarkerDragEnd() {
    final Marker marker = mock(Marker.class);

    final String googleMarkerId = "abc123";

    when(marker.getId()).thenReturn(googleMarkerId);
    when(googleMap.addMarker(any(MarkerOptions.class))).thenReturn(marker);

    final LatLng latLng = new LatLng(1.1, 2.2);

    final List<Messages.PlatformMarker> markers = Collections.singletonList(new Messages.PlatformMarker.Builder().setMarkerId(googleMarkerId).build());
    controller.addMarkers(markers);
    controller.onMarkerDragEnd(googleMarkerId, latLng);

    Mockito.verify(flutterApi)
        .onMarkerDragEnd(eq(googleMarkerId), eq(Convert.latLngToPigeon(latLng)), any());
  }

  @Test
  public void controller_OnMarkerDrag() {
    final Marker marker = mock(Marker.class);

    final String googleMarkerId = "abc123";

    when(marker.getId()).thenReturn(googleMarkerId);
    when(googleMap.addMarker(any(MarkerOptions.class))).thenReturn(marker);

    final LatLng latLng = new LatLng(1.1, 2.2);

    final List<Messages.PlatformMarker> markers = Collections.singletonList(new Messages.PlatformMarker.Builder().setMarkerId(googleMarkerId).build());
    controller.addMarkers(markers);
    controller.onMarkerDrag(googleMarkerId, latLng);

    Mockito.verify(flutterApi)
        .onMarkerDrag(eq(googleMarkerId), eq(Convert.latLngToPigeon(latLng)), any());
  }

  @Test(expected = IllegalArgumentException.class)
  public void controller_AddMarkerThrowsErrorIfMarkerIdIsNull() {
    final Map<String, String> markerOptions = new HashMap<>();

    final List<Messages.PlatformMarker> markers = Collections.singletonList(new Messages.PlatformMarker.Builder().build());
    try {
      controller.addMarkers(markers);
    } catch (IllegalArgumentException e) {
      assertEquals("markerId was null", e.getMessage());
      throw e;
    }
  }

  @Test
  public void controller_AddChangeAndRemoveMarkerWithClusterManagerId() {
    final Marker marker = mock(Marker.class);

    final String googleMarkerId = "abc123";
    final String clusterManagerId = "cm123";

    final Messages.PlatformMarker.Builder builder = new Messages.PlatformMarker.Builder();
    builder.setMarkerId(googleMarkerId)
            .setClusterManagerId(clusterManagerId)
            .setPosition(new Messages.PlatformLatLng.Builder().setLatitude(1.1).setLongitude(2.2).build());

    when(marker.getId()).thenReturn(googleMarkerId);

    // Add marker and capture the markerBuilder
    controller.addMarkers(Collections.singletonList(builder.build()));
    ArgumentCaptor<MarkerBuilder> captor = ArgumentCaptor.forClass(MarkerBuilder.class);
    Mockito.verify(clusterManagersController, times(1)).addItem(captor.capture());
    MarkerBuilder capturedMarkerBuilder = captor.getValue();
    assertEquals(clusterManagerId, capturedMarkerBuilder.clusterManagerId());

    // clusterManagersController calls onClusterItemRendered with created marker.
    controller.onClusterItemRendered(capturedMarkerBuilder, marker);

    // Change marker to test that markerController is created and the marker can be updated
    final LatLng latLng2 = new LatLng(3.3, 4.4);

    builder.setPosition(new Messages.PlatformLatLng.Builder().setLatitude(3.3).setLongitude(4.4).build());
    final List<Messages.PlatformMarker> updatedMarkers =
        Collections.singletonList(builder.build());

    controller.changeMarkers(updatedMarkers);
    Mockito.verify(marker, times(1)).setPosition(latLng2);

    // Remove marker
    controller.removeMarkers(Arrays.asList(googleMarkerId));

    Mockito.verify(clusterManagersController, times(1))
        .removeItem(
            Mockito.argThat(
                markerBuilder -> markerBuilder.clusterManagerId().equals(clusterManagerId)));
  }

  @Test
  public void controller_AddChangeAndRemoveMarkerWithoutClusterManagerId() {
    MarkerManager.Collection spyMarkerCollection = spy(markerCollection);
    controller.setCollection(spyMarkerCollection);

    final Marker marker = mock(Marker.class);

    final String googleMarkerId = "abc123";

    when(marker.getId()).thenReturn(googleMarkerId);
    when(googleMap.addMarker(any(MarkerOptions.class))).thenReturn(marker);

    final Messages.PlatformMarker.Builder builder = new Messages.PlatformMarker.Builder();
    builder.setMarkerId(googleMarkerId);
    controller.addMarkers(Collections.singletonList(builder.build()));

    // clusterManagersController should not be called when adding the marker
    Mockito.verify(clusterManagersController, times(0)).addItem(any());

    Mockito.verify(spyMarkerCollection, times(1)).addMarker(any(MarkerOptions.class));

    final float alpha = 0.1f;

    final List<Messages.PlatformMarker> markerUpdates =
        Collections.singletonList(builder.setAlpha((double) alpha).build());
    controller.changeMarkers(markerUpdates);
    Mockito.verify(marker, times(1)).setAlpha(alpha);

    controller.removeMarkers(Arrays.asList(googleMarkerId));

    // clusterManagersController should not be called when removing the marker
    Mockito.verify(clusterManagersController, times(0)).removeItem(any());

    Mockito.verify(spyMarkerCollection, times(1)).remove(marker);
  }
}
