// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import android.content.res.AssetManager;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.GroundOverlay;
import com.google.android.gms.maps.model.GroundOverlayOptions;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import kotlin.Result;
import kotlin.Unit;

class GroundOverlaysController {
  private final Map<String, GroundOverlayController> groundOverlayIdToController;
  private final HashMap<String, String> googleMapsGroundOverlayIdToDartGroundOverlayId;
  private final MapsCallbackApi flutterApi;
  private GoogleMap googleMap;
  private final AssetManager assetManager;
  private final float density;
  private final Convert.BitmapDescriptorFactoryWrapper bitmapDescriptorFactoryWrapper;

  GroundOverlaysController(
      @NonNull MapsCallbackApi flutterApi, @NonNull AssetManager assetManager, float density) {
    this(flutterApi, assetManager, density, new Convert.BitmapDescriptorFactoryWrapper());
  }

  @VisibleForTesting
  GroundOverlaysController(
      @NonNull MapsCallbackApi flutterApi,
      @NonNull AssetManager assetManager,
      float density,
      @NonNull Convert.BitmapDescriptorFactoryWrapper bitmapDescriptorFactoryWrapper) {
    this.groundOverlayIdToController = new HashMap<>();
    this.googleMapsGroundOverlayIdToDartGroundOverlayId = new HashMap<>();
    this.flutterApi = flutterApi;
    this.assetManager = assetManager;
    this.density = density;
    this.bitmapDescriptorFactoryWrapper = bitmapDescriptorFactoryWrapper;
  }

  void setGoogleMap(GoogleMap googleMap) {
    this.googleMap = googleMap;
  }

  void addGroundOverlays(@NonNull List<PlatformGroundOverlay> groundOverlaysToAdd) {
    for (PlatformGroundOverlay groundOverlayToAdd : groundOverlaysToAdd) {
      addGroundOverlay(groundOverlayToAdd);
    }
  }

  void changeGroundOverlays(@NonNull List<PlatformGroundOverlay> groundOverlaysToChange) {
    for (PlatformGroundOverlay groundOverlayToChange : groundOverlaysToChange) {
      changeGroundOverlay(groundOverlayToChange);
    }
  }

  void removeGroundOverlays(@NonNull List<String> groundOverlayIdsToRemove) {
    for (@NonNull String groundOverlayId : groundOverlayIdsToRemove) {
      removeGroundOverlay(groundOverlayId);
    }
  }

  @Nullable
  GroundOverlay getGroundOverlay(@NonNull String groundOverlayId) {
    GroundOverlayController groundOverlayController =
        groundOverlayIdToController.get(groundOverlayId);
    if (groundOverlayController == null) {
      return null;
    }
    return groundOverlayController.getGroundOverlay();
  }

  private void addGroundOverlay(@NonNull PlatformGroundOverlay platformGroundOverlay) {
    GroundOverlayBuilder groundOverlayOptionsBuilder = new GroundOverlayBuilder();
    String groundOverlayId =
        Convert.interpretGroundOverlayOptions(
            platformGroundOverlay,
            groundOverlayOptionsBuilder,
            assetManager,
            density,
            bitmapDescriptorFactoryWrapper);
    GroundOverlayOptions options = groundOverlayOptionsBuilder.build();
    final GroundOverlay groundOverlay = googleMap.addGroundOverlay(options);
    if (groundOverlay != null) {
      GroundOverlayController groundOverlayController =
          new GroundOverlayController(groundOverlay, platformGroundOverlay.getBounds() != null);
      groundOverlayIdToController.put(groundOverlayId, groundOverlayController);
      googleMapsGroundOverlayIdToDartGroundOverlayId.put(groundOverlay.getId(), groundOverlayId);
    }
  }

  private void changeGroundOverlay(@NonNull PlatformGroundOverlay platformGroundOverlay) {
    String groundOverlayId = platformGroundOverlay.getGroundOverlayId();
    GroundOverlayController groundOverlayController =
        groundOverlayIdToController.get(groundOverlayId);
    if (groundOverlayController != null) {
      Convert.interpretGroundOverlayOptions(
          platformGroundOverlay,
          groundOverlayController,
          assetManager,
          density,
          bitmapDescriptorFactoryWrapper);
    }
  }

  private void removeGroundOverlay(@NonNull String groundOverlayId) {
    GroundOverlayController groundOverlayController =
        groundOverlayIdToController.get(groundOverlayId);
    if (groundOverlayController != null) {
      groundOverlayController.remove();
      groundOverlayIdToController.remove(groundOverlayId);
      googleMapsGroundOverlayIdToDartGroundOverlayId.remove(
          groundOverlayController.getGoogleMapsGroundOverlayId());
    }
  }

  void onGroundOverlayTap(@NonNull String googleGroundOverlayId) {
    String groundOverlayId =
        googleMapsGroundOverlayIdToDartGroundOverlayId.get(googleGroundOverlayId);
    if (groundOverlayId == null) {
      return;
    }
    flutterApi.onGroundOverlayTap(groundOverlayId, (Result<Unit> result) -> Unit.INSTANCE);
  }

  boolean isCreatedWithBounds(@NonNull String groundOverlayId) {
    GroundOverlayController groundOverlayController =
        groundOverlayIdToController.get(groundOverlayId);
    if (groundOverlayController == null) {
      return false;
    }
    return groundOverlayController.isCreatedWithBounds();
  }
}
