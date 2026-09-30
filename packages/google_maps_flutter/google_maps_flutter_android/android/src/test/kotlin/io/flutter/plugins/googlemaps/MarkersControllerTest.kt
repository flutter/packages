// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.googlemaps

import android.content.Context
import android.content.res.AssetManager
import android.graphics.Bitmap
import androidx.test.core.app.ApplicationProvider
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.model.AdvancedMarkerOptions
import com.google.android.gms.maps.model.AdvancedMarkerOptions.CollisionBehavior
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.Marker
import com.google.android.gms.maps.model.MarkerOptions
import com.google.maps.android.collections.MarkerManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.googlemaps.Convert.BitmapDescriptorFactoryWrapper
import java.io.ByteArrayOutputStream
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.any
import org.mockito.kotlin.argThat
import org.mockito.kotlin.argumentCaptor
import org.mockito.kotlin.eq
import org.mockito.kotlin.mock
import org.mockito.kotlin.never
import org.mockito.kotlin.reset
import org.mockito.kotlin.spy
import org.mockito.kotlin.times
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class MarkersControllerTest {
  private lateinit var context: Context
  private lateinit var flutterApi: MapsCallbackApi
  private lateinit var clusterManagersController: ClusterManagersController
  private lateinit var controller: MarkersController
  private val googleMap: GoogleMap = mock()
  private lateinit var markerManager: MarkerManager
  private lateinit var markerCollection: MarkerManager.Collection
  private lateinit var assetManager: AssetManager
  private val density = 1f

  private val bitmapDescriptorFactoryWrapper: BitmapDescriptorFactoryWrapper = mock()

  @Before
  fun setUp() {
    assetManager = ApplicationProvider.getApplicationContext<Context>().assets
    context = ApplicationProvider.getApplicationContext()
    flutterApi = spy(MapsCallbackApi(mock<BinaryMessenger>(), ""))
    clusterManagersController =
        spy(ClusterManagersController(flutterApi, context, PlatformMarkerType.MARKER))
    controller =
        MarkersController(
            flutterApi,
            clusterManagersController,
            assetManager,
            density,
            bitmapDescriptorFactoryWrapper,
            PlatformMarkerType.MARKER)
    markerManager = MarkerManager(googleMap)
    markerCollection = markerManager.newCollection()
    controller.setCollection(markerCollection)
    clusterManagersController.init(googleMap, markerManager)
  }

  @Test
  fun controller_OnMarkerDragStart() = runTest {
    val marker = mock<Marker>()

    val googleMarkerId = "abc123"

    whenever(marker.id).thenReturn(googleMarkerId)
    whenever(googleMap.addMarker(any())).thenReturn(marker)

    val latLng = LatLng(1.1, 2.2)

    val markers = listOf(defaultMarker(googleMarkerId))
    controller.addMarkers(markers)
    controller.onMarkerDragStart(googleMarkerId, latLng)

    verify(flutterApi).onMarkerDragStart(eq(googleMarkerId), eq(Convert.latLngToPigeon(latLng)))
  }

  @Test
  fun controller_OnMarkerDragEnd() = runTest {
    val marker = mock<Marker>()

    val googleMarkerId = "abc123"

    whenever(marker.id).thenReturn(googleMarkerId)
    whenever(googleMap.addMarker(any())).thenReturn(marker)

    val latLng = LatLng(1.1, 2.2)

    val markers = listOf(defaultMarker(googleMarkerId))
    controller.addMarkers(markers)
    controller.onMarkerDragEnd(googleMarkerId, latLng)

    verify(flutterApi).onMarkerDragEnd(eq(googleMarkerId), eq(Convert.latLngToPigeon(latLng)))
  }

  @Test
  fun controller_OnMarkerDrag() = runTest {
    val marker = mock<Marker>()

    val googleMarkerId = "abc123"

    whenever(marker.id).thenReturn(googleMarkerId)
    whenever(googleMap.addMarker(any())).thenReturn(marker)

    val latLng = LatLng(1.1, 2.2)

    val markers = listOf(defaultMarker(googleMarkerId))

    controller.addMarkers(markers)
    controller.onMarkerDrag(googleMarkerId, latLng)

    verify(flutterApi).onMarkerDrag(eq(googleMarkerId), eq(Convert.latLngToPigeon(latLng)))
  }

  @Test
  fun controller_AddChangeAndRemoveMarkerWithClusterManagerId() {
    val marker = mock<Marker>()

    val googleMarkerId = "abc123"
    val clusterManagerId = "cm123"

    val platformMarker: PlatformMarker =
        defaultMarker(googleMarkerId)
            .copy(clusterManagerId = clusterManagerId, position = PlatformLatLng(1.1, 2.2))

    whenever(marker.id).thenReturn(googleMarkerId)

    // Store reference to verify later, since markerIdToMarkerBuilder is private
    val captor = argumentCaptor<List<MarkerBuilder>>()

    // Add marker and verify addItems is called with correct parameters
    controller.addMarkers(listOf(platformMarker))
    verify(clusterManagersController, times(1)).addItems(eq(clusterManagerId), captor.capture())

    val addedMarkerBuilder = captor.firstValue[0]
    assertEquals(clusterManagerId, addedMarkerBuilder.clusterManagerId())
    // clusterManagersController calls onClusterItemRendered with created marker.
    controller.onClusterItemRendered(addedMarkerBuilder, marker)

    // Change marker to test that markerController is created and the marker can be
    // updated
    val latLng2 = LatLng(3.3, 4.4)

    val updatedMarkers =
        listOf(platformMarker.copy(position = PlatformLatLng(latLng2.latitude, latLng2.longitude)))

    controller.changeMarkers(updatedMarkers)
    verify(marker, times(1)).position = latLng2

    // Remove marker
    controller.removeMarkers(listOf(googleMarkerId))

    verify(clusterManagersController, times(1))
        .removeItems(
            eq(clusterManagerId),
            argThat { platformMarkerBuilders ->
              platformMarkerBuilders.size == 1 &&
                  (platformMarkerBuilders.firstOrNull()?.clusterManagerId() == clusterManagerId)
            })
  }

  @Test
  fun controller_AddChangeAndRemoveMarkerWithoutClusterManagerId() {
    val spyMarkerCollection = spy(markerCollection)
    controller.setCollection(spyMarkerCollection)

    val marker = mock<Marker>()

    val googleMarkerId = "abc123"

    whenever(marker.id).thenReturn(googleMarkerId)
    whenever(googleMap.addMarker(any())).thenReturn(marker)

    val platformMarker: PlatformMarker = defaultMarker(googleMarkerId)
    controller.addMarkers(listOf(platformMarker))

    // clusterManagersController should not be called when adding the marker
    verify(clusterManagersController, never()).addItem(any())

    verify(spyMarkerCollection, times(1)).addMarker(any<MarkerOptions>())

    val alpha = 0.1f

    val markerUpdates = listOf(platformMarker.copy(alpha = alpha.toDouble()))
    controller.changeMarkers(markerUpdates)
    verify(marker, times(1)).alpha = alpha

    controller.removeMarkers(listOf(googleMarkerId))

    // clusterManagersController should not be called when removing the marker
    verify(clusterManagersController, never()).removeItem(any())

    verify(spyMarkerCollection, times(1)).remove(marker)
  }

  @Test
  fun platformMarkerBuilder_setCollisionBehavior() {
    var platformMarker: PlatformMarker = defaultMarker("1")
    var markerBuilder = MarkerBuilder("m_1", "1", PlatformMarkerType.ADVANCED_MARKER)

    // Default collision behavior of an AdvancedMarker
    Convert.interpretMarkerOptions(
        platformMarker, markerBuilder, assetManager, 1f, bitmapDescriptorFactoryWrapper)
    var markerOptions = markerBuilder.build()
    assertEquals(AdvancedMarkerOptions::class.java, markerOptions.javaClass)
    assertEquals(
        CollisionBehavior.REQUIRED, (markerOptions as AdvancedMarkerOptions).collisionBehavior)

    // Customized collision behavior of an AdvancedMarker
    platformMarker =
        defaultMarker("1")
            .copy(
                collisionBehavior =
                    PlatformMarkerCollisionBehavior.OPTIONAL_AND_HIDES_LOWER_PRIORITY)
    Convert.interpretMarkerOptions(
        platformMarker, markerBuilder, assetManager, 1f, bitmapDescriptorFactoryWrapper)
    markerOptions = markerBuilder.build()
    assertEquals(AdvancedMarkerOptions::class.java, markerOptions.javaClass)
    assertEquals(
        CollisionBehavior.OPTIONAL_AND_HIDES_LOWER_PRIORITY,
        (markerOptions as AdvancedMarkerOptions).collisionBehavior)

    // Legacy markers don't have collision behavior in the marker options
    platformMarker = defaultMarker("1")
    markerBuilder = MarkerBuilder("m_1", "1", PlatformMarkerType.MARKER)
    Convert.interpretMarkerOptions(
        platformMarker, markerBuilder, assetManager, 1f, bitmapDescriptorFactoryWrapper)
    markerOptions = markerBuilder.build()
    assertEquals(MarkerOptions::class.java, markerOptions.javaClass)
  }

  @Test
  fun controller_BatchAddMultipleMarkersWithClusterManagerId() {
    val clusterManagerId = "cm123"

    // Create multiple markers with the same cluster manager
    val markers =
        (0..4).map { i ->
          defaultMarker("marker$i")
              .copy(
                  clusterManagerId = clusterManagerId, position = PlatformLatLng(1.0 + i, 2.0 + i))
        }

    // Add all markers in one batch
    controller.addMarkers(markers)

    // Verify addItems is called exactly once with all 5 markers
    verify(clusterManagersController, times(1))
        .addItems(
            eq(clusterManagerId),
            argThat { size == 5 && all { it.clusterManagerId() == clusterManagerId } })

    // Verify addItem is never called (we're using batch operation)
    verify(clusterManagersController, never()).addItem(any())
  }

  @Test
  fun controller_BatchRemoveMultipleMarkersWithClusterManagerId() {
    val clusterManagerId = "cm123"

    // First add markers
    val markers =
        (0..4).map { i ->
          val markerId = "marker$i"
          defaultMarker(markerId)
              .copy(
                  clusterManagerId = clusterManagerId, position = PlatformLatLng(1.0 + i, 2.0 + i))
        }

    controller.addMarkers(markers)

    // Remove all markers in one batch
    controller.removeMarkers(markers.map { it.markerId })

    // Verify removeItems is called exactly once with all 5 markers
    verify(clusterManagersController, times(1))
        .removeItems(
            eq(clusterManagerId),
            argThat { size == 5 && all { it.clusterManagerId() == clusterManagerId } })

    // Verify removeItem is never called (we're using batch operation)
    verify(clusterManagersController, never()).removeItem(any())
  }

  @Test
  fun controller_BatchChangeMarkersWithClusterManagerChange() {
    val clusterManagerId1 = "cm123"
    val clusterManagerId2 = "cm456"

    // First add markers to cluster manager 1
    val initialMarkers =
        (0..4).map { i ->
          defaultMarker("marker$i")
              .copy(
                  clusterManagerId = clusterManagerId1, position = PlatformLatLng(1.0 + i, 2.0 + i))
        }
    controller.addMarkers(initialMarkers)

    // Reset mock to clear invocation counts
    reset(clusterManagersController)

    // Now change all markers to cluster manager 2
    val changedMarkers =
        (0..4).map { i ->
          defaultMarker("marker$i")
              .copy(
                  clusterManagerId = clusterManagerId2, position = PlatformLatLng(3.0 + i, 4.0 + i))
        }
    controller.changeMarkers(changedMarkers)

    // Verify removeItems is called exactly once for cluster manager 1 with all 5
    // markers
    verify(clusterManagersController, times(1))
        .removeItems(
            eq(clusterManagerId1),
            argThat { size == 5 && all { it.clusterManagerId() == clusterManagerId1 } })

    // Verify addItems is called exactly once for cluster manager 2 with all 5
    // markers
    verify(clusterManagersController, times(1))
        .addItems(
            eq(clusterManagerId2),
            argThat { size == 5 && all { it.clusterManagerId() == clusterManagerId2 } })

    // Verify individual operations are never called (we're using batch operations)
    verify(clusterManagersController, never()).addItem(any())
    verify(clusterManagersController, never()).removeItem(any())
  }

  @Test
  fun controller_ChangeMarkerInPlace() {
    val marker = mock<Marker>()
    val markerId = "marker1"
    val clusterManagerId = "cm123"

    whenever(marker.id).thenReturn(markerId)

    // Add a clustered marker
    val platformMarker: PlatformMarker =
        defaultMarker(markerId)
            .copy(clusterManagerId = clusterManagerId, position = PlatformLatLng(1.0, 2.0))
    controller.addMarkers(listOf(platformMarker))

    // Capture the PlatformMarkerBuilder passed to addItems
    val captor = argumentCaptor<List<MarkerBuilder>>()
    verify(clusterManagersController).addItems(eq(clusterManagerId), captor.capture())
    val capturedMarkerBuilder = captor.firstValue[0]

    // Simulate cluster render so markerController exists
    controller.onClusterItemRendered(capturedMarkerBuilder, marker)

    // Reset to clear invocation counts
    reset(clusterManagersController)

    // Change marker in place (same clusterManagerId)
    val newLatLng = LatLng(3.0, 4.0)
    controller.changeMarkers(
        listOf(
            platformMarker.copy(
                position = PlatformLatLng(newLatLng.latitude, newLatLng.longitude))))

    // In-place update: marker position is updated directly
    verify(marker, times(1)).position = newLatLng
    // No re-clustering needed
    verify(clusterManagersController, never()).addItems(any(), any())
    verify(clusterManagersController, never()).removeItems(any(), any())
  }

  companion object {
    private fun defaultMarker(markerId: String): PlatformMarker {
      val fakeBitmap = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888)
      val byteArrayOutputStream = ByteArrayOutputStream()
      fakeBitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream)
      val byteArray = byteArrayOutputStream.toByteArray()
      val icon =
          PlatformBitmap(
              PlatformBitmapBytesMap(
                  byteArray, PlatformMapBitmapScaling.NONE, imagePixelRatio = 1.0, null, null))
      val anchor = PlatformDoublePair(0.5, 0.0)
      val infoWindow = PlatformInfoWindow(null, null, anchor)
      return PlatformMarker(
          markerId = markerId,
          position = PlatformLatLng(0.0, 0.0),
          anchor = PlatformDoublePair(0.0, 0.0),
          flat = false,
          draggable = false,
          visible = true,
          alpha = 1.0,
          rotation = 0.0,
          zIndex = 0.0,
          consumeTapEvents = false,
          icon = icon,
          infoWindow = infoWindow,
          collisionBehavior = PlatformMarkerCollisionBehavior.REQUIRED_DISPLAY)
    }
  }
}
