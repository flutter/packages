// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.TileOverlay;
import com.google.android.gms.maps.model.TileOverlayOptions;
import io.flutter.plugins.googlemaps.Messages.MapsCallbackApi;
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

  void addJsonTileOverlays(List<Map<String, ?>> tileOverlaysToAdd) {
    if (tileOverlaysToAdd == null) {
      return;
    }
    for (Map<String, ?> tileOverlayToAdd : tileOverlaysToAdd) {
      addJsonTileOverlay(tileOverlayToAdd);
    }
  }

  void addTileOverlays(@NonNull List<Messages.PlatformTileOverlay> tileOverlaysToAdd) {
    for (Messages.PlatformTileOverlay tileOverlayToAdd : tileOverlaysToAdd) {
      @SuppressWarnings("unchecked")
      final Map<String, ?> overlayJson = (Map<String, ?>) tileOverlayToAdd.getJson();
      addJsonTileOverlay(overlayJson);
    }
  }

  void changeTileOverlays(@NonNull List<Messages.PlatformTileOverlay> tileOverlaysToChange) {
    for (Messages.PlatformTileOverlay tileOverlayToChange : tileOverlaysToChange) {
      @SuppressWarnings("unchecked")
      final Map<String, ?> overlayJson = (Map<String, ?>) tileOverlayToChange.getJson();
      changeJsonTileOverlay(overlayJson);
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

  private void addJsonTileOverlay(Map<String, ?> tileOverlayOptions) {
    if (tileOverlayOptions == null) {
      return;
    }
    TileOverlayBuilder tileOverlayOptionsBuilder = new TileOverlayBuilder();
    String tileOverlayId =
        Convert.interpretTileOverlayOptions(tileOverlayOptions, tileOverlayOptionsBuilder);
    TileProviderController tileProviderController =
        new TileProviderController(flutterApi, tileOverlayId);
    tileOverlayOptionsBuilder.setTileProvider(tileProviderController);
    TileOverlayOptions options = tileOverlayOptionsBuilder.build();
    TileOverlay tileOverlay = googleMap.addTileOverlay(options);
    TileOverlayController tileOverlayController = new TileOverlayController(tileOverlay);
    tileOverlayIdToController.put(tileOverlayId, tileOverlayController);
  }

  private void changeJsonTileOverlay(Map<String, ?> tileOverlayOptions) {
    if (tileOverlayOptions == null) {
      return;
    }
    String tileOverlayId = getTileOverlayId(tileOverlayOptions);
    TileOverlayController tileOverlayController = tileOverlayIdToController.get(tileOverlayId);
    if (tileOverlayController != null) {
      Convert.interpretTileOverlayOptions(tileOverlayOptions, tileOverlayController);
    }
  }

  private void removeTileOverlay(String tileOverlayId) {
    TileOverlayController tileOverlayController = tileOverlayIdToController.get(tileOverlayId);
    if (tileOverlayController != null) {
      tileOverlayController.remove();
      tileOverlayIdToController.remove(tileOverlayId);
    }
  }

  @SuppressWarnings("unchecked")
  private static String getTileOverlayId(Map<String, ?> tileOverlay) {
    return (String) tileOverlay.get("tileOverlayId");
  }
}
