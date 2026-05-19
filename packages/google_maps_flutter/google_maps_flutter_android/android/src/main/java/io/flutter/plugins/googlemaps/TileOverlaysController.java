// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.TileOverlay;
import com.google.android.gms.maps.model.TileOverlayOptions;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class TileOverlaysController {

  private final Map<String, TileOverlayController> tileOverlayIdToController;
  private final MapsCallbackApi flutterApi;
  private GoogleMap googleMap;

  TileOverlaysController(MapsCallbackApi flutterApi) {
    this.tileOverlayIdToController = new HashMap<>();
    this.flutterApi = flutterApi;
  }

  void setGoogleMap(GoogleMap googleMap) {
    this.googleMap = googleMap;
  }

  void addTileOverlays(@NonNull List<PlatformTileOverlay> tileOverlaysToAdd) {
    for (PlatformTileOverlay tileOverlayToAdd : tileOverlaysToAdd) {
      addTileOverlay(tileOverlayToAdd);
    }
  }

  void changeTileOverlays(@NonNull List<PlatformTileOverlay> tileOverlaysToChange) {
    for (PlatformTileOverlay tileOverlayToChange : tileOverlaysToChange) {
      changeTileOverlay(tileOverlayToChange);
    }
  }

  void removeTileOverlays(List<String> tileOverlayIdsToRemove) {
    if (tileOverlayIdsToRemove == null) {
      return;
    }
    for (String tileOverlayId : tileOverlayIdsToRemove) {
      if (tileOverlayId == null) {
        continue;
      }
      removeTileOverlay(tileOverlayId);
    }
  }

  void clearTileCache(String tileOverlayId) {
    if (tileOverlayId == null) {
      return;
    }
    TileOverlayController tileOverlayController = tileOverlayIdToController.get(tileOverlayId);
    if (tileOverlayController != null) {
      tileOverlayController.clearTileCache();
    }
  }

  @Nullable
  TileOverlay getTileOverlay(String tileOverlayId) {
    if (tileOverlayId == null) {
      return null;
    }
    TileOverlayController tileOverlayController = tileOverlayIdToController.get(tileOverlayId);
    if (tileOverlayController == null) {
      return null;
    }
    return tileOverlayController.getTileOverlay();
  }

  private void addTileOverlay(@NonNull PlatformTileOverlay platformTileOverlay) {
    TileOverlayBuilder tileOverlayOptionsBuilder = new TileOverlayBuilder();
    String tileOverlayId =
        Convert.interpretTileOverlayOptions(platformTileOverlay, tileOverlayOptionsBuilder);
    TileProviderController tileProviderController =
        new TileProviderController(flutterApi, tileOverlayId);
    tileOverlayOptionsBuilder.setTileProvider(tileProviderController);
    TileOverlayOptions options = tileOverlayOptionsBuilder.build();
    TileOverlay tileOverlay = googleMap.addTileOverlay(options);
    TileOverlayController tileOverlayController = new TileOverlayController(tileOverlay);
    tileOverlayIdToController.put(tileOverlayId, tileOverlayController);
  }

  private void changeTileOverlay(@NonNull PlatformTileOverlay platformTileOverlay) {
    String tileOverlayId = platformTileOverlay.getTileOverlayId();
    TileOverlayController tileOverlayController = tileOverlayIdToController.get(tileOverlayId);
    if (tileOverlayController != null) {
      Convert.interpretTileOverlayOptions(platformTileOverlay, tileOverlayController);
    }
  }

  private void removeTileOverlay(String tileOverlayId) {
    TileOverlayController tileOverlayController = tileOverlayIdToController.get(tileOverlayId);
    if (tileOverlayController != null) {
      tileOverlayController.remove();
      tileOverlayIdToController.remove(tileOverlayId);
    }
  }
}
