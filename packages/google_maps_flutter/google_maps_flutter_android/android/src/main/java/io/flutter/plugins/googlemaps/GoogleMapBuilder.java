// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import android.content.Context;
import android.graphics.Rect;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.maps.GoogleMapOptions;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLngBounds;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.googlemaps.Messages.PlatformMarkerType;
import java.util.List;

class GoogleMapBuilder implements GoogleMapOptionsSink {
  private final GoogleMapOptions options = new GoogleMapOptions();
  private boolean trackCameraPosition = false;
  private boolean myLocationEnabled = false;
  private boolean myLocationButtonEnabled = false;
  private boolean indoorEnabled = true;
  private boolean trafficEnabled = false;
  private boolean buildingsEnabled = true;
  private List<Messages.PlatformMarker> initialMarkers;
  private List<Messages.PlatformClusterManager> initialClusterManagers;
  private List<Messages.PlatformPolygon> initialPolygons;
  private List<Messages.PlatformPolyline> initialPolylines;
  private List<Messages.PlatformCircle> initialCircles;
  private List<Messages.PlatformHeatmap> initialHeatmaps;
  private List<Messages.PlatformTileOverlay> initialTileOverlays;
  private Rect padding = new Rect(0, 0, 0, 0);
  private @Nullable String style;

  GoogleMapController build(
      int id,
      Context context,
      BinaryMessenger binaryMessenger,
      LifecycleProvider lifecycleProvider,
      PlatformMarkerType markerType) {
    final GoogleMapController controller =
        new GoogleMapController(
            id, context, binaryMessenger, lifecycleProvider, options, markerType);
    controller.init();
    controller.setMyLocationEnabled(myLocationEnabled);
    controller.setMyLocationButtonEnabled(myLocationButtonEnabled);
    controller.setIndoorEnabled(indoorEnabled);
    controller.setTrafficEnabled(trafficEnabled);
    controller.setBuildingsEnabled(buildingsEnabled);
    controller.setTrackCameraPosition(trackCameraPosition);
    controller.setInitialClusterManagers(initialClusterManagers);
    controller.setInitialMarkers(initialMarkers);
    controller.setInitialPolygons(initialPolygons);
    controller.setInitialPolylines(initialPolylines);
    controller.setInitialCircles(initialCircles);
    controller.setInitialHeatmaps(initialHeatmaps);
    controller.setPadding(padding.top, padding.left, padding.bottom, padding.right);
    controller.setInitialTileOverlays(initialTileOverlays);
    controller.setMapStyle(style);
    return controller;
  }

  void setInitialCameraPosition(CameraPosition position) {
    options.camera(position);
  }

  public void setMapId(String mapId) {
    options.mapId(mapId);
  }

  @Override
  public void setCompassEnabled(boolean compassEnabled) {
    options.compassEnabled(compassEnabled);
  }

  @Override
  public void setMapToolbarEnabled(boolean setMapToolbarEnabled) {
    options.mapToolbarEnabled(setMapToolbarEnabled);
  }

  @Override
  public void setCameraTargetBounds(LatLngBounds bounds) {
    options.latLngBoundsForCameraTarget(bounds);
  }

  @Override
  public void setMapType(int mapType) {
    options.mapType(mapType);
  }

  @Override
  public void setMinMaxZoomPreference(Float min, Float max) {
    if (min != null) {
      options.minZoomPreference(min);
    }
    if (max != null) {
      options.maxZoomPreference(max);
    }
  }

  @Override
  public void setPadding(float top, float left, float bottom, float right) {
    this.padding = new Rect((int) left, (int) top, (int) right, (int) bottom);
  }

  @Override
  public void setTrackCameraPosition(boolean trackCameraPosition) {
    this.trackCameraPosition = trackCameraPosition;
  }

  @Override
  public void setRotateGesturesEnabled(boolean rotateGesturesEnabled) {
    options.rotateGesturesEnabled(rotateGesturesEnabled);
  }

  @Override
  public void setScrollGesturesEnabled(boolean scrollGesturesEnabled) {
    options.scrollGesturesEnabled(scrollGesturesEnabled);
  }

  @Override
  public void setTiltGesturesEnabled(boolean tiltGesturesEnabled) {
    options.tiltGesturesEnabled(tiltGesturesEnabled);
  }

  @Override
  public void setZoomGesturesEnabled(boolean zoomGesturesEnabled) {
    options.zoomGesturesEnabled(zoomGesturesEnabled);
  }

  @Override
  public void setLiteModeEnabled(boolean liteModeEnabled) {
    options.liteMode(liteModeEnabled);
  }

  @Override
  public void setIndoorEnabled(boolean indoorEnabled) {
    this.indoorEnabled = indoorEnabled;
  }

  @Override
  public void setTrafficEnabled(boolean trafficEnabled) {
    this.trafficEnabled = trafficEnabled;
  }

  @Override
  public void setBuildingsEnabled(boolean buildingsEnabled) {
    this.buildingsEnabled = buildingsEnabled;
  }

  @Override
  public void setMyLocationEnabled(boolean myLocationEnabled) {
    this.myLocationEnabled = myLocationEnabled;
  }

  @Override
  public void setZoomControlsEnabled(boolean zoomControlsEnabled) {
    options.zoomControlsEnabled(zoomControlsEnabled);
  }

  @Override
  public void setMyLocationButtonEnabled(boolean myLocationButtonEnabled) {
    this.myLocationButtonEnabled = myLocationButtonEnabled;
  }

  @Override
  public void setInitialMarkers(@NonNull List<Messages.PlatformMarker> initialMarkers) {
    this.initialMarkers = initialMarkers;
  }

  @Override
  public void setInitialClusterManagers(
      @NonNull List<Messages.PlatformClusterManager> initialClusterManagers) {
    this.initialClusterManagers = initialClusterManagers;
  }

  @Override
  public void setInitialPolygons(@NonNull List<Messages.PlatformPolygon> initialPolygons) {
    this.initialPolygons = initialPolygons;
  }

  @Override
  public void setInitialPolylines(@NonNull List<Messages.PlatformPolyline> initialPolylines) {
    this.initialPolylines = initialPolylines;
  }

  @Override
  public void setInitialCircles(@NonNull List<Messages.PlatformCircle> initialCircles) {
    this.initialCircles = initialCircles;
  }

  @Override
  public void setInitialHeatmaps(@NonNull List<Messages.PlatformHeatmap> initialHeatmaps) {
    this.initialHeatmaps = initialHeatmaps;
  }

  public void setInitialTileOverlays(
      @NonNull List<Messages.PlatformTileOverlay> initialTileOverlays) {
    this.initialTileOverlays = initialTileOverlays;
  }

  @Override
  public void setMapStyle(@Nullable String style) {
    this.style = style;
  }
}
