// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.cross_file_android.proxies

import dev.flutter.packages.cross_file_android.InputStreamReadBytesResponse
import java.io.InputStream
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.kotlin.mock
import org.mockito.kotlin.whenever

class InputStreamTest {
  @Test
  fun readBytes() {
    val api = TestProxyApiRegistrar().getPigeonApiInputStream()

    val instance = mock<InputStream>()
    val len = 0
    val value = mock<InputStreamReadBytesResponse>()
    whenever(instance.readBytes(len)).thenReturn(value)

    assertEquals(value, api.readBytes(instance, len))
  }

  @Test
  fun readAllBytes() {
    val api = TestProxyApiRegistrar().getPigeonApiInputStream()

    val instance = mock<InputStream>()
    val value = byteArrayOf(0xA1.toByte())
    whenever(instance.readAllBytes()).thenReturn(value)

    assertEquals(value, api.readAllBytes(instance))
  }
}
