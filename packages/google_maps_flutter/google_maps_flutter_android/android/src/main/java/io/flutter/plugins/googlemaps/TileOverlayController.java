// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.TileOverlay;
import com.google.android.gms.maps.model.TileProvider;

class TileOverlayController implements TileOverlaySink {

  private final TileOverlay tileOverlay;

  TileOverlayController(TileOverlay tileOverlay) {
    this.tileOverlay = tileOverlay;
  }

  void remove() {
    tileOverlay.remove();
  }

  void clearTileCache() {
    tileOverlay.clearTileCache();
  }

  TileOverlay getTileOverlay() {
    return tileOverlay;
  }

  @Override
  public void setFadeIn(boolean fadeIn) {
    tileOverlay.setFadeIn(fadeIn);
  }

  @Override
  public void setTransparency(float transparency) {
    tileOverlay.setTransparency(transparency);
  }

  @Override
  public void setZIndex(float zIndex) {
    tileOverlay.setZIndex(zIndex);
  }

  @Override
  public void setVisible(boolean visible) {
    tileOverlay.setVisible(visible);
  }

  @Override
  public void setTileProvider(TileProvider tileProvider) {
    // You can not change tile provider after creation
  }
}
