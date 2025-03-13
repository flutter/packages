// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdEvent
import kotlin.test.Test
import kotlin.test.assertTrue
import org.mockito.Mockito
import org.mockito.kotlin.any
import org.mockito.kotlin.eq
import org.mockito.kotlin.whenever

class AdEventListenerProxyApiTest {
  @Test
  fun pigeon_defaultConstructor() {
    val api = TestProxyApiRegistrar().getPigeonApiAdEventListener()

    assertTrue(api.pigeon_defaultConstructor() is AdEventListenerProxyApi.AdEventListenerImpl)
  }

  @Test
  fun onAdEvent() {
    val mockApi = Mockito.mock<AdEventListenerProxyApi>()
    whenever(mockApi.pigeonRegistrar).thenReturn(TestProxyApiRegistrar())

    val instance = AdEventListenerProxyApi.AdEventListenerImpl(mockApi)
    val mockEvent = Mockito.mock<AdEvent>()
    instance.onAdEvent(mockEvent)

    Mockito.verify(mockApi).onAdEvent(eq(instance), eq(mockEvent), any())
  }
}
