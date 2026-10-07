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
import com.google.maps.android.clustering.algo.StaticCluster
import com.google.maps.android.collections.MarkerManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.googlemaps.ClusterManagersController.AdvancedMarkerClusterRenderer
import io.flutter.plugins.googlemaps.ClusterManagersController.MarkerClusterRenderer
import io.flutter.plugins.googlemaps.Convert.BitmapDescriptorFactoryWrapper
import java.io.ByteArrayOutputStream
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertSame
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.eq
import org.mockito.kotlin.mock
import org.mockito.kotlin.spy
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ClusterManagersControllerTest {
  private lateinit var context: Context
  private lateinit var flutterApi: MapsCallbackApi
  private lateinit var controller: ClusterManagersController
  private val googleMap: GoogleMap = mock()
  private lateinit var markerManager: MarkerManager
  private lateinit var assetManager: AssetManager
  private val density = 1f

  private val bitmapFactory: BitmapDescriptorFactoryWrapper = mock()

  @Before
  fun setUp() {
    context = ApplicationProvider.getApplicationContext()
    assetManager = context.assets
    flutterApi = spy(MapsCallbackApi(mock<BinaryMessenger>(), ""))
    controller = spy(ClusterManagersController(flutterApi, context, PlatformMarkerType.MARKER))
    markerManager = MarkerManager(googleMap)
    controller.init(googleMap, markerManager)
  }

  @Test
  fun addClusterManagersAndMarkers() {
    val clusterManagerId = "cm_1"
    val markerId1 = "mid_1"
    val markerId2 = "mid_2"

    val latLng1 = PlatformLatLng(1.1, 2.2)
    val latLng2 = PlatformLatLng(3.3, 4.4)

    whenever(googleMap.cameraPosition)
        .thenReturn(CameraPosition.builder().target(LatLng(0.0, 0.0)).build())
    val initialClusterManager = PlatformClusterManager(clusterManagerId)
    controller.addClusterManagers(listOf(initialClusterManager))

    val markerBuilder1 = MarkerBuilder(markerId1, clusterManagerId, PlatformMarkerType.MARKER)
    val markerBuilder2 = MarkerBuilder(markerId2, clusterManagerId, PlatformMarkerType.MARKER)

    val markerData1 = createPlatformMarker(markerId1, latLng1, clusterManagerId)
    val markerData2 = createPlatformMarker(markerId2, latLng2, clusterManagerId)

    Convert.interpretMarkerOptions(
        markerData1, markerBuilder1, assetManager, density, bitmapFactory)
    Convert.interpretMarkerOptions(
        markerData2, markerBuilder2, assetManager, density, bitmapFactory)

    controller.addItem(markerBuilder1)
    controller.addItem(markerBuilder2)

    val clusters = controller.getClustersWithClusterManagerId(clusterManagerId)

    val cluster: Cluster<MarkerBuilder> = clusters.single()
    assertNotNull("Cluster position should not be null", cluster.position)
    val markerIds: Set<String> = cluster.getItems().map { it.markerId() }.toSet()
    assertTrue("Marker IDs should contain markerId1", markerIds.contains(markerId1))
    assertTrue("Marker IDs should contain markerId2", markerIds.contains(markerId2))
    assertEquals("Cluster should contain exactly 2 markers", 2, cluster.size)
  }

  @Test
  fun selectClusterRenderer() {
    val defaultClusterManagerId = "cm_default"
    val advancedClusterManagerId = "cm_advanced"
    val defaultMarkerId = "mid_default"
    val advancedMarkerId = "mid_advanced"

    whenever(googleMap.cameraPosition)
        .thenReturn(CameraPosition.builder().target(LatLng(0.0, 0.0)).build())

    val defaultController =
        spy(ClusterManagersController(flutterApi, context, PlatformMarkerType.MARKER))
    defaultController.init(googleMap, markerManager)
    val advancedController =
        spy(ClusterManagersController(flutterApi, context, PlatformMarkerType.ADVANCED_MARKER))
    advancedController.init(googleMap, markerManager)

    val initialClusterManager1 = PlatformClusterManager(defaultClusterManagerId)
    defaultController.addClusterManagers(listOf(initialClusterManager1))

    val initialClusterManager2 = PlatformClusterManager(advancedClusterManagerId)
    advancedController.addClusterManagers(listOf(initialClusterManager2))

    val defaultMarkerBuilder =
        MarkerBuilder(defaultMarkerId, defaultClusterManagerId, PlatformMarkerType.MARKER)
    defaultMarkerBuilder.position = LatLng(10.0, 20.0)
    defaultController.addItem(defaultMarkerBuilder)

    val advancedMarkerBuilder =
        MarkerBuilder(
            advancedMarkerId, advancedClusterManagerId, PlatformMarkerType.ADVANCED_MARKER)
    advancedMarkerBuilder.position = LatLng(20.0, 10.0)
    advancedController.addItem(advancedMarkerBuilder)

    val clusterManager1 = defaultController.clusterManagerIdToManager[defaultClusterManagerId]
    assertNotNull(clusterManager1)
    assertSame(MarkerClusterRenderer::class.java, clusterManager1?.renderer?.javaClass)

    val clusterManager2 = advancedController.clusterManagerIdToManager[advancedClusterManagerId]
    assertNotNull(clusterManager2)
    assertSame(AdvancedMarkerClusterRenderer::class.java, clusterManager2?.renderer?.javaClass)
  }

  @Test
  fun onClusterClickCallsMethodChannel() = runTest {
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

    controller.onClusterClick(cluster)
    verify(flutterApi).onClusterTap(eq(Convert.clusterToPigeon(clusterManagerId, cluster)))
  }

  @Test
  fun removeClusterManagers() {
    val clusterManagerId = "cm_1"

    whenever(googleMap.cameraPosition)
        .thenReturn(CameraPosition.builder().target(LatLng(0.0, 0.0)).build())
    val initialClusterManager = PlatformClusterManager(clusterManagerId)
    val clusterManagersToAdd = listOf(initialClusterManager)
    controller.addClusterManagers(clusterManagersToAdd)

    // Verify that fetching the cluster data success and therefore ClusterManager is added.
    controller.getClustersWithClusterManagerId(clusterManagerId)

    controller.removeClusterManagers(listOf(clusterManagerId))
    // Verify that fetching the cluster data fails and therefore ClusterManager is removed.
    assertThrows(FlutterError::class.java) {
      controller.getClustersWithClusterManagerId(clusterManagerId)
    }
  }

  private fun createPlatformMarker(
      markerId: String,
      location: PlatformLatLng,
      clusterManagerId: String?
  ): PlatformMarker {
    val fakeBitmap = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888)
    val byteArrayOutputStream = ByteArrayOutputStream()
    fakeBitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream)
    val byteArray = byteArrayOutputStream.toByteArray()
    val icon =
        PlatformBitmap(
            PlatformBitmapBytesMap(
                byteArray, PlatformMapBitmapScaling.NONE, imagePixelRatio = 1.0, null, null))
    val anchor = PlatformDoublePair(0.0, 0.0)
    return PlatformMarker(
        alpha = 1.0,
        anchor,
        consumeTapEvents = false,
        draggable = false,
        flat = false,
        icon,
        PlatformInfoWindow(title = null, snippet = null, anchor),
        position = location,
        rotation = 0.0,
        visible = true,
        zIndex = 0.0,
        markerId = markerId,
        clusterManagerId = clusterManagerId,
        PlatformMarkerCollisionBehavior.REQUIRED_DISPLAY)
  }
}
