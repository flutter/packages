// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.googlemaps

import android.content.res.AssetManager
import android.graphics.BitmapFactory
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
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertThrows
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito
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
  private val base64Image: String = TestImageUtils.generateBase64Image()

  @Test
  fun convertPointsFromPigeonConvertsThePointsWithFullPrecision() {
    val latitude = 43.03725568057
    val longitude = -87.90466904649
    val platLng = PlatformLatLng(latitude, longitude)
    val latLngs = Convert.pointsFromPigeon(listOf(platLng))
    val latLng = latLngs[0]
    assertEquals(latitude, latLng.latitude, 1e-15)
    assertEquals(longitude, latLng.longitude, 1e-15)
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
    assertEquals(clusterManagerId, result.clusterManagerId)

    val position = result.position
    assertEquals(clusterPosition.latitude, position.latitude, 1e-15)
    assertEquals(clusterPosition.longitude, position.longitude, 1e-15)

    val bounds = result.bounds
    val southwest = bounds.southwest
    val northeast = bounds.northeast
    // bounding data should combine data from marker positions markerPosition1 and markerPosition2
    assertEquals(markerPosition2.latitude, southwest.latitude, 1e-15)
    assertEquals(markerPosition1.longitude, southwest.longitude, 1e-15)
    assertEquals(markerPosition1.latitude, northeast.latitude, 1e-15)
    assertEquals(markerPosition2.longitude, northeast.longitude, 1e-15)

    val markerIds = result.markerIds
    assertEquals(2, markerIds.size)
    assertEquals(marker1.markerId(), markerIds[0])
    assertEquals(marker2.markerId(), markerIds[1])
  }

  @Test
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

    assertEquals(mockBitmapDescriptor, result)
  }

  @Test
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

    assertEquals(mockBitmapDescriptor, result)
  }

  @Test
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

    assertEquals(mockBitmapDescriptor, result)
  }

  @Test
  fun getBitmapFromAssetNoScaling() {
    val fakeAssetName = "fake_asset_name"
    val fakeAssetKey = "fake_asset_key"

    whenever(flutterInjectorWrapper.getLookupKeyForAsset(fakeAssetName)).thenReturn(fakeAssetKey)

    whenever(assetManager.open(fakeAssetKey)).thenReturn(TestImageUtils.buildImageInputStream())

    whenever(bitmapDescriptorFactoryWrapper.fromAsset(any())).thenReturn(mockBitmapDescriptor)

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

    assertEquals(mockBitmapDescriptor, result)
    verify(bitmapDescriptorFactoryWrapper, never()).fromBitmap(any())
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

    assertEquals(mockBitmapDescriptor, result)
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

    assertEquals(mockBitmapDescriptor, result)
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

    assertEquals(mockBitmapDescriptor, result)
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

    assertEquals(mockBitmapDescriptor, result)
  }

  @Test
  fun getBitmapFromBytesThrowsErrorIfInvalidImageData() {
    Mockito.mockStatic(BitmapFactory::class.java).use { mockedFactory ->
      mockedFactory.whenever { BitmapFactory.decodeByteArray(any(), any(), any()) }.thenReturn(null)

      val bitmap =
          PlatformBitmapBytesMap(
              byteArrayOf(),
              bitmapScaling = PlatformMapBitmapScaling.NONE,
              imagePixelRatio = 2.0,
              width = null,
              height = null)

      val exception =
          assertThrows(IllegalArgumentException::class.java) {
            Convert.getBitmapFromBytes(bitmap, 1f, bitmapDescriptorFactoryWrapper)
          }
      assertEquals("Unable to interpret bytes as a valid image.", exception.message)
      verify(bitmapDescriptorFactoryWrapper, never()).fromBitmap(any())
    }
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
    assertEquals(0x00FFFF, pinConfig.backgroundColor)
    assertEquals(0xFF00FF, pinConfig.borderColor)
    assertEquals(0x112233, pinConfig.glyph.glyphColor)
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
    assertEquals("Hi", pinConfig.glyph.text)
    assertEquals(0xFFFFFF, pinConfig.glyph.textColor)
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

    assertEquals(0xFFFFFF, pinConfig.backgroundColor)
    assertEquals(0x000000, pinConfig.borderColor)
    assertEquals(mockBitmapDescriptor, pinConfig.glyph.bitmapDescriptor)
  }

  @Test
  fun interpretMapConfiguration_handlesNulls() {
    val config = PlatformMapConfiguration(markerType = PlatformMarkerType.MARKER)
    Convert.interpretMapConfiguration(config, optionsSink)
    verifyNoInteractions(optionsSink)
  }

  @Test
  fun interpretMapConfiguration_handlesCompassEnabled() {
    val config =
        PlatformMapConfiguration(markerType = PlatformMarkerType.MARKER, compassEnabled = false)
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setCompassEnabled(false)
  }

  @Test
  fun interpretMapConfiguration_handlesMapToolbarEnabled() {
    val config =
        PlatformMapConfiguration(markerType = PlatformMarkerType.MARKER, mapToolbarEnabled = true)
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setMapToolbarEnabled(true)
  }

  @Test
  fun interpretMapConfiguration_handlesRotateGesturesEnabled() {
    val config =
        PlatformMapConfiguration(
            markerType = PlatformMarkerType.MARKER, rotateGesturesEnabled = false)
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setRotateGesturesEnabled(false)
  }

  @Test
  fun interpretMapConfiguration_handlesScrollGesturesEnabled() {
    val config =
        PlatformMapConfiguration(
            markerType = PlatformMarkerType.MARKER, scrollGesturesEnabled = true)
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setScrollGesturesEnabled(true)
  }

  @Test
  fun interpretMapConfiguration_handlesTiltGesturesEnabled() {
    val config =
        PlatformMapConfiguration(
            markerType = PlatformMarkerType.MARKER, tiltGesturesEnabled = false)
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setTiltGesturesEnabled(false)
  }

  @Test
  fun interpretMapConfiguration_handlesTrackCameraPosition() {
    val config =
        PlatformMapConfiguration(markerType = PlatformMarkerType.MARKER, trackCameraPosition = true)
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setTrackCameraPosition(true)
  }

  @Test
  fun interpretMapConfiguration_handlesZoomControlsEnabled() {
    val config =
        PlatformMapConfiguration(
            markerType = PlatformMarkerType.MARKER, zoomControlsEnabled = false)
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setZoomControlsEnabled(false)
  }

  @Test
  fun interpretMapConfiguration_handlesZoomGesturesEnabled() {
    val config =
        PlatformMapConfiguration(markerType = PlatformMarkerType.MARKER, zoomGesturesEnabled = true)
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setZoomGesturesEnabled(true)
  }

  @Test
  fun interpretMapConfiguration_handlesMyLocationEnabled() {
    val config =
        PlatformMapConfiguration(markerType = PlatformMarkerType.MARKER, myLocationEnabled = false)
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setMyLocationEnabled(false)
  }

  @Test
  fun interpretMapConfiguration_handlesMyLocationButtonEnabled() {
    val config =
        PlatformMapConfiguration(
            markerType = PlatformMarkerType.MARKER, myLocationButtonEnabled = true)
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setMyLocationButtonEnabled(true)
  }

  @Test
  fun interpretMapConfiguration_handlesIndoorViewEnabled() {
    val config =
        PlatformMapConfiguration(markerType = PlatformMarkerType.MARKER, indoorViewEnabled = false)
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setIndoorEnabled(false)
  }

  @Test
  fun interpretMapConfiguration_handlesTrafficEnabled() {
    val config =
        PlatformMapConfiguration(markerType = PlatformMarkerType.MARKER, trafficEnabled = true)
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setTrafficEnabled(true)
  }

  @Test
  fun interpretMapConfiguration_handlesBuildingsEnabled() {
    val config =
        PlatformMapConfiguration(markerType = PlatformMarkerType.MARKER, buildingsEnabled = false)
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setBuildingsEnabled(false)
  }

  @Test
  fun interpretMapConfiguration_handlesLiteModeEnabled() {
    val config =
        PlatformMapConfiguration(markerType = PlatformMarkerType.MARKER, liteModeEnabled = true)
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setLiteModeEnabled(true)
  }

  @Test
  fun interpretMapConfiguration_handlesStyle() {
    val config = PlatformMapConfiguration(markerType = PlatformMarkerType.MARKER, style = "foo")
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setMapStyle("foo")
  }

  @Test
  fun interpretMapConfiguration_handlesUnboundedCameraTargetBounds() {
    val config =
        PlatformMapConfiguration(
            markerType = PlatformMarkerType.MARKER,
            cameraTargetBounds = PlatformCameraTargetBounds(null))
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setCameraTargetBounds(null)
  }

  @Test
  fun interpretMapConfiguration_handlesBoundedCameraTargetBounds() {
    val bounds = LatLngBounds(LatLng(10.0, 20.0), LatLng(30.0, 40.0))
    val config =
        PlatformMapConfiguration(
            markerType = PlatformMarkerType.MARKER,
            cameraTargetBounds =
                PlatformCameraTargetBounds(
                    PlatformLatLngBounds(
                        PlatformLatLng(bounds.northeast.latitude, bounds.northeast.longitude),
                        PlatformLatLng(bounds.southwest.latitude, bounds.southwest.longitude))))
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setCameraTargetBounds(bounds)
  }

  @Test
  fun interpretMapConfiguration_handlesMapType() {
    val config =
        PlatformMapConfiguration(
            markerType = PlatformMarkerType.MARKER, mapType = PlatformMapType.HYBRID)
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
        PlatformMapConfiguration(
            markerType = PlatformMarkerType.MARKER,
            padding = PlatformEdgeInsets(top = top, bottom = bottom, left = left, right = right))
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1))
        .setPadding(top.toFloat(), left.toFloat(), bottom.toFloat(), right.toFloat())
  }

  @Test
  fun interpretMapConfiguration_handlesMinMaxZoomPreference() {
    val min = 1.0
    val max = 2.0
    val config =
        PlatformMapConfiguration(
            markerType = PlatformMarkerType.MARKER,
            minMaxZoomPreference = PlatformZoomRange(min, max))
    Convert.interpretMapConfiguration(config, optionsSink)
    verify(optionsSink, times(1)).setMinMaxZoomPreference(min.toFloat(), max.toFloat())
  }

  @Test
  fun convertToWeightedLatLngReturnsCorrectData() {
    val intensity = 3.3
    val data = PlatformWeightedLatLng(PlatformLatLng(1.1, 2.2), intensity)
    val point: Point = sProjection.toPoint(LatLng(1.1, 2.2))

    val result = Convert.weightedLatLngFromPigeon(data)

    assertEquals(point.x, result.point.x, 0.0)
    assertEquals(point.y, result.point.y, 0.0)
    assertEquals(intensity, result.intensity, 0.0)
  }

  @Test
  fun convertToWeightedDataReturnsCorrectData() {
    val intensity = 3.3
    val data = listOf(PlatformWeightedLatLng(PlatformLatLng(1.1, 2.2), intensity))
    val point: Point = sProjection.toPoint(LatLng(1.1, 2.2))

    val result = Convert.weightedDataFromPigeon(data)

    assertEquals(1, result.size)
    assertEquals(point.x, result[0].point.x, 0.0)
    assertEquals(point.y, result[0].point.y, 0.0)
    assertEquals(intensity, result[0].intensity, 0.0)
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

    assertEquals(3, result.colors.size)
    assertEquals(color1, result.colors[0].toLong())
    assertEquals(color2, result.colors[1].toLong())
    assertEquals(color3, result.colors[2].toLong())
    assertEquals(3, result.startPoints.size)
    assertEquals(startPoint1, result.startPoints[0].toDouble(), 0.0)
    assertEquals(startPoint2, result.startPoints[1].toDouble(), 0.0)
    assertEquals(startPoint3, result.startPoints[2].toDouble(), 0.0)
    assertEquals(colorMapSize, result.colorMapSize.toLong())
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

    val weightedData = checkNotNull(builder.getWeightedData())
    val gradient = checkNotNull(builder.getGradient())
    assertEquals(1, weightedData.size)
    assertEquals(point.x, weightedData[0].point.x, 0.0)
    assertEquals(point.y, weightedData[0].point.y, 0.0)
    assertEquals(intensity, weightedData[0].intensity, 0.0)
    assertEquals(3, gradient.colors.size)
    assertEquals(color1, gradient.colors[0].toLong())
    assertEquals(color2, gradient.colors[1].toLong())
    assertEquals(color3, gradient.colors[2].toLong())
    assertEquals(3, gradient.startPoints.size)
    assertEquals(startPoint1, gradient.startPoints[0].toDouble(), 0.0)
    assertEquals(startPoint2, gradient.startPoints[1].toDouble(), 0.0)
    assertEquals(startPoint3, gradient.startPoints[2].toDouble(), 0.0)
    assertEquals(colorMapSize, gradient.colorMapSize.toLong())
    assertEquals(maxIntensity, builder.getMaxIntensity(), 0.0)
    assertEquals(opacity, builder.getOpacity(), 0.0)
    assertEquals(radius, builder.getRadius().toLong())
    assertEquals(idData, id)
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

    assertEquals(0.5, anchor.x, 1e-15)
    assertEquals(0.5, anchor.y, 1e-15)
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

    assertEquals(0.5, anchor.x, 1e-15)
    assertEquals(0.5, anchor.y, 1e-15)
  }

  private fun assertGroundOverlayEquals(
      result: PlatformGroundOverlay,
      expectedOverlay: GroundOverlay,
      expectedId: String?,
      expectedPosition: LatLng?,
      expectedBounds: LatLngBounds?
  ) {
    assertEquals(expectedId, result.groundOverlayId)
    if (expectedPosition != null) {
      val position = checkNotNull(result.position)
      assertEquals(expectedPosition.latitude, position.latitude, 1e-15)
      assertEquals(expectedPosition.longitude, position.longitude, 1e-15)
      val width = checkNotNull(result.width)
      val height = checkNotNull(result.height)
      assertEquals(expectedOverlay.width.toDouble(), width, 1e-15)
      assertEquals(expectedOverlay.height.toDouble(), height, 1e-15)
    } else {
      assertNull(result.position)
    }
    if (expectedBounds != null) {
      val bounds = checkNotNull(result.bounds)
      assertEquals(expectedBounds.southwest.latitude, bounds.southwest.latitude, 1e-15)
      assertEquals(expectedBounds.southwest.longitude, bounds.southwest.longitude, 1e-15)
      assertEquals(expectedBounds.northeast.latitude, bounds.northeast.latitude, 1e-15)
      assertEquals(expectedBounds.northeast.longitude, bounds.northeast.longitude, 1e-15)
    } else {
      assertNull(result.bounds)
    }

    assertEquals(expectedOverlay.bearing.toDouble(), result.bearing, 1e-15)
    assertEquals(expectedOverlay.transparency.toDouble(), result.transparency, 1e-6)
    assertEquals(expectedOverlay.zIndex.toDouble(), result.zIndex.toDouble(), 1e-6)
    assertEquals(expectedOverlay.isVisible, result.visible)
    assertEquals(expectedOverlay.isClickable, result.clickable)
    val anchor = checkNotNull(result.anchor)
    assertEquals(0.5, anchor.x, 1e-6)
    assertEquals(0.5, anchor.y, 1e-6)
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
