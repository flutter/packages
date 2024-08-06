// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static io.flutter.plugins.googlemaps.Convert.HEATMAP_ID_KEY;

import androidx.annotation.NonNull;
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

  /** Adds heatmaps to the map from json data. */
  void addJsonHeatmaps(List<Object> heatmapsToAdd) {
    if (heatmapsToAdd != null) {
      for (Object heatmapToAdd : heatmapsToAdd) {
        @SuppressWarnings("unchecked")
        Map<String, ?> heatmapMap = (Map<String, ?>) heatmapToAdd;
        addJsonHeatmap(heatmapMap);
      }
    }
  }

  /** Adds heatmaps to the map. */
  void addHeatmaps(@NonNull List<Messages.PlatformHeatmap> heatmapsToAdd) {
    for (Messages.PlatformHeatmap heatmapToAdd : heatmapsToAdd) {
      addJsonHeatmap(heatmapToAdd.getJson());
    }
  }

  /** Updates the given heatmaps on the map. */
  void changeHeatmaps(@NonNull List<Messages.PlatformHeatmap> heatmapsToChange) {
    for (Messages.PlatformHeatmap heatmapToChange : heatmapsToChange) {
      changeJsonHeatmap(heatmapToChange.getJson());
    }
  }

  /** Removes heatmaps with the given ids from the map. */
  void removeHeatmaps(@NonNull List<String> heatmapIdsToRemove) {
    for (String heatmapId : heatmapIdsToRemove) {
      HeatmapController heatmapController = heatmapIdToController.remove(heatmapId);
      if (heatmapController != null) {
        heatmapController.remove();
        heatmapIdToController.remove(heatmapId);
      }
    }
  }

  /** Builds the heatmap. This method exists to allow mocking the HeatmapTileProvider in tests. */
  @VisibleForTesting
  public @NonNull HeatmapTileProvider buildHeatmap(@NonNull HeatmapBuilder builder) {
    return builder.build();
  }

  /** Adds a heatmap to the map from json data. */
  private void addJsonHeatmap(Map<String, ?> heatmap) {
    if (heatmap == null) {
      return;
    }
    HeatmapBuilder heatmapBuilder = new HeatmapBuilder();
    String heatmapId = Convert.interpretHeatmapOptions(heatmap, heatmapBuilder);
    HeatmapTileProvider options = buildHeatmap(heatmapBuilder);
    addHeatmap(heatmapId, options);
  }

  /** Adds a heatmap to the map. */
  private void addHeatmap(String heatmapId, HeatmapTileProvider options) {
    TileOverlay heatmapTileOverlay =
        googleMap.addTileOverlay(new TileOverlayOptions().tileProvider(options));
    HeatmapController heatmapController = new HeatmapController(options, heatmapTileOverlay);
    heatmapIdToController.put(heatmapId, heatmapController);
  }

  /** Updates the given heatmap on the map. */
  private void changeJsonHeatmap(Map<String, ?> heatmap) {
    if (heatmap == null) {
      return;
    }
    String heatmapId = getHeatmapId(heatmap);
    HeatmapController heatmapController = heatmapIdToController.get(heatmapId);
    if (heatmapController != null) {
      Convert.interpretHeatmapOptions(heatmap, heatmapController);
      heatmapController.clearTileCache();
    }
  }

  /** Returns the heatmap id from the given heatmap data. */
  private static String getHeatmapId(Map<String, ?> heatmap) {
    return (String) heatmap.get(HEATMAP_ID_KEY);
  }
}
