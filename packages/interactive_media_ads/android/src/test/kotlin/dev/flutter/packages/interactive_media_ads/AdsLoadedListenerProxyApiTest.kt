// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdsManagerLoadedEvent
import kotlin.test.Test
import kotlin.test.assertTrue
import org.mockito.Mockito
import org.mockito.kotlin.any
import org.mockito.kotlin.eq
import org.mockito.kotlin.whenever

class AdsLoadedListenerProxyApiTest {
  @Test
  fun pigeon_defaultConstructor() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsLoadedListener()

    assertTrue(api.pigeon_defaultConstructor() is AdsLoadedListenerProxyApi.AdsLoadedListenerImpl)
  }

  @Test
  fun onAdsManagerLoaded() {
    val mockApi = Mockito.mock<AdsLoadedListenerProxyApi>()
    whenever(mockApi.pigeonRegistrar).thenReturn(TestProxyApiRegistrar())

    val instance = AdsLoadedListenerProxyApi.AdsLoadedListenerImpl(mockApi)
    val mockEvent = Mockito.mock<AdsManagerLoadedEvent>()
    instance.onAdsManagerLoaded(mockEvent)

    Mockito.verify(mockApi).onAdsManagerLoaded(eq(instance), eq(mockEvent), any())
  }
}
