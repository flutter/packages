// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import kotlin.test.Test
import kotlin.test.assertTrue
import org.mockito.kotlin.any
import org.mockito.kotlin.eq
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever

class SecureSignalsInitializeCallbackProxyApiTest {
  @Test
  fun pigeon_defaultConstructor() {
    val api = TestProxyApiRegistrar().getPigeonApiSecureSignalsInitializeCallback()

    assertTrue(
        api.pigeon_defaultConstructor()
            is SecureSignalsInitializeCallbackProxyApi.SecureSignalsInitializeCallbackImpl)
  }

  @Test
  fun onFailure() {
    val mockApi = mock<SecureSignalsInitializeCallbackProxyApi>()
    whenever(mockApi.pigeonRegistrar).thenReturn(TestProxyApiRegistrar())

    val instance =
        SecureSignalsInitializeCallbackProxyApi.SecureSignalsInitializeCallbackImpl(mockApi)
    val message = "myString"
    instance.onFailure(Exception(message))

    verify(mockApi).onFailure(eq(instance), eq("java.lang.Exception"), eq(message), any())
  }

  @Test
  fun onSuccess() {
    val mockApi = mock<SecureSignalsInitializeCallbackProxyApi>()
    whenever(mockApi.pigeonRegistrar).thenReturn(TestProxyApiRegistrar())

    val instance =
        SecureSignalsInitializeCallbackProxyApi.SecureSignalsInitializeCallbackImpl(mockApi)
    instance.onSuccess()

    verify(mockApi).onSuccess(eq(instance), any())
  }
}
