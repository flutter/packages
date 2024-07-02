// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Point;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import com.google.android.gms.maps.CameraUpdate;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.MapsInitializer;
import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.ButtCap;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.Cap;
import com.google.android.gms.maps.model.CustomCap;
import com.google.android.gms.maps.model.Dash;
import com.google.android.gms.maps.model.Dot;
import com.google.android.gms.maps.model.Gap;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.google.android.gms.maps.model.PatternItem;
import com.google.android.gms.maps.model.RoundCap;
import com.google.android.gms.maps.model.SquareCap;
import com.google.android.gms.maps.model.Tile;
import com.google.maps.android.clustering.Cluster;
import io.flutter.FlutterInjector;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Conversions between JSON-like values and GoogleMaps data types. */
class Convert {

  private static BitmapDescriptor toBitmapDescriptor(
      Object o, AssetManager assetManager, float density) {
    final List<?> data = toList(o);
    final String descriptorType = toString(data.get(0));
    switch (descriptorType) {
      case "defaultMarker":
        if (data.size() == 1) {
          return BitmapDescriptorFactory.defaultMarker();
        } else {
          final float hue = toFloat(data.get(1));
          return BitmapDescriptorFactory.defaultMarker(hue);
        }
      case "fromAsset":
        final String assetPath = toString(data.get(1));
        if (data.size() == 2) {
          return BitmapDescriptorFactory.fromAsset(
              FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(assetPath));
        } else {
          final String assetPackage = toString(data.get(2));
          return BitmapDescriptorFactory.fromAsset(
              FlutterInjector.instance()
                  .flutterLoader()
                  .getLookupKeyForAsset(assetPath, assetPackage));
        }
      case "fromAssetImage":
        final String assetImagePath = toString(data.get(1));
        if (data.size() == 3) {
          return BitmapDescriptorFactory.fromAsset(
              FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(assetImagePath));
        } else {
          throw new IllegalArgumentException(
              "'fromAssetImage' Expected exactly 3 arguments, got: " + data.size());
        }
      case "fromBytes":
        return getBitmapFromBytesLegacy(data);
      case "asset":
        if (!(data.get(1) instanceof Map)) {
          throw new IllegalArgumentException("'asset' expected a map as the second parameter");
        }
        final Map<?, ?> assetData = toMap(data.get(1));
        return getBitmapFromAsset(
            assetData,
            assetManager,
            density,
            new BitmapDescriptorFactoryWrapper(),
            new FlutterInjectorWrapper());
      case "bytes":
        if (!(data.get(1) instanceof Map)) {
          throw new IllegalArgumentException("'bytes' expected a map as the second parameter");
        }
        final Map<?, ?> byteData = toMap(data.get(1));
        return getBitmapFromBytes(byteData, density, new BitmapDescriptorFactoryWrapper());
      default:
        throw new IllegalArgumentException("Cannot interpret " + o + " as BitmapDescriptor");
    }
  }

  // Used for deprecated fromBytes bitmap descriptor.
  // Can be removed after support for "fromBytes" bitmap descriptor type is
  // removed.
  private static BitmapDescriptor getBitmapFromBytesLegacy(List<?> data) {
    if (data.size() == 2) {
      try {
        Bitmap bitmap = toBitmap(data.get(1));
        return BitmapDescriptorFactory.fromBitmap(bitmap);
      } catch (Exception e) {
        throw new IllegalArgumentException("Unable to interpret bytes as a valid image.", e);
      }
    } else {
      throw new IllegalArgumentException(
          "fromBytes should have exactly one argument, interpretTileOverlayOptions the bytes. Got: "
              + data.size());
    }
  }

  /**
   * Creates a BitmapDescriptor object from bytes data.
   *
   * <p>This method requires the `byteData` map to contain specific keys: 'byteData' for image
   * bytes, 'bitmapScaling' for scaling mode, and 'imagePixelRatio' for scale ratio. It may
   * optionally include 'width' and/or 'height' for explicit image dimensions.
   *
   * @param byteData a map containing the byte data and scaling instructions. Expected keys are:
   *     'byteData': the actual bytes of the image, 'bitmapScaling': the scaling mode, either 'auto'
   *     or 'none', 'imagePixelRatio': used with 'auto' bitmapScaling if width or height are not
   *     provided, 'width' (optional): the desired width, which affects scaling if 'height' is not
   *     provided, 'height' (optional): the desired height, which affects scaling if 'width' is not
   *     provided
   * @param density the density of the display, used to calculate pixel dimensions.
   * @param bitmapDescriptorFactory is an instance of the BitmapDescriptorFactoryWrapper.
   * @return BitmapDescriptor object from bytes data.
   * @throws IllegalArgumentException if any required keys are missing in `byteData` or if the byte
   *     data cannot be interpreted as a valid image.
   */
  @VisibleForTesting
  public static BitmapDescriptor getBitmapFromBytes(
      Map<?, ?> byteData, float density, BitmapDescriptorFactoryWrapper bitmapDescriptorFactory) {

    final String byteDataKey = "byteData";
    final String bitmapScalingKey = "bitmapScaling";
    final String imagePixelRatioKey = "imagePixelRatio";

    if (!byteData.containsKey(byteDataKey)) {
      throw new IllegalArgumentException("'bytes' requires '" + byteDataKey + "' key.");
    }
    if (!byteData.containsKey(bitmapScalingKey)) {
      throw new IllegalArgumentException("'bytes' requires '" + bitmapScalingKey + "' key.");
    }
    if (!byteData.containsKey(imagePixelRatioKey)) {
      throw new IllegalArgumentException("'bytes' requires '" + imagePixelRatioKey + "' key.");
    }

    try {
      Bitmap bitmap = toBitmap(byteData.get(byteDataKey));
      String scalingMode = toString(byteData.get(bitmapScalingKey));
      switch (scalingMode) {
        case "auto":
          final String widthKey = "width";
          final String heightKey = "height";

          final Double width =
              byteData.containsKey(widthKey) ? toDouble(byteData.get(widthKey)) : null;
          final Double height =
              byteData.containsKey(heightKey) ? toDouble(byteData.get(heightKey)) : null;

          if (width != null || height != null) {
            int targetWidth = width != null ? toInt(width * density) : bitmap.getWidth();
            int targetHeight = height != null ? toInt(height * density) : bitmap.getHeight();

            if (width != null && height == null) {
              // If only width is provided, calculate height based on aspect ratio.
              double aspectRatio = (double) bitmap.getHeight() / bitmap.getWidth();
              targetHeight = (int) (targetWidth * aspectRatio);
            } else if (height != null && width == null) {
              // If only height is provided, calculate width based on aspect ratio.
              double aspectRatio = (double) bitmap.getWidth() / bitmap.getHeight();
              targetWidth = (int) (targetHeight * aspectRatio);
            }
            return bitmapDescriptorFactory.fromBitmap(
                toScaledBitmap(bitmap, targetWidth, targetHeight));
          } else {
            // Scale image using given scale ratio
            final float scale = density / toFloat(byteData.get(imagePixelRatioKey));
            return bitmapDescriptorFactory.fromBitmap(toScaledBitmap(bitmap, scale));
          }
        case "none":
          break;
      }
      return bitmapDescriptorFactory.fromBitmap(bitmap);
    } catch (Exception e) {
      throw new IllegalArgumentException("Unable to interpret bytes as a valid image.", e);
    }
  }

  /**
   * Creates a BitmapDescriptor object from asset, using given details and density.
   *
   * <p>This method processes an asset specified by name and applies scaling based on the provided
   * parameters. The `assetDetails` map must contain the keys 'assetName', 'bitmapScaling', and
   * 'imagePixelRatio', and may optionally include 'width' and/or 'height' to explicitly set the
   * dimensions of the output image.
   *
   * @param assetDetails a map containing the asset details and scaling instructions, with keys
   *     'assetName': the name of the asset file, 'bitmapScaling': the scaling mode, either 'auto'
   *     or 'none', 'imagePixelRatio': used with 'auto' scaling to compute the scale ratio, 'width'
   *     (optional): the desired width, which affects scaling if 'height' is not provided, 'height'
   *     (optional): the desired height, which affects scaling if 'width' is not provided
   * @param assetManager assetManager An instance of Android's AssetManager, which provides access
   *     to any raw asset files stored in the application's assets directory.
   * @param density density the density of the display, used to calculate pixel dimensions.
   * @param bitmapDescriptorFactory is an instance of the BitmapDescriptorFactoryWrapper.
   * @param flutterInjector An instance of the FlutterInjectorWrapper class.
   * @return BitmapDescriptor object from asset.
   * @throws IllegalArgumentException if any required keys are missing in `assetDetails` or if the
   *     asset cannot be opened or processed as a valid image.
   */
  @VisibleForTesting
  public static BitmapDescriptor getBitmapFromAsset(
      Map<?, ?> assetDetails,
      AssetManager assetManager,
      float density,
      BitmapDescriptorFactoryWrapper bitmapDescriptorFactory,
      FlutterInjectorWrapper flutterInjector) {

    final String assetNameKey = "assetName";
    final String bitmapScalingKey = "bitmapScaling";
    final String imagePixelRatioKey = "imagePixelRatio";

    if (!assetDetails.containsKey(assetNameKey)) {
      throw new IllegalArgumentException("'asset' requires '" + assetNameKey + "' key.");
    }
    if (!assetDetails.containsKey(bitmapScalingKey)) {
      throw new IllegalArgumentException("'asset' requires '" + bitmapScalingKey + "' key.");
    }
    if (!assetDetails.containsKey(imagePixelRatioKey)) {
      throw new IllegalArgumentException("'asset' requires '" + imagePixelRatioKey + "' key.");
    }

    final String assetName = toString(assetDetails.get(assetNameKey));
    final String assetKey = flutterInjector.getLookupKeyForAsset(assetName);

    String scalingMode = toString(assetDetails.get(bitmapScalingKey));
    switch (scalingMode) {
      case "auto":
        final String widthKey = "width";
        final String heightKey = "height";

        final Double width =
            assetDetails.containsKey(widthKey) ? toDouble(assetDetails.get(widthKey)) : null;
        final Double height =
            assetDetails.containsKey(heightKey) ? toDouble(assetDetails.get(heightKey)) : null;
        InputStream inputStream = null;
        try {
          inputStream = assetManager.open(assetKey);
          Bitmap bitmap = BitmapFactory.decodeStream(inputStream);

          if (width != null || height != null) {
            int targetWidth = width != null ? toInt(width * density) : bitmap.getWidth();
            int targetHeight = height != null ? toInt(height * density) : bitmap.getHeight();

            if (width != null && height == null) {
              // If only width is provided, calculate height based on aspect ratio.
              double aspectRatio = (double) bitmap.getHeight() / bitmap.getWidth();
              targetHeight = (int) (targetWidth * aspectRatio);
            } else if (height != null && width == null) {
              // If only height is provided, calculate width based on aspect ratio.
              double aspectRatio = (double) bitmap.getWidth() / bitmap.getHeight();
              targetWidth = (int) (targetHeight * aspectRatio);
            }
            return bitmapDescriptorFactory.fromBitmap(
                toScaledBitmap(bitmap, targetWidth, targetHeight));
          } else {
            // Scale image using given scale.
            final float scale = density / toFloat(assetDetails.get(imagePixelRatioKey));
            return bitmapDescriptorFactory.fromBitmap(toScaledBitmap(bitmap, scale));
          }
        } catch (Exception e) {
          throw new IllegalArgumentException("'asset' cannot open asset: " + assetName, e);
        } finally {
          if (inputStream != null) {
            try {
              inputStream.close();
            } catch (IOException e) {
              e.printStackTrace();
            }
          }
        }
      case "none":
        break;
    }

    return bitmapDescriptorFactory.fromAsset(assetKey);
  }

  private static boolean toBoolean(Object o) {
    return (Boolean) o;
  }

  static CameraPosition toCameraPosition(Object o) {
    final Map<?, ?> data = toMap(o);
    final CameraPosition.Builder builder = CameraPosition.builder();
    builder.bearing(toFloat(data.get("bearing")));
    builder.target(toLatLng(data.get("target")));
    builder.tilt(toFloat(data.get("tilt")));
    builder.zoom(toFloat(data.get("zoom")));
    return builder.build();
  }

  static CameraUpdate toCameraUpdate(Object o, float density) {
    final List<?> data = toList(o);
    switch (toString(data.get(0))) {
      case "newCameraPosition":
        return CameraUpdateFactory.newCameraPosition(toCameraPosition(data.get(1)));
      case "newLatLng":
        return CameraUpdateFactory.newLatLng(toLatLng(data.get(1)));
      case "newLatLngBounds":
        return CameraUpdateFactory.newLatLngBounds(
            toLatLngBounds(data.get(1)), toPixels(data.get(2), density));
      case "newLatLngZoom":
        return CameraUpdateFactory.newLatLngZoom(toLatLng(data.get(1)), toFloat(data.get(2)));
      case "scrollBy":
        return CameraUpdateFactory.scrollBy( //
            toFractionalPixels(data.get(1), density), //
            toFractionalPixels(data.get(2), density));
      case "zoomBy":
        if (data.size() == 2) {
          return CameraUpdateFactory.zoomBy(toFloat(data.get(1)));
        } else {
          return CameraUpdateFactory.zoomBy(toFloat(data.get(1)), toPoint(data.get(2), density));
        }
      case "zoomIn":
        return CameraUpdateFactory.zoomIn();
      case "zoomOut":
        return CameraUpdateFactory.zoomOut();
      case "zoomTo":
        return CameraUpdateFactory.zoomTo(toFloat(data.get(1)));
      default:
        throw new IllegalArgumentException("Cannot interpret " + o + " as CameraUpdate");
    }
  }

  private static double toDouble(Object o) {
    return ((Number) o).doubleValue();
  }

  private static float toFloat(Object o) {
    return ((Number) o).floatValue();
  }

  private static Float toFloatWrapper(Object o) {
    return (o == null) ? null : toFloat(o);
  }

  private static int toInt(Object o) {
    return ((Number) o).intValue();
  }

  static @Nullable MapsInitializer.Renderer toMapRendererType(
      @Nullable Messages.PlatformRendererType type) {
    if (type == null) {
      return null;
    }
    switch (type) {
      case LATEST:
        return MapsInitializer.Renderer.LATEST;
      case LEGACY:
        return MapsInitializer.Renderer.LEGACY;
    }
    return null;
  }

  static Object cameraPositionToJson(CameraPosition position) {
    if (position == null) {
      return null;
    }
    final Map<String, Object> data = new HashMap<>();
    data.put("bearing", position.bearing);
    data.put("target", latLngToJson(position.target));
    data.put("tilt", position.tilt);
    data.put("zoom", position.zoom);
    return data;
  }

  static Object latLngBoundsToJson(LatLngBounds latLngBounds) {
    final Map<String, Object> arguments = new HashMap<>(2);
    arguments.put("southwest", latLngToJson(latLngBounds.southwest));
    arguments.put("northeast", latLngToJson(latLngBounds.northeast));
    return arguments;
  }

  static Messages.PlatformLatLngBounds latLngBoundsToPigeon(LatLngBounds latLngBounds) {
    return new Messages.PlatformLatLngBounds.Builder()
        .setNortheast(latLngToPigeon(latLngBounds.northeast))
        .setSouthwest(latLngToPigeon(latLngBounds.southwest))
        .build();
  }

  static Object markerIdToJson(String markerId) {
    if (markerId == null) {
      return null;
    }
    final Map<String, Object> data = new HashMap<>(1);
    data.put("markerId", markerId);
    return data;
  }

  static Object polygonIdToJson(String polygonId) {
    if (polygonId == null) {
      return null;
    }
    final Map<String, Object> data = new HashMap<>(1);
    data.put("polygonId", polygonId);
    return data;
  }

  static Object polylineIdToJson(String polylineId) {
    if (polylineId == null) {
      return null;
    }
    final Map<String, Object> data = new HashMap<>(1);
    data.put("polylineId", polylineId);
    return data;
  }

  static Object circleIdToJson(String circleId) {
    if (circleId == null) {
      return null;
    }
    final Map<String, Object> data = new HashMap<>(1);
    data.put("circleId", circleId);
    return data;
  }

  static Map<String, Object> tileOverlayArgumentsToJson(
      String tileOverlayId, int x, int y, int zoom) {

    if (tileOverlayId == null) {
      return null;
    }
    final Map<String, Object> data = new HashMap<>(4);
    data.put("tileOverlayId", tileOverlayId);
    data.put("x", x);
    data.put("y", y);
    data.put("zoom", zoom);
    return data;
  }

  static Object latLngToJson(LatLng latLng) {
    return Arrays.asList(latLng.latitude, latLng.longitude);
  }

  static Messages.PlatformLatLng latLngToPigeon(LatLng latLng) {
    return new Messages.PlatformLatLng.Builder()
        .setLatitude(latLng.latitude)
        .setLongitude(latLng.longitude)
        .build();
  }

  static LatLng latLngFromPigeon(Messages.PlatformLatLng latLng) {
    return new LatLng(latLng.getLatitude(), latLng.getLongitude());
  }

  static Object clusterToJson(String clusterManagerId, Cluster<MarkerBuilder> cluster) {
    int clusterSize = cluster.getSize();
    LatLngBounds.Builder latLngBoundsBuilder = LatLngBounds.builder();

    String[] markerIds = new String[clusterSize];
    MarkerBuilder[] markerBuilders = cluster.getItems().toArray(new MarkerBuilder[clusterSize]);

    // Loops though cluster items and reads markers position for the LatLngBounds
    // builder
    // and also builds list of marker ids on the cluster.
    for (int i = 0; i < clusterSize; i++) {
      MarkerBuilder markerBuilder = markerBuilders[i];
      latLngBoundsBuilder.include(markerBuilder.getPosition());
      markerIds[i] = markerBuilder.markerId();
    }

    Object position = latLngToJson(cluster.getPosition());
    Object bounds = latLngBoundsToJson(latLngBoundsBuilder.build());

    final Map<String, Object> data = new HashMap<>(4);

    // For dart side implementation see parseCluster method at
    // packages/google_maps_flutter/google_maps_flutter_android/lib/src/google_maps_flutter_android.dart
    data.put("clusterManagerId", clusterManagerId);
    data.put("position", position);
    data.put("bounds", bounds);
    data.put("markerIds", Arrays.asList(markerIds));
    return data;
  }

  static Messages.PlatformCluster clusterToPigeon(
      String clusterManagerId, Cluster<MarkerBuilder> cluster) {
    int clusterSize = cluster.getSize();
    String[] markerIds = new String[clusterSize];
    MarkerBuilder[] markerBuilders = cluster.getItems().toArray(new MarkerBuilder[clusterSize]);

    LatLngBounds.Builder latLngBoundsBuilder = LatLngBounds.builder();
    for (int i = 0; i < clusterSize; i++) {
      MarkerBuilder markerBuilder = markerBuilders[i];
      latLngBoundsBuilder.include(markerBuilder.getPosition());
      markerIds[i] = markerBuilder.markerId();
    }

    return new Messages.PlatformCluster.Builder()
        .setClusterManagerId(clusterManagerId)
        .setPosition(latLngToPigeon(cluster.getPosition()))
        .setBounds(latLngBoundsToPigeon(latLngBoundsBuilder.build()))
        .setMarkerIds(Arrays.asList(markerIds))
        .build();
  }

  static LatLng toLatLng(Object o) {
    final List<?> data = toList(o);
    return new LatLng(toDouble(data.get(0)), toDouble(data.get(1)));
  }

  static Point pointFromPigeon(Messages.PlatformPoint point) {
    return new Point(point.getX().intValue(), point.getY().intValue());
  }

  static Messages.PlatformPoint pointToPigeon(Point point) {
    return new Messages.PlatformPoint.Builder().setX((long) point.x).setY((long) point.y).build();
  }

  private static LatLngBounds toLatLngBounds(Object o) {
    if (o == null) {
      return null;
    }
    final List<?> data = toList(o);
    return new LatLngBounds(toLatLng(data.get(0)), toLatLng(data.get(1)));
  }

  private static List<?> toList(Object o) {
    return (List<?>) o;
  }

  private static Map<?, ?> toMap(Object o) {
    return (Map<?, ?>) o;
  }

  private static Map<String, Object> toObjectMap(Object o) {
    Map<String, Object> hashMap = new HashMap<>();
    Map<?, ?> map = (Map<?, ?>) o;
    for (Object key : map.keySet()) {
      Object object = map.get(key);
      if (object != null) {
        hashMap.put((String) key, object);
      }
    }
    return hashMap;
  }

  private static float toFractionalPixels(Object o, float density) {
    return toFloat(o) * density;
  }

  private static int toPixels(Object o, float density) {
    return (int) toFractionalPixels(o, density);
  }

  private static Bitmap toBitmap(Object o) {
    byte[] bmpData = (byte[]) o;
    Bitmap bitmap = BitmapFactory.decodeByteArray(bmpData, 0, bmpData.length);
    if (bitmap == null) {
      throw new IllegalArgumentException("Unable to decode bytes as a valid bitmap.");
    } else {
      return bitmap;
    }
  }

  private static Bitmap toScaledBitmap(Bitmap bitmap, float scale) {
    // Threshold to check if scaling is necessary.
    final float scalingThreshold = 0.001f;

    if (Math.abs(scale - 1) > scalingThreshold && scale > 0) {
      final int newWidth = (int) (bitmap.getWidth() * scale);
      final int newHeight = (int) (bitmap.getHeight() * scale);
      return toScaledBitmap(bitmap, newWidth, newHeight);
    }
    return bitmap;
  }

  private static Bitmap toScaledBitmap(Bitmap bitmap, int width, int height) {
    if (width > 0 && height > 0 && (bitmap.getWidth() != width || bitmap.getHeight() != height)) {
      return Bitmap.createScaledBitmap(bitmap, width, height, true);
    }
    return bitmap;
  }

  private static Point toPoint(Object o, float density) {
    final List<?> data = toList(o);
    return new Point(toPixels(data.get(0), density), toPixels(data.get(1), density));
  }

  private static String toString(Object o) {
    return (String) o;
  }

  static void interpretGoogleMapOptions(Object o, GoogleMapOptionsSink sink) {
    final Map<?, ?> data = toMap(o);
    final Object cameraTargetBounds = data.get("cameraTargetBounds");
    if (cameraTargetBounds != null) {
      final List<?> targetData = toList(cameraTargetBounds);
      sink.setCameraTargetBounds(toLatLngBounds(targetData.get(0)));
    }
    final Object compassEnabled = data.get("compassEnabled");
    if (compassEnabled != null) {
      sink.setCompassEnabled(toBoolean(compassEnabled));
    }
    final Object mapToolbarEnabled = data.get("mapToolbarEnabled");
    if (mapToolbarEnabled != null) {
      sink.setMapToolbarEnabled(toBoolean(mapToolbarEnabled));
    }
    final Object mapType = data.get("mapType");
    if (mapType != null) {
      sink.setMapType(toInt(mapType));
    }
    final Object minMaxZoomPreference = data.get("minMaxZoomPreference");
    if (minMaxZoomPreference != null) {
      final List<?> zoomPreferenceData = toList(minMaxZoomPreference);
      sink.setMinMaxZoomPreference( //
          toFloatWrapper(zoomPreferenceData.get(0)), //
          toFloatWrapper(zoomPreferenceData.get(1)));
    }
    final Object padding = data.get("padding");
    if (padding != null) {
      final List<?> paddingData = toList(padding);
      sink.setPadding(
          toFloat(paddingData.get(0)),
          toFloat(paddingData.get(1)),
          toFloat(paddingData.get(2)),
          toFloat(paddingData.get(3)));
    }
    final Object rotateGesturesEnabled = data.get("rotateGesturesEnabled");
    if (rotateGesturesEnabled != null) {
      sink.setRotateGesturesEnabled(toBoolean(rotateGesturesEnabled));
    }
    final Object scrollGesturesEnabled = data.get("scrollGesturesEnabled");
    if (scrollGesturesEnabled != null) {
      sink.setScrollGesturesEnabled(toBoolean(scrollGesturesEnabled));
    }
    final Object tiltGesturesEnabled = data.get("tiltGesturesEnabled");
    if (tiltGesturesEnabled != null) {
      sink.setTiltGesturesEnabled(toBoolean(tiltGesturesEnabled));
    }
    final Object trackCameraPosition = data.get("trackCameraPosition");
    if (trackCameraPosition != null) {
      sink.setTrackCameraPosition(toBoolean(trackCameraPosition));
    }
    final Object zoomGesturesEnabled = data.get("zoomGesturesEnabled");
    if (zoomGesturesEnabled != null) {
      sink.setZoomGesturesEnabled(toBoolean(zoomGesturesEnabled));
    }
    final Object liteModeEnabled = data.get("liteModeEnabled");
    if (liteModeEnabled != null) {
      sink.setLiteModeEnabled(toBoolean(liteModeEnabled));
    }
    final Object myLocationEnabled = data.get("myLocationEnabled");
    if (myLocationEnabled != null) {
      sink.setMyLocationEnabled(toBoolean(myLocationEnabled));
    }
    final Object zoomControlsEnabled = data.get("zoomControlsEnabled");
    if (zoomControlsEnabled != null) {
      sink.setZoomControlsEnabled(toBoolean(zoomControlsEnabled));
    }
    final Object myLocationButtonEnabled = data.get("myLocationButtonEnabled");
    if (myLocationButtonEnabled != null) {
      sink.setMyLocationButtonEnabled(toBoolean(myLocationButtonEnabled));
    }
    final Object indoorEnabled = data.get("indoorEnabled");
    if (indoorEnabled != null) {
      sink.setIndoorEnabled(toBoolean(indoorEnabled));
    }
    final Object trafficEnabled = data.get("trafficEnabled");
    if (trafficEnabled != null) {
      sink.setTrafficEnabled(toBoolean(trafficEnabled));
    }
    final Object buildingsEnabled = data.get("buildingsEnabled");
    if (buildingsEnabled != null) {
      sink.setBuildingsEnabled(toBoolean(buildingsEnabled));
    }
    final Object style = data.get("style");
    if (style != null) {
      sink.setMapStyle(toString(style));
    }
  }

  /** Set the options in the given object to marker options sink. */
  static void interpretMarkerOptions(
      Object o, MarkerOptionsSink sink, AssetManager assetManager, float density) {
    final Map<?, ?> data = toMap(o);
    final Object alpha = data.get("alpha");
    if (alpha != null) {
      sink.setAlpha(toFloat(alpha));
    }
    final Object anchor = data.get("anchor");
    if (anchor != null) {
      final List<?> anchorData = toList(anchor);
      sink.setAnchor(toFloat(anchorData.get(0)), toFloat(anchorData.get(1)));
    }
    final Object consumeTapEvents = data.get("consumeTapEvents");
    if (consumeTapEvents != null) {
      sink.setConsumeTapEvents(toBoolean(consumeTapEvents));
    }
    final Object draggable = data.get("draggable");
    if (draggable != null) {
      sink.setDraggable(toBoolean(draggable));
    }
    final Object flat = data.get("flat");
    if (flat != null) {
      sink.setFlat(toBoolean(flat));
    }
    final Object icon = data.get("icon");
    if (icon != null) {
      sink.setIcon(toBitmapDescriptor(icon, assetManager, density));
    }

    final Object infoWindow = data.get("infoWindow");
    if (infoWindow != null) {
      interpretInfoWindowOptions(sink, toObjectMap(infoWindow));
    }
    final Object position = data.get("position");
    if (position != null) {
      sink.setPosition(toLatLng(position));
    }
    final Object rotation = data.get("rotation");
    if (rotation != null) {
      sink.setRotation(toFloat(rotation));
    }
    final Object visible = data.get("visible");
    if (visible != null) {
      sink.setVisible(toBoolean(visible));
    }
    final Object zIndex = data.get("zIndex");
    if (zIndex != null) {
      sink.setZIndex(toFloat(zIndex));
    }
  }

  private static void interpretInfoWindowOptions(
      MarkerOptionsSink sink, Map<String, Object> infoWindow) {
    String title = (String) infoWindow.get("title");
    String snippet = (String) infoWindow.get("snippet");
    // snippet is nullable.
    if (title != null) {
      sink.setInfoWindowText(title, snippet);
    }
    Object infoWindowAnchor = infoWindow.get("anchor");
    if (infoWindowAnchor != null) {
      final List<?> anchorData = toList(infoWindowAnchor);
      sink.setInfoWindowAnchor(toFloat(anchorData.get(0)), toFloat(anchorData.get(1)));
    }
  }

  static String interpretPolygonOptions(Object o, PolygonOptionsSink sink) {
    final Map<?, ?> data = toMap(o);
    final Object consumeTapEvents = data.get("consumeTapEvents");
    if (consumeTapEvents != null) {
      sink.setConsumeTapEvents(toBoolean(consumeTapEvents));
    }
    final Object geodesic = data.get("geodesic");
    if (geodesic != null) {
      sink.setGeodesic(toBoolean(geodesic));
    }
    final Object visible = data.get("visible");
    if (visible != null) {
      sink.setVisible(toBoolean(visible));
    }
    final Object fillColor = data.get("fillColor");
    if (fillColor != null) {
      sink.setFillColor(toInt(fillColor));
    }
    final Object strokeColor = data.get("strokeColor");
    if (strokeColor != null) {
      sink.setStrokeColor(toInt(strokeColor));
    }
    final Object strokeWidth = data.get("strokeWidth");
    if (strokeWidth != null) {
      sink.setStrokeWidth(toInt(strokeWidth));
    }
    final Object zIndex = data.get("zIndex");
    if (zIndex != null) {
      sink.setZIndex(toFloat(zIndex));
    }
    final Object points = data.get("points");
    if (points != null) {
      sink.setPoints(toPoints(points));
    }
    final Object holes = data.get("holes");
    if (holes != null) {
      sink.setHoles(toHoles(holes));
    }
    final String polygonId = (String) data.get("polygonId");
    if (polygonId == null) {
      throw new IllegalArgumentException("polygonId was null");
    } else {
      return polygonId;
    }
  }

  static String interpretPolylineOptions(
      Object o, PolylineOptionsSink sink, AssetManager assetManager, float density) {
    final Map<?, ?> data = toMap(o);
    final Object consumeTapEvents = data.get("consumeTapEvents");
    if (consumeTapEvents != null) {
      sink.setConsumeTapEvents(toBoolean(consumeTapEvents));
    }
    final Object color = data.get("color");
    if (color != null) {
      sink.setColor(toInt(color));
    }
    final Object endCap = data.get("endCap");
    if (endCap != null) {
      sink.setEndCap(toCap(endCap, assetManager, density));
    }
    final Object geodesic = data.get("geodesic");
    if (geodesic != null) {
      sink.setGeodesic(toBoolean(geodesic));
    }
    final Object jointType = data.get("jointType");
    if (jointType != null) {
      sink.setJointType(toInt(jointType));
    }
    final Object startCap = data.get("startCap");
    if (startCap != null) {
      sink.setStartCap(toCap(startCap, assetManager, density));
    }
    final Object visible = data.get("visible");
    if (visible != null) {
      sink.setVisible(toBoolean(visible));
    }
    final Object width = data.get("width");
    if (width != null) {
      sink.setWidth(toInt(width));
    }
    final Object zIndex = data.get("zIndex");
    if (zIndex != null) {
      sink.setZIndex(toFloat(zIndex));
    }
    final Object points = data.get("points");
    if (points != null) {
      sink.setPoints(toPoints(points));
    }
    final Object pattern = data.get("pattern");
    if (pattern != null) {
      sink.setPattern(toPattern(pattern));
    }
    final String polylineId = (String) data.get("polylineId");
    if (polylineId == null) {
      throw new IllegalArgumentException("polylineId was null");
    } else {
      return polylineId;
    }
  }

  static String interpretCircleOptions(Object o, CircleOptionsSink sink) {
    final Map<?, ?> data = toMap(o);
    final Object consumeTapEvents = data.get("consumeTapEvents");
    if (consumeTapEvents != null) {
      sink.setConsumeTapEvents(toBoolean(consumeTapEvents));
    }
    final Object fillColor = data.get("fillColor");
    if (fillColor != null) {
      sink.setFillColor(toInt(fillColor));
    }
    final Object strokeColor = data.get("strokeColor");
    if (strokeColor != null) {
      sink.setStrokeColor(toInt(strokeColor));
    }
    final Object visible = data.get("visible");
    if (visible != null) {
      sink.setVisible(toBoolean(visible));
    }
    final Object strokeWidth = data.get("strokeWidth");
    if (strokeWidth != null) {
      sink.setStrokeWidth(toInt(strokeWidth));
    }
    final Object zIndex = data.get("zIndex");
    if (zIndex != null) {
      sink.setZIndex(toFloat(zIndex));
    }
    final Object center = data.get("center");
    if (center != null) {
      sink.setCenter(toLatLng(center));
    }
    final Object radius = data.get("radius");
    if (radius != null) {
      sink.setRadius(toDouble(radius));
    }
    final String circleId = (String) data.get("circleId");
    if (circleId == null) {
      throw new IllegalArgumentException("circleId was null");
    } else {
      return circleId;
    }
  }

  @VisibleForTesting
  static List<LatLng> toPoints(Object o) {
    final List<?> data = toList(o);
    final List<LatLng> points = new ArrayList<>(data.size());

    for (Object rawPoint : data) {
      final List<?> point = toList(rawPoint);
      points.add(new LatLng(toDouble(point.get(0)), toDouble(point.get(1))));
    }
    return points;
  }

  private static List<List<LatLng>> toHoles(Object o) {
    final List<?> data = toList(o);
    final List<List<LatLng>> holes = new ArrayList<>(data.size());

    for (Object rawHole : data) {
      holes.add(toPoints(rawHole));
    }
    return holes;
  }

  private static List<PatternItem> toPattern(Object o) {
    final List<?> data = toList(o);

    if (data.isEmpty()) {
      return null;
    }

    final List<PatternItem> pattern = new ArrayList<>(data.size());

    for (Object ob : data) {
      final List<?> patternItem = toList(ob);
      switch (toString(patternItem.get(0))) {
        case "dot":
          pattern.add(new Dot());
          break;
        case "dash":
          pattern.add(new Dash(toFloat(patternItem.get(1))));
          break;
        case "gap":
          pattern.add(new Gap(toFloat(patternItem.get(1))));
          break;
        default:
          throw new IllegalArgumentException("Cannot interpret " + pattern + " as PatternItem");
      }
    }

    return pattern;
  }

  private static Cap toCap(Object o, AssetManager assetManager, float density) {
    final List<?> data = toList(o);
    switch (toString(data.get(0))) {
      case "buttCap":
        return new ButtCap();
      case "roundCap":
        return new RoundCap();
      case "squareCap":
        return new SquareCap();
      case "customCap":
        if (data.size() == 2) {
          return new CustomCap(toBitmapDescriptor(data.get(1), assetManager, density));
        } else {
          return new CustomCap(
              toBitmapDescriptor(data.get(1), assetManager, density), toFloat(data.get(2)));
        }
      default:
        throw new IllegalArgumentException("Cannot interpret " + o + " as Cap");
    }
  }

  static String interpretTileOverlayOptions(Map<String, ?> data, TileOverlaySink sink) {
    final Object fadeIn = data.get("fadeIn");
    if (fadeIn != null) {
      sink.setFadeIn(toBoolean(fadeIn));
    }
    final Object transparency = data.get("transparency");
    if (transparency != null) {
      sink.setTransparency(toFloat(transparency));
    }
    final Object zIndex = data.get("zIndex");
    if (zIndex != null) {
      sink.setZIndex(toFloat(zIndex));
    }
    final Object visible = data.get("visible");
    if (visible != null) {
      sink.setVisible(toBoolean(visible));
    }
    final String tileOverlayId = (String) data.get("tileOverlayId");
    if (tileOverlayId == null) {
      throw new IllegalArgumentException("tileOverlayId was null");
    } else {
      return tileOverlayId;
    }
  }

  static Tile interpretTile(Map<String, ?> data) {
    int width = toInt(data.get("width"));
    int height = toInt(data.get("height"));
    byte[] dataArray = null;
    if (data.get("data") != null) {
      dataArray = (byte[]) data.get("data");
    }
    return new Tile(width, height, dataArray);
  }

  @VisibleForTesting
  static class BitmapDescriptorFactoryWrapper {
    /**
     * Creates a BitmapDescriptor from the provided asset key using the {@link
     * BitmapDescriptorFactory}.
     *
     * <p>This method is visible for testing purposes only and should never be used outside Convert
     * class.
     *
     * @param assetKey the key of the asset.
     * @return a new instance of the {@link BitmapDescriptor}.
     */
    @VisibleForTesting
    public BitmapDescriptor fromAsset(String assetKey) {
      return BitmapDescriptorFactory.fromAsset(assetKey);
    }

    /**
     * Creates a BitmapDescriptor from the provided bitmap using the {@link
     * BitmapDescriptorFactory}.
     *
     * <p>This method is visible for testing purposes only and should never be used outside Convert
     * class.
     *
     * @param bitmap the bitmap to convert.
     * @return a new instance of the {@link BitmapDescriptor}.
     */
    @VisibleForTesting
    public BitmapDescriptor fromBitmap(Bitmap bitmap) {
      return BitmapDescriptorFactory.fromBitmap(bitmap);
    }
  }

  @VisibleForTesting
  static class FlutterInjectorWrapper {
    /**
     * Retrieves the lookup key for a given asset name using the {@link FlutterInjector}.
     *
     * <p>This method is visible for testing purposes only and should never be used outside Convert
     * class.
     *
     * @param assetName the name of the asset.
     * @return the lookup key for the asset.
     */
    @VisibleForTesting
    public String getLookupKeyForAsset(@NonNull String assetName) {
      return FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(assetName);
    }
  }
}
