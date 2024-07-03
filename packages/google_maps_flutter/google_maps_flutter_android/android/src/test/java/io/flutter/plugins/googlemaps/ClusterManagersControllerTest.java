// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertThrows;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.when;

import android.content.Context;
import android.content.res.AssetManager;
import android.os.Build;
import androidx.test.core.app.ApplicationProvider;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.maps.android.clustering.Cluster;
import com.google.maps.android.clustering.algo.StaticCluster;
import com.google.maps.android.collections.MarkerManager;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodCodec;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
@Config(sdk = Build.VERSION_CODES.P)
public class ClusterManagersControllerTest {
  private Context context;
  private MethodChannel methodChannel;
  private ClusterManagersController controller;
  private GoogleMap googleMap;
  private MarkerManager markerManager;
  private MarkerManager.Collection markerCollection;
  private AssetManager assetManager;
  private final float density = 1;

  @Before
  public void setUp() {
    MockitoAnnotations.openMocks(this);
    context = ApplicationProvider.getApplicationContext();
    assetManager = context.getAssets();
    methodChannel =
        spy(new MethodChannel(mock(BinaryMessenger.class), "no-name", mock(MethodCodec.class)));
    controller = spy(new ClusterManagersController(methodChannel, context));
    googleMap = mock(GoogleMap.class);
    markerManager = new MarkerManager(googleMap);
    markerCollection = markerManager.newCollection();
    controller.init(googleMap, markerManager);
  }

  @Test
  @SuppressWarnings("unchecked")
  public void AddJsonClusterManagersAndMarkers() throws InterruptedException {
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
    Map<String, Object> initialClusterManager = new HashMap<>();
    initialClusterManager.put("clusterManagerId", clusterManagerId);
    List<Object> clusterManagersToAdd = new ArrayList<>();
    clusterManagersToAdd.add(initialClusterManager);
    controller.addJsonClusterManagers(clusterManagersToAdd);

    MarkerBuilder markerBuilder1 = new MarkerBuilder(markerId1, clusterManagerId);
    MarkerBuilder markerBuilder2 = new MarkerBuilder(markerId2, clusterManagerId);

    final Map<String, Object> markerData1 =
        createMarkerData(markerId1, location1, clusterManagerId);
    final Map<String, Object> markerData2 =
        createMarkerData(markerId2, location2, clusterManagerId);

    Convert.interpretMarkerOptions(markerData1, markerBuilder1, assetManager, density);
    Convert.interpretMarkerOptions(markerData2, markerBuilder2, assetManager, density);

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
  @SuppressWarnings("unchecked")
  public void AddClusterManagersAndMarkers() throws InterruptedException {
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

    MarkerBuilder markerBuilder1 = new MarkerBuilder(markerId1, clusterManagerId);
    MarkerBuilder markerBuilder2 = new MarkerBuilder(markerId2, clusterManagerId);

    final Map<String, Object> markerData1 =
        createMarkerData(markerId1, location1, clusterManagerId);
    final Map<String, Object> markerData2 =
        createMarkerData(markerId2, location2, clusterManagerId);

    Convert.interpretMarkerOptions(markerData1, markerBuilder1, assetManager, density);
    Convert.interpretMarkerOptions(markerData2, markerBuilder2, assetManager, density);

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
  @SuppressWarnings("unchecked")
  public void OnClusterClickCallsMethodChannel() throws InterruptedException {
    String clusterManagerId = "cm_1";
    LatLng clusterPosition = new LatLng(43.00, -87.90);
    LatLng markerPosition1 = new LatLng(43.05, -87.95);
    LatLng markerPosition2 = new LatLng(43.02, -87.92);

    StaticCluster<MarkerBuilder> cluster = new StaticCluster<>(clusterPosition);

    MarkerBuilder marker1 = new MarkerBuilder("m_1", clusterManagerId);
    marker1.setPosition(markerPosition1);
    cluster.add(marker1);

    MarkerBuilder marker2 = new MarkerBuilder("m_2", clusterManagerId);
    marker2.setPosition(markerPosition2);
    cluster.add(marker2);

    controller.onClusterClick(cluster);
    Mockito.verify(methodChannel)
        .invokeMethod("cluster#onTap", Convert.clusterToJson(clusterManagerId, cluster));
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

  private Map<String, Object> createMarkerData(
      String markerId, List<Double> location, String clusterManagerId) {
    Map<String, Object> markerData = new HashMap<>();
    markerData.put("markerId", markerId);
    markerData.put("position", location);
    markerData.put("clusterManagerId", clusterManagerId);
    return markerData;
  }
}
