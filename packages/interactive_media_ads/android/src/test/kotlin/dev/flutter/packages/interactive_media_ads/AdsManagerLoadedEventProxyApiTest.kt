// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdsManager
import com.google.ads.interactivemedia.v3.api.AdsManagerLoadedEvent
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.Mockito
import org.mockito.kotlin.whenever

class AdsManagerLoadedEventProxyApiTest {
  @Test
  fun manager() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsManagerLoadedEvent()

    val instance = Mockito.mock<AdsManagerLoadedEvent>()
    val mockManager = Mockito.mock<AdsManager>()
    whenever(instance.adsManager).thenReturn(mockManager)

    assertEquals(mockManager, api.manager(instance))
  }
}
