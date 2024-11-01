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
import android.graphics.Bitmap;
import android.os.Build;
import androidx.test.core.app.ApplicationProvider;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.maps.android.collections.MarkerManager;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.googlemaps.Messages.MapsCallbackApi;
import io.flutter.plugins.googlemaps.Messages.PlatformMarkerCollisionBehavior;
import io.flutter.plugins.googlemaps.Messages.PlatformMarkerType;
import java.io.ByteArrayOutputStream;
import java.util.Collections;
import java.util.List;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
@Config(minSdk = Build.VERSION_CODES.LOLLIPOP)
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
  private AutoCloseable mocksClosable;

  @Mock private Convert.BitmapDescriptorFactoryWrapper bitmapDescriptorFactoryWrapper;

  private static Messages.PlatformMarker.Builder defaultMarkerBuilder() {
    Bitmap fakeBitmap = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888);
    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
    fakeBitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream);
    byte[] byteArray = byteArrayOutputStream.toByteArray();
    Messages.PlatformBitmap icon =
        new Messages.PlatformBitmap.Builder()
            .setBitmap(
                new Messages.PlatformBitmapBytesMap.Builder()
                    .setByteData(byteArray)
                    .setImagePixelRatio(1.0)
                    .setBitmapScaling(Messages.PlatformMapBitmapScaling.NONE)
                    .build())
            .build();
    Messages.PlatformDoublePair anchor =
        new Messages.PlatformDoublePair.Builder().setX(0.5).setY(0.0).build();
    Messages.PlatformInfoWindow infoWindow =
        new Messages.PlatformInfoWindow.Builder().setAnchor(anchor).build();
    return new Messages.PlatformMarker.Builder()
        .setPosition(
            new Messages.PlatformLatLng.Builder().setLatitude(0.0).setLongitude(0.0).build())
        .setAnchor(new Messages.PlatformDoublePair.Builder().setX(0.0).setY(0.0).build())
        .setFlat(false)
        .setDraggable(false)
        .setVisible(true)
        .setAlpha(1.0)
        .setRotation(0.0)
        .setZIndex(0.0)
        .setConsumeTapEvents(false)
        .setIcon(icon)
        .setInfoWindow(infoWindow)
        .setCollisionBehavior(PlatformMarkerCollisionBehavior.REQUIRED);
  }

  @Before
  public void setUp() {
    mocksClosable = MockitoAnnotations.openMocks(this);
    assetManager = ApplicationProvider.getApplicationContext().getAssets();
    context = ApplicationProvider.getApplicationContext();
    flutterApi = spy(new MapsCallbackApi(mock(BinaryMessenger.class)));
    clusterManagersController =
        spy(new ClusterManagersController(flutterApi, context, PlatformMarkerType.MARKER));
    controller =
        new MarkersController(
            flutterApi,
            clusterManagersController,
            assetManager,
            density,
            bitmapDescriptorFactoryWrapper,
            PlatformMarkerType.MARKER);
    googleMap = mock(GoogleMap.class);
    markerManager = new MarkerManager(googleMap);
    markerCollection = markerManager.newCollection();
    controller.setCollection(markerCollection);
    clusterManagersController.init(googleMap, markerManager);
  }

  @After
  public void close() throws Exception {
    mocksClosable.close();
  }

  @Test
  public void controller_OnMarkerDragStart() {
    final Marker marker = mock(Marker.class);

    final String googleMarkerId = "abc123";

    when(marker.getId()).thenReturn(googleMarkerId);
    when(googleMap.addMarker(any(MarkerOptions.class))).thenReturn(marker);

    final LatLng latLng = new LatLng(1.1, 2.2);

    final List<Messages.PlatformMarker> markers =
        Collections.singletonList(defaultMarkerBuilder().setMarkerId(googleMarkerId).build());
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

    final List<Messages.PlatformMarker> markers =
        Collections.singletonList(defaultMarkerBuilder().setMarkerId(googleMarkerId).build());
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

    final List<Messages.PlatformMarker> markers =
        Collections.singletonList(defaultMarkerBuilder().setMarkerId(googleMarkerId).build());

    controller.addMarkers(markers);
    controller.onMarkerDrag(googleMarkerId, latLng);

    Mockito.verify(flutterApi)
        .onMarkerDrag(eq(googleMarkerId), eq(Convert.latLngToPigeon(latLng)), any());
  }

  @Test(expected = IllegalStateException.class)
  public void controller_AddMarkerThrowsErrorIfMarkerIdIsNull() {
    final List<Messages.PlatformMarker> markers =
        Collections.singletonList(defaultMarkerBuilder().build());
    try {
      controller.addMarkers(markers);
    } catch (IllegalStateException e) {
      assertEquals("markerId was null", e.getMessage());
      throw e;
    }
  }

  @Test
  public void controller_AddChangeAndRemoveMarkerWithClusterManagerId() {
    final Marker marker = mock(Marker.class);

    final String googleMarkerId = "abc123";
    final String clusterManagerId = "cm123";

    final Messages.PlatformMarker.Builder builder = defaultMarkerBuilder();
    builder
        .setMarkerId(googleMarkerId)
        .setClusterManagerId(clusterManagerId)
        .setPosition(
            new Messages.PlatformLatLng.Builder().setLatitude(1.1).setLongitude(2.2).build());

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

    builder.setPosition(
        new Messages.PlatformLatLng.Builder()
            .setLatitude(latLng2.latitude)
            .setLongitude(latLng2.longitude)
            .build());
    final List<Messages.PlatformMarker> updatedMarkers = Collections.singletonList(builder.build());

    controller.changeMarkers(updatedMarkers);
    Mockito.verify(marker, times(1)).setPosition(latLng2);

    // Remove marker
    controller.removeMarkers(Collections.singletonList(googleMarkerId));

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

    final Messages.PlatformMarker.Builder builder = defaultMarkerBuilder();
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

    controller.removeMarkers(Collections.singletonList(googleMarkerId));

    // clusterManagersController should not be called when removing the marker
    Mockito.verify(clusterManagersController, times(0)).removeItem(any());

    Mockito.verify(spyMarkerCollection, times(1)).remove(marker);
  }
}
