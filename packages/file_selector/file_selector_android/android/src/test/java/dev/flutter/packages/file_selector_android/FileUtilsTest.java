// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.file_selector_android;

import static java.nio.charset.StandardCharsets.UTF_8;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertThrows;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.spy;
import static org.robolectric.Shadows.shadowOf;

import android.content.ContentProvider;
import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.MatrixCursor;
import android.net.Uri;
import android.os.Environment;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.webkit.MimeTypeMap;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.test.core.app.ApplicationProvider;
import java.io.BufferedInputStream;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.MockedStatic;
import org.mockito.stubbing.Answer;
import org.robolectric.Robolectric;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.shadows.ShadowContentResolver;
import org.robolectric.shadows.ShadowMimeTypeMap;

@RunWith(RobolectricTestRunner.class)
public class FileUtilsTest {

  private Context context;
  ShadowContentResolver shadowContentResolver;
  ContentResolver contentResolver;

  @Before
  public void before() {
    context = ApplicationProvider.getApplicationContext();
    contentResolver = spy(context.getContentResolver());
    shadowContentResolver = shadowOf(context.getContentResolver());
    ShadowMimeTypeMap mimeTypeMap = shadowOf(MimeTypeMap.getSingleton());
    mimeTypeMap.addExtensionMimeTypeMapping("txt", "document/txt");
    mimeTypeMap.addExtensionMimeTypeMapping("jpg", "image/jpeg");
    mimeTypeMap.addExtensionMimeTypeMapping("png", "image/png");
    mimeTypeMap.addExtensionMimeTypeMapping("webp", "image/webp");
  }

  @Test
  public void getPathFromUri_returnsExpectedPathForExternalDocumentUri() {
    // Uri that represents Documents/test directory on device:
    Uri uri =
        Uri.parse(
            "content://com.android.externalstorage.documents/tree/primary%3ADocuments%2Ftest");
    try (MockedStatic<DocumentsContract> mockedDocumentsContract =
        mockStatic(DocumentsContract.class)) {
      mockedDocumentsContract
          .when(() -> DocumentsContract.getDocumentId(uri))
          .thenAnswer((Answer<String>) invocation -> "primary:Documents/test");
      String path = FileUtils.getPathFromUri(context, uri);
      String externalStorageDirectoryPath = Environment.getExternalStorageDirectory().getPath();
      String expectedPath = externalStorageDirectoryPath + "/Documents/test";
      assertEquals(path, expectedPath);
    }
  }

  @Test
  public void getPathFromUri_throwExceptionForExternalDocumentUriWithNonPrimaryStorageVolume() {
    // Uri that represents Documents/test directory from some external storage volume ("external" for this test):
    Uri uri =
        Uri.parse(
            "content://com.android.externalstorage.documents/tree/external%3ADocuments%2Ftest");
    try (MockedStatic<DocumentsContract> mockedDocumentsContract =
        mockStatic(DocumentsContract.class)) {
      mockedDocumentsContract
          .when(() -> DocumentsContract.getDocumentId(uri))
          .thenAnswer((Answer<String>) invocation -> "external:Documents/test");
      assertThrows(
          UnsupportedOperationException.class, () -> FileUtils.getPathFromUri(context, uri));
    }
  }

  @Test
  public void getPathFromUri_throwExceptionForUriWithUnhandledAuthority() {
    Uri uri = Uri.parse("content://com.unsupported.authority/tree/primary%3ADocuments%2Ftest");
    assertThrows(UnsupportedOperationException.class, () -> FileUtils.getPathFromUri(context, uri));
  }

  @Test
  public void getPathFromCopyOfFileFromUri_returnsPathWithContent() throws IOException {
    Uri uri = MockContentProvider.PNG_URI;
    Robolectric.buildContentProvider(MockContentProvider.class).create("dummy");
    shadowContentResolver.registerInputStream(
        uri, new ByteArrayInputStream("fileStream".getBytes(UTF_8)));

    String path = FileUtils.getPathFromCopyOfFileFromUri(context, uri);
    File file = new File(path);
    int size = (int) file.length();
    byte[] bytes = new byte[size];

    BufferedInputStream buf = new BufferedInputStream(new FileInputStream(file));
    buf.read(bytes, 0, bytes.length);
    buf.close();

    assertTrue(bytes.length > 0);
    String fileStream = new String(bytes, UTF_8);
    assertEquals("fileStream", fileStream);
  }

  @Test
  public void getFileExtension_returnsExpectedFileExtension() throws IOException {
    Uri uri = MockContentProvider.TXT_URI;
    Robolectric.buildContentProvider(MockContentProvider.class).create("dummy");
    shadowContentResolver.registerInputStream(
        uri, new ByteArrayInputStream("fileStream".getBytes(UTF_8)));

    String path = FileUtils.getPathFromCopyOfFileFromUri(context, uri);
    System.out.println(path);
    assertTrue(path.endsWith(".txt"));
  }

  @Test
  public void getFileName_returnsExpectedName() throws IOException {
    Uri uri = MockContentProvider.PNG_URI;
    Robolectric.buildContentProvider(MockContentProvider.class).create("dummy");
    shadowContentResolver.registerInputStream(
        uri, new ByteArrayInputStream("fileStream".getBytes(UTF_8)));
    String path = FileUtils.getPathFromCopyOfFileFromUri(context, uri);
    assertTrue(path.endsWith("a.b.png"));
  }

  @Test
  public void getPathFromCopyOfFileFromUri_returnsExpectedPathForUriWithNoExtensionInBaseName()
      throws IOException {
    Uri uri = MockContentProvider.NO_EXTENSION_URI;
    Robolectric.buildContentProvider(MockContentProvider.class).create("dummy");
    shadowContentResolver.registerInputStream(
        uri, new ByteArrayInputStream("fileStream".getBytes(UTF_8)));
    String path = FileUtils.getPathFromCopyOfFileFromUri(context, uri);
    assertTrue(path.endsWith("abc.png"));
  }

  @Test
  public void getPathFromCopyOfFileFromUri_returnsExpectedPathForUriWithMismatchedTypeToFile()
      throws IOException {
    Uri uri = MockContentProvider.WEBP_URI;
    Robolectric.buildContentProvider(MockContentProvider.class).create("dummy");
    shadowContentResolver.registerInputStream(
        uri, new ByteArrayInputStream("fileStream".getBytes(UTF_8)));
    String path = FileUtils.getPathFromCopyOfFileFromUri(context, uri);
    assertTrue(path.endsWith("c.d.webp"));
  }

  @Test
  public void getPathFromCopyOfFileFromUri_returnsExpectedPathForUriWithUnknownType()
      throws IOException {
    Uri uri = MockContentProvider.UNKNOWN_URI;
    Robolectric.buildContentProvider(MockContentProvider.class).create("dummy");
    shadowContentResolver.registerInputStream(
        uri, new ByteArrayInputStream("fileStream".getBytes(UTF_8)));
    String path = FileUtils.getPathFromCopyOfFileFromUri(context, uri);
    assertTrue(path.endsWith("e.f.g"));
  }

  @Test
  public void getPathFromCopyOfFileFromUri_sanitizesPathIndirection() throws IOException {
    Uri uri = Uri.parse(MockMaliciousContentProvider.PNG_URI);
    Robolectric.buildContentProvider(MockMaliciousContentProvider.class).create("dummy");
    shadowContentResolver.registerInputStream(
        uri, new ByteArrayInputStream("fileStream".getBytes(UTF_8)));
    String path = FileUtils.getPathFromCopyOfFileFromUri(context, uri);
    assertNotNull(path);
    assertTrue(path.endsWith("_bar.png"));
    assertFalse(path.contains(".."));
  }

  private static class MockContentProvider extends ContentProvider {
    public static final Uri TXT_URI = Uri.parse("content://dummy/dummydocument");
    public static final Uri PNG_URI = Uri.parse("content://dummy/a.b.png");
    public static final Uri WEBP_URI = Uri.parse("content://dummy/c.d.png");
    public static final Uri UNKNOWN_URI = Uri.parse("content://dummy/e.f.g");
    public static final Uri NO_EXTENSION_URI = Uri.parse("content://dummy/abc");

    @Override
    public boolean onCreate() {
      return true;
    }

    @Nullable
    @Override
    public Cursor query(
        @NonNull Uri uri,
        @Nullable String[] projection,
        @Nullable String selection,
        @Nullable String[] selectionArgs,
        @Nullable String sortOrder) {
      MatrixCursor cursor = new MatrixCursor(new String[] {MediaStore.MediaColumns.DISPLAY_NAME});
      cursor.addRow(new Object[] {uri.getLastPathSegment()});
      return cursor;
    }

    @Nullable
    @Override
    public String getType(@NonNull Uri uri) {
      if (uri.equals(TXT_URI)) return "document/txt";
      if (uri.equals(PNG_URI)) return "image/png";
      if (uri.equals(WEBP_URI)) return "image/webp";
      if (uri.equals(NO_EXTENSION_URI)) return "image/png";
      return null;
    }

    @Nullable
    @Override
    public Uri insert(@NonNull Uri uri, @Nullable ContentValues values) {
      return null;
    }

    @Override
    public int delete(
        @NonNull Uri uri, @Nullable String selection, @Nullable String[] selectionArgs) {
      return 0;
    }

    @Override
    public int update(
        @NonNull Uri uri,
        @Nullable ContentValues values,
        @Nullable String selection,
        @Nullable String[] selectionArgs) {
      return 0;
    }
  }

  // Mocks a malicious content provider attempting to use path indirection to modify files outside
  // of the intended directory.
  // See https://developer.android.com/privacy-and-security/risks/untrustworthy-contentprovider-provided-filename#don%27t-trust-user-input.
  private static class MockMaliciousContentProvider extends ContentProvider {
    public static String PNG_URI = "content://dummy/a.png";

    @Override
    public boolean onCreate() {
      return true;
    }

    @Nullable
    @Override
    public Cursor query(
        @NonNull Uri uri,
        @Nullable String[] projection,
        @Nullable String selection,
        @Nullable String[] selectionArgs,
        @Nullable String sortOrder) {
      MatrixCursor cursor = new MatrixCursor(new String[] {MediaStore.MediaColumns.DISPLAY_NAME});
      cursor.addRow(new Object[] {"foo/../..bar.png"});
      return cursor;
    }

    @Nullable
    @Override
    public String getType(@NonNull Uri uri) {
      return "image/png";
    }

    @Nullable
    @Override
    public Uri insert(@NonNull Uri uri, @Nullable ContentValues values) {
      return null;
    }

    @Override
    public int delete(
        @NonNull Uri uri, @Nullable String selection, @Nullable String[] selectionArgs) {
      return 0;
    }

    @Override
    public int update(
        @NonNull Uri uri,
        @Nullable ContentValues values,
        @Nullable String selection,
        @Nullable String[] selectionArgs) {
      return 0;
    }
  }
}
