// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2007-2008 OpenIntents.org
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * This file was modified by the Flutter authors from the following original file:
 * https://raw.githubusercontent.com/iPaulPro/aFileChooser/master/aFileChooser/src/com/ipaulpro/afilechooser/utils/FileUtils.java
 */

package dev.flutter.packages.file_selector_android;

import android.content.ContentResolver;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Environment;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.webkit.MimeTypeMap;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.UUID;

public class FileUtils {

  /** URI authority that represents access to external storage providers. */
  public static final String EXTERNAL_DOCUMENT_AUTHORITY = "com.android.externalstorage.documents";

  public static final String FILE_SELECTOR_EXCEPTION_PLACEHOLDER_PATH = "FILE_SELECTOR_EXCEPTION";

  /**
   * Retrieves path of directory represented by the specified {@code Uri}.
   *
   * <p>Intended to handle any cases needed to return paths from URIs retrieved from open
   * documents/directories by starting one of {@code Intent.ACTION_OPEN_FILE}, {@code
   * Intent.ACTION_OPEN_FILES}, or {@code Intent.ACTION_OPEN_DOCUMENT_TREE}.
   *
   * <p>Will return the path for on-device directories, but does not handle external storage
   * volumes.
   */
  @NonNull
  public static String getPathFromUri(@NonNull Context context, @NonNull Uri uri) {
    String uriAuthority = uri.getAuthority();

    if (EXTERNAL_DOCUMENT_AUTHORITY.equals(uriAuthority)) {
      String uriDocumentId = DocumentsContract.getDocumentId(uri);
      String[] uriDocumentIdSplit = uriDocumentId.split(":");

      if (uriDocumentIdSplit.length < 2) {
        // We expect the URI document ID to contain its storage volume and name to determine its path.
        throw new UnsupportedOperationException(
            "Retrieving the path of a document with an unknown storage volume or name is unsupported by this plugin.");
      }

      String documentStorageVolume = uriDocumentIdSplit[0];

      // Non-primary storage volumes come from SD cards, USB drives, etc. and are
      // not handled here.
      //
      // Constant for primary storage volumes found at
      // https://cs.android.com/android/platform/superproject/main/+/main:frameworks/base/core/java/android/provider/DocumentsContract.java;l=255?q=Documentscont&ss=android%2Fplatform%2Fsuperproject%2Fmain.
      if (!documentStorageVolume.equals("primary")) {
        throw new UnsupportedOperationException(
            "Retrieving the path of a document from storage volume "
                + documentStorageVolume
                + " is unsupported by this plugin.");
      }
      String innermostDirectoryName = uriDocumentIdSplit[1];
      String externalStorageDirectory = Environment.getExternalStorageDirectory().getPath();

      return externalStorageDirectory + "/" + innermostDirectoryName;
    } else {
      throw new UnsupportedOperationException(
          "Retrieving the path from URIs with authority "
              + uriAuthority.toString()
              + " is unsupported by this plugin.");
    }
  }

  /**
   * Copies the file from the given content URI to a temporary directory, retaining the original
   * file name if possible.
   *
   * <p>If the filename contains path indirection or separators (.. or /), the end file name will be
   * the segment after the final separator, with indirection replaced by underscores. E.g.
   * "example/../..file.png" -> "_file.png". See: <a
   * href="https://developer.android.com/privacy-and-security/risks/untrustworthy-contentprovider-provided-filename">Improperly
   * trusting ContentProvider-provided filename</a>.
   *
   * <p>Each file is placed in its own directory to avoid conflicts according to the following
   * scheme: {cacheDir}/{randomUuid}/{fileName}
   *
   * <p>File extension is changed to match MIME type of the file, if known. Otherwise, the extension
   * is left unchanged.
   *
   * <p>If the original file name is unknown, a predefined "file_selector" filename is used and the
   * file extension is deduced from the mime type.
   *
   * <p>Will return null if copying the URI contents into a new file does not complete successfully
   * or if a security exception is encountered when opening the input stream to start the copying.
   */
  @Nullable
  public static String getPathFromCopyOfFileFromUri(@NonNull Context context, @NonNull Uri uri)
      throws IOException, SecurityException, IllegalArgumentException {
    try (InputStream inputStream = context.getContentResolver().openInputStream(uri)) {
      String uuid = UUID.nameUUIDFromBytes(uri.toString().getBytes()).toString();
      File targetDirectory = new File(context.getCacheDir(), uuid);
      targetDirectory.mkdir();
      targetDirectory.deleteOnExit();
      String fileName = getFileName(context, uri);
      String extension = getFileExtension(context, uri);

      if (fileName == null) {
        if (extension == null) {
          throw new IllegalStateException("No name nor extension found for file.");
        } else {
          fileName = "file_selector" + extension;
        }
      } else if (extension != null) {
        fileName = getBaseName(fileName) + extension;
      }

      String filePath = new File(targetDirectory, fileName).getPath();
      File outputFile = saferOpenFile(filePath, targetDirectory.getCanonicalPath());

      try (OutputStream outputStream = new FileOutputStream(outputFile)) {
        copy(inputStream, outputStream);
        return outputFile.getPath();
      }
    }
  }

  /** Returns the extension of file with dot, or null if it's empty. */
  private static String getFileExtension(Context context, Uri uriFile) {
    String extension;

    if (uriFile.getScheme().equals(ContentResolver.SCHEME_CONTENT)) {
      final MimeTypeMap mime = MimeTypeMap.getSingleton();
      extension = mime.getExtensionFromMimeType(context.getContentResolver().getType(uriFile));
    } else {
      try {
        Uri uriFromFile = Uri.fromFile(new File(uriFile.getPath()));
        extension = MimeTypeMap.getFileExtensionFromUrl(uriFromFile.toString());
      } catch (NullPointerException e) {
        // File created from uriFile was null.
        return null;
      }
    }

    if (extension == null || extension.isEmpty()) {
      return null;
    }

    return "." + sanitizeFilename(extension);
  }

  /** Returns the name of the file provided by ContentResolver; this may be null. */
  private static String getFileName(Context context, Uri uriFile) {
    try (Cursor cursor = queryFileName(context, uriFile)) {
      if (cursor == null || !cursor.moveToFirst() || cursor.getColumnCount() < 1) {
        return null;
      }
      String unsanitizedFileName = cursor.getString(0);
      return sanitizeFilename(unsanitizedFileName);
    }
  }

  private static Cursor queryFileName(Context context, Uri uriFile) {
    return context
        .getContentResolver()
        .query(uriFile, new String[] {MediaStore.MediaColumns.DISPLAY_NAME}, null, null, null);
  }

  private static void copy(InputStream in, OutputStream out) throws IOException {
    final byte[] buffer = new byte[4 * 1024];
    int bytesRead;
    while ((bytesRead = in.read(buffer)) != -1) {
      out.write(buffer, 0, bytesRead);
    }
    out.flush();
  }

  private static String getBaseName(String fileName) {
    int lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex < 0) {
      return fileName;
    }
    // Basename is everything before the last '.'.
    return fileName.substring(0, lastDotIndex);
  }

  // From https://developer.android.com/privacy-and-security/risks/untrustworthy-contentprovider-provided-filename#sanitize-provided-filenames.
  protected static @Nullable String sanitizeFilename(@Nullable String displayName) {
    if (displayName == null) {
      return null;
    }

    String[] badCharacters = new String[] {"..", "/"};
    String[] segments = displayName.split("/");
    String fileName = segments[segments.length - 1];
    for (String suspString : badCharacters) {
      fileName = fileName.replace(suspString, "_");
    }
    return fileName;
  }

  /**
   * Use with file name sanatization and an non-guessable directory. From
   * https://developer.android.com/privacy-and-security/risks/path-traversal#path-traversal-mitigations.
   */
  protected static @NonNull File saferOpenFile(@NonNull String path, @NonNull String expectedDir)
      throws IllegalArgumentException, IOException {
    File f = new File(path);
    String canonicalPath = f.getCanonicalPath();
    if (!canonicalPath.startsWith(expectedDir)) {
      throw new IllegalArgumentException(
          "Trying to open path outside of the expected directory. File: "
              + f.getCanonicalPath()
              + " was expected to be within directory: "
              + expectedDir
              + ".");
    }
    return f;
  }
}
