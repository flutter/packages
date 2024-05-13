// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.pm.PackageManager;
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
import com.google.android.gms.maps.GoogleMap.SnapshotReadyCallback;
import com.google.android.gms.maps.GoogleMapOptions;
import com.google.android.gms.maps.MapView;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.Circle;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.google.android.gms.maps.model.MapStyleOptions;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.Polygon;
import com.google.android.gms.maps.model.Polyline;
import com.google.maps.android.clustering.ClusterManager;
import com.google.maps.android.collections.MarkerManager;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;
import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/** Controller of a single GoogleMaps MapView instance. */
class GoogleMapController
    implements DefaultLifecycleObserver,
        ActivityPluginBinding.OnSaveInstanceStateListener,
        GoogleMapOptionsSink,
        MethodChannel.MethodCallHandler,
        OnMapReadyCallback,
        GoogleMapListener,
        ClusterManager.OnClusterItemClickListener<MarkerBuilder>,
        ClusterManagersController.OnClusterItemRendered<MarkerBuilder>,
        PlatformView {

  private static final String TAG = "GoogleMapController";
  private final int id;
  private final MethodChannel methodChannel;
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
  private MethodChannel.Result mapReadyResult;
  private final Context context;
  private final LifecycleProvider lifecycleProvider;
  private final MarkersController markersController;
  private final ClusterManagersController clusterManagersController;
  private final PolygonsController polygonsController;
  private final PolylinesController polylinesController;
  private final CirclesController circlesController;
  private final TileOverlaysController tileOverlaysController;
  private MarkerManager markerManager;
  private MarkerManager.Collection markerCollection;
  private List<Object> initialMarkers;
  private List<Object> initialClusterManagers;
  private List<Object> initialPolygons;
  private List<Object> initialPolylines;
  private List<Object> initialCircles;
  private List<Map<String, ?>> initialTileOverlays;
  // Null except between initialization and onMapReady.
  private @Nullable String initialMapStyle;
  private @Nullable String lastStyleError;
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
    methodChannel =
        new MethodChannel(binaryMessenger, "plugins.flutter.dev/google_maps_android_" + id);
    methodChannel.setMethodCallHandler(this);
    this.lifecycleProvider = lifecycleProvider;
    this.clusterManagersController = new ClusterManagersController(methodChannel, context);
    this.markersController = new MarkersController(methodChannel, clusterManagersController);
    this.polygonsController = new PolygonsController(methodChannel, density);
    this.polylinesController = new PolylinesController(methodChannel, density);
    this.circlesController = new CirclesController(methodChannel, density);
    this.tileOverlaysController = new TileOverlaysController(methodChannel);
  }

  // Constructor for testing purposes only
  @VisibleForTesting
  GoogleMapController(
      int id,
      Context context,
      MethodChannel methodChannel,
      LifecycleProvider lifecycleProvider,
      GoogleMapOptions options,
      ClusterManagersController clusterManagersController,
      MarkersController markersController,
      PolygonsController polygonsController,
      PolylinesController polylinesController,
      CirclesController circlesController,
      TileOverlaysController tileOverlaysController) {
    this.id = id;
    this.context = context;
    this.methodChannel = methodChannel;
    this.options = options;
    this.mapView = new MapView(context, options);
    this.density = context.getResources().getDisplayMetrics().density;
    this.lifecycleProvider = lifecycleProvider;
    this.clusterManagersController = clusterManagersController;
    this.markersController = markersController;
    this.polygonsController = polygonsController;
    this.polylinesController = polylinesController;
    this.circlesController = circlesController;
    this.tileOverlaysController = tileOverlaysController;
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

  private void moveCamera(CameraUpdate cameraUpdate) {
    googleMap.moveCamera(cameraUpdate);
  }

  private void animateCamera(CameraUpdate cameraUpdate) {
    googleMap.animateCamera(cameraUpdate);
  }

  private CameraPosition getCameraPosition() {
    return trackCameraPosition ? googleMap.getCameraPosition() : null;
  }

  @Override
  public void onMapReady(GoogleMap googleMap) {
    this.googleMap = googleMap;
    this.googleMap.setIndoorEnabled(this.indoorEnabled);
    this.googleMap.setTrafficEnabled(this.trafficEnabled);
    this.googleMap.setBuildingsEnabled(this.buildingsEnabled);
    installInvalidator();
    if (mapReadyResult != null) {
      mapReadyResult.success(null);
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
    tileOverlaysController.setGoogleMap(googleMap);
    setMarkerCollectionListener(this);
    setClusterItemClickListener(this);
    setClusterItemRenderedListener(this);
    updateInitialClusterManagers();
    updateInitialMarkers();
    updateInitialPolygons();
    updateInitialPolylines();
    updateInitialCircles();
    updateInitialTileOverlays();
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
          public void onSurfaceTextureAvailable(SurfaceTexture surface, int width, int height) {
            if (internalListener != null) {
              internalListener.onSurfaceTextureAvailable(surface, width, height);
            }
          }

          public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
            if (internalListener != null) {
              return internalListener.onSurfaceTextureDestroyed(surface);
            }
            return true;
          }

          public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {
            if (internalListener != null) {
              internalListener.onSurfaceTextureSizeChanged(surface, width, height);
            }
          }

          public void onSurfaceTextureUpdated(SurfaceTexture surface) {
            if (internalListener != null) {
              internalListener.onSurfaceTextureUpdated(surface);
            }
            mapView.invalidate();
          }
        });
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
      case "map#waitForMap":
        if (googleMap != null) {
          result.success(null);
          return;
        }
        mapReadyResult = result;
        break;
      case "map#update":
        {
          Convert.interpretGoogleMapOptions(call.argument("options"), this);
          result.success(Convert.cameraPositionToJson(getCameraPosition()));
          break;
        }
      case "map#getVisibleRegion":
        {
          if (googleMap != null) {
            LatLngBounds latLngBounds = googleMap.getProjection().getVisibleRegion().latLngBounds;
            result.success(Convert.latLngBoundsToJson(latLngBounds));
          } else {
            result.error(
                "GoogleMap uninitialized",
                "getVisibleRegion called prior to map initialization",
                null);
          }
          break;
        }
      case "map#getScreenCoordinate":
        {
          if (googleMap != null) {
            LatLng latLng = Convert.toLatLng(call.arguments);
            Point screenLocation = googleMap.getProjection().toScreenLocation(latLng);
            result.success(Convert.pointToJson(screenLocation));
          } else {
            result.error(
                "GoogleMap uninitialized",
                "getScreenCoordinate called prior to map initialization",
                null);
          }
          break;
        }
      case "map#getLatLng":
        {
          if (googleMap != null) {
            Point point = Convert.toPoint(call.arguments);
            LatLng latLng = googleMap.getProjection().fromScreenLocation(point);
            result.success(Convert.latLngToJson(latLng));
          } else {
            result.error(
                "GoogleMap uninitialized", "getLatLng called prior to map initialization", null);
          }
          break;
        }
      case "map#takeSnapshot":
        {
          if (googleMap != null) {
            final MethodChannel.Result _result = result;
            googleMap.snapshot(
                new SnapshotReadyCallback() {
                  @Override
                  public void onSnapshotReady(Bitmap bitmap) {
                    ByteArrayOutputStream stream = new ByteArrayOutputStream();
                    bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
                    byte[] byteArray = stream.toByteArray();
                    bitmap.recycle();
                    _result.success(byteArray);
                  }
                });
          } else {
            result.error("GoogleMap uninitialized", "takeSnapshot", null);
          }
          break;
        }
      case "camera#move":
        {
          final CameraUpdate cameraUpdate =
              Convert.toCameraUpdate(call.argument("cameraUpdate"), density);
          moveCamera(cameraUpdate);
          result.success(null);
          break;
        }
      case "camera#animate":
        {
          final CameraUpdate cameraUpdate =
              Convert.toCameraUpdate(call.argument("cameraUpdate"), density);
          animateCamera(cameraUpdate);
          result.success(null);
          break;
        }
      case "markers#update":
        {
          List<Object> markersToAdd = call.argument("markersToAdd");
          markersController.addMarkers(markersToAdd);
          List<Object> markersToChange = call.argument("markersToChange");
          markersController.changeMarkers(markersToChange);
          List<Object> markerIdsToRemove = call.argument("markerIdsToRemove");
          markersController.removeMarkers(markerIdsToRemove);
          result.success(null);
          break;
        }
      case "markers#showInfoWindow":
        {
          Object markerId = call.argument("markerId");
          markersController.showMarkerInfoWindow((String) markerId, result);
          break;
        }
      case "markers#hideInfoWindow":
        {
          Object markerId = call.argument("markerId");
          markersController.hideMarkerInfoWindow((String) markerId, result);
          break;
        }
      case "markers#isInfoWindowShown":
        {
          Object markerId = call.argument("markerId");
          markersController.isInfoWindowShown((String) markerId, result);
          break;
        }
      case "clusterManagers#update":
        {
          List<Object> clusterManagersToAdd = call.argument("clusterManagersToAdd");
          if (clusterManagersToAdd != null) {
            clusterManagersController.addClusterManagers(clusterManagersToAdd);
          }
          List<Object> clusterManagerIdsToRemove = call.argument("clusterManagerIdsToRemove");
          if (clusterManagerIdsToRemove != null) {
            clusterManagersController.removeClusterManagers(clusterManagerIdsToRemove);
          }
          result.success(null);
          break;
        }
      case "clusterManager#getClusters":
        {
          // The "clusterManagerId" is set in getClusters method at:
          // packages/google_maps_flutter/google_maps_flutter_android/lib/src/google_map_inspector_android.dart
          Object clusterManagerId = call.argument("clusterManagerId");
          clusterManagersController.getClustersWithClusterManagerId(
              (String) clusterManagerId, result);
          break;
        }
      case "polygons#update":
        {
          List<Object> polygonsToAdd = call.argument("polygonsToAdd");
          polygonsController.addPolygons(polygonsToAdd);
          List<Object> polygonsToChange = call.argument("polygonsToChange");
          polygonsController.changePolygons(polygonsToChange);
          List<Object> polygonIdsToRemove = call.argument("polygonIdsToRemove");
          polygonsController.removePolygons(polygonIdsToRemove);
          result.success(null);
          break;
        }
      case "polylines#update":
        {
          List<Object> polylinesToAdd = call.argument("polylinesToAdd");
          polylinesController.addPolylines(polylinesToAdd);
          List<Object> polylinesToChange = call.argument("polylinesToChange");
          polylinesController.changePolylines(polylinesToChange);
          List<Object> polylineIdsToRemove = call.argument("polylineIdsToRemove");
          polylinesController.removePolylines(polylineIdsToRemove);
          result.success(null);
          break;
        }
      case "circles#update":
        {
          List<Object> circlesToAdd = call.argument("circlesToAdd");
          circlesController.addCircles(circlesToAdd);
          List<Object> circlesToChange = call.argument("circlesToChange");
          circlesController.changeCircles(circlesToChange);
          List<Object> circleIdsToRemove = call.argument("circleIdsToRemove");
          circlesController.removeCircles(circleIdsToRemove);
          result.success(null);
          break;
        }
      case "map#isCompassEnabled":
        {
          result.success(googleMap.getUiSettings().isCompassEnabled());
          break;
        }
      case "map#isMapToolbarEnabled":
        {
          result.success(googleMap.getUiSettings().isMapToolbarEnabled());
          break;
        }
      case "map#getMinMaxZoomLevels":
        {
          List<Float> zoomLevels = new ArrayList<>(2);
          zoomLevels.add(googleMap.getMinZoomLevel());
          zoomLevels.add(googleMap.getMaxZoomLevel());
          result.success(zoomLevels);
          break;
        }
      case "map#isZoomGesturesEnabled":
        {
          result.success(googleMap.getUiSettings().isZoomGesturesEnabled());
          break;
        }
      case "map#isLiteModeEnabled":
        {
          result.success(options.getLiteMode());
          break;
        }
      case "map#isZoomControlsEnabled":
        {
          result.success(googleMap.getUiSettings().isZoomControlsEnabled());
          break;
        }
      case "map#isScrollGesturesEnabled":
        {
          result.success(googleMap.getUiSettings().isScrollGesturesEnabled());
          break;
        }
      case "map#isTiltGesturesEnabled":
        {
          result.success(googleMap.getUiSettings().isTiltGesturesEnabled());
          break;
        }
      case "map#isRotateGesturesEnabled":
        {
          result.success(googleMap.getUiSettings().isRotateGesturesEnabled());
          break;
        }
      case "map#isMyLocationButtonEnabled":
        {
          result.success(googleMap.getUiSettings().isMyLocationButtonEnabled());
          break;
        }
      case "map#isTrafficEnabled":
        {
          result.success(googleMap.isTrafficEnabled());
          break;
        }
      case "map#isBuildingsEnabled":
        {
          result.success(googleMap.isBuildingsEnabled());
          break;
        }
      case "map#getZoomLevel":
        {
          result.success(googleMap.getCameraPosition().zoom);
          break;
        }
      case "map#setStyle":
        {
          Object arg = call.arguments;
          final String style = arg instanceof String ? (String) arg : null;
          final boolean mapStyleSet = updateMapStyle(style);
          ArrayList<Object> mapStyleResult = new ArrayList<>(2);
          mapStyleResult.add(mapStyleSet);
          if (!mapStyleSet) {
            mapStyleResult.add(lastStyleError);
          }
          result.success(mapStyleResult);
          break;
        }
      case "map#getStyleError":
        {
          result.success(lastStyleError);
          break;
        }
      case "tileOverlays#update":
        {
          List<Map<String, ?>> tileOverlaysToAdd = call.argument("tileOverlaysToAdd");
          tileOverlaysController.addTileOverlays(tileOverlaysToAdd);
          List<Map<String, ?>> tileOverlaysToChange = call.argument("tileOverlaysToChange");
          tileOverlaysController.changeTileOverlays(tileOverlaysToChange);
          List<String> tileOverlaysToRemove = call.argument("tileOverlayIdsToRemove");
          tileOverlaysController.removeTileOverlays(tileOverlaysToRemove);
          result.success(null);
          break;
        }
      case "tileOverlays#clearTileCache":
        {
          String tileOverlayId = call.argument("tileOverlayId");
          tileOverlaysController.clearTileCache(tileOverlayId);
          result.success(null);
          break;
        }
      case "map#getTileOverlayInfo":
        {
          String tileOverlayId = call.argument("tileOverlayId");
          result.success(tileOverlaysController.getTileOverlayInfo(tileOverlayId));
          break;
        }
      default:
        result.notImplemented();
    }
  }

  @Override
  public void onMapClick(LatLng latLng) {
    final Map<String, Object> arguments = new HashMap<>(2);
    arguments.put("position", Convert.latLngToJson(latLng));
    methodChannel.invokeMethod("map#onTap", arguments);
  }

  @Override
  public void onMapLongClick(LatLng latLng) {
    final Map<String, Object> arguments = new HashMap<>(2);
    arguments.put("position", Convert.latLngToJson(latLng));
    methodChannel.invokeMethod("map#onLongPress", arguments);
  }

  @Override
  public void onCameraMoveStarted(int reason) {
    final Map<String, Object> arguments = new HashMap<>(2);
    boolean isGesture = reason == GoogleMap.OnCameraMoveStartedListener.REASON_GESTURE;
    arguments.put("isGesture", isGesture);
    methodChannel.invokeMethod("camera#onMoveStarted", arguments);
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
    final Map<String, Object> arguments = new HashMap<>(2);
    arguments.put("position", Convert.cameraPositionToJson(googleMap.getCameraPosition()));
    methodChannel.invokeMethod("camera#onMove", arguments);
  }

  @Override
  public void onCameraIdle() {
    clusterManagersController.onCameraIdle();
    methodChannel.invokeMethod("camera#onIdle", Collections.singletonMap("map", id));
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
  public void dispose() {
    if (disposed) {
      return;
    }
    disposed = true;
    methodChannel.setMethodCallHandler(null);
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
  public void onSaveInstanceState(Bundle bundle) {
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
  public void setInitialMarkers(Object initialMarkers) {
    ArrayList<?> markers = (ArrayList<?>) initialMarkers;
    this.initialMarkers = markers != null ? new ArrayList<>(markers) : null;
    if (googleMap != null) {
      updateInitialMarkers();
    }
  }

  private void updateInitialMarkers() {
    markersController.addMarkers(initialMarkers);
  }

  @Override
  public void setInitialClusterManagers(Object initialClusterManagers) {
    ArrayList<?> clusterManagers = (ArrayList<?>) initialClusterManagers;
    this.initialClusterManagers = clusterManagers != null ? new ArrayList<>(clusterManagers) : null;
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
  public void setInitialPolygons(Object initialPolygons) {
    ArrayList<?> polygons = (ArrayList<?>) initialPolygons;
    this.initialPolygons = polygons != null ? new ArrayList<>(polygons) : null;
    if (googleMap != null) {
      updateInitialPolygons();
    }
  }

  private void updateInitialPolygons() {
    polygonsController.addPolygons(initialPolygons);
  }

  @Override
  public void setInitialPolylines(Object initialPolylines) {
    ArrayList<?> polylines = (ArrayList<?>) initialPolylines;
    this.initialPolylines = polylines != null ? new ArrayList<>(polylines) : null;
    if (googleMap != null) {
      updateInitialPolylines();
    }
  }

  private void updateInitialPolylines() {
    polylinesController.addPolylines(initialPolylines);
  }

  @Override
  public void setInitialCircles(Object initialCircles) {
    ArrayList<?> circles = (ArrayList<?>) initialCircles;
    this.initialCircles = circles != null ? new ArrayList<>(circles) : null;
    if (googleMap != null) {
      updateInitialCircles();
    }
  }

  private void updateInitialCircles() {
    circlesController.addCircles(initialCircles);
  }

  @Override
  public void setInitialTileOverlays(List<Map<String, ?>> initialTileOverlays) {
    this.initialTileOverlays = initialTileOverlays;
    if (googleMap != null) {
      updateInitialTileOverlays();
    }
  }

  private void updateInitialTileOverlays() {
    tileOverlaysController.addTileOverlays(initialTileOverlays);
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
  public void onClusterItemRendered(MarkerBuilder markerBuilder, Marker marker) {
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
    final boolean set = Objects.requireNonNull(googleMap).setMapStyle(mapStyleOptions);
    lastStyleError =
        set ? null : "Unable to set the map style. Please check console logs for errors.";
    return set;
  }
}
