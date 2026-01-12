// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.Ad
import com.google.ads.interactivemedia.v3.api.AdEvent
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.Mockito
import org.mockito.kotlin.whenever

class AdEventProxyApiTest {
  @Test
  fun type() {
    val api = TestProxyApiRegistrar().getPigeonApiAdEvent()

    val instance = Mockito.mock<AdEvent>()
    whenever(instance.type).thenReturn(AdEvent.AdEventType.PAUSED)

    assertEquals(AdEventType.PAUSED, api.type(instance))
  }

  @Test
  fun adData() {
    val api = TestProxyApiRegistrar().getPigeonApiAdEvent()

    val instance = Mockito.mock<AdEvent>()
    whenever(instance.adData).thenReturn(mapOf("a" to "b", "c" to "d"))

    assertEquals(mapOf("a" to "b", "c" to "d"), api.adData(instance))
  }

  @Test
  fun ad() {
    val api = TestProxyApiRegistrar().getPigeonApiAdEvent()

    val ad = Mockito.mock<Ad>()
    val instance = Mockito.mock<AdEvent>()
    whenever(instance.ad).thenReturn(ad)

    assertEquals(ad, api.ad(instance))
  }
}
