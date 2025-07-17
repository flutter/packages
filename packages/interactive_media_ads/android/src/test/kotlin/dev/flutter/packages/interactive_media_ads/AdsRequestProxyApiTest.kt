// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdsRequest
import com.google.ads.interactivemedia.v3.api.player.ContentProgressProvider
import kotlin.test.Test
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify

class AdsRequestProxyApiTest {
  @Test
  fun setAdTagUrl() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRequest()

    val instance = mock<AdsRequest>()
    api.setAdTagUrl(instance, "adTag?")

    verify(instance).adTagUrl =
        "adTag?&request_agent=Flutter-IMA-${AdsRequestProxyApi.pluginVersion}"
  }

  @Test
  fun setAdTagUrlDoesNotAddRequestAgentToIncompatibleUrls() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRequest()

    val instance = mock<AdsRequest>()

    api.setAdTagUrl(instance, "adTag#")
    verify(instance).adTagUrl = "adTag#"

    api.setAdTagUrl(instance, "adTag?#")
    verify(instance).adTagUrl = "adTag?#"
  }

  @Test
  fun setContentProgressProvider() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRequest()

    val instance = mock<AdsRequest>()
    val mockProvider = mock<ContentProgressProvider>()
    api.setContentProgressProvider(instance, mockProvider)

    verify(instance).contentProgressProvider = mockProvider
  }
}
