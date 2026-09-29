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
import com.google.android.gms.maps.GoogleMap.CancelableCallback
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.MapCapabilities
import com.google.android.gms.maps.model.Marker
import com.google.android.gms.maps.model.PointOfInterest
import com.google.maps.android.clustering.ClusterManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.googlemaps.ClusterManagersController.OnClusterItemRendered
import org.junit.After
import org.junit.Assert
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.ArgumentMatchers
import org.mockito.Mock
import org.mockito.MockedStatic
import org.mockito.Mockito
import org.mockito.MockitoAnnotations
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import java.lang.AutoCloseable
import java.util.List

@RunWith(RobolectricTestRunner::class)
class GoogleMapControllerTest {
    private var context: Context? = null
    private var activity: ComponentActivity? = null

    var mockCloseable: AutoCloseable? = null

    @Mock
    var mockMessenger: BinaryMessenger? = null

    @Mock
    var mockGoogleMap: GoogleMap? = null

    @Mock
    var flutterApi: MapsCallbackApi? = null

    @Mock
    var mockClusterManagersController: ClusterManagersController? = null

    @Mock
    var mockMarkersController: MarkersController? = null

    @Mock
    var mockPolygonsController: PolygonsController? = null

    @Mock
    var mockPolylinesController: PolylinesController? = null

    @Mock
    var mockCirclesController: CirclesController? = null

    @Mock
    var mockHeatmapsController: HeatmapsController? = null

    @Mock
    var mockTileOverlaysController: TileOverlaysController? = null

    @Mock
    var mockGroundOverlaysController: GroundOverlaysController? = null

    @Mock
    var mapCapabilities: MapCapabilities? = null

    @Before
    fun before() {
        mockCloseable = MockitoAnnotations.openMocks(this)
        context = ApplicationProvider.getApplicationContext<Context?>()
        setUpActivityLegacy()
    }

    val googleMapController: GoogleMapController
        // Returns GoogleMapController instance.
        get() {
            val googleMapController =
                GoogleMapController(
                    0,
                    context,
                    mockMessenger,
                    LifecycleProvider { activity.getLifecycle() },
                    null,
                    PlatformMarkerType.MARKER
                )
            googleMapController.init()
            return googleMapController
        }

    val googleMapControllerWithMockedDependencies: GoogleMapController
        // Returns GoogleMapController instance with mocked dependency injections.
        get() {
            val googleMapController =
                GoogleMapController(
                    0,
                    context,
                    mockMessenger,
                    flutterApi,
                    LifecycleProvider { activity.getLifecycle() },
                    null,
                    mockClusterManagersController,
                    mockMarkersController,
                    mockPolygonsController,
                    mockPolylinesController,
                    mockCirclesController,
                    mockHeatmapsController,
                    mockTileOverlaysController,
                    mockGroundOverlaysController
                )
            googleMapController.init()
            return googleMapController
        }

    // TODO(stuartmorgan): Update this to a non-deprecated test API.
    // See https://github.com/flutter/flutter/issues/122102
    @Suppress("deprecation")
    private fun setUpActivityLegacy() {
        activity = Robolectric.setupActivity<ComponentActivity>(ComponentActivity::class.java)
    }

    @After
    @Throws(Exception::class)
    fun tearDown() {
        mockCloseable!!.close()
    }

    @Test
    fun DisposeReleaseTheMap() {
        val googleMapController = this.googleMapController
        googleMapController.onMapReady(mockGoogleMap!!)
        Assert.assertNotNull(googleMapController)
        googleMapController.dispose()
        Assert.assertNull(googleMapController.getView())
    }

    @Test
    fun OnDestroyReleaseTheMap() {
        val googleMapController = this.googleMapController
        googleMapController.onMapReady(mockGoogleMap!!)
        Assert.assertNotNull(googleMapController)
        googleMapController.onDestroy(activity!!)
        Assert.assertNull(googleMapController.getView())
    }

    @Test
    fun OnMapReadySetsPaddingIfInitialPaddingIsThere() {
        val googleMapController = this.googleMapController
        val padding = 10f
        val paddingWithDensity = (padding * googleMapController.density).toInt()
        googleMapController.setInitialPadding(padding, padding, padding, padding)
        googleMapController.onMapReady(mockGoogleMap!!)
        Mockito.verify<GoogleMap?>(mockGoogleMap, Mockito.times(1))
            .setPadding(
                paddingWithDensity,
                paddingWithDensity,
                paddingWithDensity,
                paddingWithDensity
            )
    }

    @Test
    fun SetPaddingStoresThePaddingValuesInInInitialPaddingWhenGoogleMapIsNull() {
        val googleMapController = this.googleMapController
        Assert.assertNull(googleMapController.initialPadding)
        googleMapController.setPadding(0f, 0f, 0f, 0f)
        Assert.assertNotNull(googleMapController.initialPadding)
        Assert.assertEquals(4, googleMapController.initialPadding.size.toLong())
    }

    @Test
    fun OnMapReadySetsMarkerCollectionListener() {
        val googleMapController = this.googleMapController
        val spyGoogleMapController = Mockito.spy<GoogleMapController>(googleMapController)
        // setMarkerCollectionListener method should be called when map is ready
        spyGoogleMapController.onMapReady(mockGoogleMap!!)

        // Verify if the setMarkerCollectionListener method is called with listener
        Mockito.verify<GoogleMapController?>(spyGoogleMapController, Mockito.times(1))
            .setMarkerCollectionListener(ArgumentMatchers.any<GoogleMapListener?>(GoogleMapListener::class.java))

        spyGoogleMapController.dispose()
        // Verify if the setMarkerCollectionListener is cleared on dispose
        Mockito.verify<GoogleMapController?>(spyGoogleMapController, Mockito.times(1))
            .setMarkerCollectionListener(null)
    }

    @Test
    fun OnMapReadySetsClusterItemClickListener() {
        val googleMapController = this.googleMapController
        val spyGoogleMapController = Mockito.spy<GoogleMapController>(googleMapController)
        // setMarkerCollectionListener method should be called when map is ready
        spyGoogleMapController.onMapReady(mockGoogleMap!!)

        // Verify if the setMarkerCollectionListener method is called with listener
        Mockito.verify<GoogleMapController?>(spyGoogleMapController, Mockito.times(1))
            .setClusterItemClickListener(
                ArgumentMatchers.any<ClusterManager.OnClusterItemClickListener<*>?>(
                    ClusterManager.OnClusterItemClickListener::class.java
                )
            )

        spyGoogleMapController.dispose()
        // Verify if the setMarkerCollectionListener is cleared on dispose
        Mockito.verify<GoogleMapController?>(spyGoogleMapController, Mockito.times(1))
            .setClusterItemClickListener(null)
    }

    @Test
    fun OnMapReadySetsClusterItemInfoWindowClickListener() {
        val googleMapController = this.googleMapController
        val spyGoogleMapController = Mockito.spy<GoogleMapController>(googleMapController)
        spyGoogleMapController.onMapReady(mockGoogleMap!!)

        Mockito.verify<GoogleMapController?>(spyGoogleMapController, Mockito.times(1))
            .setClusterItemInfoWindowClickListener(
                ArgumentMatchers.any<ClusterManager.OnClusterItemInfoWindowClickListener<*>?>(
                    ClusterManager.OnClusterItemInfoWindowClickListener::class.java
                )
            )

        spyGoogleMapController.dispose()
        Mockito.verify<GoogleMapController?>(spyGoogleMapController, Mockito.times(1))
            .setClusterItemInfoWindowClickListener(null)
    }

    @Test
    fun OnMapReadySetsClusterItemRenderedListener() {
        val googleMapController = this.googleMapController
        val spyGoogleMapController = Mockito.spy<GoogleMapController>(googleMapController)
        // setMarkerCollectionListener method should be called when map is ready
        spyGoogleMapController.onMapReady(mockGoogleMap!!)

        // Verify if the setMarkerCollectionListener method is called with listener
        Mockito.verify<GoogleMapController?>(spyGoogleMapController, Mockito.times(1))
            .setClusterItemRenderedListener(
                ArgumentMatchers.any<OnClusterItemRendered<*>?>(
                    OnClusterItemRendered::class.java
                )
            )

        spyGoogleMapController.dispose()
        // Verify if the setMarkerCollectionListener is cleared on dispose
        Mockito.verify<GoogleMapController?>(spyGoogleMapController, Mockito.times(1))
            .setClusterItemRenderedListener(null)
    }

    @Test
    fun SetInitialClusterManagers() {
        val googleMapController =
            this.googleMapControllerWithMockedDependencies
        val initialClusterManager = PlatformClusterManager("cm_1")
        val initialClusterManagers: MutableList<PlatformClusterManager?> =
            ArrayList<PlatformClusterManager?>()
        initialClusterManagers.add(initialClusterManager)
        googleMapController.setInitialClusterManagers(initialClusterManagers)
        googleMapController.onMapReady(mockGoogleMap!!)

        // Verify if the ClusterManagersController.addClusterManagers method is called with initial
        // cluster managers.
        Mockito.verify<ClusterManagersController?>(mockClusterManagersController, Mockito.times(1))
            .addClusterManagers(
                ArgumentMatchers.any<MutableList<PlatformClusterManager?>?>()
            )
    }

    @Test
    fun OnClusterItemRenderedCallsMarkersController() {
        val googleMapController =
            this.googleMapControllerWithMockedDependencies
        val markerBuilder = MarkerBuilder("m_1", "cm_1", PlatformMarkerType.MARKER)
        val marker = Mockito.mock<Marker>(Marker::class.java)
        googleMapController.onClusterItemRendered(markerBuilder, marker)
        Mockito.verify<MarkersController?>(mockMarkersController, Mockito.times(1))
            .onClusterItemRendered(markerBuilder, marker)
    }

    @Test
    fun OnClusterItemClickCallsMarkersController() {
        val googleMapController =
            this.googleMapControllerWithMockedDependencies
        val markerBuilder = MarkerBuilder("m_1", "cm_1", PlatformMarkerType.MARKER)

        googleMapController.onClusterItemClick(markerBuilder)
        Mockito.verify<MarkersController?>(mockMarkersController, Mockito.times(1))
            .onMarkerTap(markerBuilder.markerId())
    }

    @Test
    fun OnClusterItemInfoWindowClickCallsMarkersController() {
        val googleMapController =
            this.googleMapControllerWithMockedDependencies
        val markerBuilder = MarkerBuilder("m_1", "cm_1", PlatformMarkerType.MARKER)

        googleMapController.onClusterItemInfoWindowClick(markerBuilder)
        Mockito.verify<MarkersController?>(mockMarkersController, Mockito.times(1))
            .onClusterItemInfoWindowTap(markerBuilder.markerId())
    }

    @Test
    fun OnPoiClickCallsFlutterApi() {
        val googleMapController =
            this.googleMapControllerWithMockedDependencies
        googleMapController.onMapReady(mockGoogleMap!!)

        val pointOfInterest =
            PointOfInterest(LatLng(0.0, 0.0), "place-123", "Test Place")
        googleMapController.onPoiClick(pointOfInterest)

        Mockito.verify<MapsCallbackApi?>(flutterApi, Mockito.times(1)).onPointOfInterestTap(
            ArgumentMatchers.eq<String?>("place-123"), null
        )
    }

    @Test
    fun OnPoiClickNullPlaceIdDoesNotCallFlutterApi() {
        val googleMapController =
            this.googleMapControllerWithMockedDependencies
        googleMapController.onMapReady(mockGoogleMap!!)

        googleMapController.onPoiClick(PointOfInterest(LatLng(0.0, 0.0), null, "Test Place"))

        Mockito.verify<MapsCallbackApi?>(flutterApi, Mockito.times(0)).onPointOfInterestTap(
            ArgumentMatchers.any<String>(), null
        )
    }

    @Test
    fun SetInitialHeatmaps() {
        val googleMapController =
            this.googleMapControllerWithMockedDependencies

        val initialHeatmaps = List.of<PlatformHeatmap?>(createHeatmap("hm_1"))
        googleMapController.setInitialHeatmaps(initialHeatmaps)
        googleMapController.onMapReady(mockGoogleMap!!)

        // Verify if the HeatmapsController.addHeatmaps method is called with initial heatmaps.
        Mockito.verify<HeatmapsController?>(mockHeatmapsController, Mockito.times(1))
            .addHeatmaps(initialHeatmaps)
    }

    @Test
    fun UpdateHeatmaps() {
        val googleMapController =
            this.googleMapControllerWithMockedDependencies

        val toAdd = List.of<PlatformHeatmap?>(createHeatmap("hm_add"))
        val toChange = List.of<PlatformHeatmap?>(createHeatmap("hm_change"))
        val idsToRemove = mutableListOf<String?>("hm_1")

        googleMapController.updateHeatmaps(toAdd, toChange, idsToRemove)

        Mockito.verify<HeatmapsController?>(mockHeatmapsController, Mockito.times(1))
            .addHeatmaps(toAdd)
        Mockito.verify<HeatmapsController?>(mockHeatmapsController, Mockito.times(1))
            .changeHeatmaps(toChange)
        Mockito.verify<HeatmapsController?>(mockHeatmapsController, Mockito.times(1))
            .removeHeatmaps(idsToRemove)
    }

    @Test
    fun AnimateCamera() {
        val googleMapController =
            this.googleMapControllerWithMockedDependencies
        googleMapController.onMapReady(mockGoogleMap!!)

        val newCameraPosition = PlatformCameraUpdateZoomBy(1.0, null)
        val cameraUpdate = PlatformCameraUpdate(newCameraPosition)

        Mockito.mockStatic<CameraUpdateFactory?>(CameraUpdateFactory::class.java)
            .use { mockedFactory ->
                mockedFactory
                    .`when`<Any?>(MockedStatic.Verification {
                        CameraUpdateFactory.zoomBy(
                            ArgumentMatchers.anyFloat()
                        )
                    })
                    .thenReturn(Mockito.mock<CameraUpdate?>(CameraUpdate::class.java))
                googleMapController.animateCamera(cameraUpdate, null)
            }
        Mockito.verify<GoogleMap?>(mockGoogleMap, Mockito.times(1))
            .animateCamera(ArgumentMatchers.any<CameraUpdate?>(CameraUpdate::class.java))
    }

    @Test
    fun AnimateCameraWithDuration() {
        val googleMapController =
            this.googleMapControllerWithMockedDependencies
        googleMapController.onMapReady(mockGoogleMap!!)

        val newCameraPosition = PlatformCameraUpdateZoomBy(1.0, null)
        val cameraUpdate = PlatformCameraUpdate(newCameraPosition)

        val durationMilliseconds = 1000L

        Mockito.mockStatic<CameraUpdateFactory?>(CameraUpdateFactory::class.java)
            .use { mockedFactory ->
                mockedFactory
                    .`when`<Any?>(MockedStatic.Verification {
                        CameraUpdateFactory.zoomBy(
                            ArgumentMatchers.anyFloat()
                        )
                    })
                    .thenReturn(Mockito.mock<CameraUpdate?>(CameraUpdate::class.java))
                googleMapController.animateCamera(cameraUpdate, durationMilliseconds)
            }
        Mockito.verify<GoogleMap?>(mockGoogleMap, Mockito.times(1))
            .animateCamera(
                ArgumentMatchers.any<CameraUpdate?>(CameraUpdate::class.java),
                ArgumentMatchers.eq(durationMilliseconds.toInt()),
                ArgumentMatchers.isNull<CancelableCallback?>()
            )
    }

    @Test
    fun getCameraPositionReturnsCorrectData() {
        val googleMapController =
            this.googleMapControllerWithMockedDependencies
        googleMapController.onMapReady(mockGoogleMap!!)

        val cameraPosition = CameraPosition(LatLng(10.0, 20.0), 15.0f, 30.0f, 45.0f)
        Mockito.`when`<CameraPosition?>(mockGoogleMap!!.getCameraPosition())
            .thenReturn(cameraPosition)

        val result = googleMapController.getCameraPosition()

        Assert.assertEquals(cameraPosition.target.latitude, result.target.latitude, 1e-15)
        Assert.assertEquals(cameraPosition.target.longitude, result.target.longitude, 1e-15)
        Assert.assertEquals(cameraPosition.zoom.toDouble(), result.zoom, 1e-15)
        Assert.assertEquals(cameraPosition.tilt.toDouble(), result.tilt, 1e-15)
        Assert.assertEquals(cameraPosition.bearing.toDouble(), result.bearing, 1e-15)
    }

    @Test
    fun isAdvancedMarkersAvailableReturnsCorrectData() {
        val googleMapController =
            this.googleMapControllerWithMockedDependencies
        googleMapController.onMapReady(mockGoogleMap!!)

        Mockito.`when`<MapCapabilities?>(mockGoogleMap!!.getMapCapabilities())
            .thenReturn(mapCapabilities)
        Mockito.`when`<Boolean?>(mapCapabilities!!.isAdvancedMarkersAvailable()).thenReturn(true)
        Assert.assertTrue(googleMapController.isAdvancedMarkersAvailable())

        Mockito.`when`<Boolean?>(mapCapabilities!!.isAdvancedMarkersAvailable()).thenReturn(false)
        Assert.assertFalse(googleMapController.isAdvancedMarkersAvailable())
    }

    private fun createHeatmap(id: String): PlatformHeatmap {
        val heatmapData =
            List.of<PlatformWeightedLatLng?>(PlatformWeightedLatLng(PlatformLatLng(1.1, 2.2), 3.3))
        return PlatformHeatmap(id, heatmapData, null,  /* opacity */1.0,  /* radius */20, null)
    }
}
