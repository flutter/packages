// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import android.content.res.AssetManager;
import androidx.annotation.NonNull;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.Polyline;
import com.google.android.gms.maps.model.PolylineOptions;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class PolylinesController {

  private final Map<String, PolylineController> polylineIdToController;
  private final Map<String, String> googleMapsPolylineIdToDartPolylineId;
  private final MethodChannel methodChannel;
  private GoogleMap googleMap;
  private final float density;
  private final AssetManager assetManager;

  PolylinesController(MethodChannel methodChannel, AssetManager assetManager, float density) {
    this.assetManager = assetManager;
    this.polylineIdToController = new HashMap<>();
    this.googleMapsPolylineIdToDartPolylineId = new HashMap<>();
    this.methodChannel = methodChannel;
    this.density = density;
  }

  void setGoogleMap(GoogleMap googleMap) {
    this.googleMap = googleMap;
  }

  void addJsonPolylines(List<Object> polylinesToAdd) {
    if (polylinesToAdd != null) {
      for (Object polylineToAdd : polylinesToAdd) {
        @SuppressWarnings("unchecked")
        Map<String, ?> polylineMap = (Map<String, ?>) polylineToAdd;
        addJsonPolyline(polylineMap);
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
    methodChannel.invokeMethod("polyline#onTap", Convert.polylineIdToJson(polylineId));
    PolylineController polylineController = polylineIdToController.get(polylineId);
    if (polylineController != null) {
      return polylineController.consumeTapEvents();
    }
    return false;
  }

  private void addJsonPolyline(Map<String, ?> polyline) {
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

  private void changeJsonPolyline(Map<String, ?> polyline) {
    if (polyline == null) {
      return;
    }
    String polylineId = getPolylineId(polyline);
    PolylineController polylineController = polylineIdToController.get(polylineId);
    if (polylineController != null) {
      Convert.interpretPolylineOptions(polyline, polylineController, assetManager, density);
    }
  }

  private static String getPolylineId(Map<String, ?> polyline) {
    return (String) polyline.get("polylineId");
  }
}
