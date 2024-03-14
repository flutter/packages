// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
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
import io.flutter.plugins.googlemaps.Convert.BitmapDescriptorFactoryWrapper;
import io.flutter.plugins.googlemaps.Convert.FlutterInjectorWrapper;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
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
@Config(sdk = Build.VERSION_CODES.P)
public class ConvertTest {
  @Mock private AssetManager assetManager;

  @Mock private BitmapDescriptorFactoryWrapper bitmapDescriptorFactoryWrapper;

  @Mock private BitmapDescriptor mockBitmapDescriptor;

  @Mock private FlutterInjectorWrapper flutterInjectorWrapper;

  AutoCloseable mockCloseable;

  // A 1x1 pixel (#8080ff) PNG image encoded in base64
  private String base64Image = generateBase64Image();

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
    ArrayList<Double> point = new ArrayList<Double>();
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
  public void GetBitmapFromAssetAuto() throws Exception {
    String fakeAssetName = "fake_asset_name";
    String fakeAssetKey = "fake_asset_key";
    ArrayList<Object> data = new ArrayList<>(Arrays.asList("asset", fakeAssetName, "auto", 2.0f));

    when(flutterInjectorWrapper.getLookupKeyForAsset(fakeAssetName)).thenReturn(fakeAssetKey);

    when(assetManager.open(fakeAssetKey)).thenReturn(buildImageInputStream());

    when(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor);

    BitmapDescriptor result =
        Convert.getBitmapFromAsset(
            data, assetManager, 1.0f, bitmapDescriptorFactoryWrapper, flutterInjectorWrapper);

    Assert.assertEquals(mockBitmapDescriptor, result);
  }

  @Test
  public void GetBitmapFromAssetAutoAndSize() throws Exception {
    String fakeAssetName = "fake_asset_name";
    String fakeAssetKey = "fake_asset_key";
    ArrayList<Object> data =
        new ArrayList<>(
            Arrays.asList(
                "asset", fakeAssetName, "auto", 2.0f, new ArrayList<>(Arrays.asList(15.0, 15.0))));

    when(flutterInjectorWrapper.getLookupKeyForAsset(fakeAssetName)).thenReturn(fakeAssetKey);

    when(assetManager.open(fakeAssetKey)).thenReturn(buildImageInputStream());

    when(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor);

    BitmapDescriptor result =
        Convert.getBitmapFromAsset(
            data, assetManager, 1.0f, bitmapDescriptorFactoryWrapper, flutterInjectorWrapper);

    Assert.assertEquals(mockBitmapDescriptor, result);
  }

  @Test
  public void GetBitmapFromAssetNoScaling() throws Exception {
    String fakeAssetName = "fake_asset_name";
    String fakeAssetKey = "fake_asset_key";
    ArrayList<Object> data =
        new ArrayList<>(Arrays.asList("asset", fakeAssetName, "noScaling", 2.0f));

    when(flutterInjectorWrapper.getLookupKeyForAsset(fakeAssetName)).thenReturn(fakeAssetKey);

    when(assetManager.open(fakeAssetKey)).thenReturn(buildImageInputStream());

    when(bitmapDescriptorFactoryWrapper.fromAsset(any())).thenReturn(mockBitmapDescriptor);

    verify(bitmapDescriptorFactoryWrapper, never()).fromBitmap(any());

    BitmapDescriptor result =
        Convert.getBitmapFromAsset(
            data, assetManager, 1.0f, bitmapDescriptorFactoryWrapper, flutterInjectorWrapper);

    Assert.assertEquals(mockBitmapDescriptor, result);
  }

  @Test(expected = IllegalArgumentException.class) // Expecting an IllegalArgumentException
  public void GetBitmapFromAssetThrowsErrorIfAssetNotAvailable() throws Exception {
    String fakeAssetName = "fake_asset_name";
    ArrayList<Object> data =
        new ArrayList<>(Arrays.asList("asset", fakeAssetName, "noScaling", 2.0f));

    when(flutterInjectorWrapper.getLookupKeyForAsset(fakeAssetName))
        .thenThrow(new RuntimeException("Fake exception"));

    try {
      Convert.getBitmapFromAsset(
          data, assetManager, 1.0f, bitmapDescriptorFactoryWrapper, flutterInjectorWrapper);
    } catch (IllegalArgumentException e) {
      assertTrue(e.getMessage().startsWith("'asset' cannot open asset: "));
      throw e; // rethrow the exception
    }

    fail("Expected an IllegalArgumentException to be thrown");
  }

  @Test
  public void GetBitmapFromBytesAuto() throws Exception {
    byte[] bmpData = Base64.decode(base64Image, Base64.DEFAULT);

    List<?> data = new ArrayList<>(Arrays.asList("bytes", bmpData, "auto", 2.0f));

    when(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor);

    BitmapDescriptor result = Convert.getBitmapFromBytes(data, 1f, bitmapDescriptorFactoryWrapper);

    Assert.assertEquals(mockBitmapDescriptor, result);
  }

  @Test
  public void GetBitmapFromBytesAutoAndSize() throws Exception {
    byte[] bmpData = Base64.decode(base64Image, Base64.DEFAULT);

    List<?> data =
        new ArrayList<>(
            Arrays.asList(
                "bytes", bmpData, "auto", 2.0f, new ArrayList<>(Arrays.asList(15.0, 15.0))));

    when(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor);

    BitmapDescriptor result = Convert.getBitmapFromBytes(data, 1f, bitmapDescriptorFactoryWrapper);

    Assert.assertEquals(mockBitmapDescriptor, result);
  }

  @Test
  public void GetBitmapFromBytesNoScaling() throws Exception {
    byte[] bmpData = Base64.decode(base64Image, Base64.DEFAULT);

    List<?> data = new ArrayList<>(Arrays.asList("bytes", bmpData, "noScaling", 1.0f));

    when(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor);

    BitmapDescriptor result = Convert.getBitmapFromBytes(data, 1f, bitmapDescriptorFactoryWrapper);

    Assert.assertEquals(mockBitmapDescriptor, result);
  }

  @Test(expected = IllegalArgumentException.class) // Expecting an IllegalArgumentException
  public void GetBitmapFromBytesThrowsErrorIfInvalidImageData() throws Exception {
    String invalidBase64Image = "not valid image data";
    byte[] bmpData = Base64.decode(invalidBase64Image, Base64.DEFAULT);

    List<?> data = new ArrayList<>(Arrays.asList("bytes", bmpData, "auto", 1.0f));

    verify(bitmapDescriptorFactoryWrapper, never()).fromBitmap(any());

    try {
      Convert.getBitmapFromBytes(data, 1f, bitmapDescriptorFactoryWrapper);
    } catch (IllegalArgumentException e) {
      Assert.assertEquals(e.getMessage(), "Unable to interpret bytes as a valid image.");
      throw e; // rethrow the exception
    }

    fail("Expected an IllegalArgumentException to be thrown");
  }

  private InputStream buildImageInputStream() {
    Bitmap fakeBitmap = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888);
    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
    fakeBitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream);
    byte[] byteArray = byteArrayOutputStream.toByteArray();
    InputStream fakeStream = new ByteArrayInputStream(byteArray);
    return fakeStream;
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
    String base64Image = Base64.encodeToString(pngBytes, Base64.DEFAULT);

    return base64Image;
  }
}
