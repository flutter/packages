// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.UniversalAdId
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.kotlin.mock
import org.mockito.kotlin.whenever

class UniversalAdIdProxyApiTest {
  @Test
  fun adIdRegistry() {
    val api = TestProxyApiRegistrar().getPigeonApiUniversalAdId()

    val instance = mock<UniversalAdId>()
    val value = "myString"
    whenever(instance.adIdRegistry).thenReturn(value)

    assertEquals(value, api.adIdRegistry(instance))
  }

  @Test
  fun adIdValue() {
    val api = TestProxyApiRegistrar().getPigeonApiUniversalAdId()

    val instance = mock<UniversalAdId>()
    val value = "myString"
    whenever(instance.adIdValue).thenReturn(value)

    assertEquals(value, api.adIdValue(instance))
  }
}
