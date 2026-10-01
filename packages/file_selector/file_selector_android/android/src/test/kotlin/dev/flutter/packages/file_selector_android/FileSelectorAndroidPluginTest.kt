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
import java.io.FileNotFoundException
import java.io.InputStream
import org.junit.Assert
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
import org.mockito.stubbing.Answer

class FileSelectorAndroidPluginTest {
  @Throws(FileNotFoundException::class)
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
    Mockito.lenient().`when`<String?>(mockResolver.getType(uri)).thenReturn(mimeType)
    whenever(mockResolver.openInputStream(uri)).thenReturn(mock<InputStream>())
  }

  @Test
  @Throws(FileNotFoundException::class)
  fun openFileReturnsSuccessfully() {
    Mockito.mockStatic(FileUtils::class.java).use { mockedFileUtils ->
      val mockContentResolver = mock<ContentResolver>()
      val mockUri = mock<Uri>()
      val mockUriPath = "/some/path"
      mockedFileUtils
          .`when`<Any?> { FileUtils.getPathFromCopyOfFileFromUri(any(), eq(mockUri)) }
          .thenAnswer(Answer { mockUriPath })
      mockContentResolver(mockContentResolver, mockUri, "filename", 30, "text/plain")

      val mockIntent = mock<Intent>()
      val mockObjectFactory =
          mock<NativeObjectFactory> {
            on { newIntent(Intent.ACTION_OPEN_DOCUMENT) } doReturn (mockIntent)
            on { newDataInputStream(any()) } doReturn mock<DataInputStream>()
          }
      val mockActivity = mock<Activity> { on { contentResolver } doReturn mockContentResolver }
      val mockActivityBinding =
          mock<ActivityPluginBinding> { on { activity } doReturn mockActivity }

      val fileSelectorApi =
          FileSelectorApiImpl(mockActivityBinding, mockObjectFactory) { version: Int ->
            Build.VERSION.SDK_INT >= version
          }

      val callbackCalled = arrayOfNulls<Boolean>(1)
      fileSelectorApi.openFile(null, FileTypes(mutableListOf(), mutableListOf())) { reply ->
        callbackCalled[0] = true
        val file = reply.getOrNull()
        Assert.assertNotNull(file)
        Assert.assertEquals(30, file!!.bytes.size.toLong())
        Assert.assertEquals("text/plain", file.mimeType)
        Assert.assertEquals("filename", file.name)
        Assert.assertEquals(30L, file.size)
        Assert.assertEquals(mockUriPath, file.path)
      }
      verify(mockIntent).addCategory(Intent.CATEGORY_OPENABLE)

      verify(mockActivity).startActivityForResult(mockIntent, 221)

      val listenerArgumentCaptor = argumentCaptor<ActivityResultListener>()
      verify(mockActivityBinding).addActivityResultListener(listenerArgumentCaptor.capture())

      val resultMockIntent = mock<Intent> { on { data } doReturn mockUri }
      listenerArgumentCaptor.firstValue.onActivityResult(221, Activity.RESULT_OK, resultMockIntent)
      Assert.assertTrue(callbackCalled[0]!!)
    }
  }

  @Test
  @Throws(FileNotFoundException::class)
  fun openFilesReturnsSuccessfully() {
    Mockito.mockStatic(FileUtils::class.java).use { mockedFileUtils ->
      val mockContentResolver = mock<ContentResolver>()
      val mockUri = mock<Uri>()
      val mockUriPath = "some/path/"
      mockedFileUtils
          .`when`<Any?> { FileUtils.getPathFromCopyOfFileFromUri(any(), eq(mockUri)) }
          .thenAnswer(Answer { mockUriPath })
      mockContentResolver(mockContentResolver, mockUri, "filename", 30, "text/plain")

      val mockUri2 = mock<Uri>()
      val mockUri2Path = "some/other/path/"
      mockedFileUtils
          .`when`<Any?> { FileUtils.getPathFromCopyOfFileFromUri(any(), eq(mockUri2)) }
          .thenAnswer(Answer { mockUri2Path })
      mockContentResolver(mockContentResolver, mockUri2, "filename2", 40, "image/jpg")

      val mockIntent = mock<Intent>()
      val mockObjectFactory =
          mock<NativeObjectFactory> {
            on { newIntent(Intent.ACTION_OPEN_DOCUMENT) } doReturn (mockIntent)
            on { newDataInputStream(any()) } doReturn mock<DataInputStream>()
          }
      val mockActivity = mock<Activity> { on { contentResolver } doReturn mockContentResolver }
      val mockActivityBinding =
          mock<ActivityPluginBinding> { on { activity } doReturn mockActivity }
      val fileSelectorApi =
          FileSelectorApiImpl(mockActivityBinding, mockObjectFactory) { version: Int ->
            Build.VERSION.SDK_INT >= version
          }

      val callbackCalled = arrayOfNulls<Boolean>(1)
      fileSelectorApi.openFiles(null, FileTypes(mutableListOf(), mutableListOf())) { reply ->
        callbackCalled[0] = true
        val fileList = reply.getOrNull()
        Assert.assertNotNull(fileList)
        val file1 = fileList!![0]
        Assert.assertEquals(30, file1.bytes.size.toLong())
        Assert.assertEquals("text/plain", file1.mimeType)
        Assert.assertEquals("filename", file1.name)
        Assert.assertEquals(30L, file1.size)
        Assert.assertEquals(mockUriPath, file1.path)

        val file2 = fileList[1]
        Assert.assertEquals(40, file2.bytes.size.toLong())
        Assert.assertEquals("image/jpg", file2.mimeType)
        Assert.assertEquals("filename2", file2.name)
        Assert.assertEquals(40L, file2.size)
        Assert.assertEquals(mockUri2Path, file2.path)
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
      Assert.assertTrue(callbackCalled[0]!!)
    }
  }

  // Regression test for https://github.com/flutter/flutter/issues/159568: a
  // `SecurityException` while copying a selected file must be surfaced to Dart
  // as a failed result, rather than crashing by building a `FileResponse` with a
  // null `path` (which the non-null `path` field rejects at runtime).
  @Test
  @Throws(FileNotFoundException::class)
  fun openFilesCompletesWithError_whenSecurityExceptionInGetPathFromCopyOfFileFromUri() {
    Mockito.mockStatic(FileUtils::class.java).use { mockedFileUtils ->
      val mockContentResolver = mock<ContentResolver>()
      val mockUri = mock<Uri>()
      mockedFileUtils
          .`when`<Any?> { FileUtils.getPathFromCopyOfFileFromUri(any(), eq(mockUri)) }
          .thenThrow(SecurityException::class.java)
      mockContentResolver(mockContentResolver, mockUri, "filename", 30, "text/plain")

      val mockIntent = mock<Intent>()
      val mockObjectFactory =
          mock<NativeObjectFactory> {
            on { newIntent(Intent.ACTION_OPEN_DOCUMENT) } doReturn (mockIntent)
            on { newDataInputStream(any()) } doReturn mock<DataInputStream>()
          }
      val mockActivity = mock<Activity> { on { contentResolver } doReturn mockContentResolver }
      val mockActivityBinding =
          mock<ActivityPluginBinding> { on { activity } doReturn mockActivity }
      val fileSelectorApi =
          FileSelectorApiImpl(mockActivityBinding, mockObjectFactory) { version: Int ->
            Build.VERSION.SDK_INT >= version
          }

      val callbackCalled = BooleanArray(1)
      val failure = arrayOfNulls<Throwable>(1)
      fileSelectorApi.openFiles(null, FileTypes(mutableListOf(), mutableListOf())) { reply ->
        callbackCalled[0] = true
        failure[0] = reply.exceptionOrNull()
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

      Assert.assertTrue(callbackCalled[0])
      Assert.assertNotNull(failure[0])
      Assert.assertTrue(failure[0]!!.message!!.contains("Failed to read file"))
    }
  }

  // Regression test for https://github.com/flutter/flutter/issues/159568: the
  // single-file `openFile` path must likewise surface a copy failure to Dart
  // instead of crashing.
  @Test
  @Throws(FileNotFoundException::class)
  fun openFileCompletesWithError_whenProviderReturnsNullStream() {
    val mockContentResolver = mock<ContentResolver>()
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
    whenever(mockContentResolver.query(mockUri, null, null, null, null, null))
        .thenReturn(mockCursor)
    // A provider that cannot serve the file answers the open with null; previously this reached
    // `DataInputStream#readFully` and threw a NullPointerException on the main thread.
    whenever(mockContentResolver.openInputStream(mockUri)).thenReturn(null)

    val mockIntent = mock<Intent>()
    val mockObjectFactory =
        mock<NativeObjectFactory> {
          on { newIntent(Intent.ACTION_OPEN_DOCUMENT) } doReturn (mockIntent)
          on { newDataInputStream(any()) } doReturn mock<DataInputStream>()
        }
    val mockActivity = mock<Activity> { on { contentResolver } doReturn mockContentResolver }
    val mockActivityBinding = mock<ActivityPluginBinding> { on { activity } doReturn mockActivity }
    val fileSelectorApi =
        FileSelectorApiImpl(mockActivityBinding, mockObjectFactory) { version: Int ->
          Build.VERSION.SDK_INT >= version
        }

    val callbackCalled = BooleanArray(1)
    val failure = arrayOfNulls<Throwable>(1)
    fileSelectorApi.openFile(null, FileTypes(mutableListOf(), mutableListOf())) { reply ->
      callbackCalled[0] = true
      failure[0] = reply.exceptionOrNull()
    }

    verify(mockActivity).startActivityForResult(mockIntent, 221)

    val listenerArgumentCaptor = argumentCaptor<ActivityResultListener>()
    verify(mockActivityBinding).addActivityResultListener(listenerArgumentCaptor.capture())

    val resultMockIntent = mock<Intent> { on { data } doReturn mockUri }
    listenerArgumentCaptor.firstValue.onActivityResult(221, Activity.RESULT_OK, resultMockIntent)

    Assert.assertTrue(callbackCalled[0])
    Assert.assertNotNull(failure[0])
    Assert.assertTrue(failure[0]!!.message!!.contains("Failed to read file"))
    verify(mockObjectFactory, never()).newDataInputStream(any())
  }

  @Test
  @Throws(FileNotFoundException::class)
  fun openFileCompletesWithError_whenSecurityExceptionInGetPathFromCopyOfFileFromUri() {
    Mockito.mockStatic(FileUtils::class.java).use { mockedFileUtils ->
      val mockContentResolver = mock<ContentResolver>()
      val mockUri = mock<Uri>()
      mockedFileUtils
          .`when`<Any?> { FileUtils.getPathFromCopyOfFileFromUri(any(), eq(mockUri)) }
          .thenThrow(SecurityException::class.java)
      mockContentResolver(mockContentResolver, mockUri, "filename", 30, "text/plain")

      val mockIntent = mock<Intent>()
      val mockObjectFactory =
          mock<NativeObjectFactory> {
            on { newIntent(Intent.ACTION_OPEN_DOCUMENT) } doReturn (mockIntent)
            on { newDataInputStream(any()) } doReturn mock<DataInputStream>()
          }
      val mockActivity = mock<Activity> { on { contentResolver } doReturn mockContentResolver }
      val mockActivityBinding =
          mock<ActivityPluginBinding> { on { activity } doReturn mockActivity }
      val fileSelectorApi =
          FileSelectorApiImpl(mockActivityBinding, mockObjectFactory) { version: Int ->
            Build.VERSION.SDK_INT >= version
          }

      val callbackCalled = BooleanArray(1)
      val failure = arrayOfNulls<Throwable>(1)
      fileSelectorApi.openFile(null, FileTypes(mutableListOf(), mutableListOf())) { reply ->
        callbackCalled[0] = true
        failure[0] = reply.exceptionOrNull()
      }

      verify(mockActivity).startActivityForResult(mockIntent, 221)

      val listenerArgumentCaptor = argumentCaptor<ActivityResultListener>()
      verify(mockActivityBinding).addActivityResultListener(listenerArgumentCaptor.capture())

      val resultMockIntent = mock<Intent> { on { data } doReturn mockUri }
      listenerArgumentCaptor.firstValue.onActivityResult(221, Activity.RESULT_OK, resultMockIntent)

      Assert.assertTrue(callbackCalled[0])
      Assert.assertNotNull(failure[0])
      Assert.assertTrue(failure[0]!!.message!!.contains("Failed to read file"))
    }
  }

  @Test
  @Throws(FileNotFoundException::class)
  fun openFileReturnsNativeException_whenIllegalArgumentExceptionInGetPathFromCopyOfFileFromUri() {
    Mockito.mockStatic(FileUtils::class.java).use { mockedFileUtils ->
      val mockContentResolver = mock<ContentResolver>()
      val mockUri = mock<Uri>()
      mockedFileUtils
          .`when`<Any?> { FileUtils.getPathFromCopyOfFileFromUri(any(), eq(mockUri)) }
          .thenThrow(IllegalArgumentException::class.java)
      mockContentResolver(mockContentResolver, mockUri, "filename", 30, "text/plain")

      val mockIntent = mock<Intent>()
      val mockObjectFactory =
          mock<NativeObjectFactory> {
            on { newIntent(Intent.ACTION_OPEN_DOCUMENT) } doReturn (mockIntent)
            on { newDataInputStream(any()) } doReturn mock<DataInputStream>()
          }
      val mockActivity = mock<Activity> { on { contentResolver } doReturn mockContentResolver }
      val mockActivityBinding =
          mock<ActivityPluginBinding> { on { activity } doReturn mockActivity }
      val fileSelectorApi =
          FileSelectorApiImpl(mockActivityBinding, mockObjectFactory) { version: Int ->
            Build.VERSION.SDK_INT >= version
          }

      val callbackCalled = arrayOfNulls<Boolean>(1)
      fileSelectorApi.openFile(null, FileTypes(mutableListOf(), mutableListOf())) { reply ->
        callbackCalled[0] = true
        val file = reply.getOrNull()
        Assert.assertNotNull(file)
        Assert.assertNotNull(file!!.fileSelectorNativeException)
        Assert.assertEquals(FileUtils.FILE_SELECTOR_EXCEPTION_PLACEHOLDER_PATH, file.path)
      }
      verify(mockIntent).addCategory(Intent.CATEGORY_OPENABLE)

      verify(mockActivity).startActivityForResult(mockIntent, 221)

      val listenerArgumentCaptor = argumentCaptor<ActivityResultListener>()
      verify(mockActivityBinding).addActivityResultListener(listenerArgumentCaptor.capture())

      val resultMockIntent = mock<Intent> { on { data } doReturn mockUri }
      listenerArgumentCaptor.firstValue.onActivityResult(221, Activity.RESULT_OK, resultMockIntent)
      Assert.assertTrue(callbackCalled[0]!!)
    }
  }

  @Test
  @Throws(FileNotFoundException::class)
  fun openFilesReturnsNativeException_whenIllegalArgumentExceptionInGetPathFromCopyOfFileFromUri() {
    Mockito.mockStatic(FileUtils::class.java).use { mockedFileUtils ->
      val mockContentResolver = mock<ContentResolver>()
      val mockUri = mock<Uri>()
      mockedFileUtils
          .`when`<Any?> { FileUtils.getPathFromCopyOfFileFromUri(any(), eq(mockUri)) }
          .thenThrow(IllegalArgumentException::class.java)
      mockContentResolver(mockContentResolver, mockUri, "filename", 30, "text/plain")

      val mockIntent = mock<Intent>()
      val mockObjectFactory =
          mock<NativeObjectFactory> {
            on { newIntent(Intent.ACTION_OPEN_DOCUMENT) } doReturn (mockIntent)
            on { newDataInputStream(any()) } doReturn mock<DataInputStream>()
          }
      val mockActivity = mock<Activity> { on { contentResolver } doReturn mockContentResolver }
      val mockActivityBinding =
          mock<ActivityPluginBinding> { on { activity } doReturn mockActivity }
      val fileSelectorApi =
          FileSelectorApiImpl(mockActivityBinding, mockObjectFactory) { version: Int ->
            Build.VERSION.SDK_INT >= version
          }

      val callbackCalled = arrayOfNulls<Boolean>(1)
      fileSelectorApi.openFiles(null, FileTypes(mutableListOf(), mutableListOf())) { reply ->
        callbackCalled[0] = true
        val files = reply.getOrNull()
        Assert.assertNotNull(files)
        val file = files!![0]
        Assert.assertNotNull(file.fileSelectorNativeException)
        Assert.assertEquals(FileUtils.FILE_SELECTOR_EXCEPTION_PLACEHOLDER_PATH, file.path)
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
      Assert.assertTrue(callbackCalled[0]!!)
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
          .`when`<Any?> { FileUtils.getPathFromUri(any(), eq(mockUriUsingTree)) }
          .thenAnswer(Answer { mockUriPath })
      Mockito.mockStatic(DocumentsContract::class.java).use { mockedDocumentsContract ->
        mockedDocumentsContract
            .`when`<Any?> { DocumentsContract.getTreeDocumentId(mockUri) }
            .thenAnswer(Answer { mockUriId })
        mockedDocumentsContract
            .`when`<Any?> { DocumentsContract.buildDocumentUriUsingTree(mockUri, mockUriId) }
            .thenAnswer(Answer { mockUriUsingTree })

        val mockIntent = mock<Intent>()
        val mockObjectFactory =
            mock<NativeObjectFactory> {
              on { newIntent(Intent.ACTION_OPEN_DOCUMENT_TREE) } doReturn (mockIntent)
            }
        val mockActivity = mock<Activity>()
        val mockActivityBinding =
            mock<ActivityPluginBinding> { on { activity } doReturn (mockActivity) }
        val fileSelectorApi =
            FileSelectorApiImpl(mockActivityBinding, mockObjectFactory) { version: Int ->
              Build.VERSION.SDK_INT >= version
            }

        val callbackCalled = arrayOfNulls<Boolean>(1)
        fileSelectorApi.getDirectoryPath(null) { reply ->
          callbackCalled[0] = true
          Assert.assertEquals(mockUriPath, reply.getOrNull())
        }

        verify(mockActivity).startActivityForResult(mockIntent, 223)

        val listenerArgumentCaptor = argumentCaptor<ActivityResultListener>()
        verify(mockActivityBinding).addActivityResultListener(listenerArgumentCaptor.capture())

        val resultMockIntent = mock<Intent> { on { data } doReturn mockUri }
        listenerArgumentCaptor.firstValue.onActivityResult(
            223, Activity.RESULT_OK, resultMockIntent)
        Assert.assertTrue(callbackCalled[0]!!)
      }
    }
  }
}
