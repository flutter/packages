// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdErrorEvent
import com.google.ads.interactivemedia.v3.api.AdsLoader
import com.google.ads.interactivemedia.v3.api.AdsRequest
import com.google.ads.interactivemedia.v3.api.ImaSdkSettings
import com.google.ads.interactivemedia.v3.api.StreamRequest
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever

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

  @Test
  fun getSettings() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsLoader()

    val instance = mock<AdsLoader>()
    val value = mock<ImaSdkSettings>()
    whenever(instance.getSettings()).thenReturn(value)

    assertEquals(value, api.getSettings(instance))
  }

  @Test
  fun release() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsLoader()

    val instance = mock<AdsLoader>()
    api.release(instance)

    verify(instance).release()
  }

  @Test
  fun removeAdErrorListener() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsLoader()

    val instance = mock<AdsLoader>()
    val errorListener = mock<AdErrorEvent.AdErrorListener>()
    api.removeAdErrorListener(instance, errorListener)

    verify(instance).removeAdErrorListener(errorListener)
  }

  @Test
  fun removeAdsLoadedListener() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsLoader()

    val instance = mock<AdsLoader>()
    val loadedListener = mock<AdsLoader.AdsLoadedListener>()
    api.removeAdsLoadedListener(instance, loadedListener)

    verify(instance).removeAdsLoadedListener(loadedListener)
  }

  @Test
  fun requestStream() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsLoader()

    val instance = mock<AdsLoader>()
    val streamRequest = mock<StreamRequest>()
    val value = "myString"
    whenever(instance.requestStream(streamRequest)).thenReturn(value)

    assertEquals(value, api.requestStream(instance, streamRequest))
  }
}
