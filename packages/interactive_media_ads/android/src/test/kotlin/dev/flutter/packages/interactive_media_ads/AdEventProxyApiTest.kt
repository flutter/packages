// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdError
import com.google.ads.interactivemedia.v3.api.AdEvent
import org.mockito.Mockito
import org.mockito.kotlin.whenever
import kotlin.test.Test
import kotlin.test.assertEquals

class AdEventProxyApiTest {
  @Test
  fun type() {
    val api = ProxyApiRegistrar(Mockito.mock(), Mockito.mock()).getPigeonApiAdEvent()

    val instance = Mockito.mock<AdEvent>()
    whenever(instance.type).thenReturn(AdEvent.AdEventType.PAUSED)

    assertEquals(AdEventType.PAUSED, api.type(instance))
  }
}