// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.cross_file_android.proxies

import androidx.documentfile.provider.DocumentFile
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue
import org.mockito.Mockito
import org.mockito.kotlin.any
import org.mockito.kotlin.eq
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever

class DocumentFileTest {
  @Test
  fun fromSingleUri() {
    val api = TestProxyApiRegistrar().getPigeonApiDocumentFile()

    assertTrue(api.fromSingleUri("myString") is DocumentFileProxyApi.DocumentFile)
  }

  @Test
  fun canRead() {
    val api = TestProxyApiRegistrar().getPigeonApiDocumentFile()

    val instance = mock<DocumentFile>()
    val value = true
    whenever(instance.canRead()).thenReturn(value)

    assertEquals(value, api.canRead(instance ))
  }

  @Test
  fun delete() {
    val api = TestProxyApiRegistrar().getPigeonApiDocumentFile()

    val instance = mock<DocumentFile>()
    val value = true
    whenever(instance.delete()).thenReturn(value)

    assertEquals(value, api.delete(instance ))
  }

  @Test
  fun exists() {
    val api = TestProxyApiRegistrar().getPigeonApiDocumentFile()

    val instance = mock<DocumentFile>()
    val value = true
    whenever(instance.exists()).thenReturn(value)

    assertEquals(value, api.exists(instance ))
  }

  @Test
  fun lastModified() {
    val api = TestProxyApiRegistrar().getPigeonApiDocumentFile()

    val instance = mock<DocumentFile>()
    val value = 0
    whenever(instance.lastModified()).thenReturn(value)

    assertEquals(value, api.lastModified(instance ))
  }

  @Test
  fun length() {
    val api = TestProxyApiRegistrar().getPigeonApiDocumentFile()

    val instance = mock<DocumentFile>()
    val value = 0
    whenever(instance.length()).thenReturn(value)

    assertEquals(value, api.length(instance ))
  }

}
