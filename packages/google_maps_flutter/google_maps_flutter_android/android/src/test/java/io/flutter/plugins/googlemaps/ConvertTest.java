// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static com.google.android.gms.maps.GoogleMap.MAP_TYPE_HYBRID;
import static io.flutter.plugins.googlemaps.Convert.getPinConfigFromPlatformPinConfig;
import static org.junit.Assert.fail;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import android.content.res.AssetManager;
import android.util.Base64;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.GroundOverlay;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.google.android.gms.maps.model.PinConfig;
import com.google.maps.android.clustering.algo.StaticCluster;
import com.google.maps.android.geometry.Point;
import com.google.maps.android.heatmaps.Gradient;
import com.google.maps.android.heatmaps.WeightedLatLng;
import com.google.maps.android.projection.SphericalMercatorProjection;
import io.flutter.plugins.googlemaps.Convert.BitmapDescriptorFactoryWrapper;
import io.flutter.plugins.googlemaps.Convert.FlutterInjectorWrapper;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class ConvertTest {

  @Mock private AssetManager assetManager;

  @Mock private BitmapDescriptorFactoryWrapper bitmapDescriptorFactoryWrapper;

  @Mock private BitmapDescriptor mockBitmapDescriptor;

  @Mock private FlutterInjectorWrapper flutterInjectorWrapper;

  @Mock private GoogleMapOptionsSink optionsSink;

  AutoCloseable mockCloseable;

  // A 1x1 pixel (#8080ff) PNG image encoded in base64
  private final String base64Image = TestImageUtils.generateBase64Image();

  @Before
  public void before() {
    mockCloseable = MockitoAnnotations.openMocks(this);
  }

  @After
  public void tearDown() throws Exception {
    mockCloseable.close();
  }

  @Test
  public void ConvertPointsFromPigeonConvertsThePointsWithFullPrecision() {
    double latitude = 43.03725568057;
    double longitude = -87.90466904649;
    PlatformLatLng platLng = new PlatformLatLng(latitude, longitude);
    List<LatLng> latLngs = Convert.pointsFromPigeon(Collections.singletonList(platLng));
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

    MarkerBuilder marker1 = new MarkerBuilder("m_1", clusterManagerId, PlatformMarkerType.MARKER);
    marker1.setPosition(markerPosition1);
    cluster.add(marker1);

    MarkerBuilder marker2 = new MarkerBuilder("m_2", clusterManagerId, PlatformMarkerType.MARKER);
    marker2.setPosition(markerPosition2);
    cluster.add(marker2);

    PlatformCluster result = Convert.clusterToPigeon(clusterManagerId, cluster);
    Assert.assertEquals(clusterManagerId, result.getClusterManagerId());

    PlatformLatLng position = result.getPosition();
    Assert.assertEquals(clusterPosition.latitude, position.getLatitude(), 1e-15);
    Assert.assertEquals(clusterPosition.longitude, position.getLongitude(), 1e-15);

    PlatformLatLngBounds bounds = result.getBounds();
    PlatformLatLng southwest = bounds.getSouthwest();
    PlatformLatLng northeast = bounds.getNortheast();
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

    when(flutterInjectorWrapper.getLookupKeyForAsset(fakeAssetName)).thenReturn(fakeAssetKey);

    when(assetManager.open(fakeAssetKey)).thenReturn(TestImageUtils.buildImageInputStream());

    when(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor);
    PlatformBitmapAssetMap bitmap =
        new PlatformBitmapAssetMap(
            fakeAssetName,
            PlatformMapBitmapScaling.AUTO,
            /* imagePixelRatio */ 2.0,
            /* width */ 15.0,
            /* height */ 15.0);

    BitmapDescriptor result =
        Convert.getBitmapFromAsset(
            bitmap, assetManager, 1.0f, bitmapDescriptorFactoryWrapper, flutterInjectorWrapper);

    Assert.assertEquals(mockBitmapDescriptor, result);
  }

  @Test
  public void GetBitmapFromAssetAutoAndWidth() throws Exception {
    String fakeAssetName = "fake_asset_name";
    String fakeAssetKey = "fake_asset_key";

    when(flutterInjectorWrapper.getLookupKeyForAsset(fakeAssetName)).thenReturn(fakeAssetKey);

    when(assetManager.open(fakeAssetKey)).thenReturn(TestImageUtils.buildImageInputStream());

    when(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor);
    PlatformBitmapAssetMap bitmap =
        new PlatformBitmapAssetMap(
            fakeAssetName,
            PlatformMapBitmapScaling.AUTO,
            /* imagePixelRatio */ 2.0,
            /* width */ 15.0,
            /* height */ null);

    BitmapDescriptor result =
        Convert.getBitmapFromAsset(
            bitmap, assetManager, 1.0f, bitmapDescriptorFactoryWrapper, flutterInjectorWrapper);

    Assert.assertEquals(mockBitmapDescriptor, result);
  }

  @Test
  public void GetBitmapFromAssetAutoAndHeight() throws Exception {
    String fakeAssetName = "fake_asset_name";
    String fakeAssetKey = "fake_asset_key";

    when(flutterInjectorWrapper.getLookupKeyForAsset(fakeAssetName)).thenReturn(fakeAssetKey);

    when(assetManager.open(fakeAssetKey)).thenReturn(TestImageUtils.buildImageInputStream());

    when(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor);
    PlatformBitmapAssetMap bitmap =
        new PlatformBitmapAssetMap(
            fakeAssetName,
            PlatformMapBitmapScaling.AUTO,
            /* imagePixelRatio */ 2.0,
            /* width */ null,
            /* height */ 15.0);

    BitmapDescriptor result =
        Convert.getBitmapFromAsset(
            bitmap, assetManager, 1.0f, bitmapDescriptorFactoryWrapper, flutterInjectorWrapper);

    Assert.assertEquals(mockBitmapDescriptor, result);
  }

  @Test
  public void GetBitmapFromAssetNoScaling() throws Exception {
    String fakeAssetName = "fake_asset_name";
    String fakeAssetKey = "fake_asset_key";

    when(flutterInjectorWrapper.getLookupKeyForAsset(fakeAssetName)).thenReturn(fakeAssetKey);

    when(assetManager.open(fakeAssetKey)).thenReturn(TestImageUtils.buildImageInputStream());

    when(bitmapDescriptorFactoryWrapper.fromAsset(any())).thenReturn(mockBitmapDescriptor);

    verify(bitmapDescriptorFactoryWrapper, never()).fromBitmap(any());
    PlatformBitmapAssetMap bitmap =
        new PlatformBitmapAssetMap(
            fakeAssetName,
            PlatformMapBitmapScaling.NONE,
            /* imagePixelRatio */ 2.0,
            /* width */ null,
            /* height */ null);

    BitmapDescriptor result =
        Convert.getBitmapFromAsset(
            bitmap, assetManager, 1.0f, bitmapDescriptorFactoryWrapper, flutterInjectorWrapper);

    Assert.assertEquals(mockBitmapDescriptor, result);
  }

  @Test
  public void GetBitmapFromBytesAuto() {
    byte[] bmpData = Base64.decode(base64Image, Base64.DEFAULT);

    when(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor);

    PlatformBitmapBytesMap bitmap =
        new PlatformBitmapBytesMap(
            bmpData,
            PlatformMapBitmapScaling.AUTO,
            /* imagePixelRatio */ 2.0,
            /* width */ null,
            /* height */ null);

    BitmapDescriptor result =
        Convert.getBitmapFromBytes(bitmap, 1f, bitmapDescriptorFactoryWrapper);

    Assert.assertEquals(mockBitmapDescriptor, result);
  }

  @Test
  public void GetBitmapFromBytesAutoAndWidth() {
    byte[] bmpData = Base64.decode(base64Image, Base64.DEFAULT);

    when(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor);
    PlatformBitmapBytesMap bitmap =
        new PlatformBitmapBytesMap(
            bmpData,
            /* bitmapScaling */ PlatformMapBitmapScaling.AUTO,
            /* imagePixelRatio */ 2.0,
            /* width */ 15.0,
            /* height */ null);

    BitmapDescriptor result =
        Convert.getBitmapFromBytes(bitmap, 1f, bitmapDescriptorFactoryWrapper);

    Assert.assertEquals(mockBitmapDescriptor, result);
  }

  @Test
  public void GetBitmapFromBytesAutoAndHeight() {
    byte[] bmpData = Base64.decode(base64Image, Base64.DEFAULT);

    when(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor);
    PlatformBitmapBytesMap bitmap =
        new PlatformBitmapBytesMap(
            bmpData,
            /* bitmapScaling */ PlatformMapBitmapScaling.AUTO,
            /* imagePixelRatio */ 2.0,
            /* width */ null,
            /* height */ 15.0);

    BitmapDescriptor result =
        Convert.getBitmapFromBytes(bitmap, 1f, bitmapDescriptorFactoryWrapper);

    Assert.assertEquals(mockBitmapDescriptor, result);
  }

  @Test
  public void GetBitmapFromBytesNoScaling() {
    byte[] bmpData = Base64.decode(base64Image, Base64.DEFAULT);

    when(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor);
    PlatformBitmapBytesMap bitmap =
        new PlatformBitmapBytesMap(
            bmpData,
            /* bitmapScaling */ PlatformMapBitmapScaling.NONE,
            /* imagePixelRatio */ 2.0,
            /* width */ null,
            /* height */ null);

    BitmapDescriptor result =
        Convert.getBitmapFromBytes(bitmap, 1f, bitmapDescriptorFactoryWrapper);

    Assert.assertEquals(mockBitmapDescriptor, result);
  }

  @Test(expected = IllegalArgumentException.class) // Expecting an IllegalArgumentException
  public void GetBitmapFromBytesThrowsErrorIfInvalidImageData() {
    String invalidBase64Image = "not valid image data";
    byte[] bmpData = Base64.decode(invalidBase64Image, Base64.DEFAULT);

    verify(bitmapDescriptorFactoryWrapper, never()).fromBitmap(any());
    PlatformBitmapBytesMap bitmap =
        new PlatformBitmapBytesMap(
            bmpData,
            /* bitmapScaling */ PlatformMapBitmapScaling.NONE,
            /* imagePixelRatio */ 2.0,
            /* width */ null,
            /* height */ null);

    try {
      Convert.getBitmapFromBytes(bitmap, 1f, bitmapDescriptorFactoryWrapper);
    } catch (IllegalArgumentException e) {
      Assert.assertEquals("Unable to interpret bytes as a valid image.", e.getMessage());
      throw e; // rethrow the exception
    }

    fail("Expected an IllegalArgumentException to be thrown");
  }

  @Test
  public void GetPinConfigFromPlatformPinConfig_GlyphColor() {
    PlatformBitmapPinConfig platformBitmap =
        new PlatformBitmapPinConfig(
            /* backgroundColor */ new PlatformColor(0x00FFFFL),
            /* borderColor */ new PlatformColor(0xFF00FFL),
            /* glyphColor */ new PlatformColor(0x112233L),
            /* glyphBitmap */ null,
            /* glyphText */ null,
            /* glyphTextColor */ null);

    PinConfig pinConfig =
        getPinConfigFromPlatformPinConfig(
            platformBitmap, assetManager, 1, bitmapDescriptorFactoryWrapper);
    Assert.assertEquals(0x00FFFFL, pinConfig.getBackgroundColor());
    Assert.assertEquals(0xFF00FFL, pinConfig.getBorderColor());
    Assert.assertEquals(0x112233L, pinConfig.getGlyph().getGlyphColor());
  }

  @Test
  public void GetPinConfigFromPlatformPinConfig_Glyph() {
    PlatformBitmapPinConfig platformBitmap =
        new PlatformBitmapPinConfig(
            /* backgroundColor */ null,
            /* borderColor */ null,
            /* glyphColor */ null,
            /* glyphBitmap */ null,
            /* glyphText */ "Hi",
            /* glyphTextColor */ new PlatformColor(0xFFFFFFL));
    PinConfig pinConfig =
        getPinConfigFromPlatformPinConfig(
            platformBitmap, assetManager, 1, bitmapDescriptorFactoryWrapper);
    Assert.assertEquals("Hi", pinConfig.getGlyph().getText());
    Assert.assertEquals(0xFFFFFFL, pinConfig.getGlyph().getTextColor());
  }

  @Test
  public void GetPinConfigFromPlatformPinConfig_GlyphBitmap() {
    byte[] bmpData = Base64.decode(base64Image, Base64.DEFAULT);
    PlatformBitmapBytesMap bytesBitmap =
        new PlatformBitmapBytesMap(
            bmpData,
            /* bitmapScaling */ PlatformMapBitmapScaling.AUTO,
            /* imagePixelRatio */ 2.0,
            /* width */ null,
            /* height */ null);
    PlatformBitmap icon = new PlatformBitmap(bytesBitmap);
    PlatformBitmapPinConfig platformBitmap =
        new PlatformBitmapPinConfig(
            /* backgroundColor */ new PlatformColor(0xFFFFFFL),
            /* borderColor */ new PlatformColor(0x000000L),
            /* glyphColor */ null,
            /* glyphBitmap */ icon,
            /* glyphText */ null,
            /* glyphTextColor */ null);
    when(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor);
    PinConfig pinConfig =
        getPinConfigFromPlatformPinConfig(
            platformBitmap, assetManager, 1, bitmapDescriptorFactoryWrapper);

    Assert.assertEquals(0xFFFFFFL, pinConfig.getBackgroundColor());
    Assert.assertEquals(0x000000L, pinConfig.getBorderColor());
    Assert.assertEquals(mockBitmapDescriptor, pinConfig.getGlyph().getBitmapDescriptor());
  }

  ///  Returns a PlatformMapConfiguration.Builder that sets required parameters.
  private PlatformMapConfigurationBuilder getMinimalConfigurationBuilder() {
    return new PlatformMapConfigurationBuilder().setMarkerType(PlatformMarkerType.MARKER);
  }

  @Test
  public void interpretMapConfiguration_handlesNulls() {
    final PlatformMapConfiguration config = getMinimalConfigurationBuilder().build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verifyNoInteractions(optionsSink);
  }

  @Test
  public void interpretMapConfiguration_handlesCompassEnabled() {
    final PlatformMapConfiguration config =
        getMinimalConfigurationBuilder().setCompassEnabled(false).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setCompassEnabled(false);
  }

  @Test
  public void interpretMapConfiguration_handlesMapToolbarEnabled() {
    final PlatformMapConfiguration config =
        getMinimalConfigurationBuilder().setMapToolbarEnabled(true).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setMapToolbarEnabled(true);
  }

  @Test
  public void interpretMapConfiguration_handlesRotateGesturesEnabled() {
    final PlatformMapConfiguration config =
        getMinimalConfigurationBuilder().setRotateGesturesEnabled(false).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setRotateGesturesEnabled(false);
  }

  @Test
  public void interpretMapConfiguration_handlesScrollGesturesEnabled() {
    final PlatformMapConfiguration config =
        getMinimalConfigurationBuilder().setScrollGesturesEnabled(true).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setScrollGesturesEnabled(true);
  }

  @Test
  public void interpretMapConfiguration_handlesTiltGesturesEnabled() {
    final PlatformMapConfiguration config =
        getMinimalConfigurationBuilder().setTiltGesturesEnabled(false).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setTiltGesturesEnabled(false);
  }

  @Test
  public void interpretMapConfiguration_handlesTrackCameraPosition() {
    final PlatformMapConfiguration config =
        getMinimalConfigurationBuilder().setTrackCameraPosition(true).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setTrackCameraPosition(true);
  }

  @Test
  public void interpretMapConfiguration_handlesZoomControlsEnabled() {
    final PlatformMapConfiguration config =
        getMinimalConfigurationBuilder().setZoomControlsEnabled(false).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setZoomControlsEnabled(false);
  }

  @Test
  public void interpretMapConfiguration_handlesZoomGesturesEnabled() {
    final PlatformMapConfiguration config =
        getMinimalConfigurationBuilder().setZoomGesturesEnabled(true).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setZoomGesturesEnabled(true);
  }

  @Test
  public void interpretMapConfiguration_handlesMyLocationEnabled() {
    final PlatformMapConfiguration config =
        getMinimalConfigurationBuilder().setMyLocationEnabled(false).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setMyLocationEnabled(false);
  }

  @Test
  public void interpretMapConfiguration_handlesMyLocationButtonEnabled() {
    final PlatformMapConfiguration config =
        getMinimalConfigurationBuilder().setMyLocationButtonEnabled(true).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setMyLocationButtonEnabled(true);
  }

  @Test
  public void interpretMapConfiguration_handlesIndoorViewEnabled() {
    final PlatformMapConfiguration config =
        getMinimalConfigurationBuilder().setIndoorViewEnabled(false).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setIndoorEnabled(false);
  }

  @Test
  public void interpretMapConfiguration_handlesTrafficEnabled() {
    final PlatformMapConfiguration config =
        getMinimalConfigurationBuilder().setTrafficEnabled(true).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setTrafficEnabled(true);
  }

  @Test
  public void interpretMapConfiguration_handlesBuildingsEnabled() {
    final PlatformMapConfiguration config =
        getMinimalConfigurationBuilder().setBuildingsEnabled(false).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setBuildingsEnabled(false);
  }

  @Test
  public void interpretMapConfiguration_handlesLiteModeEnabled() {
    final PlatformMapConfiguration config =
        getMinimalConfigurationBuilder().setLiteModeEnabled(true).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setLiteModeEnabled(true);
  }

  @Test
  public void interpretMapConfiguration_handlesStyle() {
    final PlatformMapConfiguration config =
        getMinimalConfigurationBuilder().setStyle("foo").build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setMapStyle("foo");
  }

  @Test
  public void interpretMapConfiguration_handlesUnboundedCameraTargetBounds() {
    final PlatformMapConfiguration config =
        getMinimalConfigurationBuilder()
            .setCameraTargetBounds(new PlatformCameraTargetBounds(null))
            .build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setCameraTargetBounds(null);
  }

  @Test
  public void interpretMapConfiguration_handlesBoundedCameraTargetBounds() {
    LatLngBounds bounds = new LatLngBounds(new LatLng(10, 20), new LatLng(30, 40));
    final PlatformMapConfiguration config =
        getMinimalConfigurationBuilder()
            .setCameraTargetBounds(
                new PlatformCameraTargetBounds(
                    new PlatformLatLngBounds(
                        new PlatformLatLng(bounds.northeast.latitude, bounds.northeast.longitude),
                        new PlatformLatLng(bounds.southwest.latitude, bounds.southwest.longitude))))
            .build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setCameraTargetBounds(bounds);
  }

  @Test
  public void interpretMapConfiguration_handlesMapType() {
    final PlatformMapConfiguration config =
        getMinimalConfigurationBuilder().setMapType(PlatformMapType.HYBRID).build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setMapType(MAP_TYPE_HYBRID);
  }

  @Test
  public void interpretMapConfiguration_handlesPadding() {
    final double top = 1.0;
    final double bottom = 2.0;
    final double left = 3.0;
    final double right = 4.0;
    final PlatformMapConfiguration config =
        getMinimalConfigurationBuilder()
            .setPadding(
                new PlatformEdgeInsets(
                    /* top= */ top, /* bottom= */ bottom, /* left= */ left, /* right= */ right))
            .build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1))
        .setPadding((float) top, (float) left, (float) bottom, (float) right);
  }

  @Test
  public void interpretMapConfiguration_handlesMinMaxZoomPreference() {
    final double min = 1.0;
    final double max = 2.0;
    final PlatformMapConfiguration config =
        getMinimalConfigurationBuilder()
            .setMinMaxZoomPreference(new PlatformZoomRange(min, max))
            .build();
    Convert.interpretMapConfiguration(config, optionsSink);
    verify(optionsSink, times(1)).setMinMaxZoomPreference((float) min, (float) max);
  }

  private static final SphericalMercatorProjection sProjection = new SphericalMercatorProjection(1);

  @Test()
  public void ConvertToWeightedLatLngReturnsCorrectData() {
    final double intensity = 3.3;
    final PlatformWeightedLatLng data =
        new PlatformWeightedLatLng(new PlatformLatLng(1.1, 2.2), intensity);
    final Point point = sProjection.toPoint(new LatLng(1.1, 2.2));

    final WeightedLatLng result = Convert.weightedLatLngFromPigeon(data);

    Assert.assertEquals(point.x, result.getPoint().x, 0);
    Assert.assertEquals(point.y, result.getPoint().y, 0);
    Assert.assertEquals(intensity, result.getIntensity(), 0);
  }

  @Test()
  public void ConvertToWeightedDataReturnsCorrectData() {
    final double intensity = 3.3;
    final List<PlatformWeightedLatLng> data =
        List.of(new PlatformWeightedLatLng(new PlatformLatLng(1.1, 2.2), intensity));
    final Point point = sProjection.toPoint(new LatLng(1.1, 2.2));

    final List<WeightedLatLng> result = Convert.weightedDataFromPigeon(data);

    Assert.assertEquals(1, result.size());
    Assert.assertEquals(point.x, result.get(0).getPoint().x, 0);
    Assert.assertEquals(point.y, result.get(0).getPoint().y, 0);
    Assert.assertEquals(intensity, result.get(0).getIntensity(), 0);
  }

  @Test()
  public void ConvertToGradientReturnsCorrectData() {
    final long color1 = 0;
    final long color2 = 1;
    final long color3 = 2;
    final List<PlatformColor> colorData =
        List.of(
            createPlatformColor(color1), createPlatformColor(color2), createPlatformColor(color3));
    final double startPoint1 = 0.0;
    final double startPoint2 = 1.0;
    final double startPoint3 = 2.0;
    List<Double> startPointData = List.of(startPoint1, startPoint2, startPoint3);
    final long colorMapSize = 3;
    final PlatformHeatmapGradient data =
        new PlatformHeatmapGradient(colorData, startPointData, colorMapSize);

    final Gradient result = Convert.gradientFromPigeon(data);

    Assert.assertEquals(3, result.getColors().length);
    Assert.assertEquals(color1, result.getColors()[0]);
    Assert.assertEquals(color2, result.getColors()[1]);
    Assert.assertEquals(color3, result.getColors()[2]);
    Assert.assertEquals(3, result.getStartPoints().length);
    Assert.assertEquals(startPoint1, result.getStartPoints()[0], 0);
    Assert.assertEquals(startPoint2, result.getStartPoints()[1], 0);
    Assert.assertEquals(startPoint3, result.getStartPoints()[2], 0);
    Assert.assertEquals(colorMapSize, result.getColorMapSize());
  }

  @Test()
  public void ConvertInterpretHeatmapOptionsReturnsCorrectData() {
    final double intensity = 3.3;
    final List<PlatformWeightedLatLng> dataData =
        List.of(new PlatformWeightedLatLng(new PlatformLatLng(1.1, 2.2), intensity));
    final Point point = sProjection.toPoint(new LatLng(1.1, 2.2));

    final long color1 = 0;
    final long color2 = 1;
    final long color3 = 2;
    final List<PlatformColor> colorData =
        List.of(
            createPlatformColor(color1), createPlatformColor(color2), createPlatformColor(color3));
    final double startPoint1 = 0.0;
    final double startPoint2 = 1.0;
    final double startPoint3 = 2.0;
    List<Double> startPointData = List.of(startPoint1, startPoint2, startPoint3);
    final long colorMapSize = 3;
    final PlatformHeatmapGradient gradientData =
        new PlatformHeatmapGradient(colorData, startPointData, colorMapSize);

    final double maxIntensity = 4.0;
    final double opacity = 5.5;
    final long radius = 6;
    final String idData = "heatmap_1";

    final PlatformHeatmap data =
        new PlatformHeatmap(
            idData,
            dataData,
            gradientData,
            /* opacity */ opacity,
            /* radius */ radius,
            /* maxIntensity */ maxIntensity);

    final MockHeatmapBuilder builder = new MockHeatmapBuilder();
    final String id = Convert.interpretHeatmapOptions(data, builder);

    Assert.assertEquals(1, builder.getWeightedData().size());
    Assert.assertEquals(point.x, builder.getWeightedData().get(0).getPoint().x, 0);
    Assert.assertEquals(point.y, builder.getWeightedData().get(0).getPoint().y, 0);
    Assert.assertEquals(intensity, builder.getWeightedData().get(0).getIntensity(), 0);
    Assert.assertEquals(3, builder.getGradient().getColors().length);
    Assert.assertEquals(color1, builder.getGradient().getColors()[0]);
    Assert.assertEquals(color2, builder.getGradient().getColors()[1]);
    Assert.assertEquals(color3, builder.getGradient().getColors()[2]);
    Assert.assertEquals(3, builder.getGradient().getStartPoints().length);
    Assert.assertEquals(startPoint1, builder.getGradient().getStartPoints()[0], 0);
    Assert.assertEquals(startPoint2, builder.getGradient().getStartPoints()[1], 0);
    Assert.assertEquals(startPoint3, builder.getGradient().getStartPoints()[2], 0);
    Assert.assertEquals(colorMapSize, builder.getGradient().getColorMapSize());
    Assert.assertEquals(maxIntensity, builder.getMaxIntensity(), 0);
    Assert.assertEquals(opacity, builder.getOpacity(), 0);
    Assert.assertEquals(radius, builder.getRadius());
    Assert.assertEquals(idData, id);
  }

  private PlatformColor createPlatformColor(long rgba) {
    return new PlatformColor(rgba);
  }

  @Test
  public void buildGroundOverlayAnchorForPigeonWithNonCrossingMeridian() {
    LatLng position = new LatLng(10, 20);
    LatLng southwest = new LatLng(5, 15);
    LatLng northeast = new LatLng(15, 25);
    LatLngBounds bounds = new LatLngBounds(southwest, northeast);
    GroundOverlay groundOverlay = mock(GroundOverlay.class);
    when(groundOverlay.getPosition()).thenReturn(position);
    when(groundOverlay.getBounds()).thenReturn(bounds);

    PlatformDoublePair anchor = Convert.buildGroundOverlayAnchorForPigeon(groundOverlay);

    Assert.assertEquals(0.5, anchor.getX(), 1e-15);
    Assert.assertEquals(0.5, anchor.getY(), 1e-15);
  }

  @Test
  public void buildGroundOverlayAnchorForPigeonWithCrossingMeridian() {
    LatLng position = new LatLng(10, -175);
    LatLng southwest = new LatLng(5, 170);
    LatLng northeast = new LatLng(15, -160);
    LatLngBounds bounds = new LatLngBounds(southwest, northeast);
    GroundOverlay groundOverlay = mock(GroundOverlay.class);
    when(groundOverlay.getPosition()).thenReturn(position);
    when(groundOverlay.getBounds()).thenReturn(bounds);

    PlatformDoublePair anchor = Convert.buildGroundOverlayAnchorForPigeon(groundOverlay);

    Assert.assertEquals(0.5, anchor.getX(), 1e-15);
    Assert.assertEquals(0.5, anchor.getY(), 1e-15);
  }

  private void assertGroundOverlayEquals(
      PlatformGroundOverlay result,
      GroundOverlay expectedOverlay,
      String expectedId,
      LatLng expectedPosition,
      LatLngBounds expectedBounds) {
    Assert.assertEquals(expectedId, result.getGroundOverlayId());
    if (expectedPosition != null) {
      Assert.assertNotNull(result.getPosition());
      Assert.assertEquals(expectedPosition.latitude, result.getPosition().getLatitude(), 1e-15);
      Assert.assertEquals(expectedPosition.longitude, result.getPosition().getLongitude(), 1e-15);
      Assert.assertNotNull(result.getWidth());
      Assert.assertNotNull(result.getHeight());
      Assert.assertEquals(expectedOverlay.getWidth(), result.getWidth(), 1e-15);
      Assert.assertEquals(expectedOverlay.getHeight(), result.getHeight(), 1e-15);
    } else {
      Assert.assertNull(result.getPosition());
    }
    if (expectedBounds != null) {
      Assert.assertNotNull(result.getBounds());
      Assert.assertEquals(
          expectedBounds.southwest.latitude,
          result.getBounds().getSouthwest().getLatitude(),
          1e-15);
      Assert.assertEquals(
          expectedBounds.southwest.longitude,
          result.getBounds().getSouthwest().getLongitude(),
          1e-15);
      Assert.assertEquals(
          expectedBounds.northeast.latitude,
          result.getBounds().getNortheast().getLatitude(),
          1e-15);
      Assert.assertEquals(
          expectedBounds.northeast.longitude,
          result.getBounds().getNortheast().getLongitude(),
          1e-15);
    } else {
      Assert.assertNull(result.getBounds());
    }

    Assert.assertEquals(expectedOverlay.getBearing(), result.getBearing(), 1e-15);
    Assert.assertEquals(expectedOverlay.getTransparency(), result.getTransparency(), 1e-6);
    Assert.assertEquals(expectedOverlay.getZIndex(), result.getZIndex(), 1e-6);
    Assert.assertEquals(expectedOverlay.isVisible(), result.getVisible());
    Assert.assertEquals(expectedOverlay.isClickable(), result.getClickable());
    PlatformDoublePair anchor = result.getAnchor();
    Assert.assertNotNull(anchor);
    Assert.assertEquals(0.5, anchor.getX(), 1e-6);
    Assert.assertEquals(0.5, anchor.getY(), 1e-6);
  }

  @Test
  public void groundOverlayToPigeonWithPosition() {
    GroundOverlay mockGroundOverlay = mock(GroundOverlay.class);
    LatLng position = new LatLng(10, 20);
    LatLng southwest = new LatLng(5, 15);
    LatLng northeast = new LatLng(15, 25);
    LatLngBounds bounds = new LatLngBounds(southwest, northeast);
    when(mockGroundOverlay.getPosition()).thenReturn(position);
    when(mockGroundOverlay.getBounds()).thenReturn(bounds);
    when(mockGroundOverlay.getWidth()).thenReturn(30f);
    when(mockGroundOverlay.getHeight()).thenReturn(40f);
    when(mockGroundOverlay.getBearing()).thenReturn(50f);
    when(mockGroundOverlay.getTransparency()).thenReturn(0.6f);
    when(mockGroundOverlay.getZIndex()).thenReturn(7f);
    when(mockGroundOverlay.isVisible()).thenReturn(true);
    when(mockGroundOverlay.isClickable()).thenReturn(false);

    String overlayId = "overlay_1";
    PlatformGroundOverlay result =
        Convert.groundOverlayToPigeon(mockGroundOverlay, overlayId, false);

    assertGroundOverlayEquals(result, mockGroundOverlay, overlayId, position, null);
  }

  @Test
  public void groundOverlayToPigeonWithBounds() {
    GroundOverlay mockGroundOverlay = mock(GroundOverlay.class);
    LatLng position = new LatLng(10, 20);
    LatLng southwest = new LatLng(5, 15);
    LatLng northeast = new LatLng(15, 25);
    LatLngBounds bounds = new LatLngBounds(southwest, northeast);
    when(mockGroundOverlay.getPosition()).thenReturn(position);
    when(mockGroundOverlay.getBounds()).thenReturn(bounds);
    when(mockGroundOverlay.getWidth()).thenReturn(30f);
    when(mockGroundOverlay.getHeight()).thenReturn(40f);
    when(mockGroundOverlay.getBearing()).thenReturn(50f);
    when(mockGroundOverlay.getTransparency()).thenReturn(0.6f);
    when(mockGroundOverlay.getZIndex()).thenReturn(7f);
    when(mockGroundOverlay.isVisible()).thenReturn(true);
    when(mockGroundOverlay.isClickable()).thenReturn(false);

    String overlayId = "overlay_2";
    PlatformGroundOverlay result =
        Convert.groundOverlayToPigeon(mockGroundOverlay, overlayId, true);

    assertGroundOverlayEquals(result, mockGroundOverlay, overlayId, null, bounds);
  }

  // Remove this if builders are added to the Kotlin generator; see discussion in
  // https://github.com/flutter/flutter/issues/158287
  private static final class PlatformMapConfigurationBuilder {
    private @Nullable Boolean compassEnabled;
    private @Nullable PlatformCameraTargetBounds cameraTargetBounds;
    private @Nullable PlatformMapType mapType;
    private @Nullable PlatformZoomRange minMaxZoomPreference;
    private @Nullable Boolean mapToolbarEnabled;
    private @Nullable Boolean rotateGesturesEnabled;
    private @Nullable Boolean scrollGesturesEnabled;
    private @Nullable Boolean tiltGesturesEnabled;
    private @Nullable Boolean trackCameraPosition;
    private @Nullable Boolean zoomControlsEnabled;
    private @Nullable Boolean zoomGesturesEnabled;
    private @Nullable Boolean myLocationEnabled;
    private @Nullable Boolean myLocationButtonEnabled;
    private @Nullable PlatformEdgeInsets padding;
    private @Nullable Boolean indoorViewEnabled;
    private @Nullable Boolean trafficEnabled;
    private @Nullable Boolean buildingsEnabled;
    private @Nullable Boolean liteModeEnabled;
    private @Nullable PlatformMarkerType markerType;
    private @Nullable String mapId;
    private @Nullable String style;

    public @NonNull PlatformMapConfigurationBuilder setCompassEnabled(@Nullable Boolean setterArg) {
      this.compassEnabled = setterArg;
      return this;
    }

    public @NonNull PlatformMapConfigurationBuilder setCameraTargetBounds(
        @Nullable PlatformCameraTargetBounds setterArg) {
      this.cameraTargetBounds = setterArg;
      return this;
    }

    public @NonNull PlatformMapConfigurationBuilder setMapType(
        @Nullable PlatformMapType setterArg) {
      this.mapType = setterArg;
      return this;
    }

    public @NonNull PlatformMapConfigurationBuilder setMinMaxZoomPreference(
        @Nullable PlatformZoomRange setterArg) {
      this.minMaxZoomPreference = setterArg;
      return this;
    }

    public @NonNull PlatformMapConfigurationBuilder setMapToolbarEnabled(
        @Nullable Boolean setterArg) {
      this.mapToolbarEnabled = setterArg;
      return this;
    }

    public @NonNull PlatformMapConfigurationBuilder setRotateGesturesEnabled(
        @Nullable Boolean setterArg) {
      this.rotateGesturesEnabled = setterArg;
      return this;
    }

    public @NonNull PlatformMapConfigurationBuilder setScrollGesturesEnabled(
        @Nullable Boolean setterArg) {
      this.scrollGesturesEnabled = setterArg;
      return this;
    }

    public @NonNull PlatformMapConfigurationBuilder setTiltGesturesEnabled(
        @Nullable Boolean setterArg) {
      this.tiltGesturesEnabled = setterArg;
      return this;
    }

    public @NonNull PlatformMapConfigurationBuilder setTrackCameraPosition(
        @Nullable Boolean setterArg) {
      this.trackCameraPosition = setterArg;
      return this;
    }

    public @NonNull PlatformMapConfigurationBuilder setZoomControlsEnabled(
        @Nullable Boolean setterArg) {
      this.zoomControlsEnabled = setterArg;
      return this;
    }

    public @NonNull PlatformMapConfigurationBuilder setZoomGesturesEnabled(
        @Nullable Boolean setterArg) {
      this.zoomGesturesEnabled = setterArg;
      return this;
    }

    public @NonNull PlatformMapConfigurationBuilder setMyLocationEnabled(
        @Nullable Boolean setterArg) {
      this.myLocationEnabled = setterArg;
      return this;
    }

    public @NonNull PlatformMapConfigurationBuilder setMyLocationButtonEnabled(
        @Nullable Boolean setterArg) {
      this.myLocationButtonEnabled = setterArg;
      return this;
    }

    public @NonNull PlatformMapConfigurationBuilder setPadding(
        @Nullable PlatformEdgeInsets setterArg) {
      this.padding = setterArg;
      return this;
    }

    public @NonNull PlatformMapConfigurationBuilder setIndoorViewEnabled(
        @Nullable Boolean setterArg) {
      this.indoorViewEnabled = setterArg;
      return this;
    }

    public @NonNull PlatformMapConfigurationBuilder setTrafficEnabled(@Nullable Boolean setterArg) {
      this.trafficEnabled = setterArg;
      return this;
    }

    public @NonNull PlatformMapConfigurationBuilder setBuildingsEnabled(
        @Nullable Boolean setterArg) {
      this.buildingsEnabled = setterArg;
      return this;
    }

    public @NonNull PlatformMapConfigurationBuilder setLiteModeEnabled(
        @Nullable Boolean setterArg) {
      this.liteModeEnabled = setterArg;
      return this;
    }

    public @NonNull PlatformMapConfigurationBuilder setMarkerType(
        @NonNull PlatformMarkerType setterArg) {
      this.markerType = setterArg;
      return this;
    }

    public @NonNull PlatformMapConfigurationBuilder setMapId(@Nullable String setterArg) {
      this.mapId = setterArg;
      return this;
    }

    public @NonNull PlatformMapConfigurationBuilder setStyle(@Nullable String setterArg) {
      this.style = setterArg;
      return this;
    }

    public @NonNull PlatformMapConfiguration build() {
      return new PlatformMapConfiguration(
          compassEnabled,
          cameraTargetBounds,
          mapType,
          minMaxZoomPreference,
          mapToolbarEnabled,
          rotateGesturesEnabled,
          scrollGesturesEnabled,
          tiltGesturesEnabled,
          trackCameraPosition,
          zoomControlsEnabled,
          zoomGesturesEnabled,
          myLocationEnabled,
          myLocationButtonEnabled,
          padding,
          indoorViewEnabled,
          trafficEnabled,
          buildingsEnabled,
          liteModeEnabled,
          Objects.requireNonNull(markerType),
          mapId,
          style);
    }
  }
}

class MockHeatmapBuilder implements HeatmapOptionsSink {
  private List<WeightedLatLng> weightedData;
  private Gradient gradient;
  private double maxIntensity;
  private double opacity;
  private int radius;

  public List<WeightedLatLng> getWeightedData() {
    return weightedData;
  }

  public Gradient getGradient() {
    return gradient;
  }

  public double getMaxIntensity() {
    return maxIntensity;
  }

  public double getOpacity() {
    return opacity;
  }

  public int getRadius() {
    return radius;
  }

  @Override
  public void setWeightedData(@NonNull List<WeightedLatLng> weightedData) {
    this.weightedData = weightedData;
  }

  @Override
  public void setGradient(@NonNull Gradient gradient) {
    this.gradient = gradient;
  }

  @Override
  public void setMaxIntensity(double maxIntensity) {
    this.maxIntensity = maxIntensity;
  }

  @Override
  public void setOpacity(double opacity) {
    this.opacity = opacity;
  }

  @Override
  public void setRadius(int radius) {
    this.radius = radius;
  }
}
