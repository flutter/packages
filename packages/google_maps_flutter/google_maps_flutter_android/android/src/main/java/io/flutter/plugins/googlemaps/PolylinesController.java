// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import android.content.res.AssetManager;
import androidx.annotation.NonNull;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.Polyline;
import com.google.android.gms.maps.model.PolylineOptions;
import io.flutter.plugins.googlemaps.Messages.MapsCallbackApi;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class PolylinesController {

  private final Map<String, PolylineController> polylineIdToController;
  private final Map<String, String> googleMapsPolylineIdToDartPolylineId;
  private final @NonNull MapsCallbackApi flutterApi;
  private GoogleMap googleMap;
  private final float density;
  private final AssetManager assetManager;

  PolylinesController(
      @NonNull MapsCallbackApi flutterApi, AssetManager assetManager, float density) {
    this.assetManager = assetManager;
    this.polylineIdToController = new HashMap<>();
    this.googleMapsPolylineIdToDartPolylineId = new HashMap<>();
    this.flutterApi = flutterApi;
    this.density = density;
  }

  void setGoogleMap(GoogleMap googleMap) {
    this.googleMap = googleMap;
  }

  void addJsonPolylines(List<Object> polylinesToAdd) {
    if (polylinesToAdd != null) {
      for (Object polylineToAdd : polylinesToAdd) {
        addJsonPolyline(polylineToAdd);
      }
    }
  }

  void addPolylines(@NonNull List<Messages.PlatformPolyline> polylinesToAdd) {
    for (Messages.PlatformPolyline polylineToAdd : polylinesToAdd) {
      addJsonPolyline(polylineToAdd.getJson());
    }
  }

  void changePolylines(@NonNull List<Messages.PlatformPolyline> polylinesToChange) {
    for (Messages.PlatformPolyline polylineToChange : polylinesToChange) {
      changeJsonPolyline(polylineToChange.getJson());
    }
  }

  void removePolylines(@NonNull List<String> polylineIdsToRemove) {
    for (String polylineId : polylineIdsToRemove) {
      final PolylineController polylineController = polylineIdToController.remove(polylineId);
      if (polylineController != null) {
        polylineController.remove();
        googleMapsPolylineIdToDartPolylineId.remove(polylineController.getGoogleMapsPolylineId());
      }
    }
  }

  boolean onPolylineTap(String googlePolylineId) {
    String polylineId = googleMapsPolylineIdToDartPolylineId.get(googlePolylineId);
    if (polylineId == null) {
      return false;
    }
    flutterApi.onPolylineTap(polylineId, new Messages.VoidResult() {
      @Override
      public void success() {}

      @Override
      public void error(@NonNull Throwable error) {}
    });
    PolylineController polylineController = polylineIdToController.get(polylineId);
    if (polylineController != null) {
      return polylineController.consumeTapEvents();
    }
    return false;
  }

  private void addJsonPolyline(Object polyline) {
    if (polyline == null) {
      return;
    }
    PolylineBuilder polylineBuilder = new PolylineBuilder(density);
    String polylineId =
        Convert.interpretPolylineOptions(polyline, polylineBuilder, assetManager, density);
    PolylineOptions options = polylineBuilder.build();
    addPolyline(polylineId, options, polylineBuilder.consumeTapEvents());
  }

  private void addPolyline(
      String polylineId, PolylineOptions polylineOptions, boolean consumeTapEvents) {
    final Polyline polyline = googleMap.addPolyline(polylineOptions);
    PolylineController controller = new PolylineController(polyline, consumeTapEvents, density);
    polylineIdToController.put(polylineId, controller);
    googleMapsPolylineIdToDartPolylineId.put(polyline.getId(), polylineId);
  }

  private void changeJsonPolyline(Object polyline) {
    if (polyline == null) {
      return;
    }
    String polylineId = getPolylineId(polyline);
    PolylineController polylineController = polylineIdToController.get(polylineId);
    if (polylineController != null) {
      Convert.interpretPolylineOptions(polyline, polylineController, assetManager, density);
    }
  }

  @SuppressWarnings("unchecked")
  private static String getPolylineId(Object polyline) {
    Map<String, Object> polylineMap = (Map<String, Object>) polyline;
    return (String) polylineMap.get("polylineId");
  }
}
