// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import androidx.annotation.NonNull;
import com.google.android.gms.maps.model.TileOverlay;
import com.google.maps.android.heatmaps.Gradient;
import com.google.maps.android.heatmaps.HeatmapTileProvider;
import com.google.maps.android.heatmaps.WeightedLatLng;
import java.util.List;

/** Controller of a single Heatmap on the map. */
public class HeatmapController implements HeatmapOptionsSink {
  private final @NonNull HeatmapTileProvider heatmap;
  private final @NonNull TileOverlay heatmapTileOverlay;

  /** Construct a HeatmapController with the given heatmap and heatmapTileOverlay. */
  HeatmapController(@NonNull HeatmapTileProvider heatmap, @NonNull TileOverlay heatmapTileOverlay) {
    this.heatmap = heatmap;
    this.heatmapTileOverlay = heatmapTileOverlay;
  }

  /** Remove the heatmap from the map. */
  void remove() {
    heatmapTileOverlay.remove();
  }

  /** Clear the tile cache of the heatmap in order to update the heatmap. */
  void clearTileCache() {
    heatmapTileOverlay.clearTileCache();
  }

  @Override
  public void setWeightedData(@NonNull List<WeightedLatLng> weightedData) {
    heatmap.setWeightedData(weightedData);
  }

  @Override
  public void setGradient(@NonNull Gradient gradient) {
    heatmap.setGradient(gradient);
  }

  @Override
  public void setMaxIntensity(double maxIntensity) {
    heatmap.setMaxIntensity(maxIntensity);
  }

  @Override
  public void setOpacity(double opacity) {
    heatmap.setOpacity(opacity);
  }

  @Override
  public void setRadius(int radius) {
    heatmap.setRadius(radius);
  }
}
