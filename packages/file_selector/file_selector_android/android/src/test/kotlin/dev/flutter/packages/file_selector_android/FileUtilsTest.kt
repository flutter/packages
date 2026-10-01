// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package dev.flutter.packages.file_selector_android

import android.content.ContentProvider
import android.content.ContentResolver
import android.content.ContentValues
import android.content.Context
import android.database.Cursor
import android.database.MatrixCursor
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.DocumentsContract
import android.provider.MediaStore
import android.webkit.MimeTypeMap
import androidx.test.core.app.ApplicationProvider
import java.io.ByteArrayInputStream
import java.io.File
import java.io.IOException
import java.nio.charset.StandardCharsets
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito
import org.mockito.kotlin.doReturn
import org.mockito.kotlin.mock
import org.mockito.kotlin.spy
import org.mockito.kotlin.whenever
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows
import org.robolectric.shadows.ShadowContentResolver

@RunWith(RobolectricTestRunner::class)
class FileUtilsTest {
  private lateinit var context: Context
  private lateinit var shadowContentResolver: ShadowContentResolver
  private lateinit var contentResolver: ContentResolver

  @Before
  @Suppress("deprecation") // shadowOf(MimeTypeMap)
  fun before() {
    context = ApplicationProvider.getApplicationContext()
    contentResolver = spy(context.contentResolver)
    shadowContentResolver = Shadows.shadowOf(context.contentResolver)
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
      // On S and higher robolectric does not need this setup because all the mappings are
      // present already.
      val mimeTypeMap = Shadows.shadowOf(MimeTypeMap.getSingleton())
      mimeTypeMap.addExtensionMimeTypeMapping("txt", "text/plain")
      mimeTypeMap.addExtensionMimeTypeMapping("jpg", "image/jpeg")
      mimeTypeMap.addExtensionMimeTypeMapping("png", "image/png")
      mimeTypeMap.addExtensionMimeTypeMapping("webp", "image/webp")
    }
  }

  @Test
  fun getPathFromCopyOfFileFromUri_throwsIOExceptionForNullStream() {
    val uri = Uri.parse("content://dummy/dummy.txt")

    val mockContentResolver = mock<ContentResolver> { on { openInputStream(uri) } doReturn null }
    val mockContext = mock<Context> { on { contentResolver } doReturn mockContentResolver }

    assertThrows(IOException::class.java) {
      FileUtils.getPathFromCopyOfFileFromUri(mockContext, uri)
    }
  }

  @Test
  fun getPathFromUri_returnsExpectedPathForExternalDocumentUri() {
    // Uri that represents Documents/test directory on device:
    val uri =
        Uri.parse("content://com.android.externalstorage.documents/tree/primary%3ADocuments%2Ftest")
    Mockito.mockStatic(DocumentsContract::class.java).use { mockedDocumentsContract ->
      mockedDocumentsContract
          .whenever { DocumentsContract.getDocumentId(uri) }
          .thenReturn("primary:Documents/test")
      val path = FileUtils.getPathFromUri(context, uri)
      val externalStorageDirectoryPath = Environment.getExternalStorageDirectory().path
      val expectedPath = "$externalStorageDirectoryPath/Documents/test"
      assertEquals(expectedPath, path)
    }
  }

  @Test
  fun getPathFromUri_throwExceptionForExternalDocumentUriWithNonPrimaryStorageVolume() {
    // Uri that represents Documents/test directory from some external storage volume ("external"
    // for this test):
    val uri =
        Uri.parse(
            "content://com.android.externalstorage.documents/tree/external%3ADocuments%2Ftest")
    Mockito.mockStatic(DocumentsContract::class.java).use { mockedDocumentsContract ->
      mockedDocumentsContract
          .whenever { DocumentsContract.getDocumentId(uri) }
          .thenReturn("external:Documents/test")
      assertThrows(UnsupportedOperationException::class.java) {
        FileUtils.getPathFromUri(context, uri)
      }
    }
  }

  @Test
  fun getPathFromUri_throwExceptionForUriWithUnhandledAuthority() {
    val uri = Uri.parse("content://com.unsupported.authority/tree/primary%3ADocuments%2Ftest")
    assertThrows(UnsupportedOperationException::class.java) {
      FileUtils.getPathFromUri(context, uri)
    }
  }

  @Test
  fun getPathFromCopyOfFileFromUri_returnsPathWithContent() {
    val uri = MockContentProvider.PNG_URI
    Robolectric.buildContentProvider(MockContentProvider::class.java).create("dummy")
    shadowContentResolver.registerInputStream(
        uri, ByteArrayInputStream("fileStream".toByteArray(StandardCharsets.UTF_8)))

    val path = checkNotNull(FileUtils.getPathFromCopyOfFileFromUri(context, uri))
    assertEquals("fileStream", File(path).readText())
  }

  @Test
  fun getFileExtension_returnsExpectedFileExtension() {
    val uri = MockContentProvider.TXT_URI
    Robolectric.buildContentProvider(MockContentProvider::class.java).create("dummy")
    shadowContentResolver.registerInputStream(
        uri, ByteArrayInputStream("fileStream".toByteArray(StandardCharsets.UTF_8)))

    val path = checkNotNull(FileUtils.getPathFromCopyOfFileFromUri(context, uri))
    assertTrue(path.endsWith(".txt"))
  }

  @Test
  fun getFileName_returnsExpectedName() {
    val uri = MockContentProvider.PNG_URI
    Robolectric.buildContentProvider(MockContentProvider::class.java).create("dummy")
    shadowContentResolver.registerInputStream(
        uri, ByteArrayInputStream("fileStream".toByteArray(StandardCharsets.UTF_8)))
    val path = checkNotNull(FileUtils.getPathFromCopyOfFileFromUri(context, uri))
    assertTrue(path.endsWith("a.b.png"))
  }

  @Test
  fun getPathFromCopyOfFileFromUri_returnsExpectedPathForUriWithNoExtensionInBaseName() {
    val uri = MockContentProvider.NO_EXTENSION_URI
    Robolectric.buildContentProvider(MockContentProvider::class.java).create("dummy")
    shadowContentResolver.registerInputStream(
        uri, ByteArrayInputStream("fileStream".toByteArray(StandardCharsets.UTF_8)))
    val path = checkNotNull(FileUtils.getPathFromCopyOfFileFromUri(context, uri))
    assertTrue(path.endsWith("abc.png"))
  }

  @Test
  fun getPathFromCopyOfFileFromUri_returnsExpectedPathForUriWithMismatchedTypeToFile() {
    val uri = MockContentProvider.WEBP_URI
    Robolectric.buildContentProvider(MockContentProvider::class.java).create("dummy")
    shadowContentResolver.registerInputStream(
        uri, ByteArrayInputStream("fileStream".toByteArray(StandardCharsets.UTF_8)))
    val path = checkNotNull(FileUtils.getPathFromCopyOfFileFromUri(context, uri))
    assertTrue(path.endsWith("c.d.webp"))
  }

  @Test
  fun getPathFromCopyOfFileFromUri_returnsExpectedPathForUriWithUnknownType() {
    val uri = MockContentProvider.UNKNOWN_URI
    Robolectric.buildContentProvider(MockContentProvider::class.java).create("dummy")
    shadowContentResolver.registerInputStream(
        uri, ByteArrayInputStream("fileStream".toByteArray(StandardCharsets.UTF_8)))
    val path = checkNotNull(FileUtils.getPathFromCopyOfFileFromUri(context, uri))
    assertTrue(path.endsWith("e.f.g"))
  }

  @Test
  fun getPathFromCopyOfFileFromUri_sanitizesPathIndirection() {
    val uri = Uri.parse(MockMaliciousContentProvider.PNG_URI)
    Robolectric.buildContentProvider(MockMaliciousContentProvider::class.java).create("dummy")
    shadowContentResolver.registerInputStream(
        uri, ByteArrayInputStream("fileStream".toByteArray(StandardCharsets.UTF_8)))
    val path = checkNotNull(FileUtils.getPathFromCopyOfFileFromUri(context, uri))
    assertTrue(path.endsWith("_bar.png"))
    assertFalse(path.contains(".."))
  }

  private class MockContentProvider : ContentProvider() {
    override fun onCreate(): Boolean {
      return true
    }

    override fun query(
        uri: Uri,
        projection: Array<String>?,
        selection: String?,
        selectionArgs: Array<String>?,
        sortOrder: String?
    ): Cursor {
      val cursor = MatrixCursor(arrayOf(MediaStore.MediaColumns.DISPLAY_NAME))
      cursor.addRow(arrayOf(uri.lastPathSegment))
      return cursor
    }

    override fun getType(uri: Uri): String? =
        when (uri) {
          TXT_URI -> "text/plain"
          PNG_URI,
          NO_EXTENSION_URI -> "image/png"
          WEBP_URI -> "image/webp"
          else -> null
        }

    override fun insert(uri: Uri, values: ContentValues?): Uri? {
      return null
    }

    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<String?>?): Int {
      return 0
    }

    override fun update(
        uri: Uri,
        values: ContentValues?,
        selection: String?,
        selectionArgs: Array<String?>?
    ): Int {
      return 0
    }

    companion object {
      val TXT_URI: Uri = Uri.parse("content://dummy/dummydocument")
      val PNG_URI: Uri = Uri.parse("content://dummy/a.b.png")
      val WEBP_URI: Uri = Uri.parse("content://dummy/c.d.png")
      val UNKNOWN_URI: Uri = Uri.parse("content://dummy/e.f.g")
      val NO_EXTENSION_URI: Uri = Uri.parse("content://dummy/abc")
    }
  }

  // Mocks a malicious content provider attempting to use path indirection to modify files outside
  // of the intended directory.
  // See
  // https://developer.android.com/privacy-and-security/risks/untrustworthy-contentprovider-provided-filename#don%27t-trust-user-input.
  private class MockMaliciousContentProvider : ContentProvider() {
    override fun onCreate(): Boolean = true

    override fun query(
        uri: Uri,
        projection: Array<String>?,
        selection: String?,
        selectionArgs: Array<String>?,
        sortOrder: String?
    ): Cursor {
      val cursor = MatrixCursor(arrayOf(MediaStore.MediaColumns.DISPLAY_NAME))
      cursor.addRow(arrayOf("foo/../..bar.png"))
      return cursor
    }

    override fun getType(uri: Uri): String = "image/png"

    override fun insert(uri: Uri, values: ContentValues?): Uri? = null

    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<String?>?): Int = 0

    override fun update(
        uri: Uri,
        values: ContentValues?,
        selection: String?,
        selectionArgs: Array<String?>?
    ): Int = 0

    companion object {
      const val PNG_URI: String = "content://dummy/a.png"
    }
  }
}
