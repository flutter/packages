// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdErrorEvent
import com.google.ads.interactivemedia.v3.api.AdEvent
import com.google.ads.interactivemedia.v3.api.BaseManager
import kotlin.test.Test
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify

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
    api.init(instance)

    verify(instance).init()
  }
}
