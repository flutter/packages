// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.googlemaps

import com.google.android.gms.internal.maps.zzl
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.model.Circle
import com.google.android.gms.maps.model.CircleOptions
import org.junit.After
import org.junit.Assert
import org.junit.Before
import org.junit.Test
import org.mockito.ArgumentMatchers
import org.mockito.Mock
import org.mockito.Mockito
import org.mockito.MockitoAnnotations
import java.lang.AutoCloseable

class CirclesControllerTest {
    @Mock
    var mockGoogleMap: GoogleMap? = null
    var mockCloseable: AutoCloseable? = null

    @Before
    fun setUp() {
        mockCloseable = MockitoAnnotations.openMocks(this)
    }

    @After
    @Throws(Exception::class)
    fun tearDown() {
        mockCloseable!!.close()
    }

    @Test
    fun controller_changeCircles_updatesExistingCircle() {
        val z = Mockito.mock<zzl>(zzl::class.java)
        val circle = Mockito.spy<Circle?>(Circle(z))
        Mockito.`when`<Circle?>(
            mockGoogleMap!!.addCircle(
                ArgumentMatchers.any<CircleOptions?>(
                    CircleOptions::class.java
                )
            )
        ).thenReturn(circle)

        val controller = CirclesController(null, 1.0f)
        controller.setGoogleMap(mockGoogleMap)

        val id = "a_circle"

        controller.addCircles(
            mutableListOf<PlatformCircle?>(
                createCircle(
                    id,  /* consumesEvents */
                    false
                )
            )
        )
        // There should be exactly one circle.
        Assert.assertEquals(1, controller.circleIdToController.size.toLong())

        controller.changeCircles(
            mutableListOf<PlatformCircle?>(createCircle(id,  /* consumesEvents */true))
        )
        // There should still only be one circle, and it should be updated.
        Assert.assertEquals(1, controller.circleIdToController.size.toLong())
        Mockito.verify<Circle?>(circle, Mockito.times(1)).setClickable(true)
    }

    private fun createCircle(circleId: String, consumesEvents: Boolean): PlatformCircle {
        return PlatformCircle(
            consumesEvents,  /* fillColor */
            PlatformColor(0L),  /* strokeColor */
            PlatformColor(0L),  /* visible */
            true,  /* strokeWidth */
            1L,  /* zIndex */
            0.0,  /* center */
            (PlatformLatLng(0.0, 0.0)),  /* radius */
            1.0,
            circleId
        )
    }
}
