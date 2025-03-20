// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyFloat;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.content.Context;
import android.os.Build;
import androidx.activity.ComponentActivity;
import androidx.test.core.app.ApplicationProvider;
import com.google.android.gms.maps.CameraUpdate;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.maps.android.clustering.ClusterManager;
import io.flutter.plugin.common.BinaryMessenger;
import java.util.ArrayList;
import java.util.List;
import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.MockitoAnnotations;
import org.robolectric.Robolectric;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
@Config(minSdk = Build.VERSION_CODES.LOLLIPOP)
public class GoogleMapControllerTest {

  private Context context;
  private ComponentActivity activity;

  AutoCloseable mockCloseable;
  @Mock BinaryMessenger mockMessenger;
  @Mock GoogleMap mockGoogleMap;
  @Mock Messages.MapsCallbackApi flutterApi;
  @Mock ClusterManagersController mockClusterManagersController;
  @Mock MarkersController mockMarkersController;
  @Mock PolygonsController mockPolygonsController;
  @Mock PolylinesController mockPolylinesController;
  @Mock CirclesController mockCirclesController;
  @Mock HeatmapsController mockHeatmapsController;
  @Mock TileOverlaysController mockTileOverlaysController;
  @Mock GroundOverlaysController mockGroundOverlaysController;

  @Before
  public void before() {
    mockCloseable = MockitoAnnotations.openMocks(this);
    context = ApplicationProvider.getApplicationContext();
    setUpActivityLegacy();
  }

  // Returns GoogleMapController instance.
  // See getGoogleMapControllerWithMockedDependencies for version with dependency injections.
  public GoogleMapController getGoogleMapController() {
    GoogleMapController googleMapController =
        new GoogleMapController(0, context, mockMessenger, activity::getLifecycle, null);
    googleMapController.init();
    return googleMapController;
  }

  // Returns GoogleMapController instance with mocked dependency injections.
  public GoogleMapController getGoogleMapControllerWithMockedDependencies() {
    GoogleMapController googleMapController =
        new GoogleMapController(
            0,
            context,
            mockMessenger,
            flutterApi,
            activity::getLifecycle,
            null,
            mockClusterManagersController,
            mockMarkersController,
            mockPolygonsController,
            mockPolylinesController,
            mockCirclesController,
            mockHeatmapsController,
            mockTileOverlaysController,
            mockGroundOverlaysController);
    googleMapController.init();
    return googleMapController;
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
  public void DisposeReleaseTheMap() {
    GoogleMapController googleMapController = getGoogleMapController();
    googleMapController.onMapReady(mockGoogleMap);
    assertNotNull(googleMapController);
    googleMapController.dispose();
    assertNull(googleMapController.getView());
  }

  @Test
  public void OnDestroyReleaseTheMap() {
    GoogleMapController googleMapController = getGoogleMapController();
    googleMapController.onMapReady(mockGoogleMap);
    assertNotNull(googleMapController);
    googleMapController.onDestroy(activity);
    assertNull(googleMapController.getView());
  }

  @Test
  public void OnMapReadySetsPaddingIfInitialPaddingIsThere() {
    GoogleMapController googleMapController = getGoogleMapController();
    float padding = 10f;
    int paddingWithDensity = (int) (padding * googleMapController.density);
    googleMapController.setInitialPadding(padding, padding, padding, padding);
    googleMapController.onMapReady(mockGoogleMap);
    verify(mockGoogleMap, times(1))
        .setPadding(paddingWithDensity, paddingWithDensity, paddingWithDensity, paddingWithDensity);
  }

  @Test
  public void SetPaddingStoresThePaddingValuesInInInitialPaddingWhenGoogleMapIsNull() {
    GoogleMapController googleMapController = getGoogleMapController();
    assertNull(googleMapController.initialPadding);
    googleMapController.setPadding(0f, 0f, 0f, 0f);
    assertNotNull(googleMapController.initialPadding);
    Assert.assertEquals(4, googleMapController.initialPadding.size());
  }

  @Test
  public void OnMapReadySetsMarkerCollectionListener() {
    GoogleMapController googleMapController = getGoogleMapController();
    GoogleMapController spyGoogleMapController = spy(googleMapController);
    // setMarkerCollectionListener method should be called when map is ready
    spyGoogleMapController.onMapReady(mockGoogleMap);

    // Verify if the setMarkerCollectionListener method is called with listener
    verify(spyGoogleMapController, times(1))
        .setMarkerCollectionListener(any(GoogleMapListener.class));

    spyGoogleMapController.dispose();
    // Verify if the setMarkerCollectionListener is cleared on dispose
    verify(spyGoogleMapController, times(1)).setMarkerCollectionListener(null);
  }

  @Test
  @SuppressWarnings("unchecked")
  public void OnMapReadySetsClusterItemClickListener() {
    GoogleMapController googleMapController = getGoogleMapController();
    GoogleMapController spyGoogleMapController = spy(googleMapController);
    // setMarkerCollectionListener method should be called when map is ready
    spyGoogleMapController.onMapReady(mockGoogleMap);

    // Verify if the setMarkerCollectionListener method is called with listener
    verify(spyGoogleMapController, times(1))
        .setClusterItemClickListener(any(ClusterManager.OnClusterItemClickListener.class));

    spyGoogleMapController.dispose();
    // Verify if the setMarkerCollectionListener is cleared on dispose
    verify(spyGoogleMapController, times(1)).setClusterItemClickListener(null);
  }

  @Test
  @SuppressWarnings("unchecked")
  public void OnMapReadySetsClusterItemRenderedListener() {
    GoogleMapController googleMapController = getGoogleMapController();
    GoogleMapController spyGoogleMapController = spy(googleMapController);
    // setMarkerCollectionListener method should be called when map is ready
    spyGoogleMapController.onMapReady(mockGoogleMap);

    // Verify if the setMarkerCollectionListener method is called with listener

    verify(spyGoogleMapController, times(1))
        .setClusterItemRenderedListener(any(ClusterManagersController.OnClusterItemRendered.class));

    spyGoogleMapController.dispose();
    // Verify if the setMarkerCollectionListener is cleared on dispose
    verify(spyGoogleMapController, times(1)).setClusterItemRenderedListener(null);
  }

  @Test
  public void SetInitialClusterManagers() {
    GoogleMapController googleMapController = getGoogleMapControllerWithMockedDependencies();
    Messages.PlatformClusterManager initialClusterManager =
        new Messages.PlatformClusterManager.Builder().setIdentifier("cm_1").build();
    List<Messages.PlatformClusterManager> initialClusterManagers = new ArrayList<>();
    initialClusterManagers.add(initialClusterManager);
    googleMapController.setInitialClusterManagers(initialClusterManagers);
    googleMapController.onMapReady(mockGoogleMap);

    // Verify if the ClusterManagersController.addClusterManagers method is called with initial cluster managers.
    verify(mockClusterManagersController, times(1)).addClusterManagers(any());
  }

  @Test
  public void OnClusterItemRenderedCallsMarkersController() {
    GoogleMapController googleMapController = getGoogleMapControllerWithMockedDependencies();
    MarkerBuilder markerBuilder = new MarkerBuilder("m_1", "cm_1");
    final Marker marker = mock(Marker.class);
    googleMapController.onClusterItemRendered(markerBuilder, marker);
    verify(mockMarkersController, times(1)).onClusterItemRendered(markerBuilder, marker);
  }

  @Test
  public void OnClusterItemClickCallsMarkersController() {
    GoogleMapController googleMapController = getGoogleMapControllerWithMockedDependencies();
    MarkerBuilder markerBuilder = new MarkerBuilder("m_1", "cm_1");

    googleMapController.onClusterItemClick(markerBuilder);
    verify(mockMarkersController, times(1)).onMarkerTap(markerBuilder.markerId());
  }

  @Test
  public void SetInitialHeatmaps() {
    GoogleMapController googleMapController = getGoogleMapControllerWithMockedDependencies();

    List<Messages.PlatformHeatmap> initialHeatmaps = List.of(new Messages.PlatformHeatmap());
    googleMapController.setInitialHeatmaps(initialHeatmaps);
    googleMapController.onMapReady(mockGoogleMap);

    // Verify if the HeatmapsController.addHeatmaps method is called with initial heatmaps.
    verify(mockHeatmapsController, times(1)).addHeatmaps(initialHeatmaps);
  }

  @Test
  public void UpdateHeatmaps() {
    GoogleMapController googleMapController = getGoogleMapControllerWithMockedDependencies();

    final List<Messages.PlatformHeatmap> toAdd = List.of(new Messages.PlatformHeatmap());
    final List<Messages.PlatformHeatmap> toChange = List.of(new Messages.PlatformHeatmap());
    final List<String> idsToRemove = List.of("hm_1");

    googleMapController.updateHeatmaps(toAdd, toChange, idsToRemove);

    verify(mockHeatmapsController, times(1)).addHeatmaps(toAdd);
    verify(mockHeatmapsController, times(1)).changeHeatmaps(toChange);
    verify(mockHeatmapsController, times(1)).removeHeatmaps(idsToRemove);
  }

  @Test
  public void AnimateCamera() {
    GoogleMapController googleMapController = getGoogleMapControllerWithMockedDependencies();
    googleMapController.onMapReady(mockGoogleMap);

    Messages.PlatformCameraUpdateZoomBy newCameraPosition =
        new Messages.PlatformCameraUpdateZoomBy.Builder().setAmount(1.0).build();
    Messages.PlatformCameraUpdate cameraUpdate =
        new Messages.PlatformCameraUpdate.Builder().setCameraUpdate(newCameraPosition).build();

    try (MockedStatic<CameraUpdateFactory> mockedFactory = mockStatic(CameraUpdateFactory.class)) {
      mockedFactory
          .when(() -> CameraUpdateFactory.zoomBy(anyFloat()))
          .thenReturn(mock(CameraUpdate.class));
      googleMapController.animateCamera(cameraUpdate, null);
    }

    verify(mockGoogleMap, times(1)).animateCamera(any(CameraUpdate.class));
  }

  @Test
  public void AnimateCameraWithDuration() {
    GoogleMapController googleMapController = getGoogleMapControllerWithMockedDependencies();
    googleMapController.onMapReady(mockGoogleMap);

    Messages.PlatformCameraUpdateZoomBy newCameraPosition =
        new Messages.PlatformCameraUpdateZoomBy.Builder().setAmount(1.0).build();
    Messages.PlatformCameraUpdate cameraUpdate =
        new Messages.PlatformCameraUpdate.Builder().setCameraUpdate(newCameraPosition).build();

    Long durationMilliseconds = 1000L;

    try (MockedStatic<CameraUpdateFactory> mockedFactory = mockStatic(CameraUpdateFactory.class)) {
      mockedFactory
          .when(() -> CameraUpdateFactory.zoomBy(anyFloat()))
          .thenReturn(mock(CameraUpdate.class));
      googleMapController.animateCamera(cameraUpdate, durationMilliseconds);
    }

    verify(mockGoogleMap, times(1))
        .animateCamera(any(CameraUpdate.class), eq(durationMilliseconds.intValue()), isNull());
  }

  @Test
  public void getCameraPositionReturnsCorrectData() {
    GoogleMapController googleMapController = getGoogleMapControllerWithMockedDependencies();
    googleMapController.onMapReady(mockGoogleMap);

    CameraPosition cameraPosition = new CameraPosition(new LatLng(10.0, 20.0), 15.0f, 30.0f, 45.0f);
    when(mockGoogleMap.getCameraPosition()).thenReturn(cameraPosition);

    Messages.PlatformCameraPosition result = googleMapController.getCameraPosition();

    Assert.assertEquals(cameraPosition.target.latitude, result.getTarget().getLatitude(), 1e-15);
    Assert.assertEquals(cameraPosition.target.longitude, result.getTarget().getLongitude(), 1e-15);
    Assert.assertEquals(cameraPosition.zoom, result.getZoom(), 1e-15);
    Assert.assertEquals(cameraPosition.tilt, result.getTilt(), 1e-15);
    Assert.assertEquals(cameraPosition.bearing, result.getBearing(), 1e-15);
  }
}
