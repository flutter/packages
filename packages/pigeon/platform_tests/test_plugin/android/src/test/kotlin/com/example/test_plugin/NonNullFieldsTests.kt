// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin

import org.junit.Assert.assertEquals
import org.junit.Test

class NonNullFieldsTests {

  @Test
  fun testMake() {
    val request = NonNullFieldSearchRequest("hello")
    assertEquals("hello", request.query)
  }

  @Test
  fun testEquality() {
    val request1 = NonNullFieldSearchRequest("hello")
    val request2 = NonNullFieldSearchRequest("hello")
    val request3 = NonNullFieldSearchRequest("world")

    assertEquals(request1, request2)
    assert(request1 != request3)
    assertEquals(request1.hashCode(), request2.hashCode())
  }
}
