// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.googlemaps

import junit.framework.TestCase
import org.junit.Test

class CircleBuilderTest {
  @Test
  fun density_AppliesToStrokeWidth() {
    val density = 5f
    val strokeWidth = 3f
    val builder = CircleBuilder(density)
    builder.setStrokeWidth(strokeWidth)

    val options = builder.build()
    val width = options.strokeWidth

    TestCase.assertEquals(density * strokeWidth, width)
  }
}
