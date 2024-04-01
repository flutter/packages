// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;

public class FileUtils {

    /** URI authority that represents access to external storage providers. */
    public static String EXTERNAL_DOCUMENT_AUTHORITY = "com.android.externalstorage.documents";

    /** URI authority that represents a media document. */
    public static String MEDIA_DOCUMENT_AUTHORITY = "com.android.providers.media.documents";

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
