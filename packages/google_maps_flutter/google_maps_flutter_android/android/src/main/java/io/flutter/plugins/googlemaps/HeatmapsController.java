// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static io.flutter.plugins.googlemaps.Convert.HEATMAP_ID_KEY;

import androidx.annotation.VisibleForTesting;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.TileOverlay;
import com.google.android.gms.maps.model.TileOverlayOptions;
import com.google.maps.android.heatmaps.HeatmapTileProvider;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Controller of multiple Heatmaps on the map. */
public class HeatmapsController {
  /** Mapping from Heatmap ID to HeatmapController. */
  private final Map<String, HeatmapController> heatmapIdToController;
  /** The GoogleMap to which the heatmaps are added. */
  private GoogleMap googleMap;

  /** Constructs a HeatmapsController. */
  HeatmapsController() {
    this.heatmapIdToController = new HashMap<>();
  }

  /** Sets the GoogleMap to which the heatmaps are added. */
  void setGoogleMap(GoogleMap googleMap) {
    this.googleMap = googleMap;
  }

  /** Adds heatmaps to the map. */
  void addHeatmaps(List<Object> heatmapsToAdd) {
    if (heatmapsToAdd == null) {
      return;
    }
    for (Object heatmapToAdd : heatmapsToAdd) {
      addHeatmap(heatmapToAdd);
    }
  }

  /** Updates the given heatmaps on the map. */
  void changeHeatmaps(List<Object> heatmapsToChange) {
    if (heatmapsToChange == null) {
      return;
    }
    for (Object heatmapToChange : heatmapsToChange) {
      changeHeatmap(heatmapToChange);
    }
  }

  /** Removes heatmaps with the given ids from the map. */
  void removeHeatmaps(List<String> heatmapIdsToRemove) {
    if (heatmapIdsToRemove == null) {
      return;
    }
    for (String heatmapId : heatmapIdsToRemove) {
      if (heatmapId == null) {
        continue;
      }
      removeHeatmap(heatmapId);
    }
  }

  /** Builds the heatmap. This method exists to allow mocking the HeatmapTileProvider in tests. */
  @VisibleForTesting
  public HeatmapTileProvider buildHeatmap(HeatmapBuilder builder) {
    return builder.build();
  }

  /** Adds a heatmap to the map. */
  private void addHeatmap(Object heatmapOptions) {
    if (heatmapOptions == null) {
      return;
    }
    HeatmapBuilder heatmapBuilder = new HeatmapBuilder();
    String heatmapId = Convert.interpretHeatmapOptions(heatmapOptions, heatmapBuilder);

    HeatmapTileProvider heatmap = buildHeatmap(heatmapBuilder);
    TileOverlay heatmapTileOverlay =
        googleMap.addTileOverlay(new TileOverlayOptions().tileProvider(heatmap));
    HeatmapController heatmapController = new HeatmapController(heatmap, heatmapTileOverlay);
    heatmapIdToController.put(heatmapId, heatmapController);
  }

  /** Updates the given heatmap on the map. */
  private void changeHeatmap(Object heatmapOptions) {
    if (heatmapOptions == null) {
      return;
    }
    String heatmapId = getHeatmapId(heatmapOptions);
    HeatmapController heatmapController = heatmapIdToController.get(heatmapId);
    if (heatmapController != null) {
      Convert.interpretHeatmapOptions(heatmapOptions, heatmapController);
      heatmapController.clearTileCache();
    }
  }

  /** Removes the heatmap with the given id from the map. */
  private void removeHeatmap(String heatmapId) {
    HeatmapController heatmapController = heatmapIdToController.get(heatmapId);
    if (heatmapController != null) {
      heatmapController.remove();
      heatmapIdToController.remove(heatmapId);
    }
  }

  /** Returns the heatmap id from the given heatmap data. */
  @SuppressWarnings("unchecked")
  private static String getHeatmapId(Object heatmap) {
    Map<String, Object> heatmapMap = (Map<String, Object>) heatmap;
    return (String) heatmapMap.get(HEATMAP_ID_KEY);
  }
}
