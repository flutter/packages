// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.googlemaps

import com.google.android.gms.internal.maps.zzar
import com.google.android.gms.maps.model.Polyline
import org.junit.Test
import org.mockito.kotlin.mock
import org.mockito.kotlin.spy
import org.mockito.kotlin.verify

class PolylineControllerTest {
  @Test
  fun controller_SetsStrokeDensity() {
    val z = mock<zzar>()
    val polyline = spy(Polyline(z))

    val density = 5f
    val strokeWidth = 3f
    val controller = PolylineController(polyline, false, density)
    controller.setWidth(strokeWidth)

    verify(polyline).width = density * strokeWidth
  }
}
