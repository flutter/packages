// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.maps.model.LatLngBounds;
import java.util.List;

/** Receiver of GoogleMap configuration options. */
interface GoogleMapOptionsSink {
  void setCameraTargetBounds(LatLngBounds bounds);

  void setCompassEnabled(boolean compassEnabled);

  void setMapToolbarEnabled(boolean setMapToolbarEnabled);

  void setMapType(int mapType);

  void setMinMaxZoomPreference(Float min, Float max);

  void setPadding(float top, float left, float bottom, float right);

  void setRotateGesturesEnabled(boolean rotateGesturesEnabled);

  void setScrollGesturesEnabled(boolean scrollGesturesEnabled);

  void setTiltGesturesEnabled(boolean tiltGesturesEnabled);

  void setTrackCameraPosition(boolean trackCameraPosition);

  void setZoomGesturesEnabled(boolean zoomGesturesEnabled);

  void setLiteModeEnabled(boolean liteModeEnabled);

  void setMyLocationEnabled(boolean myLocationEnabled);

  void setZoomControlsEnabled(boolean zoomControlsEnabled);

  void setMyLocationButtonEnabled(boolean myLocationButtonEnabled);

  void setIndoorEnabled(boolean indoorEnabled);

  void setTrafficEnabled(boolean trafficEnabled);

  void setBuildingsEnabled(boolean buildingsEnabled);

  void setInitialMarkers(@NonNull List<Messages.PlatformMarker> initialMarkers);

  void setInitialClusterManagers(
      @NonNull List<Messages.PlatformClusterManager> initialClusterManagers);

  void setInitialPolygons(@NonNull List<Messages.PlatformPolygon> initialPolygons);

  void setInitialPolylines(@NonNull List<Messages.PlatformPolyline> initialPolylines);

  void setInitialCircles(@NonNull List<Messages.PlatformCircle> initialCircles);

  void setInitialHeatmaps(@NonNull List<Messages.PlatformHeatmap> initialHeatmaps);

  void setInitialTileOverlays(@NonNull List<Messages.PlatformTileOverlay> initialTileOverlays);

  void setInitialGroundOverlays(
      @NonNull List<Messages.PlatformGroundOverlay> initialGroundOverlays);

  void setMapStyle(@Nullable String style);
}
