// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdErrorEvent
import kotlin.test.Test
import kotlin.test.assertTrue
import org.mockito.Mockito.mock
import org.mockito.Mockito.verify
import org.mockito.kotlin.any
import org.mockito.kotlin.eq
import org.mockito.kotlin.whenever

internal class AdErrorListenerProxyApiTest {
  @Test
  fun pigeon_defaultConstructor() {
    val api = TestProxyApiRegistrar().getPigeonApiAdErrorListener()

    assertTrue(api.pigeon_defaultConstructor() is AdErrorListenerProxyApi.AdErrorListenerImpl)
  }

  @Test
  fun onAdError() {
    val mockApi = mock<AdErrorListenerProxyApi>()
    whenever(mockApi.pigeonRegistrar).thenReturn(TestProxyApiRegistrar())

    val instance = AdErrorListenerProxyApi.AdErrorListenerImpl(mockApi)
    val mockEvent = mock<AdErrorEvent>()
    instance.onAdError(mockEvent)

    verify(mockApi).onAdError(eq(instance), eq(mockEvent), any())
  }
}
