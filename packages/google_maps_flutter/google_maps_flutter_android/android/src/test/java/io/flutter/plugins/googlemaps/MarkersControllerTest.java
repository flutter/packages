// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
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
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodCodec;
import java.util.ArrayList;
import java.util.Arrays;
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
  private MethodChannel methodChannel;
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
    methodChannel =
        spy(new MethodChannel(mock(BinaryMessenger.class), "no-name", mock(MethodCodec.class)));
    clusterManagersController = spy(new ClusterManagersController(methodChannel, context));
    controller =
        new MarkersController(methodChannel, clusterManagersController, assetManager, density);
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
    final Map<String, String> markerOptions = new HashMap<>();
    markerOptions.put("markerId", googleMarkerId);

    final List<Object> markers = Arrays.<Object>asList(markerOptions);
    controller.addMarkers(markers);
    controller.onMarkerDragStart(googleMarkerId, latLng);

    final List<Double> points = new ArrayList<>();
    points.add(latLng.latitude);
    points.add(latLng.longitude);

    final Map<String, Object> data = new HashMap<>();
    data.put("markerId", googleMarkerId);
    data.put("position", points);
    Mockito.verify(methodChannel).invokeMethod("marker#onDragStart", data);
  }

  @Test
  public void controller_OnMarkerDragEnd() {
    final Marker marker = mock(Marker.class);

    final String googleMarkerId = "abc123";

    when(marker.getId()).thenReturn(googleMarkerId);
    when(googleMap.addMarker(any(MarkerOptions.class))).thenReturn(marker);

    final LatLng latLng = new LatLng(1.1, 2.2);
    final Map<String, String> markerOptions = new HashMap<>();
    markerOptions.put("markerId", googleMarkerId);

    final List<Object> markers = Arrays.<Object>asList(markerOptions);
    controller.addMarkers(markers);
    controller.onMarkerDragEnd(googleMarkerId, latLng);

    final List<Double> points = new ArrayList<>();
    points.add(latLng.latitude);
    points.add(latLng.longitude);

    final Map<String, Object> data = new HashMap<>();
    data.put("markerId", googleMarkerId);
    data.put("position", points);
    Mockito.verify(methodChannel).invokeMethod("marker#onDragEnd", data);
  }

  @Test
  public void controller_OnMarkerDrag() {
    final Marker marker = mock(Marker.class);

    final String googleMarkerId = "abc123";

    when(marker.getId()).thenReturn(googleMarkerId);
    when(googleMap.addMarker(any(MarkerOptions.class))).thenReturn(marker);

    final LatLng latLng = new LatLng(1.1, 2.2);
    final Map<String, String> markerOptions = new HashMap<>();
    markerOptions.put("markerId", googleMarkerId);

    final List<Object> markers = Arrays.<Object>asList(markerOptions);
    controller.addMarkers(markers);
    controller.onMarkerDrag(googleMarkerId, latLng);

    final List<Double> points = new ArrayList<>();
    points.add(latLng.latitude);
    points.add(latLng.longitude);

    final Map<String, Object> data = new HashMap<>();
    data.put("markerId", googleMarkerId);
    data.put("position", points);
    Mockito.verify(methodChannel).invokeMethod("marker#onDrag", data);
  }

  @Test(expected = IllegalArgumentException.class)
  public void controller_AddMarkerThrowsErrorIfMarkerIdIsNull() {
    final Map<String, String> markerOptions = new HashMap<>();

    final List<Object> markers = Arrays.<Object>asList(markerOptions);
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

    when(marker.getId()).thenReturn(googleMarkerId);

    final LatLng latLng1 = new LatLng(1.1, 2.2);
    final List<Double> location1 = new ArrayList<>();
    location1.add(latLng1.latitude);
    location1.add(latLng1.longitude);

    final Map<String, Object> markerOptions1 = new HashMap<>();
    markerOptions1.put("markerId", googleMarkerId);
    markerOptions1.put("position", location1);
    markerOptions1.put("clusterManagerId", clusterManagerId);

    final List<Object> markers = Arrays.<Object>asList(markerOptions1);

    // Add marker and capture the markerBuilder
    controller.addMarkers(markers);
    ArgumentCaptor<MarkerBuilder> captor = ArgumentCaptor.forClass(MarkerBuilder.class);
    Mockito.verify(clusterManagersController, times(1)).addItem(captor.capture());
    MarkerBuilder capturedMarkerBuilder = captor.getValue();
    assertEquals(clusterManagerId, capturedMarkerBuilder.clusterManagerId());

    // clusterManagersController calls onClusterItemRendered with created marker.
    controller.onClusterItemRendered(capturedMarkerBuilder, marker);

    // Change marker to test that markerController is created and the marker can be updated
    final LatLng latLng2 = new LatLng(3.3, 4.4);
    final List<Double> location2 = new ArrayList<>();
    location2.add(latLng2.latitude);
    location2.add(latLng2.longitude);

    final Map<String, Object> markerOptions2 = new HashMap<>();
    markerOptions2.put("markerId", googleMarkerId);
    markerOptions2.put("position", location2);
    markerOptions2.put("clusterManagerId", clusterManagerId);
    final List<Object> updatedMarkers = Arrays.<Object>asList(markerOptions2);

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

    final Map<String, String> markerOptions1 = new HashMap<>();
    markerOptions1.put("markerId", googleMarkerId);

    final List<Object> markers = Arrays.<Object>asList(markerOptions1);
    controller.addMarkers(markers);

    // clusterManagersController should not be called when adding the marker
    Mockito.verify(clusterManagersController, times(0)).addItem(any());

    Mockito.verify(spyMarkerCollection, times(1)).addMarker(any(MarkerOptions.class));

    final float alpha = 0.1f;
    final Map<String, Object> markerOptions2 = new HashMap<>();
    markerOptions2.put("markerId", googleMarkerId);
    markerOptions2.put("alpha", alpha);

    final List<Object> markerUpdates = Arrays.<Object>asList(markerOptions2);
    controller.changeMarkers(markerUpdates);
    Mockito.verify(marker, times(1)).setAlpha(alpha);

    controller.removeMarkers(Arrays.asList(googleMarkerId));

    // clusterManagersController should not be called when removing the marker
    Mockito.verify(clusterManagersController, times(0)).removeItem(any());

    Mockito.verify(spyMarkerCollection, times(1)).remove(marker);
  }
}
