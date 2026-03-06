// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.when;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.TileOverlay;
import com.google.android.gms.maps.model.TileOverlayOptions;
import com.google.maps.android.heatmaps.HeatmapTileProvider;
import java.util.Collections;
import java.util.List;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mockito;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class HeatmapsControllerTest {
  private HeatmapsController controller;
  private GoogleMap googleMap;

  @Before
  public void setUp() {
    controller = spy(new HeatmapsController());
    googleMap = mock(GoogleMap.class);
    controller.setGoogleMap(googleMap);
  }

  @Test
  public void controller_AddChangeAndRemoveHeatmap() {
    final TileOverlay tileOverlay = mock(TileOverlay.class);
    final HeatmapTileProvider heatmap = mock(HeatmapTileProvider.class);

    final String googleHeatmapId = "abc123";
    final List<Messages.PlatformWeightedLatLng> heatmapData =
        List.of(
            new Messages.PlatformWeightedLatLng.Builder()
                .setPoint(
                    new Messages.PlatformLatLng.Builder()
                        .setLatitude(1.1)
                        .setLongitude(2.2)
                        .build())
                .setWeight(3.3)
                .build());
    final long radius = 20;

    when(googleMap.addTileOverlay(any(TileOverlayOptions.class))).thenReturn(tileOverlay);
    doReturn(heatmap).when(controller).buildHeatmap(any(HeatmapBuilder.class));

    final double opacity1 = 0.1f;
    final Messages.PlatformHeatmap heatmapOptions1 =
        new Messages.PlatformHeatmap.Builder()
            .setHeatmapId(googleHeatmapId)
            .setData(heatmapData)
            .setOpacity(opacity1)
            .setRadius(radius)
            .build();

    final List<Messages.PlatformHeatmap> heatmaps = Collections.singletonList(heatmapOptions1);
    controller.addHeatmaps(heatmaps);

    Mockito.verify(googleMap, times(1))
        .addTileOverlay(
            Mockito.argThat(argument -> argument.getTileProvider() instanceof HeatmapTileProvider));

    final double opacity2 = 0.2f;
    final Messages.PlatformHeatmap heatmapOptions2 =
        new Messages.PlatformHeatmap.Builder()
            .setHeatmapId(googleHeatmapId)
            .setData(heatmapData)
            .setOpacity(opacity2)
            .setRadius(radius)
            .build();

    final List<Messages.PlatformHeatmap> heatmapUpdates =
        Collections.singletonList(heatmapOptions2);

    controller.changeHeatmaps(heatmapUpdates);
    Mockito.verify(heatmap, times(1)).setOpacity(opacity2);

    controller.removeHeatmaps(Collections.singletonList(googleHeatmapId));

    Mockito.verify(tileOverlay, times(1)).remove();
  }
}
