// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.googlemaps

import android.content.Context
import android.util.Base64
import androidx.test.core.app.ApplicationProvider
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.model.BitmapDescriptor
import com.google.android.gms.maps.model.GroundOverlay
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.googlemaps.Convert.BitmapDescriptorFactoryWrapper
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.any
import org.mockito.kotlin.argThat
import org.mockito.kotlin.mock
import org.mockito.kotlin.spy
import org.mockito.kotlin.times
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class GroundOverlaysControllerTest {
  private val bitmapDescriptorFactoryWrapper: BitmapDescriptorFactoryWrapper = mock()

  private val mockBitmapDescriptor: BitmapDescriptor = mock()

  private lateinit var controller: GroundOverlaysController
  private val googleMap: GoogleMap = mock()

  // A 1x1 pixel (#8080ff) PNG image encoded in base64
  private val base64Image: String = TestImageUtils.generateBase64Image()

  private fun createGroundOverlay(overlayId: String, transparency: Double): PlatformGroundOverlay {
    val bmpData = Base64.decode(base64Image, Base64.DEFAULT)

    return PlatformGroundOverlay(
        overlayId,
        PlatformBitmap(
            PlatformBitmapBytesMap(
                bmpData,
                PlatformMapBitmapScaling.AUTO,
                imagePixelRatio = 2.0,
                width = 100.0,
                height = null)),
        position = null,
        bounds = null,
        width = null,
        height = null,
        anchor = null,
        transparency,
        bearing = 1.0,
        zIndex = 1L,
        visible = true,
        clickable = true)
  }

  @Before
  fun setUp() {
    val context = ApplicationProvider.getApplicationContext<Context>()
    val assetManager = context.assets
    val flutterApi = spy(MapsCallbackApi(mock<BinaryMessenger>(), ""))
    controller =
        spy(
            GroundOverlaysController(
                flutterApi, assetManager, 1.0f, bitmapDescriptorFactoryWrapper))
    controller.setGoogleMap(googleMap)
    whenever(bitmapDescriptorFactoryWrapper.fromBitmap(any())).thenReturn(mockBitmapDescriptor)
  }

  @Test
  fun controller_AddChangeAndRemoveGroundOverlay() {
    val groundOverlay = mock<GroundOverlay>()
    val googleGroundOverlayId = "abc123"
    val transparency = 0.1f

    whenever(groundOverlay.id).thenReturn(googleGroundOverlayId)
    whenever(googleMap.addGroundOverlay(any())).thenReturn(groundOverlay)

    controller.addGroundOverlays(
        listOf(createGroundOverlay(googleGroundOverlayId, transparency.toDouble())))
    verify(googleMap, times(1)).addGroundOverlay(argThat { this.transparency == transparency })

    val newTransparency = 0.2f
    controller.changeGroundOverlays(
        listOf(createGroundOverlay(googleGroundOverlayId, newTransparency.toDouble())))
    verify(groundOverlay, times(1)).transparency = newTransparency

    controller.removeGroundOverlays(listOf(googleGroundOverlayId))

    verify(groundOverlay, times(1)).remove()
  }
}
