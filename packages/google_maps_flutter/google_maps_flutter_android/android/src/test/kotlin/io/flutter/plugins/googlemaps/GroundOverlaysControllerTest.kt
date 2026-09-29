// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.googlemaps

import android.content.Context
import android.graphics.Bitmap
import android.util.Base64
import androidx.test.core.app.ApplicationProvider
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.model.BitmapDescriptor
import com.google.android.gms.maps.model.GroundOverlay
import com.google.android.gms.maps.model.GroundOverlayOptions
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.googlemaps.Convert.BitmapDescriptorFactoryWrapper
import java.lang.AutoCloseable
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.ArgumentMatcher
import org.mockito.ArgumentMatchers
import org.mockito.Mock
import org.mockito.Mockito
import org.mockito.MockitoAnnotations
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class GroundOverlaysControllerTest {
  @Mock private val bitmapDescriptorFactoryWrapper: BitmapDescriptorFactoryWrapper? = null

  @Mock private val mockBitmapDescriptor: BitmapDescriptor? = null

  var mockCloseable: AutoCloseable? = null

  private var controller: GroundOverlaysController? = null
  private var googleMap: GoogleMap? = null

  // A 1x1 pixel (#8080ff) PNG image encoded in base64
  private val base64Image: String? = TestImageUtils.generateBase64Image()

  private fun createGroundOverlay(overlayId: String, transparency: Double): PlatformGroundOverlay {
    val bmpData = Base64.decode(base64Image, Base64.DEFAULT)

    return PlatformGroundOverlay(
        overlayId,
        PlatformBitmap(
            PlatformBitmapBytesMap(
                bmpData,
                PlatformMapBitmapScaling.AUTO, /* imagePixelRatio */
                2.0, /* width */
                100.0, /* height */
                null)), /* position */
        null, /* bounds */
        null, /* width */
        null, /* height */
        null, /* anchor */
        null,
        transparency, /* bearing */
        1.0, /* zIndex */
        1L, /* visible */
        true, /* clickable */
        true)
  }

  @Before
  fun setUp() {
    mockCloseable = MockitoAnnotations.openMocks(this)
    val context = ApplicationProvider.getApplicationContext<Context>()
    val assetManager = context.getAssets()
    val flutterApi =
        Mockito.spy<MapsCallbackApi>(
            MapsCallbackApi(Mockito.mock<BinaryMessenger?>(BinaryMessenger::class.java), ""))
    controller =
        Mockito.spy<GroundOverlaysController>(
            GroundOverlaysController(
                flutterApi, assetManager, 1.0f, bitmapDescriptorFactoryWrapper!!))
    googleMap = Mockito.mock<GoogleMap>(GoogleMap::class.java)
    controller!!.setGoogleMap(googleMap)
    Mockito.`when`<BitmapDescriptor?>(
            bitmapDescriptorFactoryWrapper.fromBitmap(ArgumentMatchers.any<Bitmap?>()))
        .thenReturn(mockBitmapDescriptor)
  }

  @After
  @Throws(Exception::class)
  fun tearDown() {
    mockCloseable!!.close()
  }

  @Test
  fun controller_AddChangeAndRemoveGroundOverlay() {
    val groundOverlay = Mockito.mock<GroundOverlay>(GroundOverlay::class.java)
    val googleGroundOverlayId = "abc123"
    val transparency = 0.1f

    Mockito.`when`<String?>(groundOverlay.getId()).thenReturn(googleGroundOverlayId)
    Mockito.`when`<GroundOverlay?>(
            googleMap!!.addGroundOverlay(
                ArgumentMatchers.any<GroundOverlayOptions?>(GroundOverlayOptions::class.java)))
        .thenReturn(groundOverlay)

    controller!!.addGroundOverlays(
        mutableListOf<PlatformGroundOverlay?>(
            createGroundOverlay(googleGroundOverlayId, transparency.toDouble())))
    Mockito.verify<GoogleMap?>(googleMap, Mockito.times(1))
        .addGroundOverlay(
            Mockito.argThat<GroundOverlayOptions?>(
                ArgumentMatcher { argument: GroundOverlayOptions? ->
                  argument!!.getTransparency() == transparency
                }))

    val newTransparency = 0.2f
    controller!!.changeGroundOverlays(
        mutableListOf<PlatformGroundOverlay?>(
            createGroundOverlay(googleGroundOverlayId, newTransparency.toDouble())))
    Mockito.verify<GroundOverlay?>(groundOverlay, Mockito.times(1)).setTransparency(newTransparency)

    controller!!.removeGroundOverlays(mutableListOf<String?>(googleGroundOverlayId))

    Mockito.verify<GroundOverlay?>(groundOverlay, Mockito.times(1)).remove()
  }
}
