// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.cross_file_android.proxies

import android.net.Uri
import androidx.documentfile.provider.DocumentFile
import dev.flutter.packages.cross_file_android.TestProxyApiRegistrar
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.Mockito.mockStatic
import org.mockito.kotlin.mock
import org.mockito.kotlin.whenever

class DocumentFileTest {
  @Test
  fun fromSingleUri() {
    val registrar = TestProxyApiRegistrar()
    val api = registrar.getPigeonApiDocumentFile()

    mockStatic(DocumentFile::class.java).use { mockedStatic ->
      val instance = mock<DocumentFile>()
      val singleUri = Uri("myString")
      mockedStatic
          .`when`<DocumentFile> { DocumentFile.fromSingleUri(registrar.context, singleUri) }
          .thenReturn(instance)

      assertEquals(instance, api.fromSingleUri(singleUri.toString()))
    }
  }

  @Test
  fun fromTreeUri() {
    val registrar = TestProxyApiRegistrar()
    val api = registrar.getPigeonApiDocumentFile()

    mockStatic(DocumentFile::class.java).use { mockedStatic ->
      val instance = mock<DocumentFile>()
      val treeUri = Uri("myString")
      mockedStatic
          .`when`<DocumentFile> { DocumentFile.fromTreeUri(registrar.context, treeUri) }
          .thenReturn(instance)

      assertEquals(instance, api.fromTreeUri(treeUri.toString()))
    }
  }

  @Test
  fun canRead() {
    val api = TestProxyApiRegistrar().getPigeonApiDocumentFile()

    val instance = mock<DocumentFile>()
    val value = true
    whenever(instance.canRead()).thenReturn(value)

    assertEquals(value, api.canRead(instance))
  }

  @Test
  fun delete() {
    val api = TestProxyApiRegistrar().getPigeonApiDocumentFile()

    val instance = mock<DocumentFile>()
    val value = true
    whenever(instance.delete()).thenReturn(value)

    assertEquals(value, api.delete(instance))
  }

  @Test
  fun exists() {
    val api = TestProxyApiRegistrar().getPigeonApiDocumentFile()

    val instance = mock<DocumentFile>()
    val value = true
    whenever(instance.exists()).thenReturn(value)

    assertEquals(value, api.exists(instance))
  }

  @Test
  fun lastModified() {
    val api = TestProxyApiRegistrar().getPigeonApiDocumentFile()

    val instance = mock<DocumentFile>()
    val value = 0L
    whenever(instance.lastModified()).thenReturn(value)

    assertEquals(value, api.lastModified(instance))
  }

  @Test
  fun length() {
    val api = TestProxyApiRegistrar().getPigeonApiDocumentFile()

    val instance = mock<DocumentFile>()
    val value = 0L
    whenever(instance.length()).thenReturn(value)

    assertEquals(value, api.length(instance))
  }

  @Test
  fun isFile() {
    val api = TestProxyApiRegistrar().getPigeonApiDocumentFile()

    val instance = mock<DocumentFile>()
    val value = true
    whenever(instance.isFile).thenReturn(value)

    assertEquals(value, api.isFile(instance))
  }

  @Test
  fun isDirectory() {
    val api = TestProxyApiRegistrar().getPigeonApiDocumentFile()

    val instance = mock<DocumentFile>()
    val value = true
    whenever(instance.isDirectory).thenReturn(value)

    assertEquals(value, api.isDirectory(instance))
  }

  @Test
  fun listFiles() {
    val api = TestProxyApiRegistrar().getPigeonApiDocumentFile()

    val instance = mock<DocumentFile>()
    val value = listOf(mock<DocumentFile>())
    whenever(instance.listFiles()).thenReturn(value.toTypedArray())

    assertEquals(value, api.listFiles(instance))
  }

  @Test
  fun getUri() {
    val api = TestProxyApiRegistrar().getPigeonApiDocumentFile()

    val instance = mock<DocumentFile>()
    val value = Uri("myString")
    whenever(instance.uri).thenReturn(value)

    assertEquals(value.toString(), api.getUri(instance))
  }

  @Test
  fun getName() {
    val api = TestProxyApiRegistrar().getPigeonApiDocumentFile()

    val instance = mock<DocumentFile>()
    val value = "name"
    whenever(instance.name).thenReturn(value)

    assertEquals(value, api.getName(instance))
  }
}
