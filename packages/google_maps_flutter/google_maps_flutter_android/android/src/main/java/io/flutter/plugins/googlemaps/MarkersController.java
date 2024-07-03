// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import android.content.res.AssetManager;
import androidx.annotation.NonNull;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.maps.android.collections.MarkerManager;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

class MarkersController {
  private final HashMap<String, MarkerBuilder> markerIdToMarkerBuilder;
  private final HashMap<String, MarkerController> markerIdToController;
  private final HashMap<String, String> googleMapsMarkerIdToDartMarkerId;
  private final MethodChannel methodChannel;
  private MarkerManager.Collection markerCollection;
  private final ClusterManagersController clusterManagersController;
  private final AssetManager assetManager;
  private final float density;

  MarkersController(
      MethodChannel methodChannel,
      ClusterManagersController clusterManagersController,
      AssetManager assetManager,
      float density) {
    this.markerIdToMarkerBuilder = new HashMap<>();
    this.markerIdToController = new HashMap<>();
    this.googleMapsMarkerIdToDartMarkerId = new HashMap<>();
    this.methodChannel = methodChannel;
    this.clusterManagersController = clusterManagersController;
    this.assetManager = assetManager;
    this.density = density;
  }

  void setCollection(MarkerManager.Collection markerCollection) {
    this.markerCollection = markerCollection;
  }

  void addJsonMarkers(List<Object> markersToAdd) {
    if (markersToAdd != null) {
      for (Object markerToAdd : markersToAdd) {
        addJsonMarker(markerToAdd);
      }
    }
  }

  void addMarkers(@NonNull List<Messages.PlatformMarker> markersToAdd) {
    for (Messages.PlatformMarker markerToAdd : markersToAdd) {
      addJsonMarker(markerToAdd.getJson());
    }
  }

  void changeMarkers(@NonNull List<Messages.PlatformMarker> markersToChange) {
    for (Messages.PlatformMarker markerToChange : markersToChange) {
      changeJsonMarker(markerToChange.getJson());
    }
  }

  void removeMarkers(@NonNull List<String> markerIdsToRemove) {
    for (String markerId : markerIdsToRemove) {
      removeMarker(markerId);
    }
  }

  private void removeMarker(String markerId) {
    final MarkerBuilder markerBuilder = markerIdToMarkerBuilder.remove(markerId);
    if (markerBuilder == null) {
      return;
    }
    final MarkerController markerController = markerIdToController.remove(markerId);
    final String clusterManagerId = markerBuilder.clusterManagerId();
    if (clusterManagerId != null) {
      // Remove marker from clusterManager.
      clusterManagersController.removeItem(markerBuilder);
    } else if (markerController != null && this.markerCollection != null) {
      // Remove marker from map and markerCollection
      markerController.removeFromCollection(markerCollection);
    }

    if (markerController != null) {
      googleMapsMarkerIdToDartMarkerId.remove(markerController.getGoogleMapsMarkerId());
    }
  }

  void showMarkerInfoWindow(String markerId) {
    MarkerController markerController = markerIdToController.get(markerId);
    if (markerController == null) {
      throw new Messages.FlutterError(
          "Invalid markerId", "showInfoWindow called with invalid markerId", null);
    }
    markerController.showInfoWindow();
  }

  void hideMarkerInfoWindow(String markerId) {
    MarkerController markerController = markerIdToController.get(markerId);
    if (markerController == null) {
      throw new Messages.FlutterError(
          "Invalid markerId", "hideInfoWindow called with invalid markerId", null);
    }
    markerController.hideInfoWindow();
  }

  boolean isInfoWindowShown(String markerId) {
    MarkerController markerController = markerIdToController.get(markerId);
    if (markerController == null) {
      throw new Messages.FlutterError(
          "Invalid markerId", "isInfoWindowShown called with invalid markerId", null);
    }
    return markerController.isInfoWindowShown();
  }

  boolean onMapsMarkerTap(String googleMarkerId) {
    String markerId = googleMapsMarkerIdToDartMarkerId.get(googleMarkerId);
    if (markerId == null) {
      return false;
    }
    return onMarkerTap(markerId);
  }

  boolean onMarkerTap(String markerId) {
    methodChannel.invokeMethod("marker#onTap", Convert.markerIdToJson(markerId));
    MarkerController markerController = markerIdToController.get(markerId);
    if (markerController != null) {
      return markerController.consumeTapEvents();
    }
    return false;
  }

  void onMarkerDragStart(String googleMarkerId, LatLng latLng) {
    String markerId = googleMapsMarkerIdToDartMarkerId.get(googleMarkerId);
    if (markerId == null) {
      return;
    }
    final Map<String, Object> data = new HashMap<>();
    data.put("markerId", markerId);
    data.put("position", Convert.latLngToJson(latLng));
    methodChannel.invokeMethod("marker#onDragStart", data);
  }

  void onMarkerDrag(String googleMarkerId, LatLng latLng) {
    String markerId = googleMapsMarkerIdToDartMarkerId.get(googleMarkerId);
    if (markerId == null) {
      return;
    }
    final Map<String, Object> data = new HashMap<>();
    data.put("markerId", markerId);
    data.put("position", Convert.latLngToJson(latLng));
    methodChannel.invokeMethod("marker#onDrag", data);
  }

  void onMarkerDragEnd(String googleMarkerId, LatLng latLng) {
    String markerId = googleMapsMarkerIdToDartMarkerId.get(googleMarkerId);
    if (markerId == null) {
      return;
    }
    final Map<String, Object> data = new HashMap<>();
    data.put("markerId", markerId);
    data.put("position", Convert.latLngToJson(latLng));
    methodChannel.invokeMethod("marker#onDragEnd", data);
  }

  void onInfoWindowTap(String googleMarkerId) {
    String markerId = googleMapsMarkerIdToDartMarkerId.get(googleMarkerId);
    if (markerId == null) {
      return;
    }
    methodChannel.invokeMethod("infoWindow#onTap", Convert.markerIdToJson(markerId));
  }

  /**
   * Called each time clusterManager adds new visible marker to the map. Creates markerController
   * for marker for realtime marker updates.
   */
  public void onClusterItemRendered(MarkerBuilder markerBuilder, Marker marker) {
    String markerId = markerBuilder.markerId();
    if (markerIdToMarkerBuilder.get(markerId) == markerBuilder) {
      createControllerForMarker(markerBuilder.markerId(), marker, markerBuilder.consumeTapEvents());
    }
  }

  private void addJsonMarker(Object marker) {
    if (marker == null) {
      return;
    }
    String markerId = getMarkerId(marker);
    if (markerId == null) {
      throw new IllegalArgumentException("markerId was null");
    }
    String clusterManagerId = getClusterManagerId(marker);
    MarkerBuilder markerBuilder = new MarkerBuilder(markerId, clusterManagerId);
    Convert.interpretMarkerOptions(marker, markerBuilder, assetManager, density);
    addMarker(markerBuilder);
  }

  private void addMarker(MarkerBuilder markerBuilder) {
    if (markerBuilder == null) {
      return;
    }
    String markerId = markerBuilder.markerId();

    // Store marker builder for future marker rebuilds when used under clusters.
    markerIdToMarkerBuilder.put(markerId, markerBuilder);

    if (markerBuilder.clusterManagerId() == null) {
      addMarkerToCollection(markerId, markerBuilder);
    } else {
      addMarkerBuilderForCluster(markerBuilder);
    }
  }

  private void addMarkerToCollection(String markerId, MarkerBuilder markerBuilder) {
    MarkerOptions options = markerBuilder.build();
    final Marker marker = markerCollection.addMarker(options);
    createControllerForMarker(markerId, marker, markerBuilder.consumeTapEvents());
  }

  private void addMarkerBuilderForCluster(MarkerBuilder markerBuilder) {
    clusterManagersController.addItem(markerBuilder);
  }

  private void createControllerForMarker(String markerId, Marker marker, boolean consumeTapEvents) {
    MarkerController controller = new MarkerController(marker, consumeTapEvents);
    markerIdToController.put(markerId, controller);
    googleMapsMarkerIdToDartMarkerId.put(marker.getId(), markerId);
  }

  private void changeJsonMarker(Object marker) {
    if (marker == null) {
      return;
    }
    String markerId = getMarkerId(marker);

    MarkerBuilder markerBuilder = markerIdToMarkerBuilder.get(markerId);
    if (markerBuilder == null) {
      return;
    }

    String clusterManagerId = getClusterManagerId(marker);
    String oldClusterManagerId = markerBuilder.clusterManagerId();

    // If the cluster ID on the updated marker has changed, the marker needs to
    // be removed and re-added to update its cluster manager state.
    if (!(Objects.equals(clusterManagerId, oldClusterManagerId))) {
      removeMarker(markerId);
      addJsonMarker(marker);
      return;
    }

    // Update marker builder.
    Convert.interpretMarkerOptions(marker, markerBuilder, assetManager, density);

    // Update existing marker on map.
    MarkerController markerController = markerIdToController.get(markerId);
    if (markerController != null) {
      Convert.interpretMarkerOptions(marker, markerController, assetManager, density);
    }
  }

  @SuppressWarnings("unchecked")
  private static String getMarkerId(Object marker) {
    Map<String, Object> markerMap = (Map<String, Object>) marker;
    return (String) markerMap.get("markerId");
  }

  @SuppressWarnings("unchecked")
  private static String getClusterManagerId(Object marker) {
    Map<String, Object> markerMap = (Map<String, Object>) marker;
    return (String) markerMap.get("clusterManagerId");
  }
}
