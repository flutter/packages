// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static com.google.android.gms.maps.GoogleMap.MAP_TYPE_HYBRID;
import static com.google.android.gms.maps.GoogleMap.MAP_TYPE_NONE;
import static com.google.android.gms.maps.GoogleMap.MAP_TYPE_NORMAL;
import static com.google.android.gms.maps.GoogleMap.MAP_TYPE_SATELLITE;
import static com.google.android.gms.maps.GoogleMap.MAP_TYPE_TERRAIN;

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
import com.google.android.gms.maps.model.JointType;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.google.android.gms.maps.model.PatternItem;
import com.google.android.gms.maps.model.RoundCap;
import com.google.android.gms.maps.model.SquareCap;
import com.google.android.gms.maps.model.Tile;
import com.google.maps.android.clustering.Cluster;
import com.google.maps.android.heatmaps.Gradient;
import com.google.maps.android.heatmaps.WeightedLatLng;
import io.flutter.FlutterInjector;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

/** Conversions between JSON-like values and GoogleMaps data types. */
class Convert {
  // These constants must match the corresponding constants in serialization.dart
  public static final String HEATMAP_ID_KEY = "heatmapId";
  public static final String HEATMAP_DATA_KEY = "data";
  public static final String HEATMAP_GRADIENT_KEY = "gradient";
  public static final String HEATMAP_MAX_INTENSITY_KEY = "maxIntensity";
  public static final String HEATMAP_OPACITY_KEY = "opacity";
  public static final String HEATMAP_RADIUS_KEY = "radius";
  public static final String HEATMAP_GRADIENT_COLORS_KEY = "colors";
  public static final String HEATMAP_GRADIENT_START_POINTS_KEY = "startPoints";
  public static final String HEATMAP_GRADIENT_COLOR_MAP_SIZE_KEY = "colorMapSize";

  private static BitmapDescriptor toBitmapDescriptor(
      Object o, AssetManager assetManager, float density) {
    return toBitmapDescriptor(o, assetManager, density, new BitmapDescriptorFactoryWrapper());
  }

  private static BitmapDescriptor toBitmapDescriptor(
      Object o, AssetManager assetManager, float density, BitmapDescriptorFactoryWrapper wrapper) {
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
            assetData, assetManager, density, wrapper, new FlutterInjectorWrapper());
      case "bytes":
        if (!(data.get(1) instanceof Map)) {
          throw new IllegalArgumentException("'bytes' expected a map as the second parameter");
        }
        final Map<?, ?> byteData = toMap(data.get(1));
        return getBitmapFromBytes(byteData, density, wrapper);
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

  static @NonNull CameraPosition cameraPositionFromPigeon(
      @NonNull Messages.PlatformCameraPosition position) {
    final CameraPosition.Builder builder = CameraPosition.builder();
    builder.bearing(position.getBearing().floatValue());
    builder.target(latLngFromPigeon(position.getTarget()));
    builder.tilt(position.getTilt().floatValue());
    builder.zoom(position.getZoom().floatValue());
    return builder.build();
  }

  static CameraUpdate cameraUpdateFromPigeon(Messages.PlatformCameraUpdate update, float density) {
    Object cameraUpdate = update.getCameraUpdate();
    if (cameraUpdate instanceof Messages.PlatformCameraUpdateNewCameraPosition) {
      Messages.PlatformCameraUpdateNewCameraPosition newCameraPosition =
          (Messages.PlatformCameraUpdateNewCameraPosition) cameraUpdate;
      return CameraUpdateFactory.newCameraPosition(
          cameraPositionFromPigeon(newCameraPosition.getCameraPosition()));
    }
    if (cameraUpdate instanceof Messages.PlatformCameraUpdateNewLatLng) {
      Messages.PlatformCameraUpdateNewLatLng newLatLng =
          (Messages.PlatformCameraUpdateNewLatLng) cameraUpdate;
      return CameraUpdateFactory.newLatLng(latLngFromPigeon(newLatLng.getLatLng()));
    }
    if (cameraUpdate instanceof Messages.PlatformCameraUpdateNewLatLngZoom) {
      Messages.PlatformCameraUpdateNewLatLngZoom newLatLngZoom =
          (Messages.PlatformCameraUpdateNewLatLngZoom) cameraUpdate;
      return CameraUpdateFactory.newLatLngZoom(
          latLngFromPigeon(newLatLngZoom.getLatLng()), newLatLngZoom.getZoom().floatValue());
    }
    if (cameraUpdate instanceof Messages.PlatformCameraUpdateNewLatLngBounds) {
      Messages.PlatformCameraUpdateNewLatLngBounds newLatLngBounds =
          (Messages.PlatformCameraUpdateNewLatLngBounds) cameraUpdate;
      return CameraUpdateFactory.newLatLngBounds(
          latLngBoundsFromPigeon(newLatLngBounds.getBounds()),
          (int) (newLatLngBounds.getPadding() * density));
    }
    if (cameraUpdate instanceof Messages.PlatformCameraUpdateScrollBy) {
      Messages.PlatformCameraUpdateScrollBy scrollBy =
          (Messages.PlatformCameraUpdateScrollBy) cameraUpdate;
      return CameraUpdateFactory.scrollBy(
          scrollBy.getDx().floatValue() * density, scrollBy.getDy().floatValue() * density);
    }
    if (cameraUpdate instanceof Messages.PlatformCameraUpdateZoomBy) {
      Messages.PlatformCameraUpdateZoomBy zoomBy =
          (Messages.PlatformCameraUpdateZoomBy) cameraUpdate;
      final Point focus = pointFromPigeon(zoomBy.getFocus(), density);
      return (focus != null)
          ? CameraUpdateFactory.zoomBy(zoomBy.getAmount().floatValue(), focus)
          : CameraUpdateFactory.zoomBy(zoomBy.getAmount().floatValue());
    }
    if (cameraUpdate instanceof Messages.PlatformCameraUpdateZoomTo) {
      Messages.PlatformCameraUpdateZoomTo zoomTo =
          (Messages.PlatformCameraUpdateZoomTo) cameraUpdate;
      return CameraUpdateFactory.zoomTo(zoomTo.getZoom().floatValue());
    }
    if (cameraUpdate instanceof Messages.PlatformCameraUpdateZoom) {
      Messages.PlatformCameraUpdateZoom zoom = (Messages.PlatformCameraUpdateZoom) cameraUpdate;
      return (zoom.getOut()) ? CameraUpdateFactory.zoomOut() : CameraUpdateFactory.zoomIn();
    }
    throw new IllegalArgumentException(
        "PlatformCameraUpdate's cameraUpdate field must be one of the PlatformCameraUpdate... case classes.");
  }

  private static double toDouble(Object o) {
    return ((Number) o).doubleValue();
  }

  private static float toFloat(Object o) {
    return ((Number) o).floatValue();
  }

  private static @Nullable Float nullableDoubleToFloat(@Nullable Double d) {
    return (d == null) ? null : d.floatValue();
  }

  private static int toInt(Object o) {
    return ((Number) o).intValue();
  }

  static int toMapType(@NonNull Messages.PlatformMapType type) {
    switch (type) {
      case NONE:
        return MAP_TYPE_NONE;
      case NORMAL:
        return MAP_TYPE_NORMAL;
      case SATELLITE:
        return MAP_TYPE_SATELLITE;
      case TERRAIN:
        return MAP_TYPE_TERRAIN;
      case HYBRID:
        return MAP_TYPE_HYBRID;
    }
    return MAP_TYPE_NORMAL;
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

  static @NonNull Messages.PlatformCameraPosition cameraPositionToPigeon(
      @NonNull CameraPosition position) {
    return new Messages.PlatformCameraPosition.Builder()
        .setBearing((double) position.bearing)
        .setTarget(latLngToPigeon(position.target))
        .setTilt((double) position.tilt)
        .setZoom((double) position.zoom)
        .build();
  }

  static Messages.PlatformLatLngBounds latLngBoundsToPigeon(LatLngBounds latLngBounds) {
    return new Messages.PlatformLatLngBounds.Builder()
        .setNortheast(latLngToPigeon(latLngBounds.northeast))
        .setSouthwest(latLngToPigeon(latLngBounds.southwest))
        .build();
  }

  static @NonNull LatLngBounds latLngBoundsFromPigeon(
      @NonNull Messages.PlatformLatLngBounds bounds) {
    return new LatLngBounds(
        latLngFromPigeon(bounds.getSouthwest()), latLngFromPigeon(bounds.getNortheast()));
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

  /**
   * Converts a list of serialized weighted lat/lng to a list of WeightedLatLng.
   *
   * @param o The serialized list of weighted lat/lng.
   * @return The list of WeightedLatLng.
   */
  static WeightedLatLng toWeightedLatLng(Object o) {
    final List<?> data = toList(o);
    return new WeightedLatLng(toLatLng(data.get(0)), toDouble(data.get(1)));
  }

  static Point pointFromPigeon(Messages.PlatformPoint point) {
    return new Point(point.getX().intValue(), point.getY().intValue());
  }

  @Nullable
  static Point pointFromPigeon(@Nullable Messages.PlatformOffset point, float density) {
    if (point == null) {
      return null;
    }
    return new Point((int) (point.getDx() * density), (int) (point.getDy() * density));
  }

  static Messages.PlatformPoint pointToPigeon(Point point) {
    return new Messages.PlatformPoint.Builder().setX((long) point.x).setY((long) point.y).build();
  }

  private static List<?> toList(Object o) {
    return (List<?>) o;
  }

  private static Map<?, ?> toMap(Object o) {
    return (Map<?, ?>) o;
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

  private static String toString(Object o) {
    return (String) o;
  }

  static void interpretMapConfiguration(
      @NonNull Messages.PlatformMapConfiguration config, @NonNull GoogleMapOptionsSink sink) {
    final Messages.PlatformCameraTargetBounds cameraTargetBounds = config.getCameraTargetBounds();
    if (cameraTargetBounds != null) {
      final @Nullable Messages.PlatformLatLngBounds bounds = cameraTargetBounds.getBounds();
      sink.setCameraTargetBounds(bounds == null ? null : latLngBoundsFromPigeon(bounds));
    }
    final Boolean compassEnabled = config.getCompassEnabled();
    if (compassEnabled != null) {
      sink.setCompassEnabled(compassEnabled);
    }
    final Boolean mapToolbarEnabled = config.getMapToolbarEnabled();
    if (mapToolbarEnabled != null) {
      sink.setMapToolbarEnabled(mapToolbarEnabled);
    }
    final Messages.PlatformMapType mapType = config.getMapType();
    if (mapType != null) {
      sink.setMapType(toMapType(mapType));
    }
    final Messages.PlatformZoomRange minMaxZoomPreference = config.getMinMaxZoomPreference();
    if (minMaxZoomPreference != null) {
      sink.setMinMaxZoomPreference(
          nullableDoubleToFloat(minMaxZoomPreference.getMin()),
          nullableDoubleToFloat(minMaxZoomPreference.getMax()));
    }
    final Messages.PlatformEdgeInsets padding = config.getPadding();
    if (padding != null) {
      sink.setPadding(
          padding.getTop().floatValue(),
          padding.getLeft().floatValue(),
          padding.getBottom().floatValue(),
          padding.getRight().floatValue());
    }
    final Boolean rotateGesturesEnabled = config.getRotateGesturesEnabled();
    if (rotateGesturesEnabled != null) {
      sink.setRotateGesturesEnabled(rotateGesturesEnabled);
    }
    final Boolean scrollGesturesEnabled = config.getScrollGesturesEnabled();
    if (scrollGesturesEnabled != null) {
      sink.setScrollGesturesEnabled(scrollGesturesEnabled);
    }
    final Boolean tiltGesturesEnabled = config.getTiltGesturesEnabled();
    if (tiltGesturesEnabled != null) {
      sink.setTiltGesturesEnabled(tiltGesturesEnabled);
    }
    final Boolean trackCameraPosition = config.getTrackCameraPosition();
    if (trackCameraPosition != null) {
      sink.setTrackCameraPosition(trackCameraPosition);
    }
    final Boolean zoomGesturesEnabled = config.getZoomGesturesEnabled();
    if (zoomGesturesEnabled != null) {
      sink.setZoomGesturesEnabled(zoomGesturesEnabled);
    }
    final Boolean liteModeEnabled = config.getLiteModeEnabled();
    if (liteModeEnabled != null) {
      sink.setLiteModeEnabled(liteModeEnabled);
    }
    final Boolean myLocationEnabled = config.getMyLocationEnabled();
    if (myLocationEnabled != null) {
      sink.setMyLocationEnabled(myLocationEnabled);
    }
    final Boolean zoomControlsEnabled = config.getZoomControlsEnabled();
    if (zoomControlsEnabled != null) {
      sink.setZoomControlsEnabled(zoomControlsEnabled);
    }
    final Boolean myLocationButtonEnabled = config.getMyLocationButtonEnabled();
    if (myLocationButtonEnabled != null) {
      sink.setMyLocationButtonEnabled(myLocationButtonEnabled);
    }
    final Boolean indoorEnabled = config.getIndoorViewEnabled();
    if (indoorEnabled != null) {
      sink.setIndoorEnabled(indoorEnabled);
    }
    final Boolean trafficEnabled = config.getTrafficEnabled();
    if (trafficEnabled != null) {
      sink.setTrafficEnabled(trafficEnabled);
    }
    final Boolean buildingsEnabled = config.getBuildingsEnabled();
    if (buildingsEnabled != null) {
      sink.setBuildingsEnabled(buildingsEnabled);
    }
    final String style = config.getStyle();
    if (style != null) {
      sink.setMapStyle(style);
    }
  }

  /** Set the options in the given object to marker options sink. */
  static void interpretMarkerOptions(
      Messages.PlatformMarker marker,
      MarkerOptionsSink sink,
      AssetManager assetManager,
      float density,
      BitmapDescriptorFactoryWrapper wrapper) {
    sink.setAlpha(marker.getAlpha().floatValue());
    sink.setAnchor(
        marker.getAnchor().getDx().floatValue(), marker.getAnchor().getDy().floatValue());
    sink.setConsumeTapEvents(marker.getConsumeTapEvents());
    sink.setDraggable(marker.getDraggable());
    sink.setFlat(marker.getFlat());
    sink.setIcon(toBitmapDescriptor(marker.getIcon(), assetManager, density, wrapper));
    interpretInfoWindowOptions(sink, marker.getInfoWindow());
    sink.setPosition(toLatLng(marker.getPosition().toList()));
    sink.setRotation(marker.getRotation().floatValue());
    sink.setVisible(marker.getVisible());
    sink.setZIndex(marker.getZIndex().floatValue());
  }

  private static void interpretInfoWindowOptions(
      MarkerOptionsSink sink, Messages.PlatformInfoWindow infoWindow) {
    String title = infoWindow.getTitle();
    if (title != null) {
      sink.setInfoWindowText(title, infoWindow.getSnippet());
    }
    Messages.PlatformOffset infoWindowAnchor = infoWindow.getAnchor();
    sink.setInfoWindowAnchor(
        infoWindowAnchor.getDx().floatValue(), infoWindowAnchor.getDy().floatValue());
  }

  static String interpretPolygonOptions(Messages.PlatformPolygon polygon, PolygonOptionsSink sink) {
    sink.setConsumeTapEvents(polygon.getConsumesTapEvents());
    sink.setGeodesic(polygon.getGeodesic());
    sink.setVisible(polygon.getVisible());
    sink.setFillColor(polygon.getFillColor().intValue());
    sink.setStrokeColor(polygon.getStrokeColor().intValue());
    sink.setStrokeWidth(polygon.getStrokeWidth());
    sink.setZIndex(polygon.getZIndex());
    sink.setPoints(pointsFromPigeon(polygon.getPoints()));
    sink.setHoles(toHoles(polygon.getHoles()));
    return polygon.getPolygonId();
  }

  static int jointTypeFromPigeon(Messages.PlatformJointType jointType) {
    switch (jointType) {
      case MITERED:
        return JointType.DEFAULT;
      case BEVEL:
        return JointType.BEVEL;
      case ROUND:
        return JointType.ROUND;
    }
    return JointType.DEFAULT;
  }

  static String interpretPolylineOptions(
      Messages.PlatformPolyline polyline,
      PolylineOptionsSink sink,
      AssetManager assetManager,
      float density) {
    sink.setConsumeTapEvents(polyline.getConsumesTapEvents());
    sink.setColor(polyline.getColor().intValue());
    sink.setEndCap(capFromPigeon(polyline.getEndCap(), assetManager, density));
    sink.setStartCap(capFromPigeon(polyline.getStartCap(), assetManager, density));
    sink.setGeodesic(polyline.getGeodesic());
    sink.setJointType(jointTypeFromPigeon(polyline.getJointType()));
    sink.setVisible(polyline.getVisible());
    sink.setWidth(polyline.getWidth());
    sink.setZIndex(polyline.getZIndex());
    sink.setPoints(pointsFromPigeon(polyline.getPoints()));
    sink.setPattern(patternFromPigeon(polyline.getPatterns()));
    return polyline.getPolylineId();
  }

  static String interpretCircleOptions(Messages.PlatformCircle circle, CircleOptionsSink sink) {
    sink.setConsumeTapEvents(circle.getConsumeTapEvents());
    sink.setFillColor(circle.getFillColor().intValue());
    sink.setStrokeColor(circle.getStrokeColor().intValue());
    sink.setStrokeWidth(circle.getStrokeWidth());
    sink.setZIndex(circle.getZIndex().floatValue());
    sink.setCenter(toLatLng(circle.getCenter().toList()));
    sink.setRadius(circle.getRadius());
    sink.setVisible(circle.getVisible());
    return circle.getCircleId();
  }

  /**
   * Set the options in the given heatmap object to the given sink.
   *
   * @param data the object expected to be a Map containing the heatmap options. The options map is
   *     expected to have the following structure:
   *     <pre>{@code
   * {
   *   "heatmapId": String,
   *   "data": List, // List of serialized weighted lat/lng
   *   "gradient": Map, // Serialized heatmap gradient
   *   "maxIntensity": Double,
   *   "opacity": Double,
   *   "radius": Integer
   * }
   * }</pre>
   *
   * @param sink the HeatmapOptionsSink where the options will be set.
   * @return the heatmapId.
   * @throws IllegalArgumentException if heatmapId is null.
   */
  static String interpretHeatmapOptions(Map<String, ?> data, HeatmapOptionsSink sink) {
    final Object rawWeightedData = data.get(HEATMAP_DATA_KEY);
    if (rawWeightedData != null) {
      sink.setWeightedData(toWeightedData(rawWeightedData));
    }
    final Object gradient = data.get(HEATMAP_GRADIENT_KEY);
    if (gradient != null) {
      sink.setGradient(toGradient(gradient));
    }
    final Object maxIntensity = data.get(HEATMAP_MAX_INTENSITY_KEY);
    if (maxIntensity != null) {
      sink.setMaxIntensity(toDouble(maxIntensity));
    }
    final Object opacity = data.get(HEATMAP_OPACITY_KEY);
    if (opacity != null) {
      sink.setOpacity(toDouble(opacity));
    }
    final Object radius = data.get(HEATMAP_RADIUS_KEY);
    if (radius != null) {
      sink.setRadius(toInt(radius));
    }
    final String heatmapId = (String) data.get(HEATMAP_ID_KEY);
    if (heatmapId == null) {
      throw new IllegalArgumentException("heatmapId was null");
    } else {
      return heatmapId;
    }
  }

  static List<LatLng> pointsFromPigeon(List<Messages.PlatformLatLng> data) {
    final List<LatLng> points = new ArrayList<>(data.size());

    for (Messages.PlatformLatLng rawPoint : data) {
      points.add(new LatLng(rawPoint.getLatitude(), rawPoint.getLongitude()));
    }
    return points;
  }

  /**
   * Converts the given object to a list of WeightedLatLng objects.
   *
   * @param o the object to convert. The object is expected to be a List of serialized weighted
   *     lat/lng.
   * @return a list of WeightedLatLng objects.
   */
  @VisibleForTesting
  static List<WeightedLatLng> toWeightedData(Object o) {
    final List<?> data = toList(o);
    final List<WeightedLatLng> weightedData = new ArrayList<>(data.size());

    for (Object rawWeightedPoint : data) {
      weightedData.add(toWeightedLatLng(rawWeightedPoint));
    }
    return weightedData;
  }

  /**
   * Converts the given object to a Gradient object.
   *
   * @param o the object to convert. The object is expected to be a Map containing the gradient
   *     options. The gradient map is expected to have the following structure:
   *     <pre>{@code
   * {
   *   "colors": List<Integer>,
   *   "startPoints": List<Float>,
   *   "colorMapSize": Integer
   * }
   * }</pre>
   *
   * @return a Gradient object.
   */
  @VisibleForTesting
  static Gradient toGradient(Object o) {
    final Map<?, ?> data = toMap(o);

    final List<?> colorData = toList(data.get(HEATMAP_GRADIENT_COLORS_KEY));
    assert colorData != null;
    final int[] colors = new int[colorData.size()];
    for (int i = 0; i < colorData.size(); i++) {
      colors[i] = toInt(colorData.get(i));
    }

    final List<?> startPointData = toList(data.get(HEATMAP_GRADIENT_START_POINTS_KEY));
    assert startPointData != null;
    final float[] startPoints = new float[startPointData.size()];
    for (int i = 0; i < startPointData.size(); i++) {
      startPoints[i] = toFloat(startPointData.get(i));
    }

    final int colorMapSize = toInt(data.get(HEATMAP_GRADIENT_COLOR_MAP_SIZE_KEY));

    return new Gradient(colors, startPoints, colorMapSize);
  }

  private static List<List<LatLng>> toHoles(List<List<Messages.PlatformLatLng>> data) {
    final List<List<LatLng>> holes = new ArrayList<>(data.size());

    for (List<Messages.PlatformLatLng> hole : data) {
      holes.add(pointsFromPigeon(hole));
    }
    return holes;
  }

  private static List<PatternItem> patternFromPigeon(
      List<Messages.PlatformPatternItem> patternItems) {
    if (patternItems.isEmpty()) {
      return null;
    }
    final List<PatternItem> pattern = new ArrayList<>();
    for (Messages.PlatformPatternItem patternItem : patternItems) {
      switch (patternItem.getType()) {
        case DOT:
          pattern.add(new Dot());
          break;
        case DASH:
          assert patternItem.getLength() != null;
          pattern.add(new Dash(patternItem.getLength().floatValue()));
          break;
        case GAP:
          assert patternItem.getLength() != null;
          pattern.add(new Gap(patternItem.getLength().floatValue()));
          break;
      }
    }
    return pattern;
  }

  private static Cap capFromPigeon(
      Messages.PlatformCap cap, AssetManager assetManager, float density) {
    switch (cap.getType()) {
      case BUTT_CAP:
        return new ButtCap();
      case ROUND_CAP:
        return new RoundCap();
      case SQUARE_CAP:
        return new SquareCap();
      case CUSTOM_CAP:
        if (cap.getRefWidth() == null) {
          throw new IllegalArgumentException("A Custom Cap must specify a refWidth value.");
        }
        return new CustomCap(
            toBitmapDescriptor(cap.getBitmapDescriptor(), assetManager, density),
            cap.getRefWidth().floatValue());
    }
    throw new IllegalArgumentException("Unrecognized Cap type: " + cap.getType());
  }

  static String interpretTileOverlayOptions(
      Messages.PlatformTileOverlay tileOverlay, TileOverlaySink sink) {
    sink.setFadeIn(tileOverlay.getFadeIn());
    sink.setTransparency(tileOverlay.getTransparency().floatValue());
    sink.setZIndex(tileOverlay.getZIndex());
    sink.setVisible(tileOverlay.getVisible());
    return tileOverlay.getTileOverlayId();
  }

  static Tile tileFromPigeon(Messages.PlatformTile tile) {
    return new Tile(tile.getWidth().intValue(), tile.getHeight().intValue(), tile.getData());
  }

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
