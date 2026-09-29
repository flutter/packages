// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.googlemaps

import com.google.android.gms.internal.maps.zzar
import com.google.android.gms.maps.model.Polyline
import org.junit.Test
import org.mockito.Mockito

class PolylineControllerTest {
    @Test
    fun controller_SetsStrokeDensity() {
        val z = Mockito.mock<zzar>(zzar::class.java)
        val polyline = Mockito.spy<Polyline>(Polyline(z))

        val density = 5f
        val strokeWidth = 3f
        val controller = PolylineController(polyline, false, density)
        controller.setWidth(strokeWidth)

        Mockito.verify<Polyline?>(polyline).setWidth(density * strokeWidth)
    }
}
