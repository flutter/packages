// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.googlemaps

import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.model.TileOverlay
import com.google.android.gms.maps.model.TileOverlayOptions
import com.google.maps.android.heatmaps.HeatmapTileProvider
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.ArgumentMatcher
import org.mockito.ArgumentMatchers
import org.mockito.Mockito
import org.robolectric.RobolectricTestRunner
import java.util.List

@RunWith(RobolectricTestRunner::class)
class HeatmapsControllerTest {
    private var controller: HeatmapsController? = null
    private var googleMap: GoogleMap? = null

    @Before
    fun setUp() {
        controller = Mockito.spy<HeatmapsController>(HeatmapsController())
        googleMap = Mockito.mock<GoogleMap>(GoogleMap::class.java)
        controller!!.setGoogleMap(googleMap)
    }

    @Test
    fun controller_AddChangeAndRemoveHeatmap() {
        val tileOverlay = Mockito.mock<TileOverlay?>(TileOverlay::class.java)
        val heatmap = Mockito.mock<HeatmapTileProvider?>(HeatmapTileProvider::class.java)

        val googleHeatmapId = "abc123"
        val heatmapData =
            List.of<PlatformWeightedLatLng?>(PlatformWeightedLatLng(PlatformLatLng(1.1, 2.2), 3.3))
        val radius: Long = 20

        Mockito.`when`<TileOverlay?>(
            googleMap!!.addTileOverlay(
                ArgumentMatchers.any<TileOverlayOptions?>(
                    TileOverlayOptions::class.java
                )
            )
        ).thenReturn(tileOverlay)
        Mockito.doReturn(heatmap).`when`<HeatmapsController?>(controller)
            .buildHeatmap(ArgumentMatchers.any<HeatmapBuilder?>(HeatmapBuilder::class.java))

        val opacity1 = 0.1
        val heatmap1 =
            PlatformHeatmap(
                googleHeatmapId,
                heatmapData,  /* gradient */
                null,
                opacity1,
                radius,  /* maxIntensity */
                null
            )

        val heatmaps = mutableListOf<PlatformHeatmap?>(heatmap1)
        controller!!.addHeatmaps(heatmaps)

        Mockito.verify<GoogleMap?>(googleMap, Mockito.times(1))
            .addTileOverlay(
                Mockito.argThat<TileOverlayOptions?>(ArgumentMatcher { argument: TileOverlayOptions? -> argument!!.getTileProvider() is HeatmapTileProvider })
            )

        val opacity2 = 0.2
        val heatmap2 =
            PlatformHeatmap(
                googleHeatmapId,
                heatmapData,  /* gradient */
                null,
                opacity2,
                radius,  /* maxIntensity */
                null
            )

        val heatmapUpdates = mutableListOf<PlatformHeatmap?>(heatmap2)

        controller!!.changeHeatmaps(heatmapUpdates)
        Mockito.verify<HeatmapTileProvider?>(heatmap, Mockito.times(1)).opacity = opacity2

        controller!!.removeHeatmaps(mutableListOf<String?>(googleHeatmapId))

        Mockito.verify<TileOverlay?>(tileOverlay, Mockito.times(1)).remove()
    }
}
