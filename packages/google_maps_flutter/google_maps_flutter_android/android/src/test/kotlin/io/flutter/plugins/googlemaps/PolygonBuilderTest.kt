// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.googlemaps

import org.junit.Assert.assertEquals
import org.junit.Test

class PolygonBuilderTest {
  @Test
  fun density_AppliesToStrokeWidth() {
    val density = 5f
    val strokeWidth = 3f

    val builder = PolygonBuilder(density)
    builder.setStrokeWidth(strokeWidth)

    val options = builder.build()
    val width = options.strokeWidth

    assertEquals(density * strokeWidth, width)
  }
}
