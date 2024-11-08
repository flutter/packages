// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import androidx.annotation.NonNull;
import com.google.maps.android.heatmaps.Gradient;
import com.google.maps.android.heatmaps.WeightedLatLng;
import java.util.List;

/** Receiver of Heatmap configuration options. */
interface HeatmapOptionsSink {
  /** Set the weighted data to be used to generate the heatmap. */
  void setWeightedData(@NonNull List<WeightedLatLng> weightedData);

  /** Set the gradient to be used to color the heatmap. */
  void setGradient(@NonNull Gradient gradient);

  /** Set the maximum intensity for the heatmap. */
  void setMaxIntensity(double maxIntensity);

  /** Set the opacity of the heatmap. */
  void setOpacity(double opacity);

  /** Set the radius of the heatmap. */
  void setRadius(int radius);
}
