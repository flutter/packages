// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.VersionInfo
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.kotlin.mock
import org.mockito.kotlin.whenever

class VersionInfoProxyApiTest {
  @Test
  fun majorVersion() {
    val api = TestProxyApiRegistrar().getPigeonApiVersionInfo()

    val instance = mock<VersionInfo>()
    val value = 0
    whenever(instance.majorVersion).thenReturn(value)

    assertEquals(value.toLong(), api.majorVersion(instance))
  }

  @Test
  fun minorVersion() {
    val api = TestProxyApiRegistrar().getPigeonApiVersionInfo()

    val instance = mock<VersionInfo>()
    val value = 0
    whenever(instance.minorVersion).thenReturn(value)

    assertEquals(value.toLong(), api.minorVersion(instance))
  }

  @Test
  fun microVersion() {
    val api = TestProxyApiRegistrar().getPigeonApiVersionInfo()

    val instance = mock<VersionInfo>()
    val value = 0
    whenever(instance.microVersion).thenReturn(value)

    assertEquals(value.toLong(), api.microVersion(instance))
  }
}
