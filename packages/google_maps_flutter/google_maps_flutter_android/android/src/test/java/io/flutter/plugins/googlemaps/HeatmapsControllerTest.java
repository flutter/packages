// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static io.flutter.plugins.googlemaps.Convert.HEATMAP_DATA_KEY;
import static io.flutter.plugins.googlemaps.Convert.HEATMAP_ID_KEY;
import static io.flutter.plugins.googlemaps.Convert.HEATMAP_OPACITY_KEY;
import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.when;

import android.os.Build;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.TileOverlay;
import com.google.android.gms.maps.model.TileOverlayOptions;
import com.google.maps.android.heatmaps.HeatmapTileProvider;
import com.google.maps.android.heatmaps.WeightedLatLng;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mockito;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
@Config(sdk = Build.VERSION_CODES.P)
public class HeatmapsControllerTest {
  private HeatmapsController controller;
  private GoogleMap googleMap;

  @Before
  public void setUp() {
    controller = spy(new HeatmapsController());
    googleMap = mock(GoogleMap.class);
    controller.setGoogleMap(googleMap);
  }

  @Test(expected = IllegalArgumentException.class)
  public void controller_AddHeatmapThrowsErrorIfHeatmapIdIsNull() {
    final Map<String, String> heatmapOptions = new HashMap<>();

    final List<Object> heatmaps = Collections.singletonList(heatmapOptions);
    try {
      controller.addJsonHeatmaps(heatmaps);
    } catch (IllegalArgumentException e) {
      assertEquals("heatmapId was null", e.getMessage());
      throw e;
    }
  }

  @Test
  public void controller_AddChangeAndRemoveHeatmap() {
    final TileOverlay tileOverlay = mock(TileOverlay.class);
    final HeatmapTileProvider heatmap = mock(HeatmapTileProvider.class);

    final String googleHeatmapId = "abc123";
    final Object heatmapData = Collections.singletonList(Arrays.asList(Arrays.asList(1.1, 2.2), 3.3));

    when(googleMap.addTileOverlay(any(TileOverlayOptions.class))).thenReturn(tileOverlay);
    doReturn(heatmap).when(controller).buildHeatmap(any(HeatmapBuilder.class));

    final Map<String, Object> heatmapOptions1 = new HashMap<>();
    heatmapOptions1.put(HEATMAP_ID_KEY, googleHeatmapId);
    heatmapOptions1.put(HEATMAP_DATA_KEY, heatmapData);

    final List<Object> heatmaps = Collections.singletonList(heatmapOptions1);
    controller.addJsonHeatmaps(heatmaps);

    Mockito.verify(googleMap, times(1))
        .addTileOverlay(
            Mockito.argThat(argument -> argument.getTileProvider() instanceof HeatmapTileProvider));

    final float opacity = 0.1f;
    final Map<String, Object> heatmapOptions2 = new HashMap<>();
    heatmapOptions2.put(HEATMAP_ID_KEY, googleHeatmapId);
    heatmapOptions2.put(HEATMAP_DATA_KEY, heatmapData);
    heatmapOptions2.put(HEATMAP_OPACITY_KEY, opacity);

    final List<Messages.PlatformHeatmap> heatmapUpdates =
        Collections.singletonList(heatmapOptions2)
            .stream()
            .map(
                json -> {
                  final Messages.PlatformHeatmap platformHeatmap = new Messages.PlatformHeatmap();
                  platformHeatmap.setJson(json);
                  return platformHeatmap;
                })
            .toList();

    controller.changeHeatmaps(heatmapUpdates);
    Mockito.verify(heatmap, times(1)).setOpacity(opacity);

    controller.removeHeatmaps(Collections.singletonList(googleHeatmapId));

    Mockito.verify(tileOverlay, times(1)).remove();
  }
}
