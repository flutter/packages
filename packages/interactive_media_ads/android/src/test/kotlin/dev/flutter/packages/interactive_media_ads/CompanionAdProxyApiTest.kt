// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.CompanionAd
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.kotlin.mock
import org.mockito.kotlin.whenever

class CompanionAdProxyApiTest {
  @Test
  fun apiFramework() {
    val api = TestProxyApiRegistrar().getPigeonApiCompanionAd()

    val instance = mock<CompanionAd>()
    val value = "myString"
    whenever(instance.apiFramework).thenReturn(value)

    assertEquals(value, api.apiFramework(instance))
  }

  @Test
  fun height() {
    val api = TestProxyApiRegistrar().getPigeonApiCompanionAd()

    val instance = mock<CompanionAd>()
    val value = 0
    whenever(instance.height).thenReturn(value)

    assertEquals(value.toLong(), api.height(instance))
  }

  @Test
  fun resourceValue() {
    val api = TestProxyApiRegistrar().getPigeonApiCompanionAd()

    val instance = mock<CompanionAd>()
    val value = "myString"
    whenever(instance.resourceValue).thenReturn(value)

    assertEquals(value, api.resourceValue(instance))
  }

  @Test
  fun width() {
    val api = TestProxyApiRegistrar().getPigeonApiCompanionAd()

    val instance = mock<CompanionAd>()
    val value = 0
    whenever(instance.width).thenReturn(value)

    assertEquals(value.toLong(), api.width(instance))
  }
}
