// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.googlemaps

import android.content.res.AssetManager
import android.util.Base64
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.model.BitmapDescriptor
import com.google.android.gms.maps.model.GroundOverlay
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.LatLngBounds
import com.google.maps.android.clustering.algo.StaticCluster
import com.google.maps.android.geometry.Point
import com.google.maps.android.heatmaps.Gradient
import com.google.maps.android.heatmaps.WeightedLatLng
import com.google.maps.android.projection.SphericalMercatorProjection
import io.flutter.plugins.googlemaps.Convert.BitmapDescriptorFactoryWrapper
import io.flutter.plugins.googlemaps.Convert.FlutterInjectorWrapper
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.any
import org.mockito.kotlin.mock
import org.mockito.kotlin.never
import org.mockito.kotlin.times
import org.mockito.kotlin.verify
import org.mockito.kotlin.verifyNoInteractions
import org.mockito.kotlin.whenever
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ConvertTest {
  private val assetManager: AssetManager = mock()

  private val bitmapDescriptorFactoryWrapper: BitmapDescriptorFactoryWrapper = mock()

  private val mockBitmapDescriptor: BitmapDescriptor = mock()

  private val flutterInjectorWrapper: FlutterInjectorWrapper = mock()

  private val optionsSink: GoogleMapOptionsSink = mock()

  // A 1x1 pixel (#8080ff) PNG image encoded in base64
  private val base64Image: String? = TestImageUtils.generateBase64Image()

  @Test
  fun convertPointsFromPigeonConvertsThePointsWithFullPrecision() {
    val latitude = 43.03725568057
    val longitude = -87.90466904649
    val platLng = PlatformLatLng(latitude, longitude)
    val latLngs = Convert.pointsFromPigeon(listOf(platLng))
    val latLng = latLngs[0]
    Assert.assertEquals(latitude, latLng.latitude, 1e-15)
    Assert.assertEquals(longitude, latLng.longitude, 1e-15)
  }

  @Test
  fun convertClusterToPigeonReturnsCorrectData() {
    val clusterManagerId = "cm_1"
    val clusterPosition = LatLng(43.00, -87.90)
    val markerPosition1 = LatLng(43.05, -87.95)
    val markerPosition2 = LatLng(43.02, -87.92)

    val cluster = StaticCluster<MarkerBuilder>(clusterPosition)

    val marker1 = MarkerBuilder("m_1", clusterManagerId, PlatformMarkerType.MARKER)
    marker1.position = markerPosition1
    cluster.add(marker1)

    val marker2 = MarkerBuilder("m_2", clusterManagerId, PlatformMarkerType.MARKER)
    marker2.position = markerPosition2
    cluster.add(marker2)

    val result = Convert.clusterToPigeon(clusterManagerId, cluster)
    Assert.assertEquals(clusterManagerId, result.clusterManagerId)

    val position = result.position
    Assert.assertEquals(clusterPosition.latitude, position.latitude, 1e-15)
    Assert.assertEquals(clusterPosition.longitude, position.longitude, 1e-15)

    val bounds = result.bounds
    val southwest = bounds.southwest
    val northeast = bounds.northeast
    // bounding data should combine data from marker positions markerPosition1 and markerPosition2
    Assert.assertEquals(markerPosition2.latitude, southwest.latitude, 1e-15)
    Assert.assertEquals(markerPosition1.longitude, southwest.longitude, 1e-15)
    Assert.assertEquals(markerPosition1.latitude, northeast.latitude, 1e-15)
    Assert.assertEquals(markerPosition2.longitude, northeast.longitude, 1e-15)

    val markerIds = result.markerIds
    Assert.assertEquals(2, markerIds.size.toLong())
    Assert.assertEquals(marker1.markerId(), markerIds[0])
    Assert.assertEquals(marker2.markerId(), markerIds[1])
  }

  @Test
  @Throws(Exception::class)
  fun getBitmapFromAssetAuto() {
    val fakeAssetName = "fake_asset_name"
    val fakeAssetKey = "fake_asset_key"

    whenever(flutterInjectorWrapper.getLookupKeyForAsset(fakeAssetName)).thenReturn(fakeAssetKey)

    whenever(assetManager.open(fakeAssetKey)).thenReturn(TestImageUtils.buildImageInputStream())

    whenever(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor)
    val bitmap =
        PlatformBitmapAssetMap(
            fakeAssetName,
            PlatformMapBitmapScaling.AUTO,
            imagePixelRatio = 2.0,
            width = 15.0,
            height = 15.0)

    val result =
        Convert.getBitmapFromAsset(
            bitmap, assetManager, 1.0f, bitmapDescriptorFactoryWrapper, flutterInjectorWrapper)

    Assert.assertEquals(mockBitmapDescriptor, result)
  }

  @Test
  @Throws(Exception::class)
  fun getBitmapFromAssetAutoAndWidth() {
    val fakeAssetName = "fake_asset_name"
    val fakeAssetKey = "fake_asset_key"

    whenever(flutterInjectorWrapper.getLookupKeyForAsset(fakeAssetName)).thenReturn(fakeAssetKey)

    whenever(assetManager.open(fakeAssetKey)).thenReturn(TestImageUtils.buildImageInputStream())

    whenever(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor)
    val bitmap =
        PlatformBitmapAssetMap(
            fakeAssetName,
            PlatformMapBitmapScaling.AUTO,
            imagePixelRatio = 2.0,
            width = 15.0,
            height = null)

    val result =
        Convert.getBitmapFromAsset(
            bitmap, assetManager, 1.0f, bitmapDescriptorFactoryWrapper, flutterInjectorWrapper)

    Assert.assertEquals(mockBitmapDescriptor, result)
  }

  @Test
  @Throws(Exception::class)
  fun getBitmapFromAssetAutoAndHeight() {
    val fakeAssetName = "fake_asset_name"
    val fakeAssetKey = "fake_asset_key"

    whenever(flutterInjectorWrapper.getLookupKeyForAsset(fakeAssetName)).thenReturn(fakeAssetKey)

    whenever(assetManager.open(fakeAssetKey)).thenReturn(TestImageUtils.buildImageInputStream())

    whenever(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor)
    val bitmap =
        PlatformBitmapAssetMap(
            fakeAssetName,
            PlatformMapBitmapScaling.AUTO,
            imagePixelRatio = 2.0,
            width = null,
            height = 15.0)

    val result =
        Convert.getBitmapFromAsset(
            bitmap, assetManager, 1.0f, bitmapDescriptorFactoryWrapper, flutterInjectorWrapper)

    Assert.assertEquals(mockBitmapDescriptor, result)
  }

  @Test
  @Throws(Exception::class)
  fun getBitmapFromAssetNoScaling() {
    val fakeAssetName = "fake_asset_name"
    val fakeAssetKey = "fake_asset_key"

    whenever(flutterInjectorWrapper.getLookupKeyForAsset(fakeAssetName)).thenReturn(fakeAssetKey)

    whenever(assetManager.open(fakeAssetKey)).thenReturn(TestImageUtils.buildImageInputStream())

    whenever(bitmapDescriptorFactoryWrapper.fromAsset(any())).thenReturn(mockBitmapDescriptor)

    verify(bitmapDescriptorFactoryWrapper, never()).fromBitmap(any())
    val bitmap =
        PlatformBitmapAssetMap(
            fakeAssetName,
            PlatformMapBitmapScaling.NONE,
            imagePixelRatio = 2.0,
            width = null,
            height = null)

    val result =
        Convert.getBitmapFromAsset(
            bitmap, assetManager, 1.0f, bitmapDescriptorFactoryWrapper, flutterInjectorWrapper)

    Assert.assertEquals(mockBitmapDescriptor, result)
  }

  @Test
  fun getBitmapFromBytesAuto() {
    val bmpData = Base64.decode(base64Image, Base64.DEFAULT)

    whenever(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor)

    val bitmap =
        PlatformBitmapBytesMap(
            bmpData,
            PlatformMapBitmapScaling.AUTO,
            imagePixelRatio = 2.0,
            width = null,
            height = null)

    val result = Convert.getBitmapFromBytes(bitmap, 1f, bitmapDescriptorFactoryWrapper)

    Assert.assertEquals(mockBitmapDescriptor, result)
  }

  @Test
  fun getBitmapFromBytesAutoAndWidth() {
    val bmpData = Base64.decode(base64Image, Base64.DEFAULT)

    whenever(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor)
    val bitmap =
        PlatformBitmapBytesMap(
            bmpData,
            bitmapScaling = PlatformMapBitmapScaling.AUTO,
            imagePixelRatio = 2.0,
            width = 15.0,
            height = null)

    val result = Convert.getBitmapFromBytes(bitmap, 1f, bitmapDescriptorFactoryWrapper)

    Assert.assertEquals(mockBitmapDescriptor, result)
  }

  @Test
  fun getBitmapFromBytesAutoAndHeight() {
    val bmpData = Base64.decode(base64Image, Base64.DEFAULT)

    whenever(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor)
    val bitmap =
        PlatformBitmapBytesMap(
            bmpData,
            bitmapScaling = PlatformMapBitmapScaling.AUTO,
            imagePixelRatio = 2.0,
            width = null,
            height = 15.0)

    val result = Convert.getBitmapFromBytes(bitmap, 1f, bitmapDescriptorFactoryWrapper)

    Assert.assertEquals(mockBitmapDescriptor, result)
  }

  @Test
  fun getBitmapFromBytesNoScaling() {
    val bmpData = Base64.decode(base64Image, Base64.DEFAULT)

    whenever(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor)
    val bitmap =
        PlatformBitmapBytesMap(
            bmpData,
            bitmapScaling = PlatformMapBitmapScaling.NONE,
            imagePixelRatio = 2.0,
            width = null,
            height = null)

    val result = Convert.getBitmapFromBytes(bitmap, 1f, bitmapDescriptorFactoryWrapper)

    Assert.assertEquals(mockBitmapDescriptor, result)
  }

  @Test(expected = IllegalArgumentException::class) // Expecting an IllegalArgumentException
  fun getBitmapFromBytesThrowsErrorIfInvalidImageData() {
    val invalidBase64Image = "not valid image data"
    val bmpData = Base64.decode(invalidBase64Image, Base64.DEFAULT)

    verify(bitmapDescriptorFactoryWrapper, never()).fromBitmap(any())
    val bitmap =
        PlatformBitmapBytesMap(
            bmpData,
            bitmapScaling = PlatformMapBitmapScaling.NONE,
            imagePixelRatio = 2.0,
            width = null,
            height = null)

    try {
      Convert.getBitmapFromBytes(bitmap, 1f, bitmapDescriptorFactoryWrapper)
    } catch (e: IllegalArgumentException) {
      Assert.assertEquals("Unable to interpret bytes as a valid image.", e.message)
      throw e // rethrow the exception
    }

    Assert.fail("Expected an IllegalArgumentException to be thrown")
  }

  @Test
  fun getPinConfigFromPlatformPinConfig_GlyphColor() {
    val platformBitmap =
        PlatformBitmapPinConfig(
            backgroundColor = PlatformColor(0x00FFFFL),
            borderColor = PlatformColor(0xFF00FFL),
            glyphColor = PlatformColor(0x112233L),
            glyphBitmap = null,
            glyphText = null,
            glyphTextColor = null)

    val pinConfig =
        Convert.getPinConfigFromPlatformPinConfig(
            platformBitmap, assetManager, 1f, bitmapDescriptorFactoryWrapper)
    Assert.assertEquals(0x00FFFFL, pinConfig.backgroundColor.toLong())
    Assert.assertEquals(0xFF00FFL, pinConfig.borderColor.toLong())
    Assert.assertEquals(0x112233L, pinConfig.glyph.glyphColor.toLong())
  }

  @Test
  fun getPinConfigFromPlatformPinConfig_Glyph() {
    val platformBitmap =
        PlatformBitmapPinConfig(
            backgroundColor = null,
            borderColor = null,
            glyphColor = null,
            glyphBitmap = null,
            glyphText = "Hi",
            glyphTextColor = PlatformColor(0xFFFFFFL))
    val pinConfig =
        Convert.getPinConfigFromPlatformPinConfig(
            platformBitmap, assetManager, 1f, bitmapDescriptorFactoryWrapper)
    Assert.assertEquals("Hi", pinConfig.glyph.text)
    Assert.assertEquals(0xFFFFFFL, pinConfig.glyph.textColor.toLong())
  }

  @Test
  fun getPinConfigFromPlatformPinConfig_GlyphBitmap() {
    val bmpData = Base64.decode(base64Image, Base64.DEFAULT)
    val bytesBitmap =
        PlatformBitmapBytesMap(
            bmpData,
            bitmapScaling = PlatformMapBitmapScaling.AUTO,
            imagePixelRatio = 2.0,
            width = null,
            height = null)
    val icon = PlatformBitmap(bytesBitmap)
    val platformBitmap =
        PlatformBitmapPinConfig(
            backgroundColor = PlatformColor(0xFFFFFFL),
            borderColor = PlatformColor(0x000000L),
            glyphColor = null,
            glyphBitmap = icon,
            glyphText = null,
            glyphTextColor = null)
    whenever(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor)
    val pinConfig =
        Convert.getPinConfigFromPlatformPinConfig(
            platformBitmap, assetManager, 1f, bitmapDescriptorFactoryWrapper)

    Assert.assertEquals(0xFFFFFFL, pinConfig.backgroundColor.toLong())
    Assert.assertEquals(0x000000L, pinConfig.borderColor.toLong())
    Assert.assertEquals(mockBitmapDescriptor, pinConfig.glyph.bitmapDescriptor)
  }

  private val minimalConfigurationBuilder: PlatformMapConfigurationBuilder
    /** Returns a PlatformMapConfiguration.Builder that sets required parameters. */
    get() = PlatformMapConfigurationBuilder().setMarkerType(PlatformMarkerType.MARKER)

  @Test
  fun interpretMapConfiguration_handlesNulls() {
    val config = this.minimalConfigurationBuilder.build()
    Convert.interpretMapConfiguration(config, optionsSink)
    verifyNoInteractions(optionsSink)
  }

  @Test
  fun interpretMapConfiguration_handlesCompassEnabled() {
    val config = this.minimalConfigurationBuilder.setCompassEnabled(false).build()
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setCompassEnabled(false)
  }

  @Test
  fun interpretMapConfiguration_handlesMapToolbarEnabled() {
    val config = this.minimalConfigurationBuilder.setMapToolbarEnabled(true).build()
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setMapToolbarEnabled(true)
  }

  @Test
  fun interpretMapConfiguration_handlesRotateGesturesEnabled() {
    val config = this.minimalConfigurationBuilder.setRotateGesturesEnabled(false).build()
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setRotateGesturesEnabled(false)
  }

  @Test
  fun interpretMapConfiguration_handlesScrollGesturesEnabled() {
    val config = this.minimalConfigurationBuilder.setScrollGesturesEnabled(true).build()
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setScrollGesturesEnabled(true)
  }

  @Test
  fun interpretMapConfiguration_handlesTiltGesturesEnabled() {
    val config = this.minimalConfigurationBuilder.setTiltGesturesEnabled(false).build()
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setTiltGesturesEnabled(false)
  }

  @Test
  fun interpretMapConfiguration_handlesTrackCameraPosition() {
    val config = this.minimalConfigurationBuilder.setTrackCameraPosition(true).build()
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setTrackCameraPosition(true)
  }

  @Test
  fun interpretMapConfiguration_handlesZoomControlsEnabled() {
    val config = this.minimalConfigurationBuilder.setZoomControlsEnabled(false).build()
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setZoomControlsEnabled(false)
  }

  @Test
  fun interpretMapConfiguration_handlesZoomGesturesEnabled() {
    val config = this.minimalConfigurationBuilder.setZoomGesturesEnabled(true).build()
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setZoomGesturesEnabled(true)
  }

  @Test
  fun interpretMapConfiguration_handlesMyLocationEnabled() {
    val config = this.minimalConfigurationBuilder.setMyLocationEnabled(false).build()
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setMyLocationEnabled(false)
  }

  @Test
  fun interpretMapConfiguration_handlesMyLocationButtonEnabled() {
    val config = this.minimalConfigurationBuilder.setMyLocationButtonEnabled(true).build()
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setMyLocationButtonEnabled(true)
  }

  @Test
  fun interpretMapConfiguration_handlesIndoorViewEnabled() {
    val config = this.minimalConfigurationBuilder.setIndoorViewEnabled(false).build()
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setIndoorEnabled(false)
  }

  @Test
  fun interpretMapConfiguration_handlesTrafficEnabled() {
    val config = this.minimalConfigurationBuilder.setTrafficEnabled(true).build()
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setTrafficEnabled(true)
  }

  @Test
  fun interpretMapConfiguration_handlesBuildingsEnabled() {
    val config = this.minimalConfigurationBuilder.setBuildingsEnabled(false).build()
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setBuildingsEnabled(false)
  }

  @Test
  fun interpretMapConfiguration_handlesLiteModeEnabled() {
    val config = this.minimalConfigurationBuilder.setLiteModeEnabled(true).build()
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setLiteModeEnabled(true)
  }

  @Test
  fun interpretMapConfiguration_handlesStyle() {
    val config = this.minimalConfigurationBuilder.setStyle("foo").build()
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setMapStyle("foo")
  }

  @Test
  fun interpretMapConfiguration_handlesUnboundedCameraTargetBounds() {
    val config =
        this.minimalConfigurationBuilder
            .setCameraTargetBounds(PlatformCameraTargetBounds(null))
            .build()
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setCameraTargetBounds(null)
  }

  @Test
  fun interpretMapConfiguration_handlesBoundedCameraTargetBounds() {
    val bounds = LatLngBounds(LatLng(10.0, 20.0), LatLng(30.0, 40.0))
    val config =
        this.minimalConfigurationBuilder
            .setCameraTargetBounds(
                PlatformCameraTargetBounds(
                    PlatformLatLngBounds(
                        PlatformLatLng(bounds.northeast.latitude, bounds.northeast.longitude),
                        PlatformLatLng(bounds.southwest.latitude, bounds.southwest.longitude))))
            .build()
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setCameraTargetBounds(bounds)
  }

  @Test
  fun interpretMapConfiguration_handlesMapType() {
    val config = this.minimalConfigurationBuilder.setMapType(PlatformMapType.HYBRID).build()
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setMapType(GoogleMap.MAP_TYPE_HYBRID)
  }

  @Test
  fun interpretMapConfiguration_handlesPadding() {
    val top = 1.0
    val bottom = 2.0
    val left = 3.0
    val right = 4.0
    val config =
        this.minimalConfigurationBuilder
            .setPadding(PlatformEdgeInsets(top = top, bottom = bottom, left = left, right = right))
            .build()
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1))
        .setPadding(top.toFloat(), left.toFloat(), bottom.toFloat(), right.toFloat())
  }

  @Test
  fun interpretMapConfiguration_handlesMinMaxZoomPreference() {
    val min = 1.0
    val max = 2.0
    val config =
        this.minimalConfigurationBuilder
            .setMinMaxZoomPreference(PlatformZoomRange(min, max))
            .build()
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setMinMaxZoomPreference(min.toFloat(), max.toFloat())
  }

  @Test
  fun convertToWeightedLatLngReturnsCorrectData() {
    val intensity = 3.3
    val data = PlatformWeightedLatLng(PlatformLatLng(1.1, 2.2), intensity)
    val point: Point = sProjection.toPoint(LatLng(1.1, 2.2))

    val result = Convert.weightedLatLngFromPigeon(data)

    Assert.assertEquals(point.x, result.point.x, 0.0)
    Assert.assertEquals(point.y, result.point.y, 0.0)
    Assert.assertEquals(intensity, result.intensity, 0.0)
  }

  @Test
  fun convertToWeightedDataReturnsCorrectData() {
    val intensity = 3.3
    val data = listOf(PlatformWeightedLatLng(PlatformLatLng(1.1, 2.2), intensity))
    val point: Point = sProjection.toPoint(LatLng(1.1, 2.2))

    val result = Convert.weightedDataFromPigeon(data)

    Assert.assertEquals(1, result.size.toLong())
    Assert.assertEquals(point.x, result[0].point.x, 0.0)
    Assert.assertEquals(point.y, result[0].point.y, 0.0)
    Assert.assertEquals(intensity, result[0].intensity, 0.0)
  }

  @Test
  fun convertToGradientReturnsCorrectData() {
    val color1: Long = 0
    val color2: Long = 1
    val color3: Long = 2
    val colorData =
        listOf(
            createPlatformColor(color1), createPlatformColor(color2), createPlatformColor(color3))
    val startPoint1 = 0.0
    val startPoint2 = 1.0
    val startPoint3 = 2.0
    val startPointData = listOf(startPoint1, startPoint2, startPoint3)
    val colorMapSize: Long = 3
    val data = PlatformHeatmapGradient(colorData, startPointData, colorMapSize)

    val result = Convert.gradientFromPigeon(data)

    Assert.assertEquals(3, result.colors.size.toLong())
    Assert.assertEquals(color1, result.colors[0].toLong())
    Assert.assertEquals(color2, result.colors[1].toLong())
    Assert.assertEquals(color3, result.colors[2].toLong())
    Assert.assertEquals(3, result.startPoints.size.toLong())
    Assert.assertEquals(startPoint1, result.startPoints[0].toDouble(), 0.0)
    Assert.assertEquals(startPoint2, result.startPoints[1].toDouble(), 0.0)
    Assert.assertEquals(startPoint3, result.startPoints[2].toDouble(), 0.0)
    Assert.assertEquals(colorMapSize, result.colorMapSize.toLong())
  }

  @Test
  fun convertInterpretHeatmapOptionsReturnsCorrectData() {
    val intensity = 3.3
    val dataData = listOf(PlatformWeightedLatLng(PlatformLatLng(1.1, 2.2), intensity))
    val point: Point = sProjection.toPoint(LatLng(1.1, 2.2))

    val color1: Long = 0
    val color2: Long = 1
    val color3: Long = 2
    val colorData =
        listOf(
            createPlatformColor(color1), createPlatformColor(color2), createPlatformColor(color3))
    val startPoint1 = 0.0
    val startPoint2 = 1.0
    val startPoint3 = 2.0
    val startPointData = listOf(startPoint1, startPoint2, startPoint3)
    val colorMapSize: Long = 3
    val gradientData = PlatformHeatmapGradient(colorData, startPointData, colorMapSize)

    val maxIntensity = 4.0
    val opacity = 5.5
    val radius: Long = 6
    val idData = "heatmap_1"

    val data =
        PlatformHeatmap(
            idData,
            dataData,
            gradientData,
            opacity = opacity,
            radius = radius,
            maxIntensity = maxIntensity)

    val builder = MockHeatmapBuilder()
    val id = Convert.interpretHeatmapOptions(data, builder)

    Assert.assertEquals(1, builder.getWeightedData()!!.size.toLong())
    Assert.assertEquals(point.x, builder.getWeightedData()!![0].point.x, 0.0)
    Assert.assertEquals(point.y, builder.getWeightedData()!![0].point.y, 0.0)
    Assert.assertEquals(intensity, builder.getWeightedData()!![0].intensity, 0.0)
    Assert.assertEquals(3, builder.getGradient()!!.colors.size.toLong())
    Assert.assertEquals(color1, builder.getGradient()!!.colors[0].toLong())
    Assert.assertEquals(color2, builder.getGradient()!!.colors[1].toLong())
    Assert.assertEquals(color3, builder.getGradient()!!.colors[2].toLong())
    Assert.assertEquals(3, builder.getGradient()!!.startPoints.size.toLong())
    Assert.assertEquals(startPoint1, builder.getGradient()!!.startPoints[0].toDouble(), 0.0)
    Assert.assertEquals(startPoint2, builder.getGradient()!!.startPoints[1].toDouble(), 0.0)
    Assert.assertEquals(startPoint3, builder.getGradient()!!.startPoints[2].toDouble(), 0.0)
    Assert.assertEquals(colorMapSize, builder.getGradient()!!.colorMapSize.toLong())
    Assert.assertEquals(maxIntensity, builder.getMaxIntensity(), 0.0)
    Assert.assertEquals(opacity, builder.getOpacity(), 0.0)
    Assert.assertEquals(radius, builder.getRadius().toLong())
    Assert.assertEquals(idData, id)
  }

  private fun createPlatformColor(rgba: Long): PlatformColor {
    return PlatformColor(rgba)
  }

  @Test
  fun buildGroundOverlayAnchorForPigeonWithNonCrossingMeridian() {
    val position = LatLng(10.0, 20.0)
    val southwest = LatLng(5.0, 15.0)
    val northeast = LatLng(15.0, 25.0)
    val bounds = LatLngBounds(southwest, northeast)
    val groundOverlay = mock<GroundOverlay>()
    whenever(groundOverlay.position).thenReturn(position)
    whenever(groundOverlay.bounds).thenReturn(bounds)

    val anchor = Convert.buildGroundOverlayAnchorForPigeon(groundOverlay)

    Assert.assertEquals(0.5, anchor.x, 1e-15)
    Assert.assertEquals(0.5, anchor.y, 1e-15)
  }

  @Test
  fun buildGroundOverlayAnchorForPigeonWithCrossingMeridian() {
    val position = LatLng(10.0, -175.0)
    val southwest = LatLng(5.0, 170.0)
    val northeast = LatLng(15.0, -160.0)
    val bounds = LatLngBounds(southwest, northeast)
    val groundOverlay = mock<GroundOverlay>()
    whenever(groundOverlay.position).thenReturn(position)
    whenever(groundOverlay.bounds).thenReturn(bounds)

    val anchor = Convert.buildGroundOverlayAnchorForPigeon(groundOverlay)

    Assert.assertEquals(0.5, anchor.x, 1e-15)
    Assert.assertEquals(0.5, anchor.y, 1e-15)
  }

  private fun assertGroundOverlayEquals(
      result: PlatformGroundOverlay,
      expectedOverlay: GroundOverlay,
      expectedId: String?,
      expectedPosition: LatLng?,
      expectedBounds: LatLngBounds?
  ) {
    Assert.assertEquals(expectedId, result.groundOverlayId)
    if (expectedPosition != null) {
      Assert.assertNotNull(result.position)
      Assert.assertEquals(expectedPosition.latitude, result.position!!.latitude, 1e-15)
      Assert.assertEquals(expectedPosition.longitude, result.position.longitude, 1e-15)
      Assert.assertNotNull(result.width)
      Assert.assertNotNull(result.height)
      Assert.assertEquals(expectedOverlay.width.toDouble(), result.width!!, 1e-15)
      Assert.assertEquals(expectedOverlay.height.toDouble(), result.height!!, 1e-15)
    } else {
      Assert.assertNull(result.position)
    }
    if (expectedBounds != null) {
      Assert.assertNotNull(result.bounds)
      Assert.assertEquals(
          expectedBounds.southwest.latitude, result.bounds!!.southwest.latitude, 1e-15)
      Assert.assertEquals(
          expectedBounds.southwest.longitude, result.bounds.southwest.longitude, 1e-15)
      Assert.assertEquals(
          expectedBounds.northeast.latitude, result.bounds.northeast.latitude, 1e-15)
      Assert.assertEquals(
          expectedBounds.northeast.longitude, result.bounds.northeast.longitude, 1e-15)
    } else {
      Assert.assertNull(result.bounds)
    }

    Assert.assertEquals(expectedOverlay.bearing.toDouble(), result.bearing, 1e-15)
    Assert.assertEquals(expectedOverlay.transparency.toDouble(), result.transparency, 1e-6)
    Assert.assertEquals(expectedOverlay.zIndex.toDouble(), result.zIndex.toDouble(), 1e-6)
    Assert.assertEquals(expectedOverlay.isVisible, result.visible)
    Assert.assertEquals(expectedOverlay.isClickable, result.clickable)
    val anchor = result.anchor
    Assert.assertNotNull(anchor)
    Assert.assertEquals(0.5, anchor!!.x, 1e-6)
    Assert.assertEquals(0.5, anchor.y, 1e-6)
  }

  @Test
  fun groundOverlayToPigeonWithPosition() {
    val mockGroundOverlay = mock<GroundOverlay>()
    val position = LatLng(10.0, 20.0)
    val southwest = LatLng(5.0, 15.0)
    val northeast = LatLng(15.0, 25.0)
    val bounds = LatLngBounds(southwest, northeast)
    whenever(mockGroundOverlay.position).thenReturn(position)
    whenever(mockGroundOverlay.bounds).thenReturn(bounds)
    whenever(mockGroundOverlay.width).thenReturn(30f)
    whenever(mockGroundOverlay.height).thenReturn(40f)
    whenever(mockGroundOverlay.bearing).thenReturn(50f)
    whenever(mockGroundOverlay.transparency).thenReturn(0.6f)
    whenever(mockGroundOverlay.zIndex).thenReturn(7f)
    whenever(mockGroundOverlay.isVisible).thenReturn(true)
    whenever(mockGroundOverlay.isClickable).thenReturn(false)

    val overlayId = "overlay_1"
    val result = Convert.groundOverlayToPigeon(mockGroundOverlay, overlayId, false)

    assertGroundOverlayEquals(result, mockGroundOverlay, overlayId, position, null)
  }

  @Test
  fun groundOverlayToPigeonWithBounds() {
    val mockGroundOverlay = mock<GroundOverlay>()
    val position = LatLng(10.0, 20.0)
    val southwest = LatLng(5.0, 15.0)
    val northeast = LatLng(15.0, 25.0)
    val bounds = LatLngBounds(southwest, northeast)
    whenever(mockGroundOverlay.position).thenReturn(position)
    whenever(mockGroundOverlay.bounds).thenReturn(bounds)
    whenever(mockGroundOverlay.width).thenReturn(30f)
    whenever(mockGroundOverlay.height).thenReturn(40f)
    whenever(mockGroundOverlay.bearing).thenReturn(50f)
    whenever(mockGroundOverlay.transparency).thenReturn(0.6f)
    whenever(mockGroundOverlay.zIndex).thenReturn(7f)
    whenever(mockGroundOverlay.isVisible).thenReturn(true)
    whenever(mockGroundOverlay.isClickable).thenReturn(false)

    val overlayId = "overlay_2"
    val result = Convert.groundOverlayToPigeon(mockGroundOverlay, overlayId, true)

    assertGroundOverlayEquals(result, mockGroundOverlay, overlayId, null, bounds)
  }

  // Remove this if builders are added to the Kotlin generator; see discussion in
  // https://github.com/flutter/flutter/issues/158287
  private class PlatformMapConfigurationBuilder {
    private var compassEnabled: Boolean? = null
    private var cameraTargetBounds: PlatformCameraTargetBounds? = null
    private var mapType: PlatformMapType? = null
    private var minMaxZoomPreference: PlatformZoomRange? = null
    private var mapToolbarEnabled: Boolean? = null
    private var rotateGesturesEnabled: Boolean? = null
    private var scrollGesturesEnabled: Boolean? = null
    private var tiltGesturesEnabled: Boolean? = null
    private var trackCameraPosition: Boolean? = null
    private var zoomControlsEnabled: Boolean? = null
    private var zoomGesturesEnabled: Boolean? = null
    private var myLocationEnabled: Boolean? = null
    private var myLocationButtonEnabled: Boolean? = null
    private var padding: PlatformEdgeInsets? = null
    private var indoorViewEnabled: Boolean? = null
    private var trafficEnabled: Boolean? = null
    private var buildingsEnabled: Boolean? = null
    private var liteModeEnabled: Boolean? = null
    private var markerType: PlatformMarkerType? = null
    private var mapId: String? = null
    private var style: String? = null

    fun setCompassEnabled(setterArg: Boolean?): PlatformMapConfigurationBuilder {
      this.compassEnabled = setterArg
      return this
    }

    fun setCameraTargetBounds(
        setterArg: PlatformCameraTargetBounds?
    ): PlatformMapConfigurationBuilder {
      this.cameraTargetBounds = setterArg
      return this
    }

    fun setMapType(setterArg: PlatformMapType?): PlatformMapConfigurationBuilder {
      this.mapType = setterArg
      return this
    }

    fun setMinMaxZoomPreference(setterArg: PlatformZoomRange?): PlatformMapConfigurationBuilder {
      this.minMaxZoomPreference = setterArg
      return this
    }

    fun setMapToolbarEnabled(setterArg: Boolean?): PlatformMapConfigurationBuilder {
      this.mapToolbarEnabled = setterArg
      return this
    }

    fun setRotateGesturesEnabled(setterArg: Boolean?): PlatformMapConfigurationBuilder {
      this.rotateGesturesEnabled = setterArg
      return this
    }

    fun setScrollGesturesEnabled(setterArg: Boolean?): PlatformMapConfigurationBuilder {
      this.scrollGesturesEnabled = setterArg
      return this
    }

    fun setTiltGesturesEnabled(setterArg: Boolean?): PlatformMapConfigurationBuilder {
      this.tiltGesturesEnabled = setterArg
      return this
    }

    fun setTrackCameraPosition(setterArg: Boolean?): PlatformMapConfigurationBuilder {
      this.trackCameraPosition = setterArg
      return this
    }

    fun setZoomControlsEnabled(setterArg: Boolean?): PlatformMapConfigurationBuilder {
      this.zoomControlsEnabled = setterArg
      return this
    }

    fun setZoomGesturesEnabled(setterArg: Boolean?): PlatformMapConfigurationBuilder {
      this.zoomGesturesEnabled = setterArg
      return this
    }

    fun setMyLocationEnabled(setterArg: Boolean?): PlatformMapConfigurationBuilder {
      this.myLocationEnabled = setterArg
      return this
    }

    fun setMyLocationButtonEnabled(setterArg: Boolean?): PlatformMapConfigurationBuilder {
      this.myLocationButtonEnabled = setterArg
      return this
    }

    fun setPadding(setterArg: PlatformEdgeInsets?): PlatformMapConfigurationBuilder {
      this.padding = setterArg
      return this
    }

    fun setIndoorViewEnabled(setterArg: Boolean?): PlatformMapConfigurationBuilder {
      this.indoorViewEnabled = setterArg
      return this
    }

    fun setTrafficEnabled(setterArg: Boolean?): PlatformMapConfigurationBuilder {
      this.trafficEnabled = setterArg
      return this
    }

    fun setBuildingsEnabled(setterArg: Boolean?): PlatformMapConfigurationBuilder {
      this.buildingsEnabled = setterArg
      return this
    }

    fun setLiteModeEnabled(setterArg: Boolean?): PlatformMapConfigurationBuilder {
      this.liteModeEnabled = setterArg
      return this
    }

    fun setMarkerType(setterArg: PlatformMarkerType): PlatformMapConfigurationBuilder {
      this.markerType = setterArg
      return this
    }

    fun setMapId(setterArg: String?): PlatformMapConfigurationBuilder {
      this.mapId = setterArg
      return this
    }

    fun setStyle(setterArg: String?): PlatformMapConfigurationBuilder {
      this.style = setterArg
      return this
    }

    fun build(): PlatformMapConfiguration {
      return PlatformMapConfiguration(
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
          markerType!!,
          mapId,
          style)
    }
  }

  companion object {
    private val sProjection = SphericalMercatorProjection(1.0)
  }
}

internal class MockHeatmapBuilder : HeatmapOptionsSink {
  private var weightedData: MutableList<WeightedLatLng>? = null
  private var gradient: Gradient? = null
  private var maxIntensity = 0.0
  private var opacity = 0.0
  private var radius = 0

  fun getWeightedData(): MutableList<WeightedLatLng>? {
    return weightedData
  }

  fun getGradient(): Gradient? {
    return gradient
  }

  fun getMaxIntensity(): Double {
    return maxIntensity
  }

  fun getOpacity(): Double {
    return opacity
  }

  fun getRadius(): Int {
    return radius
  }

  override fun setWeightedData(weightedData: MutableList<WeightedLatLng>) {
    this.weightedData = weightedData
  }

  override fun setGradient(gradient: Gradient) {
    this.gradient = gradient
  }

  override fun setMaxIntensity(maxIntensity: Double) {
    this.maxIntensity = maxIntensity
  }

  override fun setOpacity(opacity: Double) {
    this.opacity = opacity
  }

  override fun setRadius(radius: Int) {
    this.radius = radius
  }
}
