// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.googlemaps

import android.content.Context
import android.content.res.AssetManager
import android.graphics.Bitmap
import androidx.test.core.app.ApplicationProvider
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.maps.android.clustering.Cluster
import com.google.maps.android.clustering.ClusterManager
import com.google.maps.android.clustering.algo.StaticCluster
import com.google.maps.android.collections.MarkerManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.googlemaps.ClusterManagersController.AdvancedMarkerClusterRenderer
import io.flutter.plugins.googlemaps.ClusterManagersController.MarkerClusterRenderer
import io.flutter.plugins.googlemaps.Convert.BitmapDescriptorFactoryWrapper
import org.junit.After
import org.junit.Assert
import org.junit.Before
import org.junit.Test
import org.junit.function.ThrowingRunnable
import org.junit.runner.RunWith
import org.mockito.ArgumentMatchers
import org.mockito.Mock
import org.mockito.Mockito
import org.mockito.MockitoAnnotations
import org.robolectric.RobolectricTestRunner
import java.io.ByteArrayOutputStream
import java.lang.AutoCloseable

@RunWith(RobolectricTestRunner::class)
class ClusterManagersControllerTest {
    private var context: Context? = null
    private var flutterApi: MapsCallbackApi? = null
    private var controller: ClusterManagersController? = null
    private var googleMap: GoogleMap? = null
    private var markerManager: MarkerManager? = null
    private var assetManager: AssetManager? = null
    private val density = 1f

    @Mock
    var bitmapFactory: BitmapDescriptorFactoryWrapper? = null

    private var mocksClosable: AutoCloseable? = null

    @Before
    fun setUp() {
        mocksClosable = MockitoAnnotations.openMocks(this)
        context = ApplicationProvider.getApplicationContext<Context>()
        assetManager = context!!.getAssets()
        flutterApi = Mockito.spy<MapsCallbackApi>(
            MapsCallbackApi(
                Mockito.mock<BinaryMessenger?>(BinaryMessenger::class.java), ""
            )
        )
        controller = Mockito.spy<ClusterManagersController>(
            ClusterManagersController(
                flutterApi!!,
                context!!,
                PlatformMarkerType.MARKER
            )
        )
        googleMap = Mockito.mock<GoogleMap>(GoogleMap::class.java)
        markerManager = MarkerManager(googleMap)
        controller!!.init(googleMap, markerManager)
    }

    @After
    @Throws(Exception::class)
    fun close() {
        mocksClosable!!.close()
    }

    @Test
    fun AddClusterManagersAndMarkers() {
        val clusterManagerId = "cm_1"
        val markerId1 = "mid_1"
        val markerId2 = "mid_2"

        val latLng1 = LatLng(1.1, 2.2)
        val latLng2 = LatLng(3.3, 4.4)

        val location1: MutableList<Double?> = ArrayList<Double?>()
        location1.add(latLng1.latitude)
        location1.add(latLng1.longitude)

        val location2: MutableList<Double?> = ArrayList<Double?>()
        location2.add(latLng2.latitude)
        location2.add(latLng2.longitude)

        Mockito.`when`<CameraPosition?>(googleMap!!.getCameraPosition())
            .thenReturn(CameraPosition.builder().target(LatLng(0.0, 0.0)).build())
        val initialClusterManager = PlatformClusterManager(clusterManagerId)
        val clusterManagersToAdd: MutableList<PlatformClusterManager?> =
            ArrayList<PlatformClusterManager?>()
        clusterManagersToAdd.add(initialClusterManager)
        controller!!.addClusterManagers(clusterManagersToAdd)

        val markerBuilder1 =
            MarkerBuilder(markerId1, clusterManagerId, PlatformMarkerType.MARKER)
        val markerBuilder2 =
            MarkerBuilder(markerId2, clusterManagerId, PlatformMarkerType.MARKER)

        val markerData1 = createPlatformMarker(markerId1, location1, clusterManagerId)
        val markerData2 = createPlatformMarker(markerId2, location2, clusterManagerId)

        Convert.interpretMarkerOptions(
            markerData1, markerBuilder1, assetManager, density, bitmapFactory
        )
        Convert.interpretMarkerOptions(
            markerData2, markerBuilder2, assetManager, density, bitmapFactory
        )

        controller!!.addItem(markerBuilder1)
        controller!!.addItem(markerBuilder2)

        val clusters =
            controller!!.getClustersWithClusterManagerId(clusterManagerId)
        Assert.assertEquals("Amount of clusters should be 1", 1, clusters.size.toLong())

        val cluster: Cluster<MarkerBuilder> = clusters.iterator().next()
        Assert.assertNotNull("Cluster position should not be null", cluster.getPosition())
        val markerIds: MutableSet<String?> = HashSet<String?>()
        for (marker in cluster.getItems()) {
            markerIds.add(marker.markerId())
        }
        Assert.assertTrue("Marker IDs should contain markerId1", markerIds.contains(markerId1))
        Assert.assertTrue("Marker IDs should contain markerId2", markerIds.contains(markerId2))
        Assert.assertEquals(
            "Cluster should contain exactly 2 markers",
            2,
            cluster.getSize().toLong()
        )
    }

    @Test
    fun SelectClusterRenderer() {
        val defaultClusterManagerId = "cm_default"
        val advancedClusterManagerId = "cm_advanced"
        val defaultMarkerId = "mid_default"
        val advancedMarkerId = "mid_advanced"

        Mockito.`when`<CameraPosition?>(googleMap!!.getCameraPosition())
            .thenReturn(CameraPosition.builder().target(LatLng(0.0, 0.0)).build())

        val defaultController =
            Mockito.spy<ClusterManagersController>(
                ClusterManagersController(
                    flutterApi!!,
                    context!!,
                    PlatformMarkerType.MARKER
                )
            )
        defaultController.init(googleMap, markerManager)
        val advancedController =
            Mockito.spy<ClusterManagersController>(
                ClusterManagersController(
                    flutterApi!!,
                    context!!,
                    PlatformMarkerType.ADVANCED_MARKER
                )
            )
        advancedController.init(googleMap, markerManager)

        val initialClusterManager1 =
            PlatformClusterManager(defaultClusterManagerId)
        val clusterManagersToAdd1: MutableList<PlatformClusterManager?> =
            ArrayList<PlatformClusterManager?>()
        clusterManagersToAdd1.add(initialClusterManager1)
        defaultController.addClusterManagers(clusterManagersToAdd1)

        val initialClusterManager2 =
            PlatformClusterManager(advancedClusterManagerId)
        val clusterManagersToAdd2: MutableList<PlatformClusterManager?> =
            ArrayList<PlatformClusterManager?>()
        clusterManagersToAdd2.add(initialClusterManager2)
        advancedController.addClusterManagers(clusterManagersToAdd2)

        val defaultMarkerBuilder =
            MarkerBuilder(defaultMarkerId, defaultClusterManagerId, PlatformMarkerType.MARKER)
        defaultMarkerBuilder.setPosition(LatLng(10.0, 20.0))
        defaultController.addItem(defaultMarkerBuilder)

        val advancedMarkerBuilder =
            MarkerBuilder(
                advancedMarkerId, advancedClusterManagerId, PlatformMarkerType.ADVANCED_MARKER
            )
        advancedMarkerBuilder.setPosition(LatLng(20.0, 10.0))
        advancedController.addItem(advancedMarkerBuilder)

        val clusterManager1: ClusterManager<*>? =
            defaultController.clusterManagerIdToManager.get(defaultClusterManagerId)
        Assert.assertNotNull(clusterManager1)
        Assert.assertSame(
            MarkerClusterRenderer::class.java,
            clusterManager1!!.getRenderer().javaClass
        )

        val clusterManager2: ClusterManager<*>? =
            advancedController.clusterManagerIdToManager.get(advancedClusterManagerId)
        Assert.assertNotNull(clusterManager2)
        Assert.assertSame(
            AdvancedMarkerClusterRenderer::class.java,
            clusterManager2!!.getRenderer().javaClass
        )
    }

    @Test
    fun OnClusterClickCallsMethodChannel() {
        val clusterManagerId = "cm_1"
        val clusterPosition = LatLng(43.00, -87.90)
        val markerPosition1 = LatLng(43.05, -87.95)
        val markerPosition2 = LatLng(43.02, -87.92)

        val cluster = StaticCluster<MarkerBuilder?>(clusterPosition)

        val marker1 = MarkerBuilder("m_1", clusterManagerId, PlatformMarkerType.MARKER)
        marker1.setPosition(markerPosition1)
        cluster.add(marker1)

        val marker2 = MarkerBuilder("m_2", clusterManagerId, PlatformMarkerType.MARKER)
        marker2.setPosition(markerPosition2)
        cluster.add(marker2)

        controller!!.onClusterClick(cluster)
        Mockito.verify<MapsCallbackApi?>(flutterApi)
            .onClusterTap(
                ArgumentMatchers.eq<PlatformCluster?>(
                    Convert.clusterToPigeon(
                        clusterManagerId,
                        cluster
                    )
                ), null
            )
    }

    @Test
    fun RemoveClusterManagers() {
        val clusterManagerId = "cm_1"

        Mockito.`when`<CameraPosition?>(googleMap!!.getCameraPosition())
            .thenReturn(CameraPosition.builder().target(LatLng(0.0, 0.0)).build())
        val initialClusterManager = PlatformClusterManager(clusterManagerId)
        val clusterManagersToAdd: MutableList<PlatformClusterManager?> =
            ArrayList<PlatformClusterManager?>()
        clusterManagersToAdd.add(initialClusterManager)
        controller!!.addClusterManagers(clusterManagersToAdd)

        // Verify that fetching the cluster data success and therefore ClusterManager is added.
        controller!!.getClustersWithClusterManagerId(clusterManagerId)

        controller!!.removeClusterManagers(mutableListOf<String?>(clusterManagerId))
        // Verify that fetching the cluster data fails and therefore ClusterManager is removed.
        Assert.assertThrows<FlutterError?>(
            FlutterError::class.java,
            ThrowingRunnable { controller!!.getClustersWithClusterManagerId(clusterManagerId) })
    }

    private fun createPlatformMarker(
        markerId: String, location: MutableList<Double?>, clusterManagerId: String?
    ): PlatformMarker {
        val fakeBitmap = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888)
        val byteArrayOutputStream = ByteArrayOutputStream()
        fakeBitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream)
        val byteArray = byteArrayOutputStream.toByteArray()
        val icon =
            PlatformBitmap(
                PlatformBitmapBytesMap(
                    byteArray, PlatformMapBitmapScaling.NONE,  /* imagePixelRatio */1.0, null, null
                )
            )
        val anchor = PlatformDoublePair(0.0, 0.0)
        return PlatformMarker( /* alpha */
            1.0,
            anchor,  /* consumeTapEvents */
            false,  /* draggable */
            false,  /* flat */
            false,
            icon,
            PlatformInfoWindow( /* title */null,  /* snippet */null, anchor),  /* position */
            PlatformLatLng(location.get(0)!!, location.get(1)!!),  /* rotation */
            0.0,  /* visible */
            true,  /* zIndex */
            0.0,
            markerId,
            clusterManagerId,
            PlatformMarkerCollisionBehavior.REQUIRED_DISPLAY
        )
    }
}
