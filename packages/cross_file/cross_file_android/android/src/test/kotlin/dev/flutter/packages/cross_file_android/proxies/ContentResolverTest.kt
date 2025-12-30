// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.cross_file_android.proxies

import android.content.ContentResolver
import android.net.Uri
import android.os.Looper
import androidx.core.net.toUri
import dev.flutter.packages.cross_file_android.TestProxyApiRegistrar
import org.mockito.kotlin.any
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
    whenever(instance.openInputStream(any())).thenReturn(value)

    assertEquals(value, api.openInputStream(instance, uri))
    assertEquals(uri, Uri.lastValue)
  }
}
