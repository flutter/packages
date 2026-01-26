// Copyright 2013 The Flutter Authors
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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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
    // Group markers by cluster manager ID for batch operations
    Map<String, List<MarkerBuilder>> markersByCluster = new HashMap<>();
    List<MarkerBuilder> nonClusteredMarkers = new ArrayList<>();

    for (Messages.PlatformMarker markerToAdd : markersToAdd) {
      String markerId = markerToAdd.getMarkerId();
      String clusterManagerId = markerToAdd.getClusterManagerId();
      MarkerBuilder markerBuilder = new MarkerBuilder(markerId, clusterManagerId);
      Convert.interpretMarkerOptions(
          markerToAdd, markerBuilder, assetManager, density, bitmapDescriptorFactoryWrapper);

      // Store marker builder for future marker rebuilds when used under clusters.
      markerIdToMarkerBuilder.put(markerId, markerBuilder);

      if (clusterManagerId == null) {
        nonClusteredMarkers.add(markerBuilder);
      } else {
        if (!markersByCluster.containsKey(clusterManagerId)) {
          markersByCluster.put(clusterManagerId, new ArrayList<>());
        }
        markersByCluster.get(clusterManagerId).add(markerBuilder);
      }
    }

    // Add non-clustered markers to the collection
    for (MarkerBuilder markerBuilder : nonClusteredMarkers) {
      addMarkerToCollection(markerBuilder.markerId(), markerBuilder);
    }

    // Batch add clustered markers
    for (Map.Entry<String, List<MarkerBuilder>> entry : markersByCluster.entrySet()) {
      clusterManagersController.addItems(entry.getKey(), entry.getValue());
    }
  }

  void changeMarkers(@NonNull List<Messages.PlatformMarker> markersToChange) {
    // Collect markers that need cluster manager changes for batch processing
    Map<String, List<MarkerBuilder>> markersToAddByCluster = new HashMap<>();
    Map<String, List<MarkerBuilder>> markersToRemoveByCluster = new HashMap<>();

    for (Messages.PlatformMarker markerToChange : markersToChange) {
      String markerId = markerToChange.getMarkerId();
      MarkerBuilder markerBuilder = markerIdToMarkerBuilder.get(markerId);
      if (markerBuilder == null) {
        continue;
      }

      String clusterManagerId = markerToChange.getClusterManagerId();
      String oldClusterManagerId = markerBuilder.clusterManagerId();

      // If the cluster ID on the updated marker has changed, collect for batch processing
      if (!(Objects.equals(clusterManagerId, oldClusterManagerId))) {
        // Remove from old cluster manager
        if (oldClusterManagerId != null) {
          if (!markersToRemoveByCluster.containsKey(oldClusterManagerId)) {
            markersToRemoveByCluster.put(oldClusterManagerId, new ArrayList<>());
          }
          markersToRemoveByCluster.get(oldClusterManagerId).add(markerBuilder);
        }

        // Prepare new marker for addition
        MarkerBuilder newMarkerBuilder = new MarkerBuilder(markerId, clusterManagerId);
        Convert.interpretMarkerOptions(
            markerToChange,
            newMarkerBuilder,
            assetManager,
            density,
            bitmapDescriptorFactoryWrapper);
        markerIdToMarkerBuilder.put(markerId, newMarkerBuilder);

        if (clusterManagerId != null) {
          if (!markersToAddByCluster.containsKey(clusterManagerId)) {
            markersToAddByCluster.put(clusterManagerId, new ArrayList<>());
          }
          markersToAddByCluster.get(clusterManagerId).add(newMarkerBuilder);
        } else {
          // Add to map immediately if not clustered
          addMarkerToCollection(markerId, newMarkerBuilder);
        }

        // Clean up old marker controller if it's not clustered
        if (oldClusterManagerId == null) {
          MarkerController oldController = markerIdToController.remove(markerId);
          if (oldController != null && markerCollection != null) {
            oldController.removeFromCollection(markerCollection);
            googleMapsMarkerIdToDartMarkerId.remove(oldController.getGoogleMapsMarkerId());
          }
        }
      } else {
        // Update existing marker in place
        Convert.interpretMarkerOptions(
            markerToChange, markerBuilder, assetManager, density, bitmapDescriptorFactoryWrapper);
        MarkerController markerController = markerIdToController.get(markerId);
        if (markerController != null) {
          Convert.interpretMarkerOptions(
              markerToChange,
              markerController,
              assetManager,
              density,
              bitmapDescriptorFactoryWrapper);
        }
      }
    }

    // Batch remove from cluster managers
    for (Map.Entry<String, List<MarkerBuilder>> entry : markersToRemoveByCluster.entrySet()) {
      clusterManagersController.removeItems(entry.getKey(), entry.getValue());
    }

    // Batch add to cluster managers
    for (Map.Entry<String, List<MarkerBuilder>> entry : markersToAddByCluster.entrySet()) {
      clusterManagersController.addItems(entry.getKey(), entry.getValue());
    }
  }

  void removeMarkers(@NonNull List<String> markerIdsToRemove) {
    // Group markers by cluster manager ID for batch operations
    Map<String, List<MarkerBuilder>> markersByCluster = new HashMap<>();
    List<MarkerController> nonClusteredControllers = new ArrayList<>();

    for (String markerId : markerIdsToRemove) {
      final MarkerBuilder markerBuilder = markerIdToMarkerBuilder.get(markerId);
      if (markerBuilder == null) {
        continue;
      }

      final String clusterManagerId = markerBuilder.clusterManagerId();
      if (clusterManagerId != null) {
        if (!markersByCluster.containsKey(clusterManagerId)) {
          markersByCluster.put(clusterManagerId, new ArrayList<>());
        }
        markersByCluster.get(clusterManagerId).add(markerBuilder);
      } else {
        final MarkerController markerController = markerIdToController.get(markerId);
        if (markerController != null) {
          nonClusteredControllers.add(markerController);
        }
      }
    }

    // Batch remove clustered markers
    for (Map.Entry<String, List<MarkerBuilder>> entry : markersByCluster.entrySet()) {
      clusterManagersController.removeItems(entry.getKey(), entry.getValue());
    }

    // Remove non-clustered markers from the collection
    for (MarkerController markerController : nonClusteredControllers) {
      if (this.markerCollection != null) {
        markerController.removeFromCollection(markerCollection);
      }
    }

    // Clean up all marker references
    for (String markerId : markerIdsToRemove) {
      markerIdToMarkerBuilder.remove(markerId);
      final MarkerController markerController = markerIdToController.remove(markerId);
      if (markerController != null) {
        googleMapsMarkerIdToDartMarkerId.remove(markerController.getGoogleMapsMarkerId());
      }
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
