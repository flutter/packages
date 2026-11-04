// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package dev.flutter.packages.file_selector_android

import android.app.Activity
import android.content.ClipData
import android.content.ContentResolver
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import android.provider.OpenableColumns
import dev.flutter.packages.file_selector_android.FileSelectorApiImpl.NativeObjectFactory
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import java.io.DataInputStream
import java.io.InputStream
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.mockito.Mockito
import org.mockito.kotlin.any
import org.mockito.kotlin.argumentCaptor
import org.mockito.kotlin.doReturn
import org.mockito.kotlin.eq
import org.mockito.kotlin.mock
import org.mockito.kotlin.never
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever

class FileSelectorAndroidPluginTest {
  @Test
  fun openFileReturnsSuccessfully() {
      val mockUriPath = "/some/path"
      val mockUri = mock<Uri>() {
          on {toString()} doReturn mockUriPath
      }

      val mockIntent = mock<Intent>()
      val mockObjectFactory =
          mock<NativeObjectFactory> {
            on { newIntent(Intent.ACTION_OPEN_DOCUMENT) } doReturn mockIntent
            on { newDataInputStream(any()) } doReturn mock<DataInputStream>()
          }

      val mockActivity = mock<Activity>()
      val mockActivityBinding =
          mock<ActivityPluginBinding> { on { activity } doReturn mockActivity }

      val fileSelectorApi =
          FileSelectorApiImpl(mockActivityBinding, mockObjectFactory)
      var callbackCalled = false
      fileSelectorApi.openFile(null, FileTypes(emptyList(), emptyList())) { reply ->
        callbackCalled = true
        assertEquals(mockUriPath, reply.getOrNull())
      }
      verify(mockIntent).addCategory(Intent.CATEGORY_OPENABLE)

      verify(mockActivity).startActivityForResult(mockIntent, 221)

      val listenerArgumentCaptor = argumentCaptor<ActivityResultListener>()
      verify(mockActivityBinding).addActivityResultListener(listenerArgumentCaptor.capture())

      val resultMockIntent = mock<Intent> { on { data } doReturn mockUri }
      listenerArgumentCaptor.firstValue.onActivityResult(221, Activity.RESULT_OK, resultMockIntent)
      assertTrue(callbackCalled)

  }

  @Test
  fun openFilesReturnsSuccessfully() {
      val mockUriPath = "/some/path"
      val mockUri = mock<Uri> {
          on {toString()} doReturn mockUriPath
      }

      val mockUri2Path = "some/other/path/"
      val mockUri2 = mock<Uri> {
          on {toString()} doReturn mockUri2Path
      }

      val mockIntent = mock<Intent>()
      val mockObjectFactory =
          mock<NativeObjectFactory> {
            on { newIntent(Intent.ACTION_OPEN_DOCUMENT) } doReturn mockIntent
          }
      val mockActivity = mock<Activity>()
      val mockActivityBinding =
          mock<ActivityPluginBinding> { on { activity } doReturn mockActivity }
      val fileSelectorApi =
          FileSelectorApiImpl(mockActivityBinding, mockObjectFactory)

      var callbackCalled = false
      fileSelectorApi.openFiles(null, FileTypes(emptyList(), emptyList())) { reply ->
        callbackCalled = true
        val pathList = checkNotNull(reply.getOrNull())
        assertEquals(mockUriPath, pathList[0])
        assertEquals(mockUri2Path, pathList[1])
      }
      verify(mockIntent).addCategory(Intent.CATEGORY_OPENABLE)
      verify(mockIntent).putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)

      verify(mockActivity).startActivityForResult(mockIntent, 222)

      val listenerArgumentCaptor = argumentCaptor<ActivityResultListener>()
      verify(mockActivityBinding).addActivityResultListener(listenerArgumentCaptor.capture())

      val mockClipDataItem = mock<ClipData.Item> { on { uri } doReturn mockUri }
      val mockClipDataItem2 = mock<ClipData.Item> { on { uri } doReturn mockUri2 }
      val mockClipData =
          mock<ClipData> {
            on { itemCount } doReturn 2
            on { getItemAt(0) } doReturn mockClipDataItem
            on { getItemAt(1) } doReturn mockClipDataItem2
          }
      val resultMockIntent = mock<Intent> { on { clipData } doReturn mockClipData }

      listenerArgumentCaptor.firstValue.onActivityResult(222, Activity.RESULT_OK, resultMockIntent)
      assertTrue(callbackCalled)
  }

  @Test
  fun getDirectoryPathReturnsSuccessfully() {
      val mockUriPath = "some/path/"
      val mockUri = mock<Uri> {
          on {toString()} doReturn mockUriPath
      }



        val mockIntent = mock<Intent>()
        val mockObjectFactory =
            mock<NativeObjectFactory> {
              on { newIntent(Intent.ACTION_OPEN_DOCUMENT_TREE) } doReturn mockIntent
            }
        val mockActivity = mock<Activity>()
        val mockActivityBinding =
            mock<ActivityPluginBinding> { on { activity } doReturn mockActivity }
        val fileSelectorApi =
            FileSelectorApiImpl(mockActivityBinding, mockObjectFactory)

        var callbackCalled = false
        fileSelectorApi.getDirectoryPath(null) { reply ->
          callbackCalled = true
          assertEquals(mockUriPath, reply.getOrNull())
        }

        verify(mockActivity).startActivityForResult(mockIntent, 223)

        val listenerArgumentCaptor = argumentCaptor<ActivityResultListener>()
        verify(mockActivityBinding).addActivityResultListener(listenerArgumentCaptor.capture())

        val resultMockIntent = mock<Intent> { on { data } doReturn mockUri }
        listenerArgumentCaptor.firstValue.onActivityResult(
            223, Activity.RESULT_OK, resultMockIntent)
        assertTrue(callbackCalled)
  }
}
