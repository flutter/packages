// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.LatLng;
import com.google.maps.android.clustering.Cluster;
import com.google.maps.android.clustering.algo.StaticCluster;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.junit.Assert;
import org.junit.Test;

public class ConvertTest {

  @Test
  public void ConvertToPointsConvertsThePointsWithFullPrecision() {
    double latitude = 43.03725568057;
    double longitude = -87.90466904649;
    ArrayList<Double> point = new ArrayList<Double>();
    point.add(latitude);
    point.add(longitude);
    ArrayList<ArrayList<Double>> pointsList = new ArrayList<>();
    pointsList.add(point);
    List<LatLng> latLngs = Convert.toPoints(pointsList);
    LatLng latLng = latLngs.get(0);
    Assert.assertEquals(latitude, latLng.latitude, 1e-15);
    Assert.assertEquals(longitude, latLng.longitude, 1e-15);
  }

  @Test
  public void ConvertClustersToJsonReturnsCorrectData() {
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

    Set<Cluster<MarkerBuilder>> clusters = new HashSet<>();
    clusters.add(cluster);

    Object result = Convert.clustersToJson(clusterManagerId, clusters);

    Assert.assertTrue(result instanceof List);

    List<?> data = (List<?>) result;
    Assert.assertEquals(1, data.size());

    Map<?, ?> clusterData = (Map<?, ?>) data.get(0);
    Assert.assertEquals(clusterManagerId, clusterData.get("clusterManagerId"));

    List<?> position = (List<?>) clusterData.get("position");
    Assert.assertTrue(position instanceof List);
    Assert.assertEquals(clusterPosition.latitude, (double) position.get(0), 1e-15);
    Assert.assertEquals(clusterPosition.longitude, (double) position.get(1), 1e-15);

    Map<?, ?> bounds = (Map<?, ?>) clusterData.get("bounds");
    Assert.assertTrue(bounds instanceof Map);
    List<?> southwest = (List<?>) bounds.get("southwest");
    List<?> northeast = (List<?>) bounds.get("northeast");
    Assert.assertTrue(southwest instanceof List);
    Assert.assertTrue(northeast instanceof List);

    // bounding data should combine data from marker positions markerPosition1 and markerPosition2
    Assert.assertEquals(markerPosition2.latitude, (double) southwest.get(0), 1e-15);
    Assert.assertEquals(markerPosition1.longitude, (double) southwest.get(1), 1e-15);
    Assert.assertEquals(markerPosition1.latitude, (double) northeast.get(0), 1e-15);
    Assert.assertEquals(markerPosition2.longitude, (double) northeast.get(1), 1e-15);

    Object markerIds = clusterData.get("markerIds");
    Assert.assertTrue(markerIds instanceof List);
    List<?> markerIdList = (List<?>) markerIds;
    Assert.assertEquals(2, markerIdList.size());
    Assert.assertEquals(marker1.markerId(), markerIdList.get(0));
    Assert.assertEquals(marker2.markerId(), markerIdList.get(1));
  }
}
