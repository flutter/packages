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

class CompanionAdSlotClickListenerProxyApiTest {
  @Test
  fun pigeon_defaultConstructor() {
    val api = TestProxyApiRegistrar().getPigeonApiCompanionAdSlotClickListener()

    assertTrue(
        api.pigeon_defaultConstructor() is CompanionAdSlotClickListenerProxyApi.ClickListenerImpl)
  }

  @Test
  fun onCompanionAdClick() {
    val mockApi = mock<CompanionAdSlotClickListenerProxyApi>()
    whenever(mockApi.pigeonRegistrar).thenReturn(TestProxyApiRegistrar())

    val instance = CompanionAdSlotClickListenerProxyApi.ClickListenerImpl(mockApi)
    instance.onCompanionAdClick()

    verify(mockApi).onCompanionAdClick(eq(instance), any())
  }
}
