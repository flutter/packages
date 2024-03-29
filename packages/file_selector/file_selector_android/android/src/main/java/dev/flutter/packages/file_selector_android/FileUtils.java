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

    /**
     * Retrieves path of directory represented by the specified {@code Uri}.
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
                throw new UnsupportedOperationException("Retrieving the path of a document from storage volume " + documentStorageVolume + "is unsupported by this plugin.");
            }
            String innermostDirectoryName = uriDocumentId.split(":")[1];
            String externalStorageDirectory = Environment.getExternalStorageDirectory().getPath();

            return externalStorageDirectory + "/" + innermostDirectoryName;
        } else {
            throw new UnsupportedOperationException("Retrieving the path from URIs with authority " + uriAuthority.toString() + "are unsupported by this plugin.");
        }
    }
}
