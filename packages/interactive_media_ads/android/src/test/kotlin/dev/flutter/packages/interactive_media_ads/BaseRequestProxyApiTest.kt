// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.BaseRequest
import com.google.ads.interactivemedia.v3.api.signals.SecureSignals
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever

class BaseRequestProxyApiTest {
  @Test
  fun getContentUrl() {
    val api = TestProxyApiRegistrar().getPigeonApiBaseRequest()

    val instance = mock<BaseRequest>()
    val value = "myString"
    whenever(instance.contentUrl).thenReturn(value)

    assertEquals(value, api.getContentUrl(instance))
  }

  @Test
  fun getSecureSignals() {
    val api = TestProxyApiRegistrar().getPigeonApiBaseRequest()

    val instance = mock<BaseRequest>()
    val value = mock<SecureSignals>()
    whenever(instance.secureSignals).thenReturn(value)

    assertEquals(value, api.getSecureSignals(instance))
  }

  @Test
  fun getUserRequestContext() {
    val api = TestProxyApiRegistrar().getPigeonApiBaseRequest()

    val instance = mock<BaseRequest>()
    val value = -1
    whenever(instance.userRequestContext).thenReturn(value)

    assertEquals(value, api.getUserRequestContext(instance))
  }

  @Test
  fun setContentUrl() {
    val api = TestProxyApiRegistrar().getPigeonApiBaseRequest()

    val instance = mock<BaseRequest>()
    val url = "myString"
    api.setContentUrl(instance, url)

    verify(instance).contentUrl = url
  }

  @Test
  fun setSecureSignals() {
    val api = TestProxyApiRegistrar().getPigeonApiBaseRequest()

    val instance = mock<BaseRequest>()
    val signal = mock<SecureSignals>()
    api.setSecureSignals(instance, signal)

    verify(instance).secureSignals = signal
  }

  @Test
  fun setUserRequestContext() {
    val api = TestProxyApiRegistrar().getPigeonApiBaseRequest()

    val instance = mock<BaseRequest>()
    val userRequestContext = -1
    api.setUserRequestContext(instance, userRequestContext)

    verify(instance).userRequestContext = userRequestContext
  }
}
