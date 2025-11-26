// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.cross_file_android.proxies

import android.content.ContentResolver
import java.io.InputStream
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.kotlin.mock
import org.mockito.kotlin.whenever

class ContentResolverTest {
  @Test
  fun openInputStream() {
    val api = TestProxyApiRegistrar().getPigeonApiContentResolver()

    val instance = mock<ContentResolver>()
    val uri = "myString"
    val value = mock<InputStream>()
    whenever(instance.openInputStream(uri)).thenReturn(value)

    assertEquals(value, api.openInputStream(instance, uri))
  }
}
