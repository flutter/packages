// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static io.flutter.plugins.googlemaps.Convert.clusterToPigeon;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.pm.PackageManager;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.Point;
import android.graphics.SurfaceTexture;
import android.os.Bundle;
import android.util.Log;
import android.view.TextureView;
import android.view.TextureView.SurfaceTextureListener;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;
import com.google.android.gms.maps.CameraUpdate;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.GoogleMapOptions;
import com.google.android.gms.maps.MapView;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.model.Circle;
import com.google.android.gms.maps.model.GroundOverlay;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.google.android.gms.maps.model.MapStyleOptions;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.Polygon;
import com.google.android.gms.maps.model.Polyline;
import com.google.android.gms.maps.model.TileOverlay;
import com.google.maps.android.clustering.Cluster;
import com.google.maps.android.clustering.ClusterManager;
import com.google.maps.android.collections.MarkerManager;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugins.googlemaps.Messages.FlutterError;
import io.flutter.plugins.googlemaps.Messages.MapsApi;
import io.flutter.plugins.googlemaps.Messages.MapsCallbackApi;
import io.flutter.plugins.googlemaps.Messages.MapsInspectorApi;
import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Set;

/** Controller of a single GoogleMaps MapView instance. */
class GoogleMapController
    implements ActivityPluginBinding.OnSaveInstanceStateListener,
        ClusterManager.OnClusterItemClickListener<MarkerBuilder>,
        ClusterManagersController.OnClusterItemRendered<MarkerBuilder>,
        DefaultLifecycleObserver,
        GoogleMapListener,
        GoogleMapOptionsSink,
        MapsApi,
        MapsInspectorApi,
        OnMapReadyCallback,
        PlatformView {

  private static final String TAG = "GoogleMapController";
  private final int id;
  private final MapsCallbackApi flutterApi;
  private final BinaryMessenger binaryMessenger;
  private final GoogleMapOptions options;
  @Nullable private MapView mapView;
  @Nullable private GoogleMap googleMap;
  private boolean trackCameraPosition = false;
  private boolean myLocationEnabled = false;
  private boolean myLocationButtonEnabled = false;
  private boolean zoomControlsEnabled = true;
  private boolean indoorEnabled = true;
  private boolean trafficEnabled = false;
  private boolean buildingsEnabled = true;
  private boolean disposed = false;
  @VisibleForTesting final float density;
  private @Nullable Messages.VoidResult mapReadyResult;
  private final Context context;
  private final LifecycleProvider lifecycleProvider;
  private final MarkersController markersController;
  private final ClusterManagersController clusterManagersController;
  private final PolygonsController polygonsController;
  private final PolylinesController polylinesController;
  private final CirclesController circlesController;
  private final HeatmapsController heatmapsController;
  private final TileOverlaysController tileOverlaysController;
  private final GroundOverlaysController groundOverlaysController;
  private MarkerManager markerManager;
  private MarkerManager.Collection markerCollection;
  private @Nullable List<Messages.PlatformMarker> initialMarkers;
  private @Nullable List<Messages.PlatformClusterManager> initialClusterManagers;
  private @Nullable List<Messages.PlatformPolygon> initialPolygons;
  private @Nullable List<Messages.PlatformPolyline> initialPolylines;
  private @Nullable List<Messages.PlatformCircle> initialCircles;
  private @Nullable List<Messages.PlatformHeatmap> initialHeatmaps;
  private @Nullable List<Messages.PlatformTileOverlay> initialTileOverlays;
  private @Nullable List<Messages.PlatformGroundOverlay> initialGroundOverlays;
  // Null except between initialization and onMapReady.
  private @Nullable String initialMapStyle;
  private boolean lastSetStyleSucceeded;
  @VisibleForTesting List<Float> initialPadding;

  GoogleMapController(
      int id,
      Context context,
      BinaryMessenger binaryMessenger,
      LifecycleProvider lifecycleProvider,
      GoogleMapOptions options) {
    this.id = id;
    this.context = context;
    this.options = options;
    this.mapView = new MapView(context, options);
    this.density = context.getResources().getDisplayMetrics().density;
    this.binaryMessenger = binaryMessenger;
    flutterApi = new MapsCallbackApi(binaryMessenger, Integer.toString(id));
    MapsApi.setUp(binaryMessenger, Integer.toString(id), this);
    MapsInspectorApi.setUp(binaryMessenger, Integer.toString(id), this);
    AssetManager assetManager = context.getAssets();
    this.lifecycleProvider = lifecycleProvider;
    this.clusterManagersController = new ClusterManagersController(flutterApi, context);
    this.markersController =
        new MarkersController(
            flutterApi,
            clusterManagersController,
            assetManager,
            density,
            new Convert.BitmapDescriptorFactoryWrapper());
    this.polygonsController = new PolygonsController(flutterApi, density);
    this.polylinesController = new PolylinesController(flutterApi, assetManager, density);
    this.circlesController = new CirclesController(flutterApi, density);
    this.heatmapsController = new HeatmapsController();
    this.tileOverlaysController = new TileOverlaysController(flutterApi);
    this.groundOverlaysController = new GroundOverlaysController(flutterApi, assetManager, density);
  }

  // Constructor for testing purposes only
  @VisibleForTesting
  GoogleMapController(
      int id,
      Context context,
      BinaryMessenger binaryMessenger,
      MapsCallbackApi flutterApi,
      LifecycleProvider lifecycleProvider,
      GoogleMapOptions options,
      ClusterManagersController clusterManagersController,
      MarkersController markersController,
      PolygonsController polygonsController,
      PolylinesController polylinesController,
      CirclesController circlesController,
      HeatmapsController heatmapController,
      TileOverlaysController tileOverlaysController,
      GroundOverlaysController groundOverlaysController) {
    this.id = id;
    this.context = context;
    this.binaryMessenger = binaryMessenger;
    this.flutterApi = flutterApi;
    this.options = options;
    this.mapView = new MapView(context, options);
    this.density = context.getResources().getDisplayMetrics().density;
    this.lifecycleProvider = lifecycleProvider;
    this.clusterManagersController = clusterManagersController;
    this.markersController = markersController;
    this.polygonsController = polygonsController;
    this.polylinesController = polylinesController;
    this.circlesController = circlesController;
    this.heatmapsController = heatmapController;
    this.tileOverlaysController = tileOverlaysController;
    this.groundOverlaysController = groundOverlaysController;
  }

  @Override
  public View getView() {
    return mapView;
  }

  @VisibleForTesting
  /* package */ void setView(MapView view) {
    mapView = view;
  }

  void init() {
    lifecycleProvider.getLifecycle().addObserver(this);
    mapView.getMapAsync(this);
  }

  @Override
  public void onMapReady(@NonNull GoogleMap googleMap) {
    this.googleMap = googleMap;
    this.googleMap.setIndoorEnabled(this.indoorEnabled);
    this.googleMap.setTrafficEnabled(this.trafficEnabled);
    this.googleMap.setBuildingsEnabled(this.buildingsEnabled);
    installInvalidator();
    if (mapReadyResult != null) {
      mapReadyResult.success();
      mapReadyResult = null;
    }
    setGoogleMapListener(this);
    markerManager = new MarkerManager(googleMap);
    markerCollection = markerManager.newCollection();
    updateMyLocationSettings();
    markersController.setCollection(markerCollection);
    clusterManagersController.init(googleMap, markerManager);
    polygonsController.setGoogleMap(googleMap);
    polylinesController.setGoogleMap(googleMap);
    circlesController.setGoogleMap(googleMap);
    heatmapsController.setGoogleMap(googleMap);
    tileOverlaysController.setGoogleMap(googleMap);
    groundOverlaysController.setGoogleMap(googleMap);
    setMarkerCollectionListener(this);
    setClusterItemClickListener(this);
    setClusterItemRenderedListener(this);
    updateInitialClusterManagers();
    updateInitialMarkers();
    updateInitialPolygons();
    updateInitialPolylines();
    updateInitialCircles();
    updateInitialHeatmaps();
    updateInitialTileOverlays();
    updateInitialGroundOverlays();
    if (initialPadding != null && initialPadding.size() == 4) {
      setPadding(
          initialPadding.get(0),
          initialPadding.get(1),
          initialPadding.get(2),
          initialPadding.get(3));
    }
    if (initialMapStyle != null) {
      updateMapStyle(initialMapStyle);
      initialMapStyle = null;
    }
  }

  // Returns the first TextureView found in the view hierarchy.
  private static TextureView findTextureView(ViewGroup group) {
    final int n = group.getChildCount();
    for (int i = 0; i < n; i++) {
      View view = group.getChildAt(i);
      if (view instanceof TextureView) {
        return (TextureView) view;
      }
      if (view instanceof ViewGroup) {
        TextureView r = findTextureView((ViewGroup) view);
        if (r != null) {
          return r;
        }
      }
    }
    return null;
  }

  private void installInvalidator() {
    if (mapView == null) {
      // This should only happen in tests.
      return;
    }
    TextureView textureView = findTextureView(mapView);
    if (textureView == null) {
      Log.i(TAG, "No TextureView found. Likely using the LEGACY renderer.");
      return;
    }
    Log.i(TAG, "Installing custom TextureView driven invalidator.");
    SurfaceTextureListener internalListener = textureView.getSurfaceTextureListener();
    // Override the Maps internal SurfaceTextureListener with our own. Our listener
    // mostly just invokes the internal listener callbacks but in onSurfaceTextureUpdated
    // the mapView is invalidated which ensures that all map updates are presented to the
    // screen.
    final MapView mapView = this.mapView;
    textureView.setSurfaceTextureListener(
        new TextureView.SurfaceTextureListener() {
          public void onSurfaceTextureAvailable(
              @NonNull SurfaceTexture surface, int width, int height) {
            if (internalListener != null) {
              internalListener.onSurfaceTextureAvailable(surface, width, height);
            }
          }

          public boolean onSurfaceTextureDestroyed(@NonNull SurfaceTexture surface) {
            if (internalListener != null) {
              return internalListener.onSurfaceTextureDestroyed(surface);
            }
            return true;
          }

          public void onSurfaceTextureSizeChanged(
              @NonNull SurfaceTexture surface, int width, int height) {
            if (internalListener != null) {
              internalListener.onSurfaceTextureSizeChanged(surface, width, height);
            }
          }

          public void onSurfaceTextureUpdated(@NonNull SurfaceTexture surface) {
            if (internalListener != null) {
              internalListener.onSurfaceTextureUpdated(surface);
            }
            mapView.invalidate();
          }
        });
  }

  @Override
  public void onMapClick(@NonNull LatLng latLng) {
    flutterApi.onTap(Convert.latLngToPigeon(latLng), new NoOpVoidResult());
  }

  @Override
  public void onMapLongClick(@NonNull LatLng latLng) {
    flutterApi.onLongPress(Convert.latLngToPigeon(latLng), new NoOpVoidResult());
  }

  @Override
  public void onCameraMoveStarted(int reason) {
    flutterApi.onCameraMoveStarted(new NoOpVoidResult());
  }

  @Override
  public void onInfoWindowClick(Marker marker) {
    markersController.onInfoWindowTap(marker.getId());
  }

  @Override
  public void onCameraMove() {
    if (!trackCameraPosition) {
      return;
    }
    flutterApi.onCameraMove(
        Convert.cameraPositionToPigeon(googleMap.getCameraPosition()), new NoOpVoidResult());
  }

  @Override
  public void onCameraIdle() {
    clusterManagersController.onCameraIdle();
    flutterApi.onCameraIdle(new NoOpVoidResult());
  }

  @Override
  public boolean onMarkerClick(Marker marker) {
    return markersController.onMapsMarkerTap(marker.getId());
  }

  @Override
  public void onMarkerDragStart(Marker marker) {
    markersController.onMarkerDragStart(marker.getId(), marker.getPosition());
  }

  @Override
  public void onMarkerDrag(Marker marker) {
    markersController.onMarkerDrag(marker.getId(), marker.getPosition());
  }

  @Override
  public void onMarkerDragEnd(Marker marker) {
    markersController.onMarkerDragEnd(marker.getId(), marker.getPosition());
  }

  @Override
  public void onPolygonClick(Polygon polygon) {
    polygonsController.onPolygonTap(polygon.getId());
  }

  @Override
  public void onPolylineClick(Polyline polyline) {
    polylinesController.onPolylineTap(polyline.getId());
  }

  @Override
  public void onCircleClick(Circle circle) {
    circlesController.onCircleTap(circle.getId());
  }

  @Override
  public void onGroundOverlayClick(@NonNull GroundOverlay groundOverlay) {
    groundOverlaysController.onGroundOverlayTap(groundOverlay.getId());
  }

  @Override
  public void dispose() {
    if (disposed) {
      return;
    }
    disposed = true;
    MapsApi.setUp(binaryMessenger, Integer.toString(id), null);
    MapsInspectorApi.setUp(binaryMessenger, Integer.toString(id), null);
    setGoogleMapListener(null);
    setMarkerCollectionListener(null);
    setClusterItemClickListener(null);
    setClusterItemRenderedListener(null);
    destroyMapViewIfNecessary();
    Lifecycle lifecycle = lifecycleProvider.getLifecycle();
    if (lifecycle != null) {
      lifecycle.removeObserver(this);
    }
  }

  private void setGoogleMapListener(@Nullable GoogleMapListener listener) {
    if (googleMap == null) {
      Log.v(TAG, "Controller was disposed before GoogleMap was ready.");
      return;
    }
    googleMap.setOnCameraMoveStartedListener(listener);
    googleMap.setOnCameraMoveListener(listener);
    googleMap.setOnCameraIdleListener(listener);
    googleMap.setOnPolygonClickListener(listener);
    googleMap.setOnPolylineClickListener(listener);
    googleMap.setOnCircleClickListener(listener);
    googleMap.setOnMapClickListener(listener);
    googleMap.setOnMapLongClickListener(listener);
    googleMap.setOnGroundOverlayClickListener(listener);
  }

  @VisibleForTesting
  public void setMarkerCollectionListener(@Nullable GoogleMapListener listener) {
    if (googleMap == null) {
      Log.v(TAG, "Controller was disposed before GoogleMap was ready.");
      return;
    }

    markerCollection.setOnMarkerClickListener(listener);
    markerCollection.setOnMarkerDragListener(listener);
    markerCollection.setOnInfoWindowClickListener(listener);
  }

  @VisibleForTesting
  public void setClusterItemClickListener(
      @Nullable ClusterManager.OnClusterItemClickListener<MarkerBuilder> listener) {
    if (googleMap == null) {
      Log.v(TAG, "Controller was disposed before GoogleMap was ready.");
      return;
    }

    clusterManagersController.setClusterItemClickListener(listener);
  }

  @VisibleForTesting
  public void setClusterItemRenderedListener(
      @Nullable ClusterManagersController.OnClusterItemRendered<MarkerBuilder> listener) {
    if (googleMap == null) {
      Log.v(TAG, "Controller was disposed before GoogleMap was ready.");
      return;
    }

    clusterManagersController.setClusterItemRenderedListener(listener);
  }

  // DefaultLifecycleObserver

  @Override
  public void onCreate(@NonNull LifecycleOwner owner) {
    if (disposed) {
      return;
    }
    mapView.onCreate(null);
  }

  @Override
  public void onStart(@NonNull LifecycleOwner owner) {
    if (disposed) {
      return;
    }
    mapView.onStart();
  }

  @Override
  public void onResume(@NonNull LifecycleOwner owner) {
    if (disposed) {
      return;
    }
    mapView.onResume();
  }

  @Override
  public void onPause(@NonNull LifecycleOwner owner) {
    if (disposed) {
      return;
    }
    mapView.onResume();
  }

  @Override
  public void onStop(@NonNull LifecycleOwner owner) {
    if (disposed) {
      return;
    }
    mapView.onStop();
  }

  @Override
  public void onDestroy(@NonNull LifecycleOwner owner) {
    owner.getLifecycle().removeObserver(this);
    if (disposed) {
      return;
    }
    destroyMapViewIfNecessary();
  }

  @Override
  public void onRestoreInstanceState(Bundle bundle) {
    if (disposed) {
      return;
    }
    mapView.onCreate(bundle);
  }

  @Override
  public void onSaveInstanceState(@NonNull Bundle bundle) {
    if (disposed) {
      return;
    }
    mapView.onSaveInstanceState(bundle);
  }

  // GoogleMapOptionsSink methods

  @Override
  public void setCameraTargetBounds(LatLngBounds bounds) {
    googleMap.setLatLngBoundsForCameraTarget(bounds);
  }

  @Override
  public void setCompassEnabled(boolean compassEnabled) {
    googleMap.getUiSettings().setCompassEnabled(compassEnabled);
  }

  @Override
  public void setMapToolbarEnabled(boolean mapToolbarEnabled) {
    googleMap.getUiSettings().setMapToolbarEnabled(mapToolbarEnabled);
  }

  @Override
  public void setMapType(int mapType) {
    googleMap.setMapType(mapType);
  }

  @Override
  public void setTrackCameraPosition(boolean trackCameraPosition) {
    this.trackCameraPosition = trackCameraPosition;
  }

  @Override
  public void setRotateGesturesEnabled(boolean rotateGesturesEnabled) {
    googleMap.getUiSettings().setRotateGesturesEnabled(rotateGesturesEnabled);
  }

  @Override
  public void setScrollGesturesEnabled(boolean scrollGesturesEnabled) {
    googleMap.getUiSettings().setScrollGesturesEnabled(scrollGesturesEnabled);
  }

  @Override
  public void setTiltGesturesEnabled(boolean tiltGesturesEnabled) {
    googleMap.getUiSettings().setTiltGesturesEnabled(tiltGesturesEnabled);
  }

  @Override
  public void setMinMaxZoomPreference(Float min, Float max) {
    googleMap.resetMinMaxZoomPreference();
    if (min != null) {
      googleMap.setMinZoomPreference(min);
    }
    if (max != null) {
      googleMap.setMaxZoomPreference(max);
    }
  }

  @Override
  public void setPadding(float top, float left, float bottom, float right) {
    if (googleMap != null) {
      googleMap.setPadding(
          (int) (left * density),
          (int) (top * density),
          (int) (right * density),
          (int) (bottom * density));
    } else {
      setInitialPadding(top, left, bottom, right);
    }
  }

  @VisibleForTesting
  void setInitialPadding(float top, float left, float bottom, float right) {
    if (initialPadding == null) {
      initialPadding = new ArrayList<>();
    } else {
      initialPadding.clear();
    }
    initialPadding.add(top);
    initialPadding.add(left);
    initialPadding.add(bottom);
    initialPadding.add(right);
  }

  @Override
  public void setZoomGesturesEnabled(boolean zoomGesturesEnabled) {
    googleMap.getUiSettings().setZoomGesturesEnabled(zoomGesturesEnabled);
  }

  /** This call will have no effect on already created map */
  @Override
  public void setLiteModeEnabled(boolean liteModeEnabled) {
    options.liteMode(liteModeEnabled);
  }

  @Override
  public void setMyLocationEnabled(boolean myLocationEnabled) {
    if (this.myLocationEnabled == myLocationEnabled) {
      return;
    }
    this.myLocationEnabled = myLocationEnabled;
    if (googleMap != null) {
      updateMyLocationSettings();
    }
  }

  @Override
  public void setMyLocationButtonEnabled(boolean myLocationButtonEnabled) {
    if (this.myLocationButtonEnabled == myLocationButtonEnabled) {
      return;
    }
    this.myLocationButtonEnabled = myLocationButtonEnabled;
    if (googleMap != null) {
      updateMyLocationSettings();
    }
  }

  @Override
  public void setZoomControlsEnabled(boolean zoomControlsEnabled) {
    if (this.zoomControlsEnabled == zoomControlsEnabled) {
      return;
    }
    this.zoomControlsEnabled = zoomControlsEnabled;
    if (googleMap != null) {
      googleMap.getUiSettings().setZoomControlsEnabled(zoomControlsEnabled);
    }
  }

  @Override
  public void setInitialMarkers(@NonNull List<Messages.PlatformMarker> initialMarkers) {
    this.initialMarkers = initialMarkers;
    if (googleMap != null) {
      updateInitialMarkers();
    }
  }

  private void updateInitialMarkers() {
    if (initialMarkers != null) {
      markersController.addMarkers(initialMarkers);
    }
  }

  @Override
  public void setInitialClusterManagers(
      @NonNull List<Messages.PlatformClusterManager> initialClusterManagers) {
    this.initialClusterManagers = initialClusterManagers;
    if (googleMap != null) {
      updateInitialClusterManagers();
    }
  }

  private void updateInitialClusterManagers() {
    if (initialClusterManagers != null) {
      clusterManagersController.addClusterManagers(initialClusterManagers);
    }
  }

  @Override
  public void setInitialPolygons(@NonNull List<Messages.PlatformPolygon> initialPolygons) {
    this.initialPolygons = initialPolygons;
    if (googleMap != null) {
      updateInitialPolygons();
    }
  }

  private void updateInitialPolygons() {
    if (initialPolygons != null) {
      polygonsController.addPolygons(initialPolygons);
    }
  }

  @Override
  public void setInitialPolylines(@NonNull List<Messages.PlatformPolyline> initialPolylines) {
    this.initialPolylines = initialPolylines;
    if (googleMap != null) {
      updateInitialPolylines();
    }
  }

  private void updateInitialPolylines() {
    if (initialPolylines != null) {
      polylinesController.addPolylines(initialPolylines);
    }
  }

  @Override
  public void setInitialCircles(@NonNull List<Messages.PlatformCircle> initialCircles) {
    this.initialCircles = initialCircles;
    if (googleMap != null) {
      updateInitialCircles();
    }
  }

  @Override
  public void setInitialHeatmaps(@NonNull List<Messages.PlatformHeatmap> initialHeatmaps) {
    this.initialHeatmaps = initialHeatmaps;
    if (googleMap != null) {
      updateInitialHeatmaps();
    }
  }

  private void updateInitialCircles() {
    if (initialCircles != null) {
      circlesController.addCircles(initialCircles);
    }
  }

  private void updateInitialHeatmaps() {
    if (initialHeatmaps != null) {
      heatmapsController.addHeatmaps(initialHeatmaps);
    }
  }

  @Override
  public void setInitialTileOverlays(
      @NonNull List<Messages.PlatformTileOverlay> initialTileOverlays) {
    this.initialTileOverlays = initialTileOverlays;
    if (googleMap != null) {
      updateInitialTileOverlays();
    }
  }

  private void updateInitialTileOverlays() {
    if (initialTileOverlays != null) {
      tileOverlaysController.addTileOverlays(initialTileOverlays);
    }
  }

  @Override
  public void setInitialGroundOverlays(
      @NonNull List<Messages.PlatformGroundOverlay> initialGroundOverlays) {
    this.initialGroundOverlays = initialGroundOverlays;
    if (googleMap != null) {
      updateInitialGroundOverlays();
    }
  }

  private void updateInitialGroundOverlays() {
    if (initialGroundOverlays != null) {
      groundOverlaysController.addGroundOverlays(initialGroundOverlays);
    }
  }

  @SuppressLint("MissingPermission")
  private void updateMyLocationSettings() {
    if (hasLocationPermission()) {
      // The plugin doesn't add the location permission by default so that apps that don't need
      // the feature won't require the permission.
      // Gradle is doing a static check for missing permission and in some configurations will
      // fail the build if the permission is missing. The following disables the Gradle lint.
      // noinspection ResourceType
      googleMap.setMyLocationEnabled(myLocationEnabled);
      googleMap.getUiSettings().setMyLocationButtonEnabled(myLocationButtonEnabled);
    } else {
      // TODO(amirh): Make the options update fail.
      // https://github.com/flutter/flutter/issues/24327
      Log.e(TAG, "Cannot enable MyLocation layer as location permissions are not granted");
    }
  }

  private boolean hasLocationPermission() {
    return checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION)
            == PackageManager.PERMISSION_GRANTED
        || checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION)
            == PackageManager.PERMISSION_GRANTED;
  }

  private int checkSelfPermission(String permission) {
    if (permission == null) {
      throw new IllegalArgumentException("permission is null");
    }
    return context.checkPermission(
        permission, android.os.Process.myPid(), android.os.Process.myUid());
  }

  private void destroyMapViewIfNecessary() {
    if (mapView == null) {
      return;
    }
    mapView.onDestroy();
    mapView = null;
  }

  public void setIndoorEnabled(boolean indoorEnabled) {
    this.indoorEnabled = indoorEnabled;
  }

  public void setTrafficEnabled(boolean trafficEnabled) {
    this.trafficEnabled = trafficEnabled;
    if (googleMap == null) {
      return;
    }
    googleMap.setTrafficEnabled(trafficEnabled);
  }

  public void setBuildingsEnabled(boolean buildingsEnabled) {
    this.buildingsEnabled = buildingsEnabled;
  }

  @Override
  public void onClusterItemRendered(@NonNull MarkerBuilder markerBuilder, @NonNull Marker marker) {
    markersController.onClusterItemRendered(markerBuilder, marker);
  }

  @Override
  public boolean onClusterItemClick(MarkerBuilder item) {
    return markersController.onMarkerTap(item.markerId());
  }

  public void setMapStyle(@Nullable String style) {
    if (googleMap == null) {
      initialMapStyle = style;
    } else {
      updateMapStyle(style);
    }
  }

  private boolean updateMapStyle(String style) {
    // Dart passes an empty string to indicate that the style should be cleared.
    final MapStyleOptions mapStyleOptions =
        style == null || style.isEmpty() ? null : new MapStyleOptions(style);
    lastSetStyleSucceeded = Objects.requireNonNull(googleMap).setMapStyle(mapStyleOptions);
    return lastSetStyleSucceeded;
  }

  /** MapsApi implementation */
  @Override
  public void waitForMap(@NonNull Messages.VoidResult result) {
    if (googleMap == null) {
      mapReadyResult = result;
    } else {
      result.success();
    }
  }

  @Override
  public void updateMapConfiguration(@NonNull Messages.PlatformMapConfiguration configuration) {
    Convert.interpretMapConfiguration(configuration, this);
  }

  @Override
  public void updateCircles(
      @NonNull List<Messages.PlatformCircle> toAdd,
      @NonNull List<Messages.PlatformCircle> toChange,
      @NonNull List<String> idsToRemove) {
    circlesController.addCircles(toAdd);
    circlesController.changeCircles(toChange);
    circlesController.removeCircles(idsToRemove);
  }

  @Override
  public void updateHeatmaps(
      @NonNull List<Messages.PlatformHeatmap> toAdd,
      @NonNull List<Messages.PlatformHeatmap> toChange,
      @NonNull List<String> idsToRemove) {
    heatmapsController.addHeatmaps(toAdd);
    heatmapsController.changeHeatmaps(toChange);
    heatmapsController.removeHeatmaps(idsToRemove);
  }

  @Override
  public void updateClusterManagers(
      @NonNull List<Messages.PlatformClusterManager> toAdd, @NonNull List<String> idsToRemove) {
    clusterManagersController.addClusterManagers(toAdd);
    clusterManagersController.removeClusterManagers(idsToRemove);
  }

  @Override
  public void updateMarkers(
      @NonNull List<Messages.PlatformMarker> toAdd,
      @NonNull List<Messages.PlatformMarker> toChange,
      @NonNull List<String> idsToRemove) {
    markersController.addMarkers(toAdd);
    markersController.changeMarkers(toChange);
    markersController.removeMarkers(idsToRemove);
  }

  @Override
  public void updatePolygons(
      @NonNull List<Messages.PlatformPolygon> toAdd,
      @NonNull List<Messages.PlatformPolygon> toChange,
      @NonNull List<String> idsToRemove) {
    polygonsController.addPolygons(toAdd);
    polygonsController.changePolygons(toChange);
    polygonsController.removePolygons(idsToRemove);
  }

  @Override
  public void updatePolylines(
      @NonNull List<Messages.PlatformPolyline> toAdd,
      @NonNull List<Messages.PlatformPolyline> toChange,
      @NonNull List<String> idsToRemove) {
    polylinesController.addPolylines(toAdd);
    polylinesController.changePolylines(toChange);
    polylinesController.removePolylines(idsToRemove);
  }

  @Override
  public void updateTileOverlays(
      @NonNull List<Messages.PlatformTileOverlay> toAdd,
      @NonNull List<Messages.PlatformTileOverlay> toChange,
      @NonNull List<String> idsToRemove) {
    tileOverlaysController.addTileOverlays(toAdd);
    tileOverlaysController.changeTileOverlays(toChange);
    tileOverlaysController.removeTileOverlays(idsToRemove);
  }

  @Override
  public void updateGroundOverlays(
      @NonNull List<Messages.PlatformGroundOverlay> toAdd,
      @NonNull List<Messages.PlatformGroundOverlay> toChange,
      @NonNull List<String> idsToRemove) {
    groundOverlaysController.addGroundOverlays(toAdd);
    groundOverlaysController.changeGroundOverlays(toChange);
    groundOverlaysController.removeGroundOverlays(idsToRemove);
  }

  @Override
  public @NonNull Messages.PlatformPoint getScreenCoordinate(
      @NonNull Messages.PlatformLatLng latLng) {
    if (googleMap == null) {
      throw new FlutterError(
          "GoogleMap uninitialized",
          "getScreenCoordinate called prior to map initialization",
          null);
    }
    Point screenLocation =
        googleMap.getProjection().toScreenLocation(Convert.latLngFromPigeon(latLng));
    return Convert.pointToPigeon(screenLocation);
  }

  @Override
  public @NonNull Messages.PlatformLatLng getLatLng(
      @NonNull Messages.PlatformPoint screenCoordinate) {
    if (googleMap == null) {
      throw new FlutterError(
          "GoogleMap uninitialized", "getLatLng called prior to map initialization", null);
    }
    LatLng latLng =
        googleMap.getProjection().fromScreenLocation(Convert.pointFromPigeon(screenCoordinate));
    return Convert.latLngToPigeon(latLng);
  }

  @Override
  public @NonNull Messages.PlatformLatLngBounds getVisibleRegion() {
    if (googleMap == null) {
      throw new FlutterError(
          "GoogleMap uninitialized", "getVisibleRegion called prior to map initialization", null);
    }
    LatLngBounds latLngBounds = googleMap.getProjection().getVisibleRegion().latLngBounds;
    return Convert.latLngBoundsToPigeon(latLngBounds);
  }

  @Override
  public void moveCamera(@NonNull Messages.PlatformCameraUpdate cameraUpdate) {
    if (googleMap == null) {
      throw new FlutterError(
          "GoogleMap uninitialized", "moveCamera called prior to map initialization", null);
    }
    googleMap.moveCamera(Convert.cameraUpdateFromPigeon(cameraUpdate, density));
  }

  @Override
  public void animateCamera(
      @NonNull Messages.PlatformCameraUpdate cameraUpdate, @Nullable Long durationMilliseconds) {
    if (googleMap == null) {
      throw new FlutterError(
          "GoogleMap uninitialized", "animateCamera called prior to map initialization", null);
    }
    CameraUpdate update = Convert.cameraUpdateFromPigeon(cameraUpdate, density);
    if (durationMilliseconds != null) {
      googleMap.animateCamera(update, durationMilliseconds.intValue(), null);
    } else {
      googleMap.animateCamera(update);
    }
  }

  @Override
  public @NonNull Double getZoomLevel() {
    if (googleMap == null) {
      throw new FlutterError(
          "GoogleMap uninitialized", "getZoomLevel called prior to map initialization", null);
    }
    return (double) googleMap.getCameraPosition().zoom;
  }

  @Override
  public void showInfoWindow(@NonNull String markerId) {
    markersController.showMarkerInfoWindow(markerId);
  }

  @Override
  public void hideInfoWindow(@NonNull String markerId) {
    markersController.hideMarkerInfoWindow(markerId);
  }

  @NonNull
  @Override
  public Boolean isInfoWindowShown(@NonNull String markerId) {
    return markersController.isInfoWindowShown(markerId);
  }

  @Override
  public @NonNull Boolean setStyle(@NonNull String style) {
    return updateMapStyle(style);
  }

  @Override
  public @NonNull Boolean didLastStyleSucceed() {
    return lastSetStyleSucceeded;
  }

  @Override
  public void clearTileCache(@NonNull String tileOverlayId) {
    tileOverlaysController.clearTileCache(tileOverlayId);
  }

  @Override
  public void takeSnapshot(@NonNull Messages.Result<byte[]> result) {
    if (googleMap == null) {
      result.error(new FlutterError("GoogleMap uninitialized", "takeSnapshot", null));
    } else {
      googleMap.snapshot(
          bitmap -> {
            if (bitmap == null) {
              result.error(new FlutterError("Snapshot failure", "Unable to take snapshot", null));
            } else {
              ByteArrayOutputStream stream = new ByteArrayOutputStream();
              bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
              byte[] byteArray = stream.toByteArray();
              bitmap.recycle();
              result.success(byteArray);
            }
          });
    }
  }

  /** MapsInspectorApi implementation */
  @Override
  public @NonNull Boolean areBuildingsEnabled() {
    return Objects.requireNonNull(googleMap).isBuildingsEnabled();
  }

  @Override
  public @NonNull Boolean areRotateGesturesEnabled() {
    return Objects.requireNonNull(googleMap).getUiSettings().isRotateGesturesEnabled();
  }

  @Override
  public @NonNull Boolean areZoomControlsEnabled() {
    return Objects.requireNonNull(googleMap).getUiSettings().isZoomControlsEnabled();
  }

  @Override
  public @NonNull Boolean areScrollGesturesEnabled() {
    return Objects.requireNonNull(googleMap).getUiSettings().isScrollGesturesEnabled();
  }

  @Override
  public @NonNull Boolean areTiltGesturesEnabled() {
    return Objects.requireNonNull(googleMap).getUiSettings().isTiltGesturesEnabled();
  }

  @Override
  public @NonNull Boolean areZoomGesturesEnabled() {
    return Objects.requireNonNull(googleMap).getUiSettings().isZoomGesturesEnabled();
  }

  @Override
  public @NonNull Boolean isCompassEnabled() {
    return Objects.requireNonNull(googleMap).getUiSettings().isCompassEnabled();
  }

  @Override
  public Boolean isLiteModeEnabled() {
    return options.getLiteMode();
  }

  @Override
  public @NonNull Boolean isMapToolbarEnabled() {
    return Objects.requireNonNull(googleMap).getUiSettings().isMapToolbarEnabled();
  }

  @Override
  public @NonNull Boolean isMyLocationButtonEnabled() {
    return Objects.requireNonNull(googleMap).getUiSettings().isMyLocationButtonEnabled();
  }

  @Override
  public @NonNull Boolean isTrafficEnabled() {
    return Objects.requireNonNull(googleMap).isTrafficEnabled();
  }

  @Override
  public @NonNull Messages.PlatformCameraPosition getCameraPosition() {
    return Convert.cameraPositionToPigeon(Objects.requireNonNull(googleMap).getCameraPosition());
  }

  @Override
  public @Nullable Messages.PlatformTileLayer getTileOverlayInfo(@NonNull String tileOverlayId) {
    TileOverlay tileOverlay = tileOverlaysController.getTileOverlay(tileOverlayId);
    if (tileOverlay == null) {
      return null;
    }
    return new Messages.PlatformTileLayer.Builder()
        .setFadeIn(tileOverlay.getFadeIn())
        .setTransparency((double) tileOverlay.getTransparency())
        .setZIndex((double) tileOverlay.getZIndex())
        .setVisible(tileOverlay.isVisible())
        .build();
  }

  @Override
  public @Nullable Messages.PlatformGroundOverlay getGroundOverlayInfo(
      @NonNull String groundOverlayId) {
    GroundOverlay groundOverlay = groundOverlaysController.getGroundOverlay(groundOverlayId);
    if (groundOverlay == null) {
      return null;
    }

    return Convert.groundOverlayToPigeon(
        groundOverlay,
        groundOverlayId,
        groundOverlaysController.isCreatedWithBounds(groundOverlayId));
  }

  @Override
  public @NonNull Messages.PlatformZoomRange getZoomRange() {
    return new Messages.PlatformZoomRange.Builder()
        .setMin((double) Objects.requireNonNull(googleMap).getMinZoomLevel())
        .setMax((double) Objects.requireNonNull(googleMap).getMaxZoomLevel())
        .build();
  }

  @Override
  public @NonNull List<Messages.PlatformCluster> getClusters(@NonNull String clusterManagerId) {
    Set<? extends Cluster<MarkerBuilder>> clusters =
        clusterManagersController.getClustersWithClusterManagerId(clusterManagerId);
    List<Messages.PlatformCluster> data = new ArrayList<>(clusters.size());
    for (Cluster<MarkerBuilder> cluster : clusters) {
      data.add(clusterToPigeon(clusterManagerId, cluster));
    }
    return data;
  }
}
