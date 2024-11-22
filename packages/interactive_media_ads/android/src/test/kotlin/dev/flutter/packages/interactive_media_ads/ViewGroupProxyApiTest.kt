// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import android.view.View
import android.view.ViewGroup
import kotlin.test.Test
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify

class ViewGroupProxyApiTest {
  @Test
  fun addView() {
    val api = TestProxyApiRegistrar().getPigeonApiViewGroup()

    val instance = mock<ViewGroup>()
    val mockView = mock<View>()
    api.addView(instance, mockView)

    verify(instance).addView(mockView)
  }

  @Test
  fun removeView() {
    val api = TestProxyApiRegistrar().getPigeonApiViewGroup()

    val instance = mock<ViewGroup>()
    val mockView = mock<View>()
    api.removeView(instance, mockView)

    verify(instance).removeView(mockView)
  }
}
