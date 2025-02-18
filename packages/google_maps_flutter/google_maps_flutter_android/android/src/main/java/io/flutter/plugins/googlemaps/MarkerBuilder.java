// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.AdvancedMarkerOptions;
import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.maps.android.clustering.ClusterItem;
import io.flutter.plugins.googlemaps.Messages.PlatformMarkerType;

class MarkerBuilder implements MarkerOptionsSink, ClusterItem {
  private final MarkerOptions markerOptions;
  private String clusterManagerId;
  private String markerId;
  private boolean consumeTapEvents;

  MarkerBuilder(String markerId, String clusterManagerId, PlatformMarkerType markerType) {
    this.markerOptions =
        markerType == PlatformMarkerType.ADVANCED_MARKER
            ? new AdvancedMarkerOptions()
            : new MarkerOptions();
    this.markerId = markerId;
    this.clusterManagerId = clusterManagerId;
  }

  MarkerOptions build() {
    return markerOptions;
  }

  /** Update existing markerOptions with builder values */
  void update(MarkerOptions markerOptionsToUpdate) {
    markerOptionsToUpdate.alpha(markerOptions.getAlpha());
    markerOptionsToUpdate.anchor(markerOptions.getAnchorU(), markerOptions.getAnchorV());
    markerOptionsToUpdate.draggable(markerOptions.isDraggable());
    markerOptionsToUpdate.flat(markerOptions.isFlat());
    markerOptionsToUpdate.icon(markerOptions.getIcon());
    markerOptionsToUpdate.infoWindowAnchor(
        markerOptions.getInfoWindowAnchorU(), markerOptions.getInfoWindowAnchorV());
    markerOptionsToUpdate.title(markerOptions.getTitle());
    markerOptionsToUpdate.snippet(markerOptions.getSnippet());
    markerOptionsToUpdate.position(markerOptions.getPosition());
    markerOptionsToUpdate.rotation(markerOptions.getRotation());
    markerOptionsToUpdate.visible(markerOptions.isVisible());
    markerOptionsToUpdate.zIndex(markerOptions.getZIndex());
  }

  boolean consumeTapEvents() {
    return consumeTapEvents;
  }

  String clusterManagerId() {
    return clusterManagerId;
  }

  String markerId() {
    return markerId;
  }

  @Override
  public void setAlpha(float alpha) {
    markerOptions.alpha(alpha);
  }

  @Override
  public void setAnchor(float u, float v) {
    markerOptions.anchor(u, v);
  }

  @Override
  public void setConsumeTapEvents(boolean consumeTapEvents) {
    this.consumeTapEvents = consumeTapEvents;
  }

  @Override
  public void setDraggable(boolean draggable) {
    markerOptions.draggable(draggable);
  }

  @Override
  public void setFlat(boolean flat) {
    markerOptions.flat(flat);
  }

  @Override
  public void setIcon(BitmapDescriptor bitmapDescriptor) {
    markerOptions.icon(bitmapDescriptor);
  }

  @Override
  public void setInfoWindowAnchor(float u, float v) {
    markerOptions.infoWindowAnchor(u, v);
  }

  @Override
  public void setInfoWindowText(String title, String snippet) {
    markerOptions.title(title);
    markerOptions.snippet(snippet);
  }

  @Override
  public void setPosition(LatLng position) {
    markerOptions.position(position);
  }

  @Override
  public void setRotation(float rotation) {
    markerOptions.rotation(rotation);
  }

  @Override
  public void setVisible(boolean visible) {
    markerOptions.visible(visible);
  }

  @Override
  public void setZIndex(float zIndex) {
    markerOptions.zIndex(zIndex);
  }

  @Override
  public void setCollisionBehavior(int collisionBehavior) {
    if (markerOptions.getClass() == AdvancedMarkerOptions.class) {
      ((AdvancedMarkerOptions) markerOptions).collisionBehavior(collisionBehavior);
    }
  }

  @Override
  public LatLng getPosition() {
    return markerOptions.getPosition();
  }

  @Override
  public String getTitle() {
    return markerOptions.getTitle();
  }

  @Override
  public String getSnippet() {
    return markerOptions.getSnippet();
  }

  @Override
  public Float getZIndex() {
    return markerOptions.getZIndex();
  }
}
