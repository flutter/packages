// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.googlemaps

import com.google.android.gms.internal.maps.zzl
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.model.Circle
import com.google.android.gms.maps.model.CircleOptions
import java.lang.AutoCloseable
import org.junit.After
import org.junit.Assert
import org.junit.Before
import org.junit.Test
import org.mockito.kotlin.any
import org.mockito.kotlin.mock
import org.mockito.kotlin.spy
import org.mockito.kotlin.times
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever

class CirclesControllerTest {
  var mockGoogleMap: GoogleMap = mock()

  @Test
  fun controller_changeCircles_updatesExistingCircle() {
    val z = mock<zzl>()
    val circle = spy(Circle(z))
    whenever(
            mockGoogleMap!!.addCircle(any()))
        .thenReturn(circle)

    val controller = CirclesController(null, 1.0f)
    controller.setGoogleMap(mockGoogleMap)

    val id = "a_circle"

    controller.addCircles(
        mutableListOf<PlatformCircle?>(createCircle(id, /* consumesEvents */ false)))
    // There should be exactly one circle.
    Assert.assertEquals(1, controller.circleIdToController.size.toLong())

    controller.changeCircles(
        mutableListOf<PlatformCircle?>(createCircle(id, /* consumesEvents */ true)))
    // There should still only be one circle, and it should be updated.
    Assert.assertEquals(1, controller.circleIdToController.size.toLong())
    verify(circle, times(1)).setClickable(true)
  }

  private fun createCircle(circleId: String, consumesEvents: Boolean): PlatformCircle {
    return PlatformCircle(
        consumesEvents, /* fillColor */
        PlatformColor(0L), /* strokeColor */
        PlatformColor(0L), /* visible */
        true, /* strokeWidth */
        1L, /* zIndex */
        0.0, /* center */
        (PlatformLatLng(0.0, 0.0)), /* radius */
        1.0,
        circleId)
  }
}
