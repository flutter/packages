// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package dev.flutter.packages.file_selector_android

import android.app.Activity
import android.content.ClipData
import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import android.provider.OpenableColumns
import dev.flutter.packages.file_selector_android.FileSelectorApiImpl.AndroidSdkChecker
import dev.flutter.packages.file_selector_android.FileSelectorApiImpl.NativeObjectFactory
import dev.flutter.packages.file_selector_android.ResultCompat.Companion.asCompatCallback
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import org.junit.Assert
import org.junit.Rule
import org.junit.Test
import org.mockito.ArgumentCaptor
import org.mockito.ArgumentMatchers
import org.mockito.Mock
import org.mockito.MockedStatic
import org.mockito.Mockito
import org.mockito.invocation.InvocationOnMock
import org.mockito.junit.MockitoJUnit
import org.mockito.junit.MockitoRule
import org.mockito.stubbing.Answer
import java.io.DataInputStream
import java.io.FileNotFoundException
import java.io.InputStream

class FileSelectorAndroidPluginTest {
    @Rule
    var mockitoRule: MockitoRule = MockitoJUnit.rule()

    @Mock
    var mockIntent: Intent? = null

    @Mock
    var mockActivity: Activity? = null

    @Mock
    var mockObjectFactory: NativeObjectFactory? = null

    @Mock
    var mockActivityBinding: ActivityPluginBinding? = null

    @Throws(FileNotFoundException::class)
    private fun mockContentResolver(
        mockResolver: ContentResolver,
        uri: Uri,
        displayName: String,
        size: Int,
        mimeType: String
    ) {
        val mockCursor = Mockito.mock<Cursor>(Cursor::class.java)
        Mockito.`when`<Boolean?>(mockCursor.moveToFirst()).thenReturn(true)

        Mockito.`when`<Int?>(mockCursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)).thenReturn(0)
        Mockito.`when`<String?>(mockCursor.getString(0)).thenReturn(displayName)

        Mockito.`when`<Int?>(mockCursor.getColumnIndex(OpenableColumns.SIZE)).thenReturn(1)
        Mockito.`when`<Boolean?>(mockCursor.isNull(1)).thenReturn(false)
        Mockito.`when`<Int?>(mockCursor.getInt(1)).thenReturn(size)

        Mockito.`when`<Cursor?>(mockResolver.query(uri, null, null, null, null, null))
            .thenReturn(mockCursor)
        // `getType` is only reached when a `FileResponse` is built, so it is unused by
        // the error-path tests; keep it lenient to avoid strict-stubbing warnings.
        Mockito.lenient().`when`<String?>(mockResolver.getType(uri)).thenReturn(mimeType)
        Mockito.`when`<InputStream?>(mockResolver.openInputStream(uri)).thenReturn(
            Mockito.mock<InputStream?>(
                InputStream::class.java
            )
        )
    }

    @Test
    @Throws(FileNotFoundException::class)
    fun openFileReturnsSuccessfully() {
        Mockito.mockStatic<FileUtils?>(FileUtils::class.java).use { mockedFileUtils ->
            val mockContentResolver = Mockito.mock<ContentResolver>(ContentResolver::class.java)
            val mockUri = Mockito.mock<Uri>(Uri::class.java)
            val mockUriPath = "/some/path"
            mockedFileUtils
                .`when`<Any?>(MockedStatic.Verification {
                    FileUtils.getPathFromCopyOfFileFromUri(
                        ArgumentMatchers.any<Context?>(Context::class.java),
                        ArgumentMatchers.eq<Uri?>(mockUri)
                    )
                })
                .thenAnswer(Answer { invocation: InvocationOnMock? -> mockUriPath })
            mockContentResolver(mockContentResolver, mockUri, "filename", 30, "text/plain")

            Mockito.`when`<Intent?>(mockObjectFactory!!.newIntent(Intent.ACTION_OPEN_DOCUMENT))
                .thenReturn(mockIntent)
            Mockito.`when`<DataInputStream?>(mockObjectFactory!!.newDataInputStream(ArgumentMatchers.any<InputStream?>()))
                .thenReturn(
                    Mockito.mock<DataInputStream?>(DataInputStream::class.java)
                )
            Mockito.`when`<ContentResolver?>(mockActivity!!.getContentResolver())
                .thenReturn(mockContentResolver)
            Mockito.`when`<Activity?>(mockActivityBinding!!.getActivity()).thenReturn(mockActivity)
            val fileSelectorApi =
                FileSelectorApiImpl(
                    mockActivityBinding!!,
                    mockObjectFactory!!,
                    AndroidSdkChecker { version: Int -> Build.VERSION.SDK_INT >= version })

            val callbackCalled = arrayOfNulls<Boolean>(1)
            fileSelectorApi.openFile(
                null,
                FileTypes(mutableListOf<String>(), mutableListOf<String>()),
                asCompatCallback<FileResponse?> { reply: ResultCompat<FileResponse?>? ->
                    callbackCalled[0] = true
                    val file = reply!!.getOrNull()
                    Assert.assertNotNull(file)
                    Assert.assertEquals(30, file!!.bytes.size.toLong())
                    Assert.assertEquals("text/plain", file.mimeType)
                    Assert.assertEquals("filename", file.name)
                    Assert.assertEquals(30L, file.size)
                    Assert.assertEquals(mockUriPath, file.path)
                    null
                })
            Mockito.verify<Intent?>(mockIntent).addCategory(Intent.CATEGORY_OPENABLE)

            Mockito.verify<Activity?>(mockActivity).startActivityForResult(mockIntent, 221)

            val listenerArgumentCaptor =
                ArgumentCaptor.forClass<ActivityResultListener?, ActivityResultListener?>(
                    ActivityResultListener::class.java
                )
            Mockito.verify<ActivityPluginBinding?>(mockActivityBinding)
                .addActivityResultListener(listenerArgumentCaptor.capture()!!)

            val resultMockIntent = Mockito.mock<Intent>(Intent::class.java)
            Mockito.`when`<Uri?>(resultMockIntent.getData()).thenReturn(mockUri)
            listenerArgumentCaptor.getValue()!!
                .onActivityResult(221, Activity.RESULT_OK, resultMockIntent)
            Assert.assertTrue(callbackCalled[0]!!)
        }
    }

    @Test
    @Throws(FileNotFoundException::class)
    fun openFilesReturnsSuccessfully() {
        Mockito.mockStatic<FileUtils?>(FileUtils::class.java).use { mockedFileUtils ->
            val mockContentResolver = Mockito.mock<ContentResolver>(ContentResolver::class.java)
            val mockUri = Mockito.mock<Uri>(Uri::class.java)
            val mockUriPath = "some/path/"
            mockedFileUtils
                .`when`<Any?>(MockedStatic.Verification {
                    FileUtils.getPathFromCopyOfFileFromUri(
                        ArgumentMatchers.any<Context?>(Context::class.java),
                        ArgumentMatchers.eq<Uri?>(mockUri)
                    )
                })
                .thenAnswer(Answer { invocation: InvocationOnMock? -> mockUriPath })
            mockContentResolver(mockContentResolver, mockUri, "filename", 30, "text/plain")

            val mockUri2 = Mockito.mock<Uri>(Uri::class.java)
            val mockUri2Path = "some/other/path/"
            mockedFileUtils
                .`when`<Any?>(MockedStatic.Verification {
                    FileUtils.getPathFromCopyOfFileFromUri(
                        ArgumentMatchers.any<Context?>(Context::class.java),
                        ArgumentMatchers.eq<Uri?>(mockUri2)
                    )
                })
                .thenAnswer(Answer { invocation: InvocationOnMock? -> mockUri2Path })
            mockContentResolver(mockContentResolver, mockUri2, "filename2", 40, "image/jpg")

            Mockito.`when`<Intent?>(mockObjectFactory!!.newIntent(Intent.ACTION_OPEN_DOCUMENT))
                .thenReturn(mockIntent)
            Mockito.`when`<DataInputStream?>(mockObjectFactory!!.newDataInputStream(ArgumentMatchers.any<InputStream?>()))
                .thenReturn(
                    Mockito.mock<DataInputStream?>(DataInputStream::class.java)
                )
            Mockito.`when`<ContentResolver?>(mockActivity!!.getContentResolver())
                .thenReturn(mockContentResolver)
            Mockito.`when`<Activity?>(mockActivityBinding!!.getActivity()).thenReturn(mockActivity)
            val fileSelectorApi =
                FileSelectorApiImpl(
                    mockActivityBinding!!,
                    mockObjectFactory!!,
                    AndroidSdkChecker { version: Int -> Build.VERSION.SDK_INT >= version })

            val callbackCalled = arrayOfNulls<Boolean>(1)
            fileSelectorApi.openFiles(
                null,
                FileTypes(mutableListOf<String>(), mutableListOf<String>()),
                ResultCompat.asCompatCallback<MutableList<FileResponse>> { reply: ResultCompat<MutableList<FileResponse>?>? ->
                    callbackCalled[0] = true
                    val fileList = reply!!.getOrNull()
                    Assert.assertNotNull(fileList)
                    val file1 = fileList!!.get(0)
                    Assert.assertEquals(30, file1.bytes.size.toLong())
                    Assert.assertEquals("text/plain", file1.mimeType)
                    Assert.assertEquals("filename", file1.name)
                    Assert.assertEquals(30L, file1.size)
                    Assert.assertEquals(mockUriPath, file1.path)

                    val file2 = fileList.get(1)
                    Assert.assertEquals(40, file2.bytes.size.toLong())
                    Assert.assertEquals("image/jpg", file2.mimeType)
                    Assert.assertEquals("filename2", file2.name)
                    Assert.assertEquals(40L, file2.size)
                    Assert.assertEquals(mockUri2Path, file2.path)
                    null
                })
            Mockito.verify<Intent?>(mockIntent).addCategory(Intent.CATEGORY_OPENABLE)
            Mockito.verify<Intent?>(mockIntent).putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)

            Mockito.verify<Activity?>(mockActivity).startActivityForResult(mockIntent, 222)

            val listenerArgumentCaptor =
                ArgumentCaptor.forClass<ActivityResultListener?, ActivityResultListener?>(
                    ActivityResultListener::class.java
                )
            Mockito.verify<ActivityPluginBinding?>(mockActivityBinding)
                .addActivityResultListener(listenerArgumentCaptor.capture()!!)

            val resultMockIntent = Mockito.mock<Intent>(Intent::class.java)
            val mockClipData = Mockito.mock<ClipData>(ClipData::class.java)
            Mockito.`when`<Int?>(mockClipData.getItemCount()).thenReturn(2)

            val mockClipDataItem = Mockito.mock<ClipData.Item>(ClipData.Item::class.java)
            Mockito.`when`<Uri?>(mockClipDataItem.getUri()).thenReturn(mockUri)
            Mockito.`when`<ClipData.Item?>(mockClipData.getItemAt(0)).thenReturn(mockClipDataItem)

            val mockClipDataItem2 = Mockito.mock<ClipData.Item>(ClipData.Item::class.java)
            Mockito.`when`<Uri?>(mockClipDataItem2.getUri()).thenReturn(mockUri2)
            Mockito.`when`<ClipData.Item?>(mockClipData.getItemAt(1)).thenReturn(mockClipDataItem2)

            Mockito.`when`<ClipData?>(resultMockIntent.getClipData()).thenReturn(mockClipData)

            listenerArgumentCaptor.getValue()!!
                .onActivityResult(222, Activity.RESULT_OK, resultMockIntent)
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
        Mockito.mockStatic<FileUtils?>(FileUtils::class.java).use { mockedFileUtils ->
            val mockContentResolver = Mockito.mock<ContentResolver>(ContentResolver::class.java)
            val mockUri = Mockito.mock<Uri>(Uri::class.java)
            mockedFileUtils
                .`when`<Any?>(MockedStatic.Verification {
                    FileUtils.getPathFromCopyOfFileFromUri(
                        ArgumentMatchers.any<Context?>(Context::class.java),
                        ArgumentMatchers.eq<Uri?>(mockUri)
                    )
                })
                .thenThrow(SecurityException::class.java)
            mockContentResolver(mockContentResolver, mockUri, "filename", 30, "text/plain")

            Mockito.`when`<Intent?>(mockObjectFactory!!.newIntent(Intent.ACTION_OPEN_DOCUMENT))
                .thenReturn(mockIntent)
            Mockito.`when`<DataInputStream?>(mockObjectFactory!!.newDataInputStream(ArgumentMatchers.any<InputStream?>()))
                .thenReturn(
                    Mockito.mock<DataInputStream?>(DataInputStream::class.java)
                )
            Mockito.`when`<ContentResolver?>(mockActivity!!.getContentResolver())
                .thenReturn(mockContentResolver)
            Mockito.`when`<Activity?>(mockActivityBinding!!.getActivity()).thenReturn(mockActivity)
            val fileSelectorApi =
                FileSelectorApiImpl(
                    mockActivityBinding!!,
                    mockObjectFactory!!,
                    AndroidSdkChecker { version: Int -> Build.VERSION.SDK_INT >= version })

            val callbackCalled = BooleanArray(1)
            val failure = arrayOfNulls<Throwable>(1)
            fileSelectorApi.openFiles(
                null,
                FileTypes(mutableListOf<String>(), mutableListOf<String>()),
                ResultCompat.asCompatCallback<MutableList<FileResponse>> { reply: ResultCompat<MutableList<FileResponse>?>? ->
                    callbackCalled[0] = true
                    failure[0] = reply!!.exceptionOrNull()
                    null
                })
            Mockito.verify<Intent?>(mockIntent).addCategory(Intent.CATEGORY_OPENABLE)
            Mockito.verify<Intent?>(mockIntent).putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)

            Mockito.verify<Activity?>(mockActivity).startActivityForResult(mockIntent, 222)

            val listenerArgumentCaptor =
                ArgumentCaptor.forClass<ActivityResultListener?, ActivityResultListener?>(
                    ActivityResultListener::class.java
                )
            Mockito.verify<ActivityPluginBinding?>(mockActivityBinding)
                .addActivityResultListener(listenerArgumentCaptor.capture()!!)

            val resultMockIntent = Mockito.mock<Intent>(Intent::class.java)
            val mockClipData = Mockito.mock<ClipData>(ClipData::class.java)
            Mockito.`when`<Int?>(mockClipData.getItemCount()).thenReturn(1)

            val mockClipDataItem = Mockito.mock<ClipData.Item>(ClipData.Item::class.java)
            Mockito.`when`<Uri?>(mockClipDataItem.getUri()).thenReturn(mockUri)
            Mockito.`when`<ClipData.Item?>(mockClipData.getItemAt(0)).thenReturn(mockClipDataItem)

            Mockito.`when`<ClipData?>(resultMockIntent.getClipData()).thenReturn(mockClipData)

            // Previously this threw a NullPointerException (see #159568); it must now
            // complete the callback with a failure instead of crashing.
            listenerArgumentCaptor.getValue()!!
                .onActivityResult(222, Activity.RESULT_OK, resultMockIntent)

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
        val mockContentResolver = Mockito.mock<ContentResolver>(ContentResolver::class.java)
        val mockUri = Mockito.mock<Uri>(Uri::class.java)

        val mockCursor = Mockito.mock<Cursor>(Cursor::class.java)
        Mockito.`when`<Boolean?>(mockCursor.moveToFirst()).thenReturn(true)
        Mockito.`when`<Int?>(mockCursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)).thenReturn(0)
        Mockito.`when`<String?>(mockCursor.getString(0)).thenReturn("filename")
        Mockito.`when`<Int?>(mockCursor.getColumnIndex(OpenableColumns.SIZE)).thenReturn(1)
        Mockito.`when`<Boolean?>(mockCursor.isNull(1)).thenReturn(false)
        Mockito.`when`<Int?>(mockCursor.getInt(1)).thenReturn(30)
        Mockito.`when`<Cursor?>(mockContentResolver.query(mockUri, null, null, null, null, null))
            .thenReturn(mockCursor)
        // A provider that cannot serve the file answers the open with null; previously this reached
        // `DataInputStream#readFully` and threw a NullPointerException on the main thread.
        Mockito.`when`<InputStream?>(mockContentResolver.openInputStream(mockUri)).thenReturn(null)

        Mockito.`when`<Intent?>(mockObjectFactory!!.newIntent(Intent.ACTION_OPEN_DOCUMENT))
            .thenReturn(mockIntent)
        Mockito.`when`<ContentResolver?>(mockActivity!!.getContentResolver())
            .thenReturn(mockContentResolver)
        Mockito.`when`<Activity?>(mockActivityBinding!!.getActivity()).thenReturn(mockActivity)
        val fileSelectorApi =
            FileSelectorApiImpl(
                mockActivityBinding!!,
                mockObjectFactory!!,
                AndroidSdkChecker { version: Int -> Build.VERSION.SDK_INT >= version })

        val callbackCalled = BooleanArray(1)
        val failure = arrayOfNulls<Throwable>(1)
        fileSelectorApi.openFile(
            null,
            FileTypes(mutableListOf<String>(), mutableListOf<String>()),
            asCompatCallback<FileResponse?> { reply: ResultCompat<FileResponse?>? ->
                callbackCalled[0] = true
                failure[0] = reply!!.exceptionOrNull()
                null
            })

        Mockito.verify<Activity?>(mockActivity).startActivityForResult(mockIntent, 221)

        val listenerArgumentCaptor =
            ArgumentCaptor.forClass<ActivityResultListener?, ActivityResultListener?>(
                ActivityResultListener::class.java
            )
        Mockito.verify<ActivityPluginBinding?>(mockActivityBinding)
            .addActivityResultListener(listenerArgumentCaptor.capture()!!)

        val resultMockIntent = Mockito.mock<Intent>(Intent::class.java)
        Mockito.`when`<Uri?>(resultMockIntent.getData()).thenReturn(mockUri)
        listenerArgumentCaptor.getValue()!!
            .onActivityResult(221, Activity.RESULT_OK, resultMockIntent)

        Assert.assertTrue(callbackCalled[0])
        Assert.assertNotNull(failure[0])
        Assert.assertTrue(failure[0]!!.message!!.contains("Failed to read file"))
        Mockito.verify<NativeObjectFactory?>(mockObjectFactory, Mockito.never()).newDataInputStream(
            ArgumentMatchers.any<InputStream?>()
        )
    }

    @Test
    @Throws(FileNotFoundException::class)
    fun openFileCompletesWithError_whenSecurityExceptionInGetPathFromCopyOfFileFromUri() {
        Mockito.mockStatic<FileUtils?>(FileUtils::class.java).use { mockedFileUtils ->
            val mockContentResolver = Mockito.mock<ContentResolver>(ContentResolver::class.java)
            val mockUri = Mockito.mock<Uri>(Uri::class.java)
            mockedFileUtils
                .`when`<Any?>(MockedStatic.Verification {
                    FileUtils.getPathFromCopyOfFileFromUri(
                        ArgumentMatchers.any<Context?>(Context::class.java),
                        ArgumentMatchers.eq<Uri?>(mockUri)
                    )
                })
                .thenThrow(SecurityException::class.java)
            mockContentResolver(mockContentResolver, mockUri, "filename", 30, "text/plain")

            Mockito.`when`<Intent?>(mockObjectFactory!!.newIntent(Intent.ACTION_OPEN_DOCUMENT))
                .thenReturn(mockIntent)
            Mockito.`when`<DataInputStream?>(mockObjectFactory!!.newDataInputStream(ArgumentMatchers.any<InputStream?>()))
                .thenReturn(
                    Mockito.mock<DataInputStream?>(DataInputStream::class.java)
                )
            Mockito.`when`<ContentResolver?>(mockActivity!!.getContentResolver())
                .thenReturn(mockContentResolver)
            Mockito.`when`<Activity?>(mockActivityBinding!!.getActivity()).thenReturn(mockActivity)
            val fileSelectorApi =
                FileSelectorApiImpl(
                    mockActivityBinding!!,
                    mockObjectFactory!!,
                    AndroidSdkChecker { version: Int -> Build.VERSION.SDK_INT >= version })

            val callbackCalled = BooleanArray(1)
            val failure = arrayOfNulls<Throwable>(1)
            fileSelectorApi.openFile(
                null,
                FileTypes(mutableListOf<String>(), mutableListOf<String>()),
                asCompatCallback<FileResponse?> { reply: ResultCompat<FileResponse?>? ->
                    callbackCalled[0] = true
                    failure[0] = reply!!.exceptionOrNull()
                    null
                })

            Mockito.verify<Activity?>(mockActivity).startActivityForResult(mockIntent, 221)

            val listenerArgumentCaptor =
                ArgumentCaptor.forClass<ActivityResultListener?, ActivityResultListener?>(
                    ActivityResultListener::class.java
                )
            Mockito.verify<ActivityPluginBinding?>(mockActivityBinding)
                .addActivityResultListener(listenerArgumentCaptor.capture()!!)

            val resultMockIntent = Mockito.mock<Intent>(Intent::class.java)
            Mockito.`when`<Uri?>(resultMockIntent.getData()).thenReturn(mockUri)
            listenerArgumentCaptor.getValue()!!
                .onActivityResult(221, Activity.RESULT_OK, resultMockIntent)

            Assert.assertTrue(callbackCalled[0])
            Assert.assertNotNull(failure[0])
            Assert.assertTrue(failure[0]!!.message!!.contains("Failed to read file"))
        }
    }

    @Test
    @Throws(FileNotFoundException::class)
    fun openFileReturnsNativeException_whenIllegalArgumentExceptionInGetPathFromCopyOfFileFromUri() {
        Mockito.mockStatic<FileUtils?>(FileUtils::class.java).use { mockedFileUtils ->
            val mockContentResolver = Mockito.mock<ContentResolver>(ContentResolver::class.java)
            val mockUri = Mockito.mock<Uri>(Uri::class.java)
            mockedFileUtils
                .`when`<Any?>(MockedStatic.Verification {
                    FileUtils.getPathFromCopyOfFileFromUri(
                        ArgumentMatchers.any<Context?>(Context::class.java),
                        ArgumentMatchers.eq<Uri?>(mockUri)
                    )
                })
                .thenThrow(IllegalArgumentException::class.java)
            mockContentResolver(mockContentResolver, mockUri, "filename", 30, "text/plain")

            Mockito.`when`<Intent?>(mockObjectFactory!!.newIntent(Intent.ACTION_OPEN_DOCUMENT))
                .thenReturn(mockIntent)
            Mockito.`when`<DataInputStream?>(mockObjectFactory!!.newDataInputStream(ArgumentMatchers.any<InputStream?>()))
                .thenReturn(
                    Mockito.mock<DataInputStream?>(DataInputStream::class.java)
                )
            Mockito.`when`<ContentResolver?>(mockActivity!!.getContentResolver())
                .thenReturn(mockContentResolver)
            Mockito.`when`<Activity?>(mockActivityBinding!!.getActivity()).thenReturn(mockActivity)
            val fileSelectorApi =
                FileSelectorApiImpl(
                    mockActivityBinding!!,
                    mockObjectFactory!!,
                    AndroidSdkChecker { version: Int -> Build.VERSION.SDK_INT >= version })

            val callbackCalled = arrayOfNulls<Boolean>(1)
            fileSelectorApi.openFile(
                null,
                FileTypes(mutableListOf<String>(), mutableListOf<String>()),
                asCompatCallback<FileResponse?> { reply: ResultCompat<FileResponse?>? ->
                    callbackCalled[0] = true
                    val file = reply!!.getOrNull()
                    Assert.assertNotNull(file)
                    Assert.assertNotNull(file!!.fileSelectorNativeException)
                    Assert.assertEquals(
                        FileUtils.FILE_SELECTOR_EXCEPTION_PLACEHOLDER_PATH,
                        file.path
                    )
                    null
                })
            Mockito.verify<Intent?>(mockIntent).addCategory(Intent.CATEGORY_OPENABLE)

            Mockito.verify<Activity?>(mockActivity).startActivityForResult(mockIntent, 221)

            val listenerArgumentCaptor =
                ArgumentCaptor.forClass<ActivityResultListener?, ActivityResultListener?>(
                    ActivityResultListener::class.java
                )
            Mockito.verify<ActivityPluginBinding?>(mockActivityBinding)
                .addActivityResultListener(listenerArgumentCaptor.capture()!!)

            val resultMockIntent = Mockito.mock<Intent>(Intent::class.java)
            Mockito.`when`<Uri?>(resultMockIntent.getData()).thenReturn(mockUri)
            listenerArgumentCaptor.getValue()!!
                .onActivityResult(221, Activity.RESULT_OK, resultMockIntent)
            Assert.assertTrue(callbackCalled[0]!!)
        }
    }

    @Test
    @Throws(FileNotFoundException::class)
    fun openFilesReturnsNativeException_whenIllegalArgumentExceptionInGetPathFromCopyOfFileFromUri() {
        Mockito.mockStatic<FileUtils?>(FileUtils::class.java).use { mockedFileUtils ->
            val mockContentResolver = Mockito.mock<ContentResolver>(ContentResolver::class.java)
            val mockUri = Mockito.mock<Uri>(Uri::class.java)
            val mockUriPath = "some/path/"
            mockedFileUtils
                .`when`<Any?>(MockedStatic.Verification {
                    FileUtils.getPathFromCopyOfFileFromUri(
                        ArgumentMatchers.any<Context?>(Context::class.java),
                        ArgumentMatchers.eq<Uri?>(mockUri)
                    )
                })
                .thenThrow(IllegalArgumentException::class.java)
            mockContentResolver(mockContentResolver, mockUri, "filename", 30, "text/plain")

            Mockito.`when`<Intent?>(mockObjectFactory!!.newIntent(Intent.ACTION_OPEN_DOCUMENT))
                .thenReturn(mockIntent)
            Mockito.`when`<DataInputStream?>(mockObjectFactory!!.newDataInputStream(ArgumentMatchers.any<InputStream?>()))
                .thenReturn(
                    Mockito.mock<DataInputStream?>(DataInputStream::class.java)
                )
            Mockito.`when`<ContentResolver?>(mockActivity!!.getContentResolver())
                .thenReturn(mockContentResolver)
            Mockito.`when`<Activity?>(mockActivityBinding!!.getActivity()).thenReturn(mockActivity)
            val fileSelectorApi =
                FileSelectorApiImpl(
                    mockActivityBinding!!,
                    mockObjectFactory!!,
                    AndroidSdkChecker { version: Int -> Build.VERSION.SDK_INT >= version })

            val callbackCalled = arrayOfNulls<Boolean>(1)
            fileSelectorApi.openFiles(
                null,
                FileTypes(mutableListOf<String>(), mutableListOf<String>()),
                ResultCompat.asCompatCallback<MutableList<FileResponse>> { reply: ResultCompat<MutableList<FileResponse>?>? ->
                    callbackCalled[0] = true
                    val files = reply!!.getOrNull()
                    Assert.assertNotNull(files)
                    val file = files!!.get(0)
                    Assert.assertNotNull(file.fileSelectorNativeException)
                    Assert.assertEquals(
                        FileUtils.FILE_SELECTOR_EXCEPTION_PLACEHOLDER_PATH,
                        file.path
                    )
                    null
                })
            Mockito.verify<Intent?>(mockIntent).addCategory(Intent.CATEGORY_OPENABLE)
            Mockito.verify<Intent?>(mockIntent).putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)

            Mockito.verify<Activity?>(mockActivity).startActivityForResult(mockIntent, 222)

            val listenerArgumentCaptor =
                ArgumentCaptor.forClass<ActivityResultListener?, ActivityResultListener?>(
                    ActivityResultListener::class.java
                )
            Mockito.verify<ActivityPluginBinding?>(mockActivityBinding)
                .addActivityResultListener(listenerArgumentCaptor.capture()!!)

            val resultMockIntent = Mockito.mock<Intent>(Intent::class.java)
            val mockClipData = Mockito.mock<ClipData>(ClipData::class.java)
            Mockito.`when`<Int?>(mockClipData.getItemCount()).thenReturn(1)

            val mockClipDataItem = Mockito.mock<ClipData.Item>(ClipData.Item::class.java)
            Mockito.`when`<Uri?>(mockClipDataItem.getUri()).thenReturn(mockUri)
            Mockito.`when`<ClipData.Item?>(mockClipData.getItemAt(0)).thenReturn(mockClipDataItem)

            Mockito.`when`<ClipData?>(resultMockIntent.getClipData()).thenReturn(mockClipData)

            listenerArgumentCaptor.getValue()!!
                .onActivityResult(222, Activity.RESULT_OK, resultMockIntent)
            Assert.assertTrue(callbackCalled[0]!!)
        }
    }

    @Test
    fun getDirectoryPathReturnsSuccessfully() {
        Mockito.mockStatic<FileUtils?>(FileUtils::class.java).use { mockedFileUtils ->
            val mockUri = Mockito.mock<Uri?>(Uri::class.java)
            val mockUriPath = "some/path/"
            val mockUriId = "someId"
            val mockUriUsingTree = Mockito.mock<Uri?>(Uri::class.java)

            mockedFileUtils
                .`when`<Any?>(MockedStatic.Verification {
                    FileUtils.getPathFromUri(
                        ArgumentMatchers.any<Context?>(
                            Context::class.java
                        ), ArgumentMatchers.eq<Uri?>(mockUriUsingTree)
                    )
                })
                .thenAnswer(Answer { invocation: InvocationOnMock? -> mockUriPath })
            Mockito.mockStatic<DocumentsContract?>(DocumentsContract::class.java)
                .use { mockedDocumentsContract ->
                    mockedDocumentsContract
                        .`when`<Any?>(MockedStatic.Verification {
                            DocumentsContract.getTreeDocumentId(
                                mockUri
                            )
                        })
                        .thenAnswer(Answer { invocation: InvocationOnMock? -> mockUriId })
                    mockedDocumentsContract
                        .`when`<Any?>(MockedStatic.Verification {
                            DocumentsContract.buildDocumentUriUsingTree(
                                mockUri,
                                mockUriId
                            )
                        })
                        .thenAnswer(Answer { invocation: InvocationOnMock? -> mockUriUsingTree })

                    Mockito.`when`<Intent?>(mockObjectFactory!!.newIntent(Intent.ACTION_OPEN_DOCUMENT_TREE))
                        .thenReturn(mockIntent)
                    Mockito.`when`<Activity?>(mockActivityBinding!!.getActivity())
                        .thenReturn(mockActivity)
                    val fileSelectorApi =
                        FileSelectorApiImpl(
                            mockActivityBinding!!,
                            mockObjectFactory!!,
                            AndroidSdkChecker { version: Int -> Build.VERSION.SDK_INT >= version })

                    val callbackCalled = arrayOfNulls<Boolean>(1)
                    fileSelectorApi.getDirectoryPath(
                        null,
                        asCompatCallback<String?> { reply: ResultCompat<String?>? ->
                            callbackCalled[0] = true
                            Assert.assertEquals(mockUriPath, reply!!.getOrNull())
                            null
                        })

                    Mockito.verify<Activity?>(mockActivity).startActivityForResult(mockIntent, 223)

                    val listenerArgumentCaptor =
                        ArgumentCaptor.forClass<ActivityResultListener?, ActivityResultListener?>(
                            ActivityResultListener::class.java
                        )
                    Mockito.verify<ActivityPluginBinding?>(mockActivityBinding)
                        .addActivityResultListener(listenerArgumentCaptor.capture()!!)

                    val resultMockIntent = Mockito.mock<Intent>(Intent::class.java)
                    Mockito.`when`<Uri?>(resultMockIntent.getData()).thenReturn(mockUri)
                    listenerArgumentCaptor
                        .getValue()!!
                        .onActivityResult(223, Activity.RESULT_OK, resultMockIntent)
                    Assert.assertTrue(callbackCalled[0]!!)
                }
        }
    }
}
