// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import androidx.annotation.NonNull;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.Polygon;
import com.google.android.gms.maps.model.PolygonOptions;
import io.flutter.plugins.googlemaps.Messages.MapsCallbackApi;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class PolygonsController {

  private final Map<String, PolygonController> polygonIdToController;
  private final Map<String, String> googleMapsPolygonIdToDartPolygonId;
  private final @NonNull MapsCallbackApi flutterApi;
  private final float density;
  private GoogleMap googleMap;

  PolygonsController(@NonNull MapsCallbackApi flutterApi, float density) {
    this.polygonIdToController = new HashMap<>();
    this.googleMapsPolygonIdToDartPolygonId = new HashMap<>();
    this.flutterApi = flutterApi;
    this.density = density;
  }

  void setGoogleMap(GoogleMap googleMap) {
    this.googleMap = googleMap;
  }

  void addPolygons(@NonNull List<Messages.PlatformPolygon> polygonsToAdd) {
    for (Messages.PlatformPolygon polygonToAdd : polygonsToAdd) {
      addPolygon(polygonToAdd);
    }
  }

  void changePolygons(@NonNull List<Messages.PlatformPolygon> polygonsToChange) {
    for (Messages.PlatformPolygon polygonToChange : polygonsToChange) {
      changePolygon(polygonToChange);
    }
  }

  void removePolygons(@NonNull List<String> polygonIdsToRemove) {
    for (String polygonId : polygonIdsToRemove) {
      final PolygonController polygonController = polygonIdToController.remove(polygonId);
      if (polygonController != null) {
        polygonController.remove();
        googleMapsPolygonIdToDartPolygonId.remove(polygonController.getGoogleMapsPolygonId());
      }
    }
  }

  boolean onPolygonTap(String googlePolygonId) {
    String polygonId = googleMapsPolygonIdToDartPolygonId.get(googlePolygonId);
    if (polygonId == null) {
      return false;
    }
    flutterApi.onPolygonTap(polygonId, new NoOpVoidResult());
    PolygonController polygonController = polygonIdToController.get(polygonId);
    if (polygonController != null) {
      return polygonController.consumeTapEvents();
    }
    return false;
  }

  private void addPolygon(@NonNull Messages.PlatformPolygon polygon) {
    PolygonBuilder polygonBuilder = new PolygonBuilder(density);
    String polygonId = Convert.interpretPolygonOptions(polygon, polygonBuilder);
    PolygonOptions options = polygonBuilder.build();
    addPolygon(polygonId, options, polygonBuilder.consumeTapEvents());
  }

  private void addPolygon(
      String polygonId, PolygonOptions polygonOptions, boolean consumeTapEvents) {
    final Polygon polygon = googleMap.addPolygon(polygonOptions);
    PolygonController controller = new PolygonController(polygon, consumeTapEvents, density);
    polygonIdToController.put(polygonId, controller);
    googleMapsPolygonIdToDartPolygonId.put(polygon.getId(), polygonId);
  }

  private void changePolygon(@NonNull Messages.PlatformPolygon polygon) {
    PolygonController polygonController = polygonIdToController.get(polygon.getPolygonId());
    if (polygonController != null) {
      Convert.interpretPolygonOptions(polygon, polygonController);
    }
  }

  private static String getPolygonId(Map<String, ?> polygon) {
    return (String) polygon.get("polygonId");
  }
}
