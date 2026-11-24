// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.googlemaps

import com.google.android.gms.internal.maps.zzl
import com.google.android.gms.maps.model.Circle
import org.junit.Test
import org.mockito.kotlin.mock
import org.mockito.kotlin.spy
import org.mockito.kotlin.verify

class CircleControllerTest {
  @Test
  fun controller_SetsStrokeDensity() {
    val z = mock<zzl>()
    val circle = spy(Circle(z))

    val density = 5f
    val strokeWidth = 3f
    val controller = CircleController(circle, false, density)
    controller.setStrokeWidth(strokeWidth)

    verify(circle).strokeWidth = density * strokeWidth
  }
}
