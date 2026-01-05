// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.cross_file_android.proxies

import dev.flutter.packages.cross_file_android.InputStreamReadBytesResponse
import dev.flutter.packages.cross_file_android.TestProxyApiRegistrar
import java.io.ByteArrayInputStream
import java.io.InputStream
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.ArgumentCaptor
import org.mockito.kotlin.capture
import org.mockito.kotlin.eq
import org.mockito.kotlin.mock
import org.mockito.kotlin.whenever

class InputStreamTest {
  @Test
  fun readBytes() {
    val api = TestProxyApiRegistrar().getPigeonApiInputStream()

    val instance = mock<InputStream>()
    val bytesCaptor = ArgumentCaptor.forClass(ByteArray::class.java)
    val len = 2
    val value = 3
    whenever(instance.read(bytesCaptor.capture())).thenReturn(value)

    assertEquals(
        api.readBytes(instance, len.toLong()),
        InputStreamReadBytesResponse(value, bytesCaptor.value))
    assertEquals(bytesCaptor.value.size, len)
  }

  @Test
  fun readAllBytes() {
    val api = TestProxyApiRegistrar().getPigeonApiInputStream()

    val value = byteArrayOf(0xA1.toByte())
    val instance = ByteArrayInputStream(value)

    val result = api.readAllBytes(instance)
    assertEquals(value.size, result.size)
    assertEquals(value.first(), result.first())
  }

  @Test
  fun skip() {
    val api = TestProxyApiRegistrar().getPigeonApiInputStream()

    val instance = mock<InputStream>()
    val n = 5L
    val value = 6L
    whenever(instance.skip(n)).thenReturn(value)

    assertEquals(value, api.skip(instance, n))
  }
}
