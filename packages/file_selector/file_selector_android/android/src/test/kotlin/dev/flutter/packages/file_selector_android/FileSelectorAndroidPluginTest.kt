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
  private fun mockContentResolver(
      mockResolver: ContentResolver,
      uri: Uri,
      displayName: String,
      size: Int,
      mimeType: String
  ) {
    val mockCursor =
        mock<Cursor> {
          on { moveToFirst() } doReturn true
          on { getColumnIndex(OpenableColumns.DISPLAY_NAME) } doReturn 0
          on { getString(0) } doReturn displayName
          on { getColumnIndex(OpenableColumns.SIZE) } doReturn 1
          on { isNull(1) } doReturn false
          on { getInt(1) } doReturn size
        }

    whenever(mockResolver.query(uri, null, null, null, null, null)).thenReturn(mockCursor)
    // `getType` is only reached when a `FileResponse` is built, so it is unused by
    // the error-path tests; keep it lenient to avoid strict-stubbing warnings.
    Mockito.lenient().whenever(mockResolver.getType(uri)).thenReturn(mimeType)
    whenever(mockResolver.openInputStream(uri)).thenReturn(mock<InputStream>())
  }

  @Test
  fun openFileReturnsSuccessfully() {
    Mockito.mockStatic(FileUtils::class.java).use { mockedFileUtils ->
      val mockContentResolver = mock<ContentResolver>()
      val mockUri = mock<Uri>()
      val mockUriPath = "/some/path"
      mockedFileUtils
          .whenever { FileUtils.getPathFromCopyOfFileFromUri(any(), eq(mockUri)) }
          .thenReturn(mockUriPath)
      mockContentResolver(mockContentResolver, mockUri, "filename", 30, "text/plain")

      val mockIntent = mock<Intent>()
      val mockObjectFactory =
          mock<NativeObjectFactory> {
            on { newIntent(Intent.ACTION_OPEN_DOCUMENT) } doReturn mockIntent
            on { newDataInputStream(any()) } doReturn mock<DataInputStream>()
          }
      val mockActivity = mock<Activity> { on { contentResolver } doReturn mockContentResolver }
      val mockActivityBinding =
          mock<ActivityPluginBinding> { on { activity } doReturn mockActivity }

      val fileSelectorApi =
          FileSelectorApiImpl(mockActivityBinding, mockObjectFactory) { version ->
            Build.VERSION.SDK_INT >= version
          }

      var callbackCalled = false
      fileSelectorApi.openFile(null, FileTypes(emptyList(), emptyList())) { reply ->
        callbackCalled = true
        val file = checkNotNull(reply.getOrNull())
        assertEquals(30, file.bytes.size)
        assertEquals("text/plain", file.mimeType)
        assertEquals("filename", file.name)
        assertEquals(30L, file.size)
        assertEquals(mockUriPath, file.path)
      }
      verify(mockIntent).addCategory(Intent.CATEGORY_OPENABLE)

      verify(mockActivity).startActivityForResult(mockIntent, 221)

      val listenerArgumentCaptor = argumentCaptor<ActivityResultListener>()
      verify(mockActivityBinding).addActivityResultListener(listenerArgumentCaptor.capture())

      val resultMockIntent = mock<Intent> { on { data } doReturn mockUri }
      listenerArgumentCaptor.firstValue.onActivityResult(221, Activity.RESULT_OK, resultMockIntent)
      assertTrue(callbackCalled)
    }
  }

  @Test
  fun openFilesReturnsSuccessfully() {
    Mockito.mockStatic(FileUtils::class.java).use { mockedFileUtils ->
      val mockContentResolver = mock<ContentResolver>()
      val mockUri = mock<Uri>()
      val mockUriPath = "some/path/"
      mockedFileUtils
          .whenever { FileUtils.getPathFromCopyOfFileFromUri(any(), eq(mockUri)) }
          .thenReturn(mockUriPath)
      mockContentResolver(mockContentResolver, mockUri, "filename", 30, "text/plain")

      val mockUri2 = mock<Uri>()
      val mockUri2Path = "some/other/path/"
      mockedFileUtils
          .whenever { FileUtils.getPathFromCopyOfFileFromUri(any(), eq(mockUri2)) }
          .thenReturn(mockUri2Path)
      mockContentResolver(mockContentResolver, mockUri2, "filename2", 40, "image/jpg")

      val mockIntent = mock<Intent>()
      val mockObjectFactory =
          mock<NativeObjectFactory> {
            on { newIntent(Intent.ACTION_OPEN_DOCUMENT) } doReturn mockIntent
            on { newDataInputStream(any()) } doReturn mock<DataInputStream>()
          }
      val mockActivity = mock<Activity> { on { contentResolver } doReturn mockContentResolver }
      val mockActivityBinding =
          mock<ActivityPluginBinding> { on { activity } doReturn mockActivity }
      val fileSelectorApi =
          FileSelectorApiImpl(mockActivityBinding, mockObjectFactory) { version ->
            Build.VERSION.SDK_INT >= version
          }

      var callbackCalled = false
      fileSelectorApi.openFiles(null, FileTypes(emptyList(), emptyList())) { reply ->
        callbackCalled = true
        val fileList = checkNotNull(reply.getOrNull())
        val file1 = fileList[0]
        assertEquals(30, file1.bytes.size)
        assertEquals("text/plain", file1.mimeType)
        assertEquals("filename", file1.name)
        assertEquals(30L, file1.size)
        assertEquals(mockUriPath, file1.path)

        val file2 = fileList[1]
        assertEquals(40, file2.bytes.size)
        assertEquals("image/jpg", file2.mimeType)
        assertEquals("filename2", file2.name)
        assertEquals(40L, file2.size)
        assertEquals(mockUri2Path, file2.path)
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
  }

  // Regression test for https://github.com/flutter/flutter/issues/159568: a
  // `SecurityException` while copying a selected file must be surfaced to Dart
  // as a failed result, rather than crashing by building a `FileResponse` with a
  // null `path` (which the non-null `path` field rejects at runtime).
  @Test
  fun openFilesCompletesWithError_whenSecurityExceptionInGetPathFromCopyOfFileFromUri() {
    Mockito.mockStatic(FileUtils::class.java).use { mockedFileUtils ->
      val mockContentResolver = mock<ContentResolver>()
      val mockUri = mock<Uri>()
      mockedFileUtils
          .whenever { FileUtils.getPathFromCopyOfFileFromUri(any(), eq(mockUri)) }
          .thenThrow(SecurityException::class.java)
      mockContentResolver(mockContentResolver, mockUri, "filename", 30, "text/plain")

      val mockIntent = mock<Intent>()
      val mockObjectFactory =
          mock<NativeObjectFactory> {
            on { newIntent(Intent.ACTION_OPEN_DOCUMENT) } doReturn mockIntent
            on { newDataInputStream(any()) } doReturn mock<DataInputStream>()
          }
      val mockActivity = mock<Activity> { on { contentResolver } doReturn mockContentResolver }
      val mockActivityBinding =
          mock<ActivityPluginBinding> { on { activity } doReturn mockActivity }
      val fileSelectorApi =
          FileSelectorApiImpl(mockActivityBinding, mockObjectFactory) { version ->
            Build.VERSION.SDK_INT >= version
          }

      var callbackCalled = false
      var failure: Throwable? = null
      fileSelectorApi.openFiles(null, FileTypes(emptyList(), emptyList())) { reply ->
        callbackCalled = true
        failure = reply.exceptionOrNull()
      }
      verify(mockIntent).addCategory(Intent.CATEGORY_OPENABLE)
      verify(mockIntent).putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)

      verify(mockActivity).startActivityForResult(mockIntent, 222)

      val listenerArgumentCaptor = argumentCaptor<ActivityResultListener>()
      verify(mockActivityBinding).addActivityResultListener(listenerArgumentCaptor.capture())

      val mockClipDataItem = mock<ClipData.Item> { on { uri } doReturn mockUri }

      val mockClipData =
          mock<ClipData> {
            on { itemCount } doReturn 1
            on { getItemAt(0) } doReturn mockClipDataItem
          }

      val resultMockIntent = mock<Intent> { on { clipData } doReturn mockClipData }

      // Previously this threw a NullPointerException (see #159568); it must now
      // complete the callback with a failure instead of crashing.
      listenerArgumentCaptor.firstValue.onActivityResult(222, Activity.RESULT_OK, resultMockIntent)

      assertTrue(callbackCalled)
      assertNotNull(failure)
      assertTrue(failure!!.message!!.contains("Failed to read file"))
    }
  }

  // Regression test for https://github.com/flutter/flutter/issues/159568: the
  // single-file `openFile` path must likewise surface a copy failure to Dart
  // instead of crashing.
  @Test
  fun openFileCompletesWithError_whenProviderReturnsNullStream() {
    val mockUri = mock<Uri>()

    val mockCursor =
        mock<Cursor> {
          on { moveToFirst() } doReturn true
          on { getColumnIndex(OpenableColumns.DISPLAY_NAME) } doReturn 0
          on { getString(0) } doReturn "filename"
          on { getColumnIndex(OpenableColumns.SIZE) } doReturn 1
          on { isNull(1) } doReturn false
          on { getInt(1) } doReturn 30
        }
    val mockContentResolver =
        mock<ContentResolver> {
          on { query(mockUri, null, null, null, null, null) } doReturn mockCursor
          // A provider that cannot serve the file answers the open with null; previously this
          // reached
          // `DataInputStream#readFully` and threw a NullPointerException on the main thread.
          on { openInputStream(mockUri) } doReturn null
        }

    val mockIntent = mock<Intent>()
    val mockObjectFactory =
        mock<NativeObjectFactory> {
          on { newIntent(Intent.ACTION_OPEN_DOCUMENT) } doReturn mockIntent
          on { newDataInputStream(any()) } doReturn mock<DataInputStream>()
        }
    val mockActivity = mock<Activity> { on { contentResolver } doReturn mockContentResolver }
    val mockActivityBinding = mock<ActivityPluginBinding> { on { activity } doReturn mockActivity }
    val fileSelectorApi =
        FileSelectorApiImpl(mockActivityBinding, mockObjectFactory) { version ->
          Build.VERSION.SDK_INT >= version
        }

    var callbackCalled = false
    var failure: Throwable? = null
    fileSelectorApi.openFile(null, FileTypes(emptyList(), emptyList())) { reply ->
      callbackCalled = true
      failure = reply.exceptionOrNull()
    }

    verify(mockActivity).startActivityForResult(mockIntent, 221)

    val listenerArgumentCaptor = argumentCaptor<ActivityResultListener>()
    verify(mockActivityBinding).addActivityResultListener(listenerArgumentCaptor.capture())

    val resultMockIntent = mock<Intent> { on { data } doReturn mockUri }
    listenerArgumentCaptor.firstValue.onActivityResult(221, Activity.RESULT_OK, resultMockIntent)

    assertTrue(callbackCalled)
    assertNotNull(failure)
    assertTrue(failure!!.message!!.contains("Failed to read file"))
    verify(mockObjectFactory, never()).newDataInputStream(any())
  }

  @Test
  fun openFileCompletesWithError_whenSecurityExceptionInGetPathFromCopyOfFileFromUri() {
    Mockito.mockStatic(FileUtils::class.java).use { mockedFileUtils ->
      val mockContentResolver = mock<ContentResolver>()
      val mockUri = mock<Uri>()
      mockedFileUtils
          .whenever { FileUtils.getPathFromCopyOfFileFromUri(any(), eq(mockUri)) }
          .thenThrow(SecurityException::class.java)
      mockContentResolver(mockContentResolver, mockUri, "filename", 30, "text/plain")

      val mockIntent = mock<Intent>()
      val mockObjectFactory =
          mock<NativeObjectFactory> {
            on { newIntent(Intent.ACTION_OPEN_DOCUMENT) } doReturn mockIntent
            on { newDataInputStream(any()) } doReturn mock<DataInputStream>()
          }
      val mockActivity = mock<Activity> { on { contentResolver } doReturn mockContentResolver }
      val mockActivityBinding =
          mock<ActivityPluginBinding> { on { activity } doReturn mockActivity }
      val fileSelectorApi =
          FileSelectorApiImpl(mockActivityBinding, mockObjectFactory) { version ->
            Build.VERSION.SDK_INT >= version
          }

      var callbackCalled = false
      var failure: Throwable? = null
      fileSelectorApi.openFile(null, FileTypes(emptyList(), emptyList())) { reply ->
        callbackCalled = true
        failure = reply.exceptionOrNull()
      }

      verify(mockActivity).startActivityForResult(mockIntent, 221)

      val listenerArgumentCaptor = argumentCaptor<ActivityResultListener>()
      verify(mockActivityBinding).addActivityResultListener(listenerArgumentCaptor.capture())

      val resultMockIntent = mock<Intent> { on { data } doReturn mockUri }
      listenerArgumentCaptor.firstValue.onActivityResult(221, Activity.RESULT_OK, resultMockIntent)

      assertTrue(callbackCalled)
      assertNotNull(failure)
      assertTrue(failure!!.message!!.contains("Failed to read file"))
    }
  }

  @Test
  fun openFileReturnsNativeException_whenIllegalArgumentExceptionInGetPathFromCopyOfFileFromUri() {
    Mockito.mockStatic(FileUtils::class.java).use { mockedFileUtils ->
      val mockContentResolver = mock<ContentResolver>()
      val mockUri = mock<Uri>()
      mockedFileUtils
          .whenever { FileUtils.getPathFromCopyOfFileFromUri(any(), eq(mockUri)) }
          .thenThrow(IllegalArgumentException::class.java)
      mockContentResolver(mockContentResolver, mockUri, "filename", 30, "text/plain")

      val mockIntent = mock<Intent>()
      val mockObjectFactory =
          mock<NativeObjectFactory> {
            on { newIntent(Intent.ACTION_OPEN_DOCUMENT) } doReturn mockIntent
            on { newDataInputStream(any()) } doReturn mock<DataInputStream>()
          }
      val mockActivity = mock<Activity> { on { contentResolver } doReturn mockContentResolver }
      val mockActivityBinding =
          mock<ActivityPluginBinding> { on { activity } doReturn mockActivity }
      val fileSelectorApi =
          FileSelectorApiImpl(mockActivityBinding, mockObjectFactory) { version ->
            Build.VERSION.SDK_INT >= version
          }

      var callbackCalled = false
      fileSelectorApi.openFile(null, FileTypes(emptyList(), emptyList())) { reply ->
        callbackCalled = true
        val file = checkNotNull(reply.getOrNull())
        assertNotNull(file.fileSelectorNativeException)
        assertEquals(FileUtils.FILE_SELECTOR_EXCEPTION_PLACEHOLDER_PATH, file.path)
      }
      verify(mockIntent).addCategory(Intent.CATEGORY_OPENABLE)

      verify(mockActivity).startActivityForResult(mockIntent, 221)

      val listenerArgumentCaptor = argumentCaptor<ActivityResultListener>()
      verify(mockActivityBinding).addActivityResultListener(listenerArgumentCaptor.capture())

      val resultMockIntent = mock<Intent> { on { data } doReturn mockUri }
      listenerArgumentCaptor.firstValue.onActivityResult(221, Activity.RESULT_OK, resultMockIntent)
      assertTrue(callbackCalled)
    }
  }

  @Test
  fun openFilesReturnsNativeException_whenIllegalArgumentExceptionInGetPathFromCopyOfFileFromUri() {
    Mockito.mockStatic(FileUtils::class.java).use { mockedFileUtils ->
      val mockContentResolver = mock<ContentResolver>()
      val mockUri = mock<Uri>()
      mockedFileUtils
          .whenever { FileUtils.getPathFromCopyOfFileFromUri(any(), eq(mockUri)) }
          .thenThrow(IllegalArgumentException::class.java)
      mockContentResolver(mockContentResolver, mockUri, "filename", 30, "text/plain")

      val mockIntent = mock<Intent>()
      val mockObjectFactory =
          mock<NativeObjectFactory> {
            on { newIntent(Intent.ACTION_OPEN_DOCUMENT) } doReturn mockIntent
            on { newDataInputStream(any()) } doReturn mock<DataInputStream>()
          }
      val mockActivity = mock<Activity> { on { contentResolver } doReturn mockContentResolver }
      val mockActivityBinding =
          mock<ActivityPluginBinding> { on { activity } doReturn mockActivity }
      val fileSelectorApi =
          FileSelectorApiImpl(mockActivityBinding, mockObjectFactory) { version ->
            Build.VERSION.SDK_INT >= version
          }

      var callbackCalled = false
      fileSelectorApi.openFiles(null, FileTypes(emptyList(), emptyList())) { reply ->
        callbackCalled = true
        val files = checkNotNull(reply.getOrNull())
        val file = files[0]
        assertNotNull(file.fileSelectorNativeException)
        assertEquals(FileUtils.FILE_SELECTOR_EXCEPTION_PLACEHOLDER_PATH, file.path)
      }
      verify(mockIntent).addCategory(Intent.CATEGORY_OPENABLE)
      verify(mockIntent).putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)

      verify(mockActivity).startActivityForResult(mockIntent, 222)

      val listenerArgumentCaptor = argumentCaptor<ActivityResultListener>()
      verify(mockActivityBinding).addActivityResultListener(listenerArgumentCaptor.capture())

      val mockClipDataItem = mock<ClipData.Item> { on { uri } doReturn mockUri }

      val mockClipData =
          mock<ClipData> {
            on { itemCount } doReturn 1
            on { getItemAt(0) } doReturn mockClipDataItem
          }

      val resultMockIntent = mock<Intent> { on { clipData } doReturn mockClipData }

      listenerArgumentCaptor.firstValue.onActivityResult(222, Activity.RESULT_OK, resultMockIntent)
      assertTrue(callbackCalled)
    }
  }

  @Test
  fun getDirectoryPathReturnsSuccessfully() {
    Mockito.mockStatic(FileUtils::class.java).use { mockedFileUtils ->
      val mockUri = mock<Uri>()
      val mockUriPath = "some/path/"
      val mockUriId = "someId"
      val mockUriUsingTree = mock<Uri>()

      mockedFileUtils
          .whenever { FileUtils.getPathFromUri(any(), eq(mockUriUsingTree)) }
          .thenReturn(mockUriPath)
      Mockito.mockStatic(DocumentsContract::class.java).use { mockedDocumentsContract ->
        mockedDocumentsContract
            .whenever { DocumentsContract.getTreeDocumentId(mockUri) }
            .thenReturn(mockUriId)
        mockedDocumentsContract
            .whenever { DocumentsContract.buildDocumentUriUsingTree(mockUri, mockUriId) }
            .thenReturn(mockUriUsingTree)

        val mockIntent = mock<Intent>()
        val mockObjectFactory =
            mock<NativeObjectFactory> {
              on { newIntent(Intent.ACTION_OPEN_DOCUMENT_TREE) } doReturn mockIntent
            }
        val mockActivity = mock<Activity>()
        val mockActivityBinding =
            mock<ActivityPluginBinding> { on { activity } doReturn mockActivity }
        val fileSelectorApi =
            FileSelectorApiImpl(mockActivityBinding, mockObjectFactory) { version ->
              Build.VERSION.SDK_INT >= version
            }

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
  }
}
