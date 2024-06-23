// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import androidx.annotation.NonNull;
import com.google.maps.android.heatmaps.Gradient;
import com.google.maps.android.heatmaps.HeatmapTileProvider;
import com.google.maps.android.heatmaps.WeightedLatLng;
import java.util.List;

/** Builder of a single Heatmap on the map. */
public class HeatmapBuilder implements HeatmapOptionsSink {
  private final HeatmapTileProvider.Builder heatmapOptions;

  /** Construct a HeatmapBuilder. */
  HeatmapBuilder() {
    this.heatmapOptions = new HeatmapTileProvider.Builder();
  }

  /** Build the HeatmapTileProvider with the given options. */
  HeatmapTileProvider build() {
    return heatmapOptions.build();
  }

  @Override
  public void setWeightedData(@NonNull List<WeightedLatLng> weightedData) {
    heatmapOptions.weightedData(weightedData);
  }

  @Override
  public void setGradient(@NonNull Gradient gradient) {
    heatmapOptions.gradient(gradient);
  }

  @Override
  public void setMaxIntensity(double maxIntensity) {
    heatmapOptions.maxIntensity(maxIntensity);
  }

  @Override
  public void setOpacity(double opacity) {
    heatmapOptions.opacity(opacity);
  }

  @Override
  public void setRadius(int radius) {
    heatmapOptions.radius(radius);
  }
}
