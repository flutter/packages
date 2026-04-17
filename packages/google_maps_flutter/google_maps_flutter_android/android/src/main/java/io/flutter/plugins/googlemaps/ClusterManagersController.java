// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.AdvancedMarkerOptions;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.maps.android.clustering.Cluster;
import com.google.maps.android.clustering.ClusterItem;
import com.google.maps.android.clustering.ClusterManager;
import com.google.maps.android.clustering.view.ClusterRenderer;
import com.google.maps.android.clustering.view.DefaultAdvancedMarkersClusterRenderer;
import com.google.maps.android.clustering.view.DefaultClusterRenderer;
import com.google.maps.android.collections.MarkerManager;
import io.flutter.plugins.googlemaps.Messages.MapsCallbackApi;
import io.flutter.plugins.googlemaps.Messages.PlatformMarkerType;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Controls cluster managers and exposes interfaces for adding and removing cluster items for
 * specific cluster managers.
 */
class ClusterManagersController
    implements GoogleMap.OnCameraIdleListener,
        ClusterManager.OnClusterClickListener<MarkerBuilder> {
  private final @NonNull Context context;

  @VisibleForTesting @NonNull
  protected final HashMap<String, ClusterManager<MarkerBuilder>> clusterManagerIdToManager;

  private final @NonNull MapsCallbackApi flutterApi;
  private @Nullable MarkerManager markerManager;
  private @Nullable GoogleMap googleMap;
  private final @NonNull PlatformMarkerType markerType;

  @Nullable
  private ClusterManager.OnClusterItemClickListener<MarkerBuilder> clusterItemClickListener;

  @Nullable
  private ClusterManager.OnClusterItemInfoWindowClickListener<MarkerBuilder>
      clusterItemInfoWindowClickListener;

  @Nullable
  private ClusterManagersController.OnClusterItemRendered<MarkerBuilder>
      clusterItemRenderedListener;

  ClusterManagersController(
      @NonNull MapsCallbackApi flutterApi,
      @NonNull Context context,
      @NonNull PlatformMarkerType markerType) {
    this.clusterManagerIdToManager = new HashMap<>();
    this.context = context;
    this.flutterApi = flutterApi;
    this.markerType = markerType;
  }

  void init(GoogleMap googleMap, MarkerManager markerManager) {
    this.markerManager = markerManager;
    this.googleMap = googleMap;
  }

  void setClusterItemClickListener(
      @Nullable ClusterManager.OnClusterItemClickListener<MarkerBuilder> listener) {
    clusterItemClickListener = listener;
    initListenersForClusterManagers();
  }

  void setClusterItemInfoWindowClickListener(
      @Nullable ClusterManager.OnClusterItemInfoWindowClickListener<MarkerBuilder> listener) {
    clusterItemInfoWindowClickListener = listener;
    initListenersForClusterManagers();
  }

  void setClusterItemRenderedListener(
      @Nullable ClusterManagersController.OnClusterItemRendered<MarkerBuilder> listener) {
    clusterItemRenderedListener = listener;
  }

  private void initListenersForClusterManagers() {
    for (Map.Entry<String, ClusterManager<MarkerBuilder>> entry :
        clusterManagerIdToManager.entrySet()) {
      initListenersForClusterManager(
          entry.getValue(), this, clusterItemClickListener, clusterItemInfoWindowClickListener);
    }
  }

  private void initListenersForClusterManager(
      ClusterManager<MarkerBuilder> clusterManager,
      @Nullable ClusterManager.OnClusterClickListener<MarkerBuilder> clusterClickListener,
      @Nullable ClusterManager.OnClusterItemClickListener<MarkerBuilder> clusterItemClickListener,
      @Nullable
          ClusterManager.OnClusterItemInfoWindowClickListener<MarkerBuilder>
              clusterItemInfoWindowClickListener) {
    clusterManager.setOnClusterClickListener(clusterClickListener);
    clusterManager.setOnClusterItemClickListener(clusterItemClickListener);
    clusterManager.setOnClusterItemInfoWindowClickListener(clusterItemInfoWindowClickListener);
  }

  /** Adds new ClusterManagers to the controller. */
  void addClusterManagers(@NonNull List<Messages.PlatformClusterManager> clusterManagersToAdd) {
    for (Messages.PlatformClusterManager clusterToAdd : clusterManagersToAdd) {
      addClusterManager(clusterToAdd.getIdentifier());
    }
  }

  /** Adds new ClusterManager to the controller. */
  void addClusterManager(String clusterManagerId) {
    ClusterManager<MarkerBuilder> clusterManager =
        new ClusterManager<>(context, googleMap, markerManager);
    initializeRenderer(clusterManager);
    clusterManagerIdToManager.put(clusterManagerId, clusterManager);
  }

  /**
   * Initializes cluster renderer based on marker type. AdvancedMarkerCluster renderer is used for
   * advanced markers and MarkerClusterRenderer is used for default markers.
   */
  private void initializeRenderer(ClusterManager<MarkerBuilder> clusterManager) {
    final ClusterRenderer<MarkerBuilder> clusterRenderer =
        switch (markerType) {
          case ADVANCED_MARKER ->
              new AdvancedMarkerClusterRenderer<>(context, googleMap, clusterManager, this);
          default -> new MarkerClusterRenderer<>(context, googleMap, clusterManager, this);
        };
    clusterManager.setRenderer(clusterRenderer);
    initListenersForClusterManager(
        clusterManager, this, clusterItemClickListener, clusterItemInfoWindowClickListener);
  }

  /** Removes ClusterManagers by given cluster manager IDs from the controller. */
  public void removeClusterManagers(@NonNull List<String> clusterManagerIdsToRemove) {
    for (String clusterManagerId : clusterManagerIdsToRemove) {
      removeClusterManager(clusterManagerId);
    }
  }

  /**
   * Removes the ClusterManagers by the given cluster manager ID from the controller. The reference
   * to this cluster manager is removed from the clusterManagerIdToManager and it will be garbage
   * collected later.
   */
  private void removeClusterManager(String clusterManagerId) {
    // Remove the cluster manager from the hash map to allow it to be garbage collected.
    final ClusterManager<MarkerBuilder> clusterManager =
        clusterManagerIdToManager.remove(clusterManagerId);
    if (clusterManager == null) {
      return;
    }
    initListenersForClusterManager(clusterManager, null, null, null);
    clusterManager.clearItems();
    clusterManager.cluster();
  }

  /** Adds item to the ClusterManager it belongs to. */
  public void addItem(MarkerBuilder item) {
    ClusterManager<MarkerBuilder> clusterManager =
        clusterManagerIdToManager.get(item.clusterManagerId());
    if (clusterManager != null) {
      clusterManager.addItem(item);
      clusterManager.cluster();
    }
  }

  /** Adds multiple items to the ClusterManager with the given ID. */
  public void addItems(String clusterManagerId, @NonNull List<MarkerBuilder> items) {
    ClusterManager<MarkerBuilder> clusterManager = clusterManagerIdToManager.get(clusterManagerId);
    if (clusterManager != null) {
      clusterManager.addItems(items);
      clusterManager.cluster();
    }
  }

  /** Removes item from the ClusterManager it belongs to. */
  public void removeItem(MarkerBuilder item) {
    ClusterManager<MarkerBuilder> clusterManager =
        clusterManagerIdToManager.get(item.clusterManagerId());
    if (clusterManager != null) {
      clusterManager.removeItem(item);
      clusterManager.cluster();
    }
  }

  /** Removes multiple items from the ClusterManager with the given ID. */
  public void removeItems(String clusterManagerId, @NonNull List<MarkerBuilder> items) {
    ClusterManager<MarkerBuilder> clusterManager = clusterManagerIdToManager.get(clusterManagerId);
    if (clusterManager != null) {
      clusterManager.removeItems(items);
      clusterManager.cluster();
    }
  }

  /** Called when ClusterRenderer has rendered new visible marker to the map. */
  void onClusterItemRendered(@NonNull MarkerBuilder item, @NonNull Marker marker) {
    // If map is being disposed, clusterItemRenderedListener might have been cleared and
    // set to null.
    if (clusterItemRenderedListener != null) {
      clusterItemRenderedListener.onClusterItemRendered(item, marker);
    }
  }

  /**
   * Requests all current clusters from the algorithm of the requested ClusterManager and converts
   * them to result response.
   */
  public @NonNull Set<? extends Cluster<MarkerBuilder>> getClustersWithClusterManagerId(
      String clusterManagerId) {
    ClusterManager<MarkerBuilder> clusterManager = clusterManagerIdToManager.get(clusterManagerId);
    if (clusterManager == null) {
      throw new Messages.FlutterError(
          "Invalid clusterManagerId",
          "getClusters called with invalid clusterManagerId:" + clusterManagerId,
          null);
    }
    return clusterManager.getAlgorithm().getClusters(googleMap.getCameraPosition().zoom);
  }

  @Override
  public void onCameraIdle() {
    for (Map.Entry<String, ClusterManager<MarkerBuilder>> entry :
        clusterManagerIdToManager.entrySet()) {
      entry.getValue().onCameraIdle();
    }
  }

  @Override
  public boolean onClusterClick(Cluster<MarkerBuilder> cluster) {
    if (cluster.getSize() > 0) {
      MarkerBuilder[] builders = cluster.getItems().toArray(new MarkerBuilder[0]);
      String clusterManagerId = builders[0].clusterManagerId();
      flutterApi.onClusterTap(
          Convert.clusterToPigeon(clusterManagerId, cluster), new NoOpVoidResult());
    }

    // Return false to allow the default behavior of the cluster click event to occur.
    return false;
  }

  /**
   * MarkerClusterRenderer builds marker options for new markers to be rendered to the map. After
   * cluster item (marker) is rendered, it is sent to the listeners for control.
   */
  @VisibleForTesting
  static class MarkerClusterRenderer<T extends MarkerBuilder> extends DefaultClusterRenderer<T> {
    private final ClusterManagersController clusterManagersController;

    public MarkerClusterRenderer(
        Context context,
        GoogleMap map,
        ClusterManager<T> clusterManager,
        ClusterManagersController clusterManagersController) {
      super(context, map, clusterManager);
      this.clusterManagersController = clusterManagersController;
    }

    @Override
    protected void onBeforeClusterItemRendered(
        @NonNull T item, @NonNull MarkerOptions markerOptions) {
      // Builds new markerOptions for new marker created by the ClusterRenderer under
      // ClusterManager.
      item.update(markerOptions);
    }

    @Override
    protected void onClusterItemRendered(@NonNull T item, @NonNull Marker marker) {
      super.onClusterItemRendered(item, marker);
      clusterManagersController.onClusterItemRendered(item, marker);
    }
  }

  /** AdvancedMarkerClusterRenderer is a ClusterRenderer that supports AdvancedMarkers. */
  @VisibleForTesting
  static class AdvancedMarkerClusterRenderer<T extends MarkerBuilder>
      extends DefaultAdvancedMarkersClusterRenderer<T> {

    private final ClusterManagersController clusterManagersController;

    public AdvancedMarkerClusterRenderer(
        Context context,
        GoogleMap map,
        ClusterManager<T> clusterManager,
        ClusterManagersController clusterManagersController) {
      super(context, map, clusterManager);
      this.clusterManagersController = clusterManagersController;
    }

    @Override
    protected void onBeforeClusterItemRendered(
        @NonNull T item, @NonNull AdvancedMarkerOptions markerOptions) {
      item.update(markerOptions);
    }

    @Override
    protected void onClusterItemRendered(@NonNull T item, @NonNull Marker marker) {
      super.onClusterItemRendered(item, marker);
      clusterManagersController.onClusterItemRendered(item, marker);
    }
  }

  /** Interface for handling situations where clusterManager adds new visible marker to the map. */
  public interface OnClusterItemRendered<T extends ClusterItem> {
    void onClusterItemRendered(@NonNull T item, @NonNull Marker marker);
  }
}
