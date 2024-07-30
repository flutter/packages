// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static com.google.android.gms.maps.GoogleMap.MAP_TYPE_HYBRID;
import static org.junit.Assert.fail;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.os.Build;
import android.util.Base64;
import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.google.maps.android.clustering.algo.StaticCluster;
import io.flutter.plugins.googlemaps.Convert.BitmapDescriptorFactoryWrapper;
import io.flutter.plugins.googlemaps.Convert.FlutterInjectorWrapper;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
@Config(minSdk = Build.VERSION_CODES.P)
public class ConvertTest {
  @Mock private AssetManager assetManager;

  @Mock private BitmapDescriptorFactoryWrapper bitmapDescriptorFactoryWrapper;

  @Mock private BitmapDescriptor mockBitmapDescriptor;

  @Mock private FlutterInjectorWrapper flutterInjectorWrapper;

  @Mock private GoogleMapOptionsSink optionsSink;

  AutoCloseable mockCloseable;

  // A 1x1 pixel (#8080ff) PNG image encoded in base64
  private final String base64Image = generateBase64Image();

  @Before
  public void before() {
    mockCloseable = MockitoAnnotations.openMocks(this);
  }

  @After
  public void tearDown() throws Exception {
    mockCloseable.close();
  }

  @Test
  public void ConvertToPointsConvertsThePointsWithFullPrecision() {
    double latitude = 43.03725568057;
    double longitude = -87.90466904649;
    ArrayList<Double> point = new ArrayList<>();
    point.add(latitude);
    point.add(longitude);
    ArrayList<ArrayList<Double>> pointsList = new ArrayList<>();
    pointsList.add(point);
    List<LatLng> latLngs = Convert.toPoints(pointsList);
    LatLng latLng = latLngs.get(0);
    Assert.assertEquals(latitude, latLng.latitude, 1e-15);
    Assert.assertEquals(longitude, latLng.longitude, 1e-15);
  }

  @Test
  public void ConvertClusterToPigeonReturnsCorrectData() {
    String clusterManagerId = "cm_1";
    LatLng clusterPosition = new LatLng(43.00, -87.90);
    LatLng markerPosition1 = new LatLng(43.05, -87.95);
    LatLng markerPosition2 = new LatLng(43.02, -87.92);

    StaticCluster<MarkerBuilder> cluster = new StaticCluster<>(clusterPosition);

    MarkerBuilder marker1 = new MarkerBuilder("m_1", clusterManagerId);
    marker1.setPosition(markerPosition1);
    cluster.add(marker1);

    MarkerBuilder marker2 = new MarkerBuilder("m_2", clusterManagerId);
    marker2.setPosition(markerPosition2);
    cluster.add(marker2);

    Messages.PlatformCluster result = Convert.clusterToPigeon(clusterManagerId, cluster);
    Assert.assertEquals(clusterManagerId, result.getClusterManagerId());

    Messages.PlatformLatLng position = result.getPosition();
    Assert.assertEquals(clusterPosition.latitude, position.getLatitude(), 1e-15);
    Assert.assertEquals(clusterPosition.longitude, position.getLongitude(), 1e-15);

    Messages.PlatformLatLngBounds bounds = result.getBounds();
    Messages.PlatformLatLng southwest = bounds.getSouthwest();
    Messages.PlatformLatLng northeast = bounds.getNortheast();
    // bounding data should combine data from marker positions markerPosition1 and markerPosition2
    Assert.assertEquals(markerPosition2.latitude, southwest.getLatitude(), 1e-15);
    Assert.assertEquals(markerPosition1.longitude, southwest.getLongitude(), 1e-15);
    Assert.assertEquals(markerPosition1.latitude, northeast.getLatitude(), 1e-15);
    Assert.assertEquals(markerPosition2.longitude, northeast.getLongitude(), 1e-15);

    List<String> markerIds = result.getMarkerIds();
    Assert.assertEquals(2, markerIds.size());
    Assert.assertEquals(marker1.markerId(), markerIds.get(0));
    Assert.assertEquals(marker2.markerId(), markerIds.get(1));
  }

  @Test
  public void GetBitmapFromAssetAuto() throws Exception {
    String fakeAssetName = "fake_asset_name";
    String fakeAssetKey = "fake_asset_key";
    Map<String, Object> assetDetails = new HashMap<>();
    assetDetails.put("assetName", fakeAssetName);
    assetDetails.put("bitmapScaling", "auto");
    assetDetails.put("width", 15.0f);
    assetDetails.put("height", 15.0f);
    assetDetails.put("imagePixelRatio", 2.0f);

    when(flutterInjectorWrapper.getLookupKeyForAsset(fakeAssetName)).thenReturn(fakeAssetKey);

    when(assetManager.open(fakeAssetKey)).thenReturn(buildImageInputStream());

    when(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor);

    BitmapDescriptor result =
        Convert.getBitmapFromAsset(
            assetDetails,
            assetManager,
            1.0f,
            bitmapDescriptorFactoryWrapper,
            flutterInjectorWrapper);

    Assert.assertEquals(mockBitmapDescriptor, result);
  }

  @Test
  public void GetBitmapFromAssetAutoAndWidth() throws Exception {
    String fakeAssetName = "fake_asset_name";
    String fakeAssetKey = "fake_asset_key";

    Map<String, Object> assetDetails = new HashMap<>();
    assetDetails.put("assetName", fakeAssetName);
    assetDetails.put("bitmapScaling", "auto");
    assetDetails.put("width", 15.0f);
    assetDetails.put("imagePixelRatio", 2.0f);

    when(flutterInjectorWrapper.getLookupKeyForAsset(fakeAssetName)).thenReturn(fakeAssetKey);

    when(assetManager.open(fakeAssetKey)).thenReturn(buildImageInputStream());

    when(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor);

    BitmapDescriptor result =
        Convert.getBitmapFromAsset(
            assetDetails,
            assetManager,
            1.0f,
            bitmapDescriptorFactoryWrapper,
            flutterInjectorWrapper);

    Assert.assertEquals(mockBitmapDescriptor, result);
  }

  @Test
  public void GetBitmapFromAssetAutoAndHeight() throws Exception {
    String fakeAssetName = "fake_asset_name";
    String fakeAssetKey = "fake_asset_key";

    Map<String, Object> assetDetails = new HashMap<>();
    assetDetails.put("assetName", fakeAssetName);
    assetDetails.put("bitmapScaling", "auto");
    assetDetails.put("height", 15.0f);
    assetDetails.put("imagePixelRatio", 2.0f);

    when(flutterInjectorWrapper.getLookupKeyForAsset(fakeAssetName)).thenReturn(fakeAssetKey);

    when(assetManager.open(fakeAssetKey)).thenReturn(buildImageInputStream());

    when(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor);

    BitmapDescriptor result =
        Convert.getBitmapFromAsset(
            assetDetails,
            assetManager,
            1.0f,
            bitmapDescriptorFactoryWrapper,
            flutterInjectorWrapper);

    Assert.assertEquals(mockBitmapDescriptor, result);
  }

  @Test
  public void GetBitmapFromAssetNoScaling() throws Exception {
    String fakeAssetName = "fake_asset_name";
    String fakeAssetKey = "fake_asset_key";

    Map<String, Object> assetDetails = new HashMap<>();
    assetDetails.put("assetName", fakeAssetName);
    assetDetails.put("bitmapScaling", "noScaling");
    assetDetails.put("imagePixelRatio", 2.0f);

    when(flutterInjectorWrapper.getLookupKeyForAsset(fakeAssetName)).thenReturn(fakeAssetKey);

    when(assetManager.open(fakeAssetKey)).thenReturn(buildImageInputStream());

    when(bitmapDescriptorFactoryWrapper.fromAsset(any())).thenReturn(mockBitmapDescriptor);

    verify(bitmapDescriptorFactoryWrapper, never()).fromBitmap(any());

    BitmapDescriptor result =
        Convert.getBitmapFromAsset(
            assetDetails,
            assetManager,
            1.0f,
            bitmapDescriptorFactoryWrapper,
            flutterInjectorWrapper);

    Assert.assertEquals(mockBitmapDescriptor, result);
  }

  @Test
  public void GetBitmapFromBytesAuto() {
    byte[] bmpData = Base64.decode(base64Image, Base64.DEFAULT);

    Map<String, Object> assetDetails = new HashMap<>();
    assetDetails.put("byteData", bmpData);
    assetDetails.put("bitmapScaling", "auto");
    assetDetails.put("imagePixelRatio", 2.0f);

    when(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor);

    BitmapDescriptor result =
        Convert.getBitmapFromBytes(assetDetails, 1f, bitmapDescriptorFactoryWrapper);

    Assert.assertEquals(mockBitmapDescriptor, result);
  }

  @Test
  public void GetBitmapFromBytesAutoAndWidth() {
    byte[] bmpData = Base64.decode(base64Image, Base64.DEFAULT);

    Map<String, Object> assetDetails = new HashMap<>();
    assetDetails.put("byteData", bmpData);
    assetDetails.put("bitmapScaling", "auto");
    assetDetails.put("imagePixelRatio", 2.0f);
    assetDetails.put("width", 15.0f);

    when(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor);

    BitmapDescriptor result =
        Convert.getBitmapFromBytes(assetDetails, 1f, bitmapDescriptorFactoryWrapper);

    Assert.assertEquals(mockBitmapDescriptor, result);
  }

  @Test
  public void GetBitmapFromBytesAutoAndHeight() {
    byte[] bmpData = Base64.decode(base64Image, Base64.DEFAULT);

    Map<String, Object> assetDetails = new HashMap<>();
    assetDetails.put("byteData", bmpData);
    assetDetails.put("bitmapScaling", "auto");
    assetDetails.put("imagePixelRatio", 2.0f);
    assetDetails.put("height", 15.0f);

    when(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor);

    BitmapDescriptor result =
        Convert.getBitmapFromBytes(assetDetails, 1f, bitmapDescriptorFactoryWrapper);

    Assert.assertEquals(mockBitmapDescriptor, result);
  }

  @Test
  public void GetBitmapFromBytesNoScaling() {
    byte[] bmpData = Base64.decode(base64Image, Base64.DEFAULT);

    Map<String, Object> assetDetails = new HashMap<>();
    assetDetails.put("byteData", bmpData);
    assetDetails.put("bitmapScaling", "noScaling");
    assetDetails.put("imagePixelRatio", 2.0f);

    when(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor);

    BitmapDescriptor result =
        Convert.getBitmapFromBytes(assetDetails, 1f, bitmapDescriptorFactoryWrapper);

    Assert.assertEquals(mockBitmapDescriptor, result);
  }

  @Test(expected = IllegalArgumentException.class) // Expecting an IllegalArgumentException
  public void GetBitmapFromBytesThrowsErrorIfInvalidImageData() {
    String invalidBase64Image = "not valid image data";
    byte[] bmpData = Base64.decode(invalidBase64Image, Base64.DEFAULT);

    Map<String, Object> assetDetails = new HashMap<>();
    assetDetails.put("byteData", bmpData);
    assetDetails.put("bitmapScaling", "noScaling");
    assetDetails.put("imagePixelRatio", 2.0f);

    verify(bitmapDescriptorFactoryWrapper, never()).fromBitmap(any());

    try {
      Convert.getBitmapFromBytes(assetDetails, 1f, bitmapDescriptorFactoryWrapper);
    } catch (IllegalArgumentException e) {
      Assert.assertEquals(e.getMessage(), "Unable to interpret bytes as a valid image.");
      throw e; // rethrow the exception
    }

    fail("Expected an IllegalArgumentException to be thrown");
  }

  @Test
  public void interpretMapConfiguration_handlesNulls() {
    final Messages.PlatformMapConfiguration config =
        new Messages.PlatformMapConfiguration.Builder().build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verifyNoInteractions(optionsSink);
  }

  @Test
  public void interpretMapConfiguration_handlesCompassEnabled() {
    final Messages.PlatformMapConfiguration config =
        new Messages.PlatformMapConfiguration.Builder().setCompassEnabled(false).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setCompassEnabled(false);
  }

  @Test
  public void interpretMapConfiguration_handlesMapToolbarEnabled() {
    final Messages.PlatformMapConfiguration config =
        new Messages.PlatformMapConfiguration.Builder().setMapToolbarEnabled(true).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setMapToolbarEnabled(true);
  }

  @Test
  public void interpretMapConfiguration_handlesRotateGesturesEnabled() {
    final Messages.PlatformMapConfiguration config =
        new Messages.PlatformMapConfiguration.Builder().setRotateGesturesEnabled(false).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setRotateGesturesEnabled(false);
  }

  @Test
  public void interpretMapConfiguration_handlesScrollGesturesEnabled() {
    final Messages.PlatformMapConfiguration config =
        new Messages.PlatformMapConfiguration.Builder().setScrollGesturesEnabled(true).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setScrollGesturesEnabled(true);
  }

  @Test
  public void interpretMapConfiguration_handlesTiltGesturesEnabled() {
    final Messages.PlatformMapConfiguration config =
        new Messages.PlatformMapConfiguration.Builder().setTiltGesturesEnabled(false).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setTiltGesturesEnabled(false);
  }

  @Test
  public void interpretMapConfiguration_handlesTrackCameraPosition() {
    final Messages.PlatformMapConfiguration config =
        new Messages.PlatformMapConfiguration.Builder().setTrackCameraPosition(true).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setTrackCameraPosition(true);
  }

  @Test
  public void interpretMapConfiguration_handlesZoomControlsEnabled() {
    final Messages.PlatformMapConfiguration config =
        new Messages.PlatformMapConfiguration.Builder().setZoomControlsEnabled(false).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setZoomControlsEnabled(false);
  }

  @Test
  public void interpretMapConfiguration_handlesZoomGesturesEnabled() {
    final Messages.PlatformMapConfiguration config =
        new Messages.PlatformMapConfiguration.Builder().setZoomGesturesEnabled(true).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setZoomGesturesEnabled(true);
  }

  @Test
  public void interpretMapConfiguration_handlesMyLocationEnabled() {
    final Messages.PlatformMapConfiguration config =
        new Messages.PlatformMapConfiguration.Builder().setMyLocationEnabled(false).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setMyLocationEnabled(false);
  }

  @Test
  public void interpretMapConfiguration_handlesMyLocationButtonEnabled() {
    final Messages.PlatformMapConfiguration config =
        new Messages.PlatformMapConfiguration.Builder().setMyLocationButtonEnabled(true).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setMyLocationButtonEnabled(true);
  }

  @Test
  public void interpretMapConfiguration_handlesIndoorViewEnabled() {
    final Messages.PlatformMapConfiguration config =
        new Messages.PlatformMapConfiguration.Builder().setIndoorViewEnabled(false).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setIndoorEnabled(false);
  }

  @Test
  public void interpretMapConfiguration_handlesTrafficEnabled() {
    final Messages.PlatformMapConfiguration config =
        new Messages.PlatformMapConfiguration.Builder().setTrafficEnabled(true).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setTrafficEnabled(true);
  }

  @Test
  public void interpretMapConfiguration_handlesBuildingsEnabled() {
    final Messages.PlatformMapConfiguration config =
        new Messages.PlatformMapConfiguration.Builder().setBuildingsEnabled(false).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setBuildingsEnabled(false);
  }

  @Test
  public void interpretMapConfiguration_handlesLiteModeEnabled() {
    final Messages.PlatformMapConfiguration config =
        new Messages.PlatformMapConfiguration.Builder().setLiteModeEnabled(true).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setLiteModeEnabled(true);
  }

  @Test
  public void interpretMapConfiguration_handlesStyle() {
    final Messages.PlatformMapConfiguration config =
        new Messages.PlatformMapConfiguration.Builder().setStyle("foo").build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setMapStyle("foo");
  }

  @Test
  public void interpretMapConfiguration_handlesUnboundedCameraTargetBounds() {
    final Messages.PlatformMapConfiguration config =
        new Messages.PlatformMapConfiguration.Builder()
            .setCameraTargetBounds(new Messages.PlatformCameraTargetBounds.Builder().build())
            .build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setCameraTargetBounds(null);
  }

  @Test
  public void interpretMapConfiguration_handlesBoundedCameraTargetBounds() {
    LatLngBounds bounds = new LatLngBounds(new LatLng(10, 20), new LatLng(30, 40));
    final Messages.PlatformMapConfiguration config =
        new Messages.PlatformMapConfiguration.Builder()
            .setCameraTargetBounds(
                new Messages.PlatformCameraTargetBounds.Builder()
                    .setBounds(
                        new Messages.PlatformLatLngBounds.Builder()
                            .setSouthwest(
                                new Messages.PlatformLatLng.Builder()
                                    .setLatitude(bounds.southwest.latitude)
                                    .setLongitude(bounds.southwest.longitude)
                                    .build())
                            .setNortheast(
                                new Messages.PlatformLatLng.Builder()
                                    .setLatitude(bounds.northeast.latitude)
                                    .setLongitude(bounds.northeast.longitude)
                                    .build())
                            .build())
                    .build())
            .build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setCameraTargetBounds(bounds);
  }

  @Test
  public void interpretMapConfiguration_handlesMapType() {
    final Messages.PlatformMapConfiguration config =
        new Messages.PlatformMapConfiguration.Builder()
            .setMapType(Messages.PlatformMapType.HYBRID)
            .build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setMapType(MAP_TYPE_HYBRID);
  }

  @Test
  public void interpretMapConfiguration_handlesPadding() {
    final double top = 1.0;
    final double bottom = 2.0;
    final double left = 3.0;
    final double right = 4.0;
    final Messages.PlatformMapConfiguration config =
        new Messages.PlatformMapConfiguration.Builder()
            .setPadding(
                new Messages.PlatformEdgeInsets.Builder()
                    .setTop(top)
                    .setBottom(bottom)
                    .setLeft(left)
                    .setRight(right)
                    .build())
            .build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1))
        .setPadding((float) top, (float) left, (float) bottom, (float) right);
  }

  @Test
  public void interpretMapConfiguration_handlesMinMaxZoomPreference() {
    final double min = 1.0;
    final double max = 2.0;
    final Messages.PlatformMapConfiguration config =
        new Messages.PlatformMapConfiguration.Builder()
            .setMinMaxZoomPreference(
                new Messages.PlatformZoomRange.Builder().setMin(min).setMax(max).build())
            .build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setMinMaxZoomPreference((float) min, (float) max);
  }

  private InputStream buildImageInputStream() {
    Bitmap fakeBitmap = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888);
    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
    fakeBitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream);
    byte[] byteArray = byteArrayOutputStream.toByteArray();
    return new ByteArrayInputStream(byteArray);
  }

  // Helper method to generate 1x1 pixel base64 encoded png test image
  private String generateBase64Image() {
    int width = 1;
    int height = 1;
    Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
    Canvas canvas = new Canvas(bitmap);

    // Draw on the Bitmap
    Paint paint = new Paint();
    paint.setColor(Color.parseColor("#FF8080FF"));
    canvas.drawRect(0, 0, width, height, paint);

    // Convert the Bitmap to PNG format
    ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
    bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream);
    byte[] pngBytes = outputStream.toByteArray();

    // Encode the PNG bytes as a base64 string
    return Base64.encodeToString(pngBytes, Base64.DEFAULT);
  }
}
