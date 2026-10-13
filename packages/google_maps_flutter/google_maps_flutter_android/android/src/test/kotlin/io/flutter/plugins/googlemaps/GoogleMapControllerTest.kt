// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.googlemaps

import android.content.Context
import androidx.activity.ComponentActivity
import androidx.test.core.app.ApplicationProvider
import com.google.android.gms.maps.CameraUpdate
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.MapCapabilities
import com.google.android.gms.maps.model.Marker
import com.google.android.gms.maps.model.PointOfInterest
import io.flutter.plugin.common.BinaryMessenger
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito
import org.mockito.kotlin.any
import org.mockito.kotlin.eq
import org.mockito.kotlin.isNull
import org.mockito.kotlin.mock
import org.mockito.kotlin.spy
import org.mockito.kotlin.times
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class GoogleMapControllerTest {
  private lateinit var context: Context
  private lateinit var activity: ComponentActivity

  private val mockMessenger: BinaryMessenger = mock()

  private val mockGoogleMap: GoogleMap = mock()

  private val flutterApi: MapsCallbackApi = mock()

  private val mockClusterManagersController: ClusterManagersController = mock()

  private val mockMarkersController: MarkersController = mock()

  private val mockPolygonsController: PolygonsController = mock()

  private val mockPolylinesController: PolylinesController = mock()

  private val mockCirclesController: CirclesController = mock()

  private val mockHeatmapsController: HeatmapsController = mock()

  private val mockTileOverlaysController: TileOverlaysController = mock()

  private val mockGroundOverlaysController: GroundOverlaysController = mock()

  private val mapCapabilities: MapCapabilities = mock()

  @Before
  fun before() {
    context = ApplicationProvider.getApplicationContext()
    setUpActivityLegacy()
  }

  // Returns GoogleMapController instance.
  private fun createGoogleMapController(): GoogleMapController {
    return GoogleMapController(
            0, context, mockMessenger, { activity.lifecycle }, null, PlatformMarkerType.MARKER)
        .apply { init() }
  }

  // Returns GoogleMapController instance with mocked dependency injections.
  private fun createGoogleMapControllerWithMockedDependencies(): GoogleMapController {
    return GoogleMapController(
            0,
            context,
            mockMessenger,
            flutterApi,
            { activity.lifecycle },
            null,
            mockClusterManagersController,
            mockMarkersController,
            mockPolygonsController,
            mockPolylinesController,
            mockCirclesController,
            mockHeatmapsController,
            mockTileOverlaysController,
            mockGroundOverlaysController)
        .apply { init() }
  }

  // TODO(stuartmorgan): Update this to a non-deprecated test API.
  // See https://github.com/flutter/flutter/issues/122102
  @Suppress("deprecation")
  private fun setUpActivityLegacy() {
    activity = Robolectric.setupActivity(ComponentActivity::class.java)
  }

  @Test
  fun disposeReleaseTheMap() {
    val googleMapController = createGoogleMapController()
    googleMapController.onMapReady(mockGoogleMap)
    assertNotNull(googleMapController)
    googleMapController.dispose()
    assertNull(googleMapController.view)
  }

  @Test
  fun onDestroyReleaseTheMap() {
    val googleMapController = createGoogleMapController()
    googleMapController.onMapReady(mockGoogleMap)
    assertNotNull(googleMapController)
    googleMapController.onDestroy(activity)
    assertNull(googleMapController.view)
  }

  @Test
  fun onMapReadySetsPaddingIfInitialPaddingIsThere() {
    val googleMapController = createGoogleMapController()
    val padding = 10f
    val paddingWithDensity = (padding * googleMapController.density).toInt()
    googleMapController.setInitialPadding(padding, padding, padding, padding)
    googleMapController.onMapReady(mockGoogleMap)
    verify(mockGoogleMap, times(1))
        .setPadding(paddingWithDensity, paddingWithDensity, paddingWithDensity, paddingWithDensity)
  }

  @Test
  fun setPaddingStoresThePaddingValuesInInInitialPaddingWhenGoogleMapIsNull() {
    val googleMapController = createGoogleMapController()
    assertNull(googleMapController.initialPadding)
    googleMapController.setPadding(0f, 0f, 0f, 0f)
    assertNotNull(googleMapController.initialPadding)
    assertEquals(4, googleMapController.initialPadding.size)
  }

  @Test
  fun onMapReadySetsMarkerCollectionListener() {
    val spyGoogleMapController = spy(createGoogleMapController())
    // setMarkerCollectionListener method should be called when map is ready
    spyGoogleMapController.onMapReady(mockGoogleMap)

    // Verify if the setMarkerCollectionListener method is called with listener
    verify(spyGoogleMapController, times(1)).setMarkerCollectionListener(any())

    spyGoogleMapController.dispose()
    // Verify if the setMarkerCollectionListener is cleared on dispose
    verify(spyGoogleMapController, times(1)).setMarkerCollectionListener(null)
  }

  @Test
  fun onMapReadySetsClusterItemClickListener() {
    val spyGoogleMapController = spy(createGoogleMapController())
    // setMarkerCollectionListener method should be called when map is ready
    spyGoogleMapController.onMapReady(mockGoogleMap)

    // Verify if the setMarkerCollectionListener method is called with listener
    verify(spyGoogleMapController, times(1)).setClusterItemClickListener(any())

    spyGoogleMapController.dispose()
    // Verify if the setMarkerCollectionListener is cleared on dispose
    verify(spyGoogleMapController, times(1)).setClusterItemClickListener(null)
  }

  @Test
  fun onMapReadySetsClusterItemInfoWindowClickListener() {
    val spyGoogleMapController = spy(createGoogleMapController())
    spyGoogleMapController.onMapReady(mockGoogleMap)

    verify(spyGoogleMapController, times(1)).setClusterItemInfoWindowClickListener(any())

    spyGoogleMapController.dispose()
    verify(spyGoogleMapController, times(1)).setClusterItemInfoWindowClickListener(null)
  }

  @Test
  fun onMapReadySetsClusterItemRenderedListener() {
    val spyGoogleMapController = spy(createGoogleMapController())
    // setMarkerCollectionListener method should be called when map is ready
    spyGoogleMapController.onMapReady(mockGoogleMap)

    // Verify if the setMarkerCollectionListener method is called with listener
    verify(spyGoogleMapController, times(1)).setClusterItemRenderedListener(any())

    spyGoogleMapController.dispose()
    // Verify if the setMarkerCollectionListener is cleared on dispose
    verify(spyGoogleMapController, times(1)).setClusterItemRenderedListener(null)
  }

  @Test
  fun setInitialClusterManagers() {
    val googleMapController = createGoogleMapControllerWithMockedDependencies()
    val initialClusterManager = PlatformClusterManager("cm_1")
    googleMapController.setInitialClusterManagers(listOf(initialClusterManager))
    googleMapController.onMapReady(mockGoogleMap)

    // Verify if the ClusterManagersController.addClusterManagers method is called with initial
    // cluster managers.
    verify(mockClusterManagersController, times(1)).addClusterManagers(any())
  }

  @Test
  fun onClusterItemRenderedCallsMarkersController() {
    val googleMapController = createGoogleMapControllerWithMockedDependencies()
    val markerBuilder = MarkerBuilder("m_1", "cm_1", PlatformMarkerType.MARKER)
    val marker = mock<Marker>()
    googleMapController.onClusterItemRendered(markerBuilder, marker)
    verify(mockMarkersController, times(1)).onClusterItemRendered(markerBuilder, marker)
  }

  @Test
  fun onClusterItemClickCallsMarkersController() {
    val googleMapController = createGoogleMapControllerWithMockedDependencies()
    val markerBuilder = MarkerBuilder("m_1", "cm_1", PlatformMarkerType.MARKER)

    googleMapController.onClusterItemClick(markerBuilder)
    verify(mockMarkersController, times(1)).onMarkerTap(markerBuilder.markerId())
  }

  @Test
  fun onClusterItemInfoWindowClickCallsMarkersController() {
    val googleMapController = createGoogleMapControllerWithMockedDependencies()
    val markerBuilder = MarkerBuilder("m_1", "cm_1", PlatformMarkerType.MARKER)

    googleMapController.onClusterItemInfoWindowClick(markerBuilder)
    verify(mockMarkersController, times(1)).onClusterItemInfoWindowTap(markerBuilder.markerId())
  }

  @Test
  fun onPoiClickCallsFlutterApi() = runTest {
    val googleMapController = createGoogleMapControllerWithMockedDependencies()
    googleMapController.onMapReady(mockGoogleMap)

    val pointOfInterest = PointOfInterest(LatLng(0.0, 0.0), "place-123", "Test Place")
    googleMapController.onPoiClick(pointOfInterest)

    verify(flutterApi, times(1)).onPointOfInterestTap(eq("place-123"))
  }

  @Test
  fun setInitialHeatmaps() {
    val googleMapController = createGoogleMapControllerWithMockedDependencies()

    val initialHeatmaps = listOf(createHeatmap("hm_1"))
    googleMapController.setInitialHeatmaps(initialHeatmaps)
    googleMapController.onMapReady(mockGoogleMap)

    // Verify if the HeatmapsController.addHeatmaps method is called with initial heatmaps.
    verify(mockHeatmapsController, times(1)).addHeatmaps(initialHeatmaps)
  }

  @Test
  fun updateHeatmaps() {
    val googleMapController = createGoogleMapControllerWithMockedDependencies()

    val toAdd = listOf(createHeatmap("hm_add"))
    val toChange = listOf(createHeatmap("hm_change"))
    val idsToRemove = listOf("hm_1")

    googleMapController.updateHeatmaps(toAdd, toChange, idsToRemove)

    verify(mockHeatmapsController, times(1)).addHeatmaps(toAdd)
    verify(mockHeatmapsController, times(1)).changeHeatmaps(toChange)
    verify(mockHeatmapsController, times(1)).removeHeatmaps(idsToRemove)
  }

  @Test
  fun animateCamera() {
    val googleMapController = createGoogleMapControllerWithMockedDependencies()
    googleMapController.onMapReady(mockGoogleMap)

    val newCameraPosition = PlatformCameraUpdateZoomBy(1.0, null)
    val cameraUpdate = PlatformCameraUpdate(newCameraPosition)

    Mockito.mockStatic(CameraUpdateFactory::class.java).use { mockedFactory ->
      mockedFactory.whenever { CameraUpdateFactory.zoomBy(any()) }.thenReturn(mock<CameraUpdate>())
      googleMapController.animateCamera(cameraUpdate, null)
    }
    verify(mockGoogleMap, times(1)).animateCamera(any())
  }

  @Test
  fun animateCameraWithDuration() {
    val googleMapController = createGoogleMapControllerWithMockedDependencies()
    googleMapController.onMapReady(mockGoogleMap)

    val newCameraPosition = PlatformCameraUpdateZoomBy(1.0, null)
    val cameraUpdate = PlatformCameraUpdate(newCameraPosition)

    val durationMilliseconds = 1000L

    Mockito.mockStatic(CameraUpdateFactory::class.java).use { mockedFactory ->
      mockedFactory.whenever { CameraUpdateFactory.zoomBy(any()) }.thenReturn(mock<CameraUpdate>())
      googleMapController.animateCamera(cameraUpdate, durationMilliseconds)
    }
    verify(mockGoogleMap, times(1)).animateCamera(any(), eq(durationMilliseconds.toInt()), isNull())
  }

  @Test
  fun getCameraPositionReturnsCorrectData() {
    val googleMapController = createGoogleMapControllerWithMockedDependencies()
    googleMapController.onMapReady(mockGoogleMap)

    val cameraPosition = CameraPosition(LatLng(10.0, 20.0), 15.0f, 30.0f, 45.0f)
    whenever(mockGoogleMap.cameraPosition).thenReturn(cameraPosition)

    val result = googleMapController.getCameraPosition()

    assertEquals(cameraPosition.target.latitude, result.target.latitude, 1e-15)
    assertEquals(cameraPosition.target.longitude, result.target.longitude, 1e-15)
    assertEquals(cameraPosition.zoom.toDouble(), result.zoom, 1e-15)
    assertEquals(cameraPosition.tilt.toDouble(), result.tilt, 1e-15)
    assertEquals(cameraPosition.bearing.toDouble(), result.bearing, 1e-15)
  }

  @Test
  fun isAdvancedMarkersAvailableReturnsCorrectData() {
    val googleMapController = createGoogleMapControllerWithMockedDependencies()
    googleMapController.onMapReady(mockGoogleMap)

    whenever(mockGoogleMap.mapCapabilities).thenReturn(mapCapabilities)
    whenever(mapCapabilities.isAdvancedMarkersAvailable).thenReturn(true)
    assertTrue(googleMapController.isAdvancedMarkersAvailable())

    whenever(mapCapabilities.isAdvancedMarkersAvailable).thenReturn(false)
    assertFalse(googleMapController.isAdvancedMarkersAvailable())
  }

  private fun createHeatmap(id: String): PlatformHeatmap {
    val heatmapData = listOf(PlatformWeightedLatLng(PlatformLatLng(1.1, 2.2), 3.3))
    return PlatformHeatmap(id, heatmapData, null, opacity = 1.0, radius = 20, null)
  }
}
