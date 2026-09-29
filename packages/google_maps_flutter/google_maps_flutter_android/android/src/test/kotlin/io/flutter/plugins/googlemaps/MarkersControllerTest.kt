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
import java.util.Objects
import kotlinx.coroutines.test.runTest
import org.junit.Assert
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.any
import org.mockito.kotlin.argThat
import org.mockito.kotlin.argumentCaptor
import org.mockito.kotlin.eq
import org.mockito.kotlin.mock
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
    assetManager = ApplicationProvider.getApplicationContext<Context?>().getAssets()
    context = ApplicationProvider.getApplicationContext<Context>()
    flutterApi = spy(MapsCallbackApi(mock<BinaryMessenger>(), ""))
    clusterManagersController =
        spy(ClusterManagersController(flutterApi!!, context!!, PlatformMarkerType.MARKER))
    controller =
        MarkersController(
            flutterApi!!,
            clusterManagersController,
            assetManager,
            density,
            bitmapDescriptorFactoryWrapper,
            PlatformMarkerType.MARKER)
    markerManager = MarkerManager(googleMap)
    markerCollection = markerManager!!.newCollection()
    controller!!.setCollection(markerCollection)
    clusterManagersController!!.init(googleMap, markerManager)
  }

  @Test
  fun controller_OnMarkerDragStart() = runTest {
    val marker = mock<Marker>()

    val googleMarkerId = "abc123"

    whenever(marker.getId()).thenReturn(googleMarkerId)
    whenever(googleMap!!.addMarker(any())).thenReturn(marker)

    val latLng = LatLng(1.1, 2.2)

    val markers =
        mutableListOf<PlatformMarker?>(defaultMarkerBuilder().setMarkerId(googleMarkerId).build())
    controller!!.addMarkers(markers)
    controller!!.onMarkerDragStart(googleMarkerId, latLng)

    verify(flutterApi).onMarkerDragStart(eq(googleMarkerId), eq(Convert.latLngToPigeon(latLng)))
  }

  @Test
  fun controller_OnMarkerDragEnd() = runTest {
    val marker = mock<Marker>()

    val googleMarkerId = "abc123"

    whenever(marker.getId()).thenReturn(googleMarkerId)
    whenever(googleMap!!.addMarker(any())).thenReturn(marker)

    val latLng = LatLng(1.1, 2.2)

    val markers =
        mutableListOf<PlatformMarker?>(defaultMarkerBuilder().setMarkerId(googleMarkerId).build())
    controller!!.addMarkers(markers)
    controller!!.onMarkerDragEnd(googleMarkerId, latLng)

    verify(flutterApi).onMarkerDragEnd(eq(googleMarkerId), eq(Convert.latLngToPigeon(latLng)))
  }

  @Test
  fun controller_OnMarkerDrag() = runTest {
    val marker = mock<Marker>()

    val googleMarkerId = "abc123"

    whenever(marker.getId()).thenReturn(googleMarkerId)
    whenever(googleMap!!.addMarker(any())).thenReturn(marker)

    val latLng = LatLng(1.1, 2.2)

    val markers =
        mutableListOf<PlatformMarker?>(defaultMarkerBuilder().setMarkerId(googleMarkerId).build())

    controller!!.addMarkers(markers)
    controller!!.onMarkerDrag(googleMarkerId, latLng)

    verify(flutterApi).onMarkerDrag(eq(googleMarkerId), eq(Convert.latLngToPigeon(latLng)))
  }

  @Test(expected = NullPointerException::class)
  fun controller_AddMarkerThrowsErrorIfMarkerIdIsNull() {
    val markers = mutableListOf<PlatformMarker?>(defaultMarkerBuilder().build())
    try {
      controller!!.addMarkers(markers)
    } catch (e: NullPointerException) {
      Assert.assertEquals("markerId was null", e.message)
      throw e
    }
  }

  @Test
  fun controller_AddChangeAndRemoveMarkerWithClusterManagerId() {
    val marker = mock<Marker>()

    val googleMarkerId = "abc123"
    val clusterManagerId = "cm123"

    val builder: PlatformMarkerBuilder = defaultMarkerBuilder()
    builder
        .setMarkerId(googleMarkerId)
        .setClusterManagerId(clusterManagerId)
        .setPosition(PlatformLatLng(1.1, 2.2))

    whenever(marker.getId()).thenReturn(googleMarkerId)

    // Store reference to verify later, since markerIdToMarkerBuilder is private
    val addedMarkerBuilder = arrayOfNulls<MarkerBuilder>(1)

    // Add marker and verify addItems is called with correct parameters
    controller!!.addMarkers(mutableListOf<PlatformMarker?>(builder.build()))
    verify(clusterManagersController, times(1))
        .addItems(
            eq(clusterManagerId),
            argThat { markerBuilders: MutableList<MarkerBuilder?>? ->
              if (markerBuilders!!.size == 1 &&
                  markerBuilders.get(0)!!.clusterManagerId() == clusterManagerId) {
                // Store reference for later use in onClusterItemRendered
                addedMarkerBuilder[0] = markerBuilders.get(0)
                return@argThat true
              }
              false
            })

    // clusterManagersController calls onClusterItemRendered with created marker.
    controller!!.onClusterItemRendered(addedMarkerBuilder[0], marker)

    // Change marker to test that markerController is created and the marker can be
    // updated
    val latLng2 = LatLng(3.3, 4.4)

    builder.setPosition(PlatformLatLng(latLng2.latitude, latLng2.longitude))
    val updatedMarkers = mutableListOf<PlatformMarker?>(builder.build())

    controller!!.changeMarkers(updatedMarkers)
    verify(marker, times(1)).setPosition(latLng2)

    // Remove marker
    controller!!.removeMarkers(mutableListOf<String?>(googleMarkerId))

    verify(clusterManagersController, times(1))
        .removeItems(
            eq(clusterManagerId),
            argThat { PlatformMarkerBuilders: MutableList<MarkerBuilder?>? ->
              PlatformMarkerBuilders!!.size == 1 &&
                  (PlatformMarkerBuilders.get(0)!!.clusterManagerId() == clusterManagerId)
            })
  }

  @Test
  fun controller_AddChangeAndRemoveMarkerWithoutClusterManagerId() {
    val spyMarkerCollection = spy(markerCollection)
    controller!!.setCollection(spyMarkerCollection)

    val marker = mock<Marker>()

    val googleMarkerId = "abc123"

    whenever(marker.getId()).thenReturn(googleMarkerId)
    whenever(googleMap!!.addMarker(any())).thenReturn(marker)

    val builder: PlatformMarkerBuilder = defaultMarkerBuilder()
    builder.setMarkerId(googleMarkerId)
    controller!!.addMarkers(mutableListOf<PlatformMarker?>(builder.build()))

    // clusterManagersController should not be called when adding the marker
    verify(clusterManagersController, times(0)).addItem(any())

    verify(spyMarkerCollection, times(1)).addMarker(any())

    val alpha = 0.1f

    val markerUpdates = mutableListOf<PlatformMarker?>(builder.setAlpha(alpha.toDouble()).build())
    controller!!.changeMarkers(markerUpdates)
    verify(marker, times(1)).setAlpha(alpha)

    controller!!.removeMarkers(mutableListOf<String?>(googleMarkerId))

    // clusterManagersController should not be called when removing the marker
    verify(clusterManagersController, times(0)).removeItem(any())

    verify(spyMarkerCollection, times(1)).remove(marker)
  }

  @Test
  fun PlatformMarkerBuilder_setCollisionBehavior() {
    var platformMarker: PlatformMarker = defaultMarkerBuilder().setMarkerId("1").build()
    var markerBuilder = MarkerBuilder("m_1", "1", PlatformMarkerType.ADVANCED_MARKER)

    // Default collision behavior of an AdvancedMarker
    Convert.interpretMarkerOptions(
        platformMarker, markerBuilder, assetManager, 1f, bitmapDescriptorFactoryWrapper)
    var markerOptions = markerBuilder.build()
    Assert.assertEquals(AdvancedMarkerOptions::class.java, markerOptions.javaClass)
    Assert.assertEquals(
        CollisionBehavior.REQUIRED.toLong(),
        (markerOptions as AdvancedMarkerOptions).getCollisionBehavior().toLong())

    // Customized collision behavior of an AdvancedMarker
    platformMarker =
        defaultMarkerBuilder()
            .setMarkerId("1")
            .setCollisionBehavior(PlatformMarkerCollisionBehavior.OPTIONAL_AND_HIDES_LOWER_PRIORITY)
            .build()
    Convert.interpretMarkerOptions(
        platformMarker, markerBuilder, assetManager, 1f, bitmapDescriptorFactoryWrapper)
    markerOptions = markerBuilder.build()
    Assert.assertEquals(AdvancedMarkerOptions::class.java, markerOptions.javaClass)
    Assert.assertEquals(
        CollisionBehavior.OPTIONAL_AND_HIDES_LOWER_PRIORITY.toLong(),
        (markerOptions as AdvancedMarkerOptions).getCollisionBehavior().toLong())

    // Legacy markers don't have collision behavior in the marker options
    platformMarker = defaultMarkerBuilder().setMarkerId("1").build()
    markerBuilder = MarkerBuilder("m_1", "1", PlatformMarkerType.MARKER)
    Convert.interpretMarkerOptions(
        platformMarker, markerBuilder, assetManager, 1f, bitmapDescriptorFactoryWrapper)
    markerOptions = markerBuilder.build()
    Assert.assertEquals(MarkerOptions::class.java, markerOptions.javaClass)
  }

  @Test
  fun controller_BatchAddMultipleMarkersWithClusterManagerId() {
    val clusterManagerId = "cm123"

    // Create multiple markers with the same cluster manager
    val markers: MutableList<PlatformMarker?> = ArrayList<PlatformMarker?>()
    for (i in 0..4) {
      val builder: PlatformMarkerBuilder = defaultMarkerBuilder()
      builder
          .setMarkerId("marker" + i)
          .setClusterManagerId(clusterManagerId)
          .setPosition(PlatformLatLng(1.0 + i, 2.0 + i))
      markers.add(builder.build())
    }

    // Add all markers in one batch
    controller!!.addMarkers(markers)

    // Verify addItems is called exactly once with all 5 markers
    verify(clusterManagersController, times(1))
        .addItems(
            eq(clusterManagerId),
            argThat { PlatformMarkerBuilders: MutableList<MarkerBuilder?>? ->
              PlatformMarkerBuilders!!.size == 5 &&
                  PlatformMarkerBuilders.stream().allMatch { mb: MarkerBuilder? ->
                    mb!!.clusterManagerId() == clusterManagerId
                  }
            })

    // Verify addItem is never called (we're using batch operation)
    verify(clusterManagersController, times(0)).addItem(any())
  }

  @Test
  fun controller_BatchRemoveMultipleMarkersWithClusterManagerId() {
    val clusterManagerId = "cm123"

    // First add markers
    val markers: MutableList<PlatformMarker?> = ArrayList<PlatformMarker?>()
    val markerIds: MutableList<String?> = ArrayList<String?>()
    for (i in 0..4) {
      val markerId = "marker" + i
      markerIds.add(markerId)
      val builder: PlatformMarkerBuilder = defaultMarkerBuilder()
      builder
          .setMarkerId(markerId)
          .setClusterManagerId(clusterManagerId)
          .setPosition(PlatformLatLng(1.0 + i, 2.0 + i))
      markers.add(builder.build())
    }

    controller!!.addMarkers(markers)

    // Remove all markers in one batch
    controller!!.removeMarkers(markerIds)

    // Verify removeItems is called exactly once with all 5 markers
    verify(clusterManagersController, times(1))
        .removeItems(
            eq(clusterManagerId),
            argThat { PlatformMarkerBuilders: MutableList<MarkerBuilder?>? ->
              PlatformMarkerBuilders!!.size == 5 &&
                  PlatformMarkerBuilders.stream().allMatch { mb: MarkerBuilder? ->
                    mb!!.clusterManagerId() == clusterManagerId
                  }
            })

    // Verify removeItem is never called (we're using batch operation)
    verify(clusterManagersController, times(0)).removeItem(any())
  }

  @Test
  fun controller_BatchChangeMarkersWithClusterManagerChange() {
    val clusterManagerId1 = "cm123"
    val clusterManagerId2 = "cm456"

    // First add markers to cluster manager 1
    val initialMarkers: MutableList<PlatformMarker?> = ArrayList<PlatformMarker?>()
    for (i in 0..4) {
      val builder: PlatformMarkerBuilder = defaultMarkerBuilder()
      builder
          .setMarkerId("marker" + i)
          .setClusterManagerId(clusterManagerId1)
          .setPosition(PlatformLatLng(1.0 + i, 2.0 + i))
      initialMarkers.add(builder.build())
    }
    controller!!.addMarkers(initialMarkers)

    // Reset mock to clear invocation counts
    reset(clusterManagersController)

    // Now change all markers to cluster manager 2
    val changedMarkers: MutableList<PlatformMarker?> = ArrayList<PlatformMarker?>()
    for (i in 0..4) {
      val builder: PlatformMarkerBuilder = defaultMarkerBuilder()
      builder
          .setMarkerId("marker" + i)
          .setClusterManagerId(clusterManagerId2) // Different cluster manager
          .setPosition(PlatformLatLng(3.0 + i, 4.0 + i))
      changedMarkers.add(builder.build())
    }
    controller!!.changeMarkers(changedMarkers)

    // Verify removeItems is called exactly once for cluster manager 1 with all 5
    // markers
    verify(clusterManagersController, times(1))
        .removeItems(
            eq(clusterManagerId1),
            argThat { PlatformMarkerBuilders: MutableList<MarkerBuilder?>? ->
              PlatformMarkerBuilders!!.size == 5 &&
                  PlatformMarkerBuilders.stream().allMatch { mb: MarkerBuilder? ->
                    mb!!.clusterManagerId() == clusterManagerId1
                  }
            })

    // Verify addItems is called exactly once for cluster manager 2 with all 5
    // markers
    verify(clusterManagersController, times(1))
        .addItems(
            eq(clusterManagerId2),
            argThat { PlatformMarkerBuilders: MutableList<MarkerBuilder?>? ->
              PlatformMarkerBuilders!!.size == 5 &&
                  PlatformMarkerBuilders.stream().allMatch { mb: MarkerBuilder? ->
                    mb!!.clusterManagerId() == clusterManagerId2
                  }
            })

    // Verify individual operations are never called (we're using batch operations)
    verify(clusterManagersController, times(0)).addItem(any())
    verify(clusterManagersController, times(0)).removeItem(any())
  }

  @Test
  fun controller_ChangeMarkerInPlace() {
    val marker = mock<Marker>()
    val markerId = "marker1"
    val clusterManagerId = "cm123"

    whenever(marker.getId()).thenReturn(markerId)

    // Add a clustered marker
    val builder: PlatformMarkerBuilder = defaultMarkerBuilder()
    builder
        .setMarkerId(markerId)
        .setClusterManagerId(clusterManagerId)
        .setPosition(PlatformLatLng(1.0, 2.0))
    controller!!.addMarkers(mutableListOf<PlatformMarker?>(builder.build()))

    // Capture the PlatformMarkerBuilder passed to addItems
    val captor = argumentCaptor<List<MarkerBuilder>>()
    verify(clusterManagersController).addItems(eq(clusterManagerId), captor.capture()!!)
    val capturedMarkerBuilder = captor.firstValue[0]

    // Simulate cluster render so markerController exists
    controller!!.onClusterItemRendered(capturedMarkerBuilder, marker)

    // Reset to clear invocation counts
    reset(clusterManagersController)

    // Change marker in place (same clusterManagerId)
    val newLatLng = LatLng(3.0, 4.0)
    builder.setPosition(PlatformLatLng(newLatLng.latitude, newLatLng.longitude))
    controller!!.changeMarkers(mutableListOf<PlatformMarker?>(builder.build()))

    // In-place update: marker position is updated directly
    verify(marker, times(1)).setPosition(newLatLng)
    // No re-clustering needed
    verify(clusterManagersController, times(0)).addItems(any(), any())
    verify(clusterManagersController, times(0)).removeItems(any(), any())
  }

  // Remove this if builders are added to the Kotlin generator; see discussion in
  // https://github.com/flutter/flutter/issues/158287
  private class PlatformMarkerBuilder {
    private var alpha: Double? = null
    private var anchor: PlatformDoublePair? = null
    private var consumeTapEvents: Boolean? = null
    private var draggable: Boolean? = null
    private var flat: Boolean? = null
    private var icon: PlatformBitmap? = null
    private var infoWindow: PlatformInfoWindow? = null
    private var position: PlatformLatLng? = null
    private var rotation: Double? = null
    private var visible: Boolean? = null
    private var zIndex: Double? = null
    private var markerId: String? = null
    private var clusterManagerId: String? = null
    private var collisionBehavior: PlatformMarkerCollisionBehavior? = null

    fun setAlpha(setterArg: Double): PlatformMarkerBuilder {
      this.alpha = setterArg
      return this
    }

    fun setAnchor(setterArg: PlatformDoublePair): PlatformMarkerBuilder {
      this.anchor = setterArg
      return this
    }

    fun setConsumeTapEvents(setterArg: Boolean): PlatformMarkerBuilder {
      this.consumeTapEvents = setterArg
      return this
    }

    fun setDraggable(setterArg: Boolean): PlatformMarkerBuilder {
      this.draggable = setterArg
      return this
    }

    fun setFlat(setterArg: Boolean): PlatformMarkerBuilder {
      this.flat = setterArg
      return this
    }

    fun setIcon(setterArg: PlatformBitmap): PlatformMarkerBuilder {
      this.icon = setterArg
      return this
    }

    fun setInfoWindow(setterArg: PlatformInfoWindow): PlatformMarkerBuilder {
      this.infoWindow = setterArg
      return this
    }

    fun setPosition(setterArg: PlatformLatLng): PlatformMarkerBuilder {
      this.position = setterArg
      return this
    }

    fun setRotation(setterArg: Double): PlatformMarkerBuilder {
      this.rotation = setterArg
      return this
    }

    fun setVisible(setterArg: Boolean): PlatformMarkerBuilder {
      this.visible = setterArg
      return this
    }

    fun setZIndex(setterArg: Double): PlatformMarkerBuilder {
      this.zIndex = setterArg
      return this
    }

    fun setMarkerId(setterArg: String): PlatformMarkerBuilder {
      this.markerId = setterArg
      return this
    }

    fun setClusterManagerId(setterArg: String?): PlatformMarkerBuilder {
      this.clusterManagerId = setterArg
      return this
    }

    fun setCollisionBehavior(setterArg: PlatformMarkerCollisionBehavior): PlatformMarkerBuilder {
      this.collisionBehavior = setterArg
      return this
    }

    fun build(): PlatformMarker {
      return PlatformMarker(
          Objects.requireNonNull<Double?>(alpha),
          Objects.requireNonNull<PlatformDoublePair?>(anchor),
          Objects.requireNonNull<Boolean?>(consumeTapEvents),
          Objects.requireNonNull<Boolean?>(draggable),
          Objects.requireNonNull<Boolean?>(flat),
          Objects.requireNonNull<PlatformBitmap?>(icon),
          Objects.requireNonNull<PlatformInfoWindow?>(infoWindow),
          Objects.requireNonNull<PlatformLatLng?>(position),
          Objects.requireNonNull<Double?>(rotation),
          Objects.requireNonNull<Boolean?>(visible),
          Objects.requireNonNull<Double?>(zIndex),
          Objects.requireNonNull<String?>(markerId),
          clusterManagerId,
          Objects.requireNonNull<PlatformMarkerCollisionBehavior?>(collisionBehavior))
    }
  }

  companion object {
    private fun defaultMarkerBuilder(): PlatformMarkerBuilder {
      val fakeBitmap = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888)
      val byteArrayOutputStream = ByteArrayOutputStream()
      fakeBitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream)
      val byteArray = byteArrayOutputStream.toByteArray()
      val icon =
          PlatformBitmap(
              PlatformBitmapBytesMap(
                  byteArray, PlatformMapBitmapScaling.NONE, /* imagePixelRatio */ 1.0, null, null))
      val anchor = PlatformDoublePair(0.5, 0.0)
      val infoWindow = PlatformInfoWindow(null, null, anchor)
      return PlatformMarkerBuilder()
          .setPosition(PlatformLatLng(0.0, 0.0))
          .setAnchor(PlatformDoublePair(0.0, 0.0))
          .setFlat(false)
          .setDraggable(false)
          .setVisible(true)
          .setAlpha(1.0)
          .setRotation(0.0)
          .setZIndex(0.0)
          .setConsumeTapEvents(false)
          .setIcon(icon)
          .setInfoWindow(infoWindow)
          .setCollisionBehavior(PlatformMarkerCollisionBehavior.REQUIRED_DISPLAY)
    }
  }
}
