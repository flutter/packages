// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.file_selector_android;

import android.app.Activity;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.provider.DocumentsContract;
import android.provider.OpenableColumns;
import android.util.Log;
import android.webkit.MimeTypeMap;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.PluginRegistry;
import java.io.DataInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

public class FileSelectorApiImpl implements GeneratedFileSelectorApi.FileSelectorApi {
  private static final String TAG = "FileSelectorApiImpl";
  // Request code for selecting a file.
  private static final int OPEN_FILE = 221;

  public Context tryContext;

  @VisibleForTesting
  abstract static class OnResultListener {
    public abstract void onResult(int resultCode, @Nullable Intent data);
  }

  @Nullable private ActivityPluginBinding activityPluginBinding;

  public FileSelectorApiImpl(@NonNull ActivityPluginBinding activityPluginBinding) {
    this.activityPluginBinding = activityPluginBinding;
  }

  @Override
  public void openFile(
      @Nullable String initialDirectory,
      @Nullable List<String> mimeTypes,
      @Nullable List<String> extensions,
      @NonNull GeneratedFileSelectorApi.Result<GeneratedFileSelectorApi.FileResponse> result) {
    final Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
    intent.addCategory(Intent.CATEGORY_OPENABLE);

    trySetMimeTypes(intent, mimeTypes, extensions);

    try {
      trySetInitialDirectory(intent, initialDirectory);
      tryStartActivityForResult(
          intent,
          OPEN_FILE,
          new OnResultListener() {
            @Override
            public void onResult(int resultCode, @Nullable Intent data) {
              if (resultCode == Activity.RESULT_OK && data != null) {
                final Uri uri = data.getData();
                result.success(toFileResponse(uri));
              } else {
                result.success(null);
              }
            }
          });
    } catch (Exception exception) {
      result.error(exception);
    }
  }

  @Override
  public void openFiles(
      @Nullable String initialDirectory,
      @Nullable List<String> mimeTypes,
      @Nullable List<String> extensions,
      @NonNull
          GeneratedFileSelectorApi.Result<List<GeneratedFileSelectorApi.FileResponse>> result) {}

  @Override
  public void getDirectoryPath(
      @Nullable String initialDirectory, @NonNull GeneratedFileSelectorApi.Result<String> result) {}

  @Override
  public void getDirectoryPaths(
      @Nullable String initialDirectory,
      @NonNull GeneratedFileSelectorApi.Result<List<String>> result) {}

  public void setActivityPluginBinding(@Nullable ActivityPluginBinding activityPluginBinding) {
    this.activityPluginBinding = activityPluginBinding;
  }

  // Setting the mimeType with `setType` is required when opening files. This handles setting the
  // mimeType based on the `mimeTypes` list and converts extensions to mimeTypes.
  // See https://developer.android.com/guide/components/intents-common#OpenFile
  private void trySetMimeTypes(
      @NonNull Intent intent, @Nullable List<String> mimeTypes, @Nullable List<String> extensions) {
    final List<String> extensionMimeTypes = tryConvertExtensionsToMimetypes(extensions);

    final List<String> allMimetypes = new ArrayList<>();
    if (mimeTypes != null) {
      allMimetypes.addAll(mimeTypes);
    }
    if (extensionMimeTypes != null) {
      allMimetypes.addAll(extensionMimeTypes);
    }

    if (mimeTypes == null && extensionMimeTypes == null) {
      intent.setType("*/*");
    } else if (allMimetypes.isEmpty()) {
      intent.setType("*/*");
    } else if (allMimetypes.size() == 1) {
      intent.setType(allMimetypes.get(0));
    } else {
      intent.setType("*/*");
      intent.putExtra(Intent.EXTRA_MIME_TYPES, allMimetypes.toArray(new String[0]));
    }
  }

  @Nullable
  private List<String> tryConvertExtensionsToMimetypes(@Nullable List<String> extensions) {
    if (extensions == null) {
      return null;
    }

    final MimeTypeMap mimeTypeMap = MimeTypeMap.getSingleton();
    final List<String> mimeTypes = new ArrayList<>();
    for (String extension : extensions) {
      final String mimetype = mimeTypeMap.getMimeTypeFromExtension(extension);
      if (mimetype != null) {
        mimeTypes.add(mimetype);
      } else {
        Log.d(TAG, String.format("Extension not supported: %s", extension));
      }
    }

    return mimeTypes;
  }

  private void trySetInitialDirectory(@NonNull Intent intent, @Nullable String initialDirectory)
      throws Exception {
    if (initialDirectory != null) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, Uri.parse(initialDirectory));
      } else {
        throw new Exception(
            "Setting an initial directory requires Android version Build.VERSION_CODES.O or greater.");
      }
    }
  }

  private void tryStartActivityForResult(
      @NonNull Intent intent, int attemptRequestCode, @NonNull OnResultListener resultListener)
      throws Exception {
    if (activityPluginBinding == null) {
      throw new Exception("No activity is available.");
    }
    activityPluginBinding.addActivityResultListener(
        new PluginRegistry.ActivityResultListener() {
          @Override
          public boolean onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
            if (requestCode == attemptRequestCode) {
              resultListener.onResult(resultCode, data);
              activityPluginBinding.removeActivityResultListener(this);
              return true;
            }

            return false;
          }
        });
    activityPluginBinding.getActivity().startActivityForResult(intent, attemptRequestCode);
  }

  @Nullable
  private GeneratedFileSelectorApi.FileResponse toFileResponse(@NonNull Uri uri) {
    if (activityPluginBinding == null) {
      Log.d(TAG, "Activity is not available");
      return null;
    }

    final ContentResolver contentResolver = tryContext.getContentResolver();

    String name = null;
    Integer size = null;
    try (Cursor cursor = contentResolver.query(uri, null, null, null, null, null)) {
      if (cursor != null && cursor.moveToFirst()) {
        // Note it's called "Display Name". This is
        // provider-specific, and might not necessarily be the file name.
        final int nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME);
        if (nameIndex >= 0) {
          name = cursor.getString(nameIndex);
        }

        final int sizeIndex = cursor.getColumnIndex(OpenableColumns.SIZE);
        // If the size is unknown, the value stored is null. But because an
        // int can't be null, the behavior is implementation-specific,
        // and unpredictable. So as
        // a rule, check if it's null before assigning to an int. This will
        // happen often: The storage API allows for remote files, whose
        // size might not be locally known.
        if (!cursor.isNull(sizeIndex)) {
          size = cursor.getInt(sizeIndex);
        }
      }
    }

    byte[] bytes = null;
    if (size != null) {
      bytes = new byte[size];
      try (InputStream inputStream = contentResolver.openInputStream(uri)) {
        final DataInputStream dataInputStream = new DataInputStream(inputStream);
        dataInputStream.readFully(bytes);
      } catch (IOException exception) {
        Log.d(TAG, String.format("Failed to read bytes from file: %s", uri));
      }
    }

    if (bytes == null) {
      return null;
    }

    return new GeneratedFileSelectorApi.FileResponse.Builder()
        .setName(name)
        .setBytes(bytes)
        .setPath(uri.toString())
        .setMimeType(contentResolver.getType(uri))
        .setSize(size.longValue())
        .build();
  }
}
