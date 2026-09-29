// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.googlemaps

import com.google.android.gms.internal.maps.zzao
import com.google.android.gms.maps.model.Polygon
import org.junit.Test
import org.mockito.Mockito

class PolygonControllerTest {
  @Test
  fun controller_SetsStrokeDensity() {
    val z = Mockito.mock<zzao>(zzao::class.java)
    val polygon = Mockito.spy<Polygon>(Polygon(z))

    val density = 5f
    val strokeWidth = 3f
    val controller = PolygonController(polygon, false, density)
    controller.setStrokeWidth(strokeWidth)

    Mockito.verify<Polygon?>(polygon).setStrokeWidth(density * strokeWidth)
  }
}
