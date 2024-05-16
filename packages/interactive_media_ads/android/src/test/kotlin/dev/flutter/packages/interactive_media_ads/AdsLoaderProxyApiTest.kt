// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdErrorEvent
import com.google.ads.interactivemedia.v3.api.AdsLoader
import com.google.ads.interactivemedia.v3.api.AdsRequest
import kotlin.test.Test
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify

class AdsLoaderProxyApiTest {
  @Test
  fun addAdErrorListener() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsLoader()

    val instance = mock<AdsLoader>()
    val mockListener = mock<AdErrorEvent.AdErrorListener>()
    api.addAdErrorListener(instance, mockListener)

    verify(instance).addAdErrorListener(mockListener)
  }

  @Test
  fun addAdsLoadedListener() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsLoader()

    val instance = mock<AdsLoader>()
    val mockListener = mock<AdsLoader.AdsLoadedListener>()
    api.addAdsLoadedListener(instance, mockListener)

    verify(instance).addAdsLoadedListener(mockListener)
  }

  @Test
  fun requestAds() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsLoader()

    val instance = mock<AdsLoader>()
    val mockRequest = mock<AdsRequest>()
    api.requestAds(instance, mockRequest)

    verify(instance).requestAds(mockRequest)
  }
}
