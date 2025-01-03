// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertSame;
import static org.junit.Assert.assertThrows;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.when;

import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.os.Build;
import androidx.test.core.app.ApplicationProvider;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.maps.android.clustering.Cluster;
import com.google.maps.android.clustering.ClusterManager;
import com.google.maps.android.clustering.algo.StaticCluster;
import com.google.maps.android.collections.MarkerManager;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.googlemaps.ClusterManagersController.AdvancedMarkerClusterRenderer;
import io.flutter.plugins.googlemaps.ClusterManagersController.MarkerClusterRenderer;
import io.flutter.plugins.googlemaps.Messages.MapsCallbackApi;
import io.flutter.plugins.googlemaps.Messages.PlatformMarkerCollisionBehavior;
import io.flutter.plugins.googlemaps.Messages.PlatformMarkerType;
import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentMatchers;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
@Config(minSdk = Build.VERSION_CODES.LOLLIPOP)
public class ClusterManagersControllerTest {
  private Context context;
  private MapsCallbackApi flutterApi;
  private ClusterManagersController controller;
  private GoogleMap googleMap;
  private MarkerManager markerManager;
  private AssetManager assetManager;
  private final float density = 1;

  @Mock Convert.BitmapDescriptorFactoryWrapper bitmapFactory;

  private AutoCloseable mocksClosable;

  @Before
  public void setUp() {
    mocksClosable = MockitoAnnotations.openMocks(this);
    context = ApplicationProvider.getApplicationContext();
    assetManager = context.getAssets();
    flutterApi = spy(new MapsCallbackApi(mock(BinaryMessenger.class)));
    controller = spy(new ClusterManagersController(flutterApi, context, PlatformMarkerType.MARKER));
    googleMap = mock(GoogleMap.class);
    markerManager = new MarkerManager(googleMap);
    controller.init(googleMap, markerManager);
  }

  @After
  public void close() throws Exception {
    mocksClosable.close();
  }

  @Test
  public void AddClusterManagersAndMarkers() {
    final String clusterManagerId = "cm_1";
    final String markerId1 = "mid_1";
    final String markerId2 = "mid_2";

    final LatLng latLng1 = new LatLng(1.1, 2.2);
    final LatLng latLng2 = new LatLng(3.3, 4.4);

    final List<Double> location1 = new ArrayList<>();
    location1.add(latLng1.latitude);
    location1.add(latLng1.longitude);

    final List<Double> location2 = new ArrayList<>();
    location2.add(latLng2.latitude);
    location2.add(latLng2.longitude);

    when(googleMap.getCameraPosition())
        .thenReturn(CameraPosition.builder().target(new LatLng(0, 0)).build());
    Messages.PlatformClusterManager initialClusterManager =
        new Messages.PlatformClusterManager.Builder().setIdentifier(clusterManagerId).build();
    List<Messages.PlatformClusterManager> clusterManagersToAdd = new ArrayList<>();
    clusterManagersToAdd.add(initialClusterManager);
    controller.addClusterManagers(clusterManagersToAdd);

    MarkerBuilder markerBuilder1 =
        new MarkerBuilder(markerId1, clusterManagerId, PlatformMarkerType.MARKER);
    MarkerBuilder markerBuilder2 =
        new MarkerBuilder(markerId2, clusterManagerId, PlatformMarkerType.MARKER);

    final Messages.PlatformMarker markerData1 =
        createPlatformMarker(markerId1, location1, clusterManagerId);
    final Messages.PlatformMarker markerData2 =
        createPlatformMarker(markerId2, location2, clusterManagerId);

    Convert.interpretMarkerOptions(
        markerData1, markerBuilder1, assetManager, density, bitmapFactory);
    Convert.interpretMarkerOptions(
        markerData2, markerBuilder2, assetManager, density, bitmapFactory);

    controller.addItem(markerBuilder1);
    controller.addItem(markerBuilder2);

    Set<? extends Cluster<MarkerBuilder>> clusters =
        controller.getClustersWithClusterManagerId(clusterManagerId);
    assertEquals("Amount of clusters should be 1", 1, clusters.size());

    Cluster<MarkerBuilder> cluster = clusters.iterator().next();
    assertNotNull("Cluster position should not be null", cluster.getPosition());
    Set<String> markerIds = new HashSet<>();
    for (MarkerBuilder marker : cluster.getItems()) {
      markerIds.add(marker.markerId());
    }
    assertTrue("Marker IDs should contain markerId1", markerIds.contains(markerId1));
    assertTrue("Marker IDs should contain markerId2", markerIds.contains(markerId2));
    assertEquals("Cluster should contain exactly 2 markers", 2, cluster.getSize());
  }

  @Test
  public void SelectClusterRenderer() {
    final String clusterManagerId1 = "cm_1";
    final String clusterManagerId2 = "cm_2";
    final String markerId1 = "mid_1";
    final String markerId2 = "mid_2";

    when(googleMap.getCameraPosition())
        .thenReturn(CameraPosition.builder().target(new LatLng(0, 0)).build());

    ClusterManagersController controller1 =
        spy(new ClusterManagersController(flutterApi, context, PlatformMarkerType.MARKER));
    controller1.init(googleMap, markerManager);
    ClusterManagersController controller2 =
        spy(new ClusterManagersController(flutterApi, context, PlatformMarkerType.ADVANCED_MARKER));
    controller2.init(googleMap, markerManager);

    Messages.PlatformClusterManager initialClusterManager1 =
        new Messages.PlatformClusterManager.Builder().setIdentifier(clusterManagerId1).build();
    List<Messages.PlatformClusterManager> clusterManagersToAdd1 = new ArrayList<>();
    clusterManagersToAdd1.add(initialClusterManager1);
    controller1.addClusterManagers(clusterManagersToAdd1);

    Messages.PlatformClusterManager initialClusterManager2 =
        new Messages.PlatformClusterManager.Builder().setIdentifier(clusterManagerId2).build();
    List<Messages.PlatformClusterManager> clusterManagersToAdd2 = new ArrayList<>();
    clusterManagersToAdd2.add(initialClusterManager2);
    controller2.addClusterManagers(clusterManagersToAdd2);

    MarkerBuilder markerBuilder1 =
        new MarkerBuilder(markerId1, clusterManagerId1, PlatformMarkerType.MARKER);
    markerBuilder1.setPosition(new LatLng(10.0, 20.0));
    controller1.addItem(markerBuilder1);

    MarkerBuilder markerBuilder2 =
        new MarkerBuilder(markerId2, clusterManagerId2, PlatformMarkerType.ADVANCED_MARKER);
    markerBuilder2.setPosition(new LatLng(20.0, 10.0));
    controller2.addItem(markerBuilder2);

    ClusterManager<?> clusterManager1 =
        controller1.clusterManagerIdToManager.get(clusterManagerId1);
    assertNotNull(clusterManager1);
    assertSame(clusterManager1.getRenderer().getClass(), MarkerClusterRenderer.class);

    ClusterManager<?> clusterManager2 =
        controller2.clusterManagerIdToManager.get(clusterManagerId2);
    assertNotNull(clusterManager2);
    assertSame(clusterManager2.getRenderer().getClass(), AdvancedMarkerClusterRenderer.class);
  }

  @Test
  public void OnClusterClickCallsMethodChannel() {
    String clusterManagerId = "cm_1";
    LatLng clusterPosition = new LatLng(43.00, -87.90);
    LatLng markerPosition1 = new LatLng(43.05, -87.95);
    LatLng markerPosition2 = new LatLng(43.02, -87.92);

    StaticCluster<MarkerBuilder> cluster = new StaticCluster<>(clusterPosition);

    MarkerBuilder marker1 = new MarkerBuilder("m_1", clusterManagerId, PlatformMarkerType.MARKER);
    marker1.setPosition(markerPosition1);
    cluster.add(marker1);

    MarkerBuilder marker2 = new MarkerBuilder("m_2", clusterManagerId, PlatformMarkerType.MARKER);
    marker2.setPosition(markerPosition2);
    cluster.add(marker2);

    controller.onClusterClick(cluster);
    Mockito.verify(flutterApi)
        .onClusterTap(
            eq(Convert.clusterToPigeon(clusterManagerId, cluster)), ArgumentMatchers.any());
  }

  @Test
  public void RemoveClusterManagers() {
    final String clusterManagerId = "cm_1";

    when(googleMap.getCameraPosition())
        .thenReturn(CameraPosition.builder().target(new LatLng(0, 0)).build());
    Messages.PlatformClusterManager initialClusterManager =
        new Messages.PlatformClusterManager.Builder().setIdentifier(clusterManagerId).build();
    List<Messages.PlatformClusterManager> clusterManagersToAdd = new ArrayList<>();
    clusterManagersToAdd.add(initialClusterManager);
    controller.addClusterManagers(clusterManagersToAdd);

    // Verify that fetching the cluster data success and therefore ClusterManager is added.
    controller.getClustersWithClusterManagerId(clusterManagerId);

    controller.removeClusterManagers(Collections.singletonList(clusterManagerId));
    // Verify that fetching the cluster data fails and therefore ClusterManager is removed.
    assertThrows(
        Messages.FlutterError.class,
        () -> controller.getClustersWithClusterManagerId(clusterManagerId));
  }

  private Messages.PlatformMarker createPlatformMarker(
      String markerId, List<Double> location, String clusterManagerId) {
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
        new Messages.PlatformDoublePair.Builder().setX(0.0).setY(0.0).build();
    return new Messages.PlatformMarker.Builder()
        .setMarkerId(markerId)
        .setConsumeTapEvents(false)
        .setIcon(icon)
        .setAlpha(1.0)
        .setDraggable(false)
        .setFlat(false)
        .setVisible(true)
        .setRotation(0.0)
        .setZIndex(0.0)
        .setPosition(
            new Messages.PlatformLatLng.Builder()
                .setLatitude(location.get(0))
                .setLongitude(location.get(1))
                .build())
        .setClusterManagerId(clusterManagerId)
        .setAnchor(anchor)
        .setInfoWindow(new Messages.PlatformInfoWindow.Builder().setAnchor(anchor).build())
        .setCollisionBehavior(PlatformMarkerCollisionBehavior.REQUIRED)
        .build();
  }
}
