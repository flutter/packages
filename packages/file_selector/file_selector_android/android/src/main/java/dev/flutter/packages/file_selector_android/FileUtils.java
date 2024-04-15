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

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.text.TextUtils;

import android.provider.MediaStore;
import android.webkit.MimeTypeMap;
import io.flutter.Log;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.UUID;

public class FileUtils {

    /** URI authority that represents access to external storage providers. */
    public static String EXTERNAL_DOCUMENT_AUTHORITY = "com.android.externalstorage.documents";

    /** URI authority that represents a media document. */
    public static String MEDIA_DOCUMENT_AUTHORITY = "com.android.providers.media.documents";

  /**
   * Copies the file from the given content URI to a temporary directory, retaining the original
   * file name if possible.
   *
   * <p>Each file is placed in its own directory to avoid conflicts according to the following
   * scheme: {cacheDir}/{randomUuid}/{fileName}
   *
   * <p>File extension is changed to match MIME type of the file, if known. Otherwise, the extension
   * is left unchanged.
   *
   * <p>If the original file name is unknown, a predefined "file_selector" filename is used and the
   * file extension is deduced from the mime type.
   */
  public static String getPathFromCopyOfFileFromUri(final Context context, final Uri uri) {
    try (InputStream inputStream = context.getContentResolver().openInputStream(uri)) {
      String uuid = UUID.randomUUID().toString();
      File targetDirectory = new File(context.getCacheDir(), uuid);
      targetDirectory.mkdir();
      // TODO(camsim99): according to the docs, `deleteOnExit` does not work reliably on Android; we should preferably
      // just clear the picked files after the app startup.
      targetDirectory.deleteOnExit();
      String fileName = getFileName(context, uri);
      String extension = getFileExtension(context, uri);

      if (fileName == null) {
        if (extension == null) {
            throw new IllegalArgumentException("CAMILLE: NO EXTENSION FOUND");
        } else {
            fileName = "file_selector" + extension;
        }
      } else if (extension != null) {
        fileName = getBaseName(fileName) + extension;
      } else {
        throw new IllegalArgumentException("CAMILLE: NO EXTENSiON FOUND 2");
      }

      File file = new File(targetDirectory, fileName);
      try (OutputStream outputStream = new FileOutputStream(file)) {
        copy(inputStream, outputStream);
        return file.getPath();
      }
    } catch (IOException e) {
      // If closing the output stream fails, we cannot be sure that the
      // target file was written in full. Flushing the stream merely moves
      // the bytes into the OS, not necessarily to the file.
      return null;
    } catch (SecurityException e) {
      // Calling `ContentResolver#openInputStream()` has been reported to throw a
      // `SecurityException` on some devices in certain circumstances. Instead of crashing, we
      // return `null`.
      //
      // See https://github.com/flutter/flutter/issues/100025 for more details.
      return null;
    }
  }

  /** Returns the extension of file with dot, or null if it's empty. */
  private static String getFileExtension(Context context, Uri uriFile) {
    String extension;

    try {
      if (uriFile.getScheme().equals(ContentResolver.SCHEME_CONTENT)) {
        final MimeTypeMap mime = MimeTypeMap.getSingleton();
        extension = mime.getExtensionFromMimeType(context.getContentResolver().getType(uriFile));
      } else {
        extension =
            MimeTypeMap.getFileExtensionFromUrl(
                Uri.fromFile(new File(uriFile.getPath())).toString());
      }
    } catch (Exception e) {
      return null;
    }

    if (extension == null || extension.isEmpty()) {
      return null;
    }

    return "." + extension;
  }

  /** Returns the name of the file provided by ContentResolver; this may be null. */
  private static String getFileName(Context context, Uri uriFile) {
    try (Cursor cursor = queryFileName(context, uriFile)) {
      if (cursor == null || !cursor.moveToFirst() || cursor.getColumnCount() < 1) return null;
      return cursor.getString(0);
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

    /**
     * Retrieves path of directory represented by the specified {@code Uri}.
     * 
     * Intended to handle any cases needed to return paths from URIS retrieved from open documents/directories
     * by starting one of {@code Intent.ACTION_OPEN_FILE}, {@code Intent.ACTION_OPEN_FILES}, or
     * {@code Intent.ACTION_OPEN_DOCUMENT_TREE}.
     * 
     * <p>Will return the path for on-device directories, but does not handle external storage volumes.
     */
    public static String getPathFromUri(Activity activity, Uri uri) {
        String uriAuthority = uri.getAuthority();

        if (uriAuthority.equals(EXTERNAL_DOCUMENT_AUTHORITY)) {
            String uriDocumentId = DocumentsContract.getDocumentId(uri);
            String documentStorageVolume = uriDocumentId.split(":")[0];

            // Non-primary storage volumes come from SD cards, USB drives, etc. and are
            // not handled here.
            if (!documentStorageVolume.equals("primary")) {
                throw new UnsupportedOperationException("Retrieving the path of a document from storage volume " + documentStorageVolume + " is unsupported by this plugin.");
            }
            String innermostDirectoryName = uriDocumentId.split(":")[1];
            String externalStorageDirectory = Environment.getExternalStorageDirectory().getPath();

            return externalStorageDirectory + "/" + innermostDirectoryName;
        } else if (uriAuthority.equals(MEDIA_DOCUMENT_AUTHORITY)) {
            String uriDocumentId = DocumentsContract.getDocumentId(uri);
            String documentStorageVolume = uriDocumentId.split(":")[0];
            ContentResolver contentResolver = activity.getContentResolver();

            // This makes an assumption that the URI has the content scheme, which we can safely
            // assume since this method only supports finding paths of URIs retrieved from
            // the Intents ACTION_OPEN_FILE(S) and ACTION_OPEN_DOCUMENT_TREE.
            Cursor cursor = contentResolver.query(uri, null, null, null, null, null);

            if (cursor != null && cursor.moveToFirst()) {
                return cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.RELATIVE_PATH)); // TODO(camsim99): probably making assumption here about file type
            } else {
                throw new IllegalStateException("Was unable to retrieve path from URI " + uri.toString() + " by using Cursor.");
            }
        } else {
            throw new UnsupportedOperationException("Retrieving the path from URIs with authority " + uriAuthority.toString() + " are unsupported by this plugin.");
        }
    }
}
