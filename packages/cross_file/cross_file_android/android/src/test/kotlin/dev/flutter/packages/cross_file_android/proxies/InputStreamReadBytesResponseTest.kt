// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.cross_file_android.proxies

import dev.flutter.packages.cross_file_android.InputStreamReadBytesResponse
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.kotlin.mock
import org.mockito.kotlin.whenever

class InputStreamReadBytesResponseTest {
  @Test
  fun returnValue() {
    val api = TestProxyApiRegistrar().getPigeonApiInputStreamReadBytesResponse()

    val instance = mock<InputStreamReadBytesResponse>()
    val value = 0
    whenever(instance.returnValue).thenReturn(value)

    assertEquals(value, api.returnValue(instance))
  }

  @Test
  fun bytes() {
    val api = TestProxyApiRegistrar().getPigeonApiInputStreamReadBytesResponse()

    val instance = mock<InputStreamReadBytesResponse>()
    val value = byteArrayOf(0xA1.toByte())
    whenever(instance.bytes).thenReturn(value)

    assertEquals(value, api.bytes(instance))
  }
}
