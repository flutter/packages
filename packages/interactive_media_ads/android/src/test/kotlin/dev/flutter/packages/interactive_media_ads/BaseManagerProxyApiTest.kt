// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.Ad
import com.google.ads.interactivemedia.v3.api.AdErrorEvent
import com.google.ads.interactivemedia.v3.api.AdEvent
import com.google.ads.interactivemedia.v3.api.AdProgressInfo
import com.google.ads.interactivemedia.v3.api.AdsRenderingSettings
import com.google.ads.interactivemedia.v3.api.BaseManager
import junit.framework.TestCase.assertEquals
import kotlin.test.Test
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever

class BaseManagerProxyApiTest {
  @Test
  fun addAdErrorListener() {
    val api = TestProxyApiRegistrar().getPigeonApiBaseManager()

    val instance = mock<BaseManager>()
    val mockListener = mock<AdErrorEvent.AdErrorListener>()
    api.addAdErrorListener(instance, mockListener)

    verify(instance).addAdErrorListener(mockListener)
  }

  @Test
  fun addAdEventListener() {
    val api = TestProxyApiRegistrar().getPigeonApiBaseManager()

    val instance = mock<BaseManager>()
    val mockListener = mock<AdEvent.AdEventListener>()
    api.addAdEventListener(instance, mockListener)

    verify(instance).addAdEventListener(mockListener)
  }

  @Test
  fun destroy() {
    val api = TestProxyApiRegistrar().getPigeonApiBaseManager()

    val instance = mock<BaseManager>()
    api.destroy(instance)

    verify(instance).destroy()
  }

  @Test
  fun init() {
    val api = TestProxyApiRegistrar().getPigeonApiBaseManager()

    val instance = mock<BaseManager>()
    val settings = mock<AdsRenderingSettings>()
    api.init(instance, settings)

    verify(instance).init(settings)
  }

  @Test
  fun focus() {
    val api = TestProxyApiRegistrar().getPigeonApiBaseManager()

    val instance = mock<BaseManager>()
    api.focus(instance)

    verify(instance).focus()
  }

  @Test
  fun getAdProgressInfo() {
    val api = TestProxyApiRegistrar().getPigeonApiBaseManager()

    val instance = mock<BaseManager>()
    val value = mock<AdProgressInfo>()
    whenever(instance.adProgressInfo).thenReturn(value)

    assertEquals(value, api.getAdProgressInfo(instance))
  }

  @Test
  fun getCurrentAd() {
    val api = TestProxyApiRegistrar().getPigeonApiBaseManager()

    val instance = mock<BaseManager>()
    val value = mock<Ad>()
    whenever(instance.currentAd).thenReturn(value)

    assertEquals(value, api.getCurrentAd(instance))
  }

  @Test
  fun removeAdErrorListener() {
    val api = TestProxyApiRegistrar().getPigeonApiBaseManager()

    val instance = mock<BaseManager>()
    val errorListener = mock<AdErrorEvent.AdErrorListener>()
    api.removeAdErrorListener(instance, errorListener)

    verify(instance).removeAdErrorListener(errorListener)
  }

  @Test
  fun removeAdEventListener() {
    val api = TestProxyApiRegistrar().getPigeonApiBaseManager()

    val instance = mock<BaseManager>()
    val adEventListener = mock<AdEvent.AdEventListener>()
    api.removeAdEventListener(instance, adEventListener)

    verify(instance).removeAdEventListener(adEventListener)
  }
}
