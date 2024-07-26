// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdsManager
import kotlin.test.Test
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify

class AdsManagerProxyApiTest {
  @Test
  fun discardAdBreak() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsManager()

    val instance = mock<AdsManager>()
    api.discardAdBreak(instance)

    verify(instance).discardAdBreak()
  }

  @Test
  fun pause() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsManager()

    val instance = mock<AdsManager>()
    api.pause(instance)

    verify(instance).pause()
  }

  @Test
  fun start() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsManager()

    val instance = mock<AdsManager>()
    api.start(instance)

    verify(instance).start()
  }
}
