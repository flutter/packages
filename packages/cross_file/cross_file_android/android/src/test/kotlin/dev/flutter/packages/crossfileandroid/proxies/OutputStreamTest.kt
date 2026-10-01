// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.crossfileandroid.proxies

import dev.flutter.packages.crossfileandroid.TestProxyApiRegistrar
import java.io.OutputStream
import kotlin.test.Test
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify

class OutputStreamTest {
  @Test
  fun write() {
    val api = TestProxyApiRegistrar().getPigeonApiOutputStream()

    val instance = mock<OutputStream>()
    val bytes = byteArrayOf(1, 2, 3)

    api.write(instance, bytes)

    verify(instance).write(bytes)
  }

  @Test
  fun close() {
    val api = TestProxyApiRegistrar().getPigeonApiOutputStream()

    val instance = mock<OutputStream>()

    api.close(instance)

    verify(instance).close()
  }

  @Test
  fun flush() {
    val api = TestProxyApiRegistrar().getPigeonApiOutputStream()

    val instance = mock<OutputStream>()

    api.flush(instance)

    verify(instance).flush()
  }
}
