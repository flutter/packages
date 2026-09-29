// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.googlemaps

import com.google.android.gms.internal.maps.zzl
import com.google.android.gms.maps.model.Circle
import org.junit.Test
import org.mockito.Mockito

class CircleControllerTest {
  @Test
  fun controller_SetsStrokeDensity() {
    val z = Mockito.mock<zzl>(zzl::class.java)
    val circle = Mockito.spy<Circle>(Circle(z))

    val density = 5f
    val strokeWidth = 3f
    val controller = CircleController(circle, false, density)
    controller.setStrokeWidth(strokeWidth)

    Mockito.verify<Circle?>(circle).setStrokeWidth(density * strokeWidth)
  }
}
