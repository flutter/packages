// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.googlemaps

import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.model.TileOverlay
import com.google.maps.android.heatmaps.HeatmapTileProvider
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.any
import org.mockito.kotlin.argThat
import org.mockito.kotlin.doReturn
import org.mockito.kotlin.mock
import org.mockito.kotlin.spy
import org.mockito.kotlin.times
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class HeatmapsControllerTest {
  private val controller: HeatmapsController = spy(HeatmapsController())
  private val googleMap: GoogleMap = mock()

  @Before
  fun setUp() {
    controller.setGoogleMap(googleMap)
  }

  @Test
  fun controller_AddChangeAndRemoveHeatmap() {
    val tileOverlay = mock<TileOverlay>()
    val heatmap = mock<HeatmapTileProvider>()

    val googleHeatmapId = "abc123"
    val heatmapData = listOf(PlatformWeightedLatLng(PlatformLatLng(1.1, 2.2), 3.3))
    val radius: Long = 20

    whenever(googleMap.addTileOverlay(any())).thenReturn(tileOverlay)
    doReturn(heatmap).whenever(controller).buildHeatmap(any())

    val opacity1 = 0.1
    val heatmap1 =
        PlatformHeatmap(
            googleHeatmapId, heatmapData, gradient = null, opacity1, radius, maxIntensity = null)

    controller.addHeatmaps(listOf(heatmap1))

    verify(googleMap, times(1)).addTileOverlay(argThat { this.tileProvider is HeatmapTileProvider })

    val opacity2 = 0.2
    val heatmap2 =
        PlatformHeatmap(
            googleHeatmapId, heatmapData, gradient = null, opacity2, radius, maxIntensity = null)

    controller.changeHeatmaps(listOf(heatmap2))
    verify(heatmap, times(1)).setOpacity(opacity2)

    controller.removeHeatmaps(listOf(googleHeatmapId))

    verify(tileOverlay, times(1)).remove()
  }
}
