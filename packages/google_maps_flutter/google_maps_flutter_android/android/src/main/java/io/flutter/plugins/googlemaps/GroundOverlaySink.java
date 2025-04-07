// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;

/** Receiver of GroundOverlayOptions configuration. */
interface GroundOverlaySink {
  /**
   * Sets the transparency of the ground overlay.
   *
   * @param transparency the transparency value, where 0 is fully opaque and 1 is fully transparent.
   */
  void setTransparency(float transparency);

  /**
   * Sets the zIndex of the ground overlay.
   *
   * @param zIndex the zIndex value.
   */
  void setZIndex(float zIndex);

  /**
   * Sets the visibility of the ground overlay.
   *
   * @param visible true to make the ground overlay visible, false to make it invisible.
   */
  void setVisible(boolean visible);

  /**
   * Sets the anchor point of the ground overlay.
   *
   * @param u the u-coordinate of the anchor, as a ratio of the image width (in the range [0, 1]).
   * @param v the v-coordinate of the anchor, as a ratio of the image height (in the range [0, 1]).
   */
  void setAnchor(float u, float v);

  /**
   * Sets the bearing of the ground overlay.
   *
   * @param bearing the bearing in degrees clockwise from north.
   */
  void setBearing(float bearing);

  /**
   * Sets the clickability of the ground overlay.
   *
   * @param clickable true to make the ground overlay clickable, false otherwise. When clickable,
   *     the ground overlay triggers click events.
   */
  void setClickable(boolean clickable);

  /**
   * Sets the image for the ground overlay.
   *
   * @param imageDescriptor the BitmapDescriptor representing the image.
   */
  void setImage(@NonNull BitmapDescriptor imageDescriptor);

  /**
   * Sets the position of the ground overlay using a location and dimensions.
   *
   * @param location the LatLng location of the anchor point.
   * @param width the width of the ground overlay.
   * @param height the height of the ground overlay, or null to calculate proportions of the image
   *     automatically.
   */
  void setPosition(@NonNull LatLng location, @NonNull Float width, @Nullable Float height);

  /**
   * Sets the position of the ground overlay using bounds.
   *
   * @param bounds the LatLngBounds to fit the ground overlay within.
   */
  void setPositionFromBounds(@NonNull LatLngBounds bounds);
}
