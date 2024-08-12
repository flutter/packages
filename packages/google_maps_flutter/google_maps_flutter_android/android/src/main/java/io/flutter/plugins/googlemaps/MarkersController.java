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
import io.flutter.plugins.googlemaps.Messages.MapsCallbackApi;
import java.util.HashMap;
import java.util.List;
import java.util.Objects;

class MarkersController {
  private final HashMap<String, MarkerBuilder> markerIdToMarkerBuilder;
  private final HashMap<String, MarkerController> markerIdToController;
  private final HashMap<String, String> googleMapsMarkerIdToDartMarkerId;
  private final @NonNull MapsCallbackApi flutterApi;
  private MarkerManager.Collection markerCollection;
  private final ClusterManagersController clusterManagersController;
  private final AssetManager assetManager;
  private final float density;
  private final Convert.BitmapDescriptorFactoryWrapper bitmapDescriptorFactoryWrapper;

  MarkersController(
      @NonNull MapsCallbackApi flutterApi,
      ClusterManagersController clusterManagersController,
      AssetManager assetManager,
      float density,
      Convert.BitmapDescriptorFactoryWrapper bitmapDescriptorFactoryWrapper) {
    this.markerIdToMarkerBuilder = new HashMap<>();
    this.markerIdToController = new HashMap<>();
    this.googleMapsMarkerIdToDartMarkerId = new HashMap<>();
    this.flutterApi = flutterApi;
    this.clusterManagersController = clusterManagersController;
    this.assetManager = assetManager;
    this.density = density;
    this.bitmapDescriptorFactoryWrapper = bitmapDescriptorFactoryWrapper;
  }

  void setCollection(MarkerManager.Collection markerCollection) {
    this.markerCollection = markerCollection;
  }

  void addMarkers(@NonNull List<Messages.PlatformMarker> markersToAdd) {
    for (Messages.PlatformMarker markerToAdd : markersToAdd) {
      addMarker(markerToAdd);
    }
  }

  void changeMarkers(@NonNull List<Messages.PlatformMarker> markersToChange) {
    for (Messages.PlatformMarker markerToChange : markersToChange) {
      changeMarker(markerToChange);
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
    flutterApi.onMarkerTap(markerId, new NoOpVoidResult());
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
    flutterApi.onMarkerDragStart(markerId, Convert.latLngToPigeon(latLng), new NoOpVoidResult());
  }

  void onMarkerDrag(String googleMarkerId, LatLng latLng) {
    String markerId = googleMapsMarkerIdToDartMarkerId.get(googleMarkerId);
    if (markerId == null) {
      return;
    }
    flutterApi.onMarkerDrag(markerId, Convert.latLngToPigeon(latLng), new NoOpVoidResult());
  }

  void onMarkerDragEnd(String googleMarkerId, LatLng latLng) {
    String markerId = googleMapsMarkerIdToDartMarkerId.get(googleMarkerId);
    if (markerId == null) {
      return;
    }
    flutterApi.onMarkerDragEnd(markerId, Convert.latLngToPigeon(latLng), new NoOpVoidResult());
  }

  void onInfoWindowTap(String googleMarkerId) {
    String markerId = googleMapsMarkerIdToDartMarkerId.get(googleMarkerId);
    if (markerId == null) {
      return;
    }
    flutterApi.onInfoWindowTap(markerId, new NoOpVoidResult());
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

  private void addMarker(@NonNull Messages.PlatformMarker marker) {
    String markerId = marker.getMarkerId();
    String clusterManagerId = marker.getClusterManagerId();
    MarkerBuilder markerBuilder = new MarkerBuilder(markerId, clusterManagerId);
    Convert.interpretMarkerOptions(
        marker, markerBuilder, assetManager, density, bitmapDescriptorFactoryWrapper);
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

  private void changeMarker(@NonNull Messages.PlatformMarker marker) {
    String markerId = marker.getMarkerId();

    MarkerBuilder markerBuilder = markerIdToMarkerBuilder.get(markerId);
    if (markerBuilder == null) {
      return;
    }

    String clusterManagerId = marker.getClusterManagerId();
    String oldClusterManagerId = markerBuilder.clusterManagerId();

    // If the cluster ID on the updated marker has changed, the marker needs to
    // be removed and re-added to update its cluster manager state.
    if (!(Objects.equals(clusterManagerId, oldClusterManagerId))) {
      removeMarker(markerId);
      addMarker(marker);
      return;
    }

    // Update marker builder.
    Convert.interpretMarkerOptions(
        marker, markerBuilder, assetManager, density, bitmapDescriptorFactoryWrapper);

    // Update existing marker on map.
    MarkerController markerController = markerIdToController.get(markerId);
    if (markerController != null) {
      Convert.interpretMarkerOptions(
          marker, markerController, assetManager, density, bitmapDescriptorFactoryWrapper);
    }
  }
}
