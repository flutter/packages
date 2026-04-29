// Copyright 2013 The Flutter Authors
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

  void setInitialMarkers(@NonNull List<PlatformMarker> initialMarkers);

  void setInitialClusterManagers(@NonNull List<PlatformClusterManager> initialClusterManagers);

  void setInitialPolygons(@NonNull List<PlatformPolygon> initialPolygons);

  void setInitialPolylines(@NonNull List<PlatformPolyline> initialPolylines);

  void setInitialCircles(@NonNull List<PlatformCircle> initialCircles);

  void setInitialHeatmaps(@NonNull List<PlatformHeatmap> initialHeatmaps);

  void setInitialTileOverlays(@NonNull List<PlatformTileOverlay> initialTileOverlays);

  void setInitialGroundOverlays(@NonNull List<PlatformGroundOverlay> initialGroundOverlays);

  void setMapStyle(@Nullable String style);
}
