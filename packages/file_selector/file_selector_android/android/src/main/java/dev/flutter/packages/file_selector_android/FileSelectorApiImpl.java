// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.file_selector_android;

import static dev.flutter.packages.file_selector_android.FileUtils.FILE_SELECTOR_EXCEPTION_PLACEHOLDER_PATH;

import android.app.Activity;
import android.content.ClipData;
import android.content.ContentResolver;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.provider.DocumentsContract;
import android.provider.OpenableColumns;
import android.util.Log;
import android.webkit.MimeTypeMap;
import androidx.annotation.ChecksSdkIntAtLeast;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.PluginRegistry;
import java.io.DataInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class FileSelectorApiImpl implements GeneratedFileSelectorApi.FileSelectorApi {
  private static final String TAG = "FileSelectorApiImpl";
  // Request code for selecting a file.
  private static final int OPEN_FILE = 221;
  // Request code for selecting files.
  private static final int OPEN_FILES = 222;
  // Request code for selecting a directory.
  private static final int OPEN_DIR = 223;

  private final @NonNull NativeObjectFactory objectFactory;
  private final @NonNull AndroidSdkChecker sdkChecker;
  @Nullable ActivityPluginBinding activityPluginBinding;

  private abstract static class OnResultListener {
    public abstract void onResult(int resultCode, @Nullable Intent data);
  }

  // Handles instantiating class objects that are needed by this class. This is provided to be
  // overridden for tests.
  @VisibleForTesting
  static class NativeObjectFactory {
    @NonNull
    Intent newIntent(@NonNull String action) {
      return new Intent(action);
    }

    @NonNull
    DataInputStream newDataInputStream(InputStream inputStream) {
      return new DataInputStream(inputStream);
    }
  }

  // Interface for an injectable SDK version checker.
  @VisibleForTesting
  interface AndroidSdkChecker {
    @ChecksSdkIntAtLeast(parameter = 0)
    boolean sdkIsAtLeast(int version);
  }

  public FileSelectorApiImpl(@NonNull ActivityPluginBinding activityPluginBinding) {
    this(
        activityPluginBinding,
        new NativeObjectFactory(),
        (int version) -> Build.VERSION.SDK_INT >= version);
  }

  @VisibleForTesting
  FileSelectorApiImpl(
      @NonNull ActivityPluginBinding activityPluginBinding,
      @NonNull NativeObjectFactory objectFactory,
      @NonNull AndroidSdkChecker sdkChecker) {
    this.activityPluginBinding = activityPluginBinding;
    this.objectFactory = objectFactory;
    this.sdkChecker = sdkChecker;
  }

  @Override
  public void openFile(
      @Nullable String initialDirectory,
      @NonNull GeneratedFileSelectorApi.FileTypes allowedTypes,
      @NonNull
          GeneratedFileSelectorApi.NullableResult<GeneratedFileSelectorApi.FileResponse> result) {
    final Intent intent = objectFactory.newIntent(Intent.ACTION_OPEN_DOCUMENT);
    intent.addCategory(Intent.CATEGORY_OPENABLE);

    setMimeTypes(intent, allowedTypes);
    trySetInitialDirectory(intent, initialDirectory);

    try {
      startActivityForResult(
          intent,
          OPEN_FILE,
          new OnResultListener() {
            @Override
            public void onResult(int resultCode, @Nullable Intent data) {
              if (resultCode == Activity.RESULT_OK && data != null) {
                final Uri uri = data.getData();
                if (uri == null) {
                  // No data retrieved from opening file.
                  result.error(new Exception("Failed to retrieve data from opening file."));
                  return;
                }

                final GeneratedFileSelectorApi.FileResponse file = toFileResponse(uri);
                if (file != null) {
                  result.success(file);
                } else {
                  result.error(new Exception("Failed to read file: " + uri));
                }
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
      @NonNull GeneratedFileSelectorApi.FileTypes allowedTypes,
      @NonNull
          GeneratedFileSelectorApi.Result<List<GeneratedFileSelectorApi.FileResponse>> result) {
    final Intent intent = objectFactory.newIntent(Intent.ACTION_OPEN_DOCUMENT);
    intent.addCategory(Intent.CATEGORY_OPENABLE);
    intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true);

    setMimeTypes(intent, allowedTypes);
    trySetInitialDirectory(intent, initialDirectory);

    try {
      startActivityForResult(
          intent,
          OPEN_FILES,
          new OnResultListener() {
            @Override
            public void onResult(int resultCode, @Nullable Intent data) {
              if (resultCode == Activity.RESULT_OK && data != null) {
                // Only one file was returned.
                final Uri uri = data.getData();
                if (uri != null) {
                  final GeneratedFileSelectorApi.FileResponse file = toFileResponse(uri);
                  if (file != null) {
                    result.success(Collections.singletonList(file));
                  } else {
                    result.error(new Exception("Failed to read file: " + uri));
                  }
                }

                // Multiple files were returned.
                final ClipData clipData = data.getClipData();
                if (clipData != null) {
                  final List<GeneratedFileSelectorApi.FileResponse> files =
                      new ArrayList<>(clipData.getItemCount());
                  for (int i = 0; i < clipData.getItemCount(); i++) {
                    final ClipData.Item clipItem = clipData.getItemAt(i);
                    final GeneratedFileSelectorApi.FileResponse file =
                        toFileResponse(clipItem.getUri());
                    if (file != null) {
                      files.add(file);
                    } else {
                      result.error(new Exception("Failed to read file: " + uri));
                      return;
                    }
                  }
                  result.success(files);
                }
              } else {
                result.success(new ArrayList<>());
              }
            }
          });
    } catch (Exception exception) {
      result.error(exception);
    }
  }

  @Override
  public void getDirectoryPath(
      @Nullable String initialDirectory,
      @NonNull GeneratedFileSelectorApi.NullableResult<String> result) {
    final Intent intent = objectFactory.newIntent(Intent.ACTION_OPEN_DOCUMENT_TREE);
    trySetInitialDirectory(intent, initialDirectory);

    try {
      startActivityForResult(
          intent,
          OPEN_DIR,
          new OnResultListener() {
            @Override
            public void onResult(int resultCode, @Nullable Intent data) {
              if (resultCode == Activity.RESULT_OK && data != null) {
                final Uri uri = data.getData();
                if (uri == null) {
                  // No data retrieved from opening directory.
                  result.error(new Exception("Failed to retrieve data from opening directory."));
                  return;
                }

                final Uri docUri =
                    DocumentsContract.buildDocumentUriUsingTree(
                        uri, DocumentsContract.getTreeDocumentId(uri));
                try {
                  final String path =
                      FileUtils.getPathFromUri(activityPluginBinding.getActivity(), docUri);
                  result.success(path);
                } catch (UnsupportedOperationException exception) {
                  result.error(exception);
                }
              } else {
                result.success(null);
              }
            }
          });
    } catch (Exception exception) {
      result.error(exception);
    }
  }

  public void setActivityPluginBinding(@Nullable ActivityPluginBinding activityPluginBinding) {
    this.activityPluginBinding = activityPluginBinding;
  }

  // Setting the mimeType with `setType` is required when opening files. This handles setting the
  // mimeType based on the `mimeTypes` list and converts extensions to mimeTypes.
  // See https://developer.android.com/guide/components/intents-common#OpenFile
  private void setMimeTypes(
      @NonNull Intent intent, @NonNull GeneratedFileSelectorApi.FileTypes allowedTypes) {
    final Set<String> allMimetypes = new HashSet<>();
    allMimetypes.addAll(allowedTypes.getMimeTypes());
    allMimetypes.addAll(tryConvertExtensionsToMimetypes(allowedTypes.getExtensions()));

    if (allMimetypes.isEmpty()) {
      intent.setType("*/*");
    } else if (allMimetypes.size() == 1) {
      intent.setType(allMimetypes.iterator().next());
    } else {
      intent.setType("*/*");
      intent.putExtra(Intent.EXTRA_MIME_TYPES, allMimetypes.toArray(new String[0]));
    }
  }

  // Attempts to convert each extension to Android compatible mimeType. Logs a warning if an
  // extension could not be converted.
  @NonNull
  private List<String> tryConvertExtensionsToMimetypes(@NonNull List<String> extensions) {
    if (extensions.isEmpty()) {
      return Collections.emptyList();
    }

    final MimeTypeMap mimeTypeMap = MimeTypeMap.getSingleton();
    final Set<String> mimeTypes = new HashSet<>();
    for (String extension : extensions) {
      final String mimetype = mimeTypeMap.getMimeTypeFromExtension(extension);
      if (mimetype != null) {
        mimeTypes.add(mimetype);
      } else {
        Log.w(TAG, "Extension not supported: " + extension);
      }
    }

    return new ArrayList<>(mimeTypes);
  }

  private void trySetInitialDirectory(@NonNull Intent intent, @Nullable String initialDirectory) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && initialDirectory != null) {
      intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, Uri.parse(initialDirectory));
    }
  }

  private void startActivityForResult(
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
  GeneratedFileSelectorApi.FileResponse toFileResponse(@NonNull Uri uri) {
    if (activityPluginBinding == null) {
      Log.d(TAG, "Activity is not available.");
      return null;
    }

    final ContentResolver contentResolver =
        activityPluginBinding.getActivity().getContentResolver();

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
        // If the size is unknown, the value stored is null. This will
        // happen often: The storage API allows for remote files, whose
        // size might not be locally known.
        if (!cursor.isNull(sizeIndex)) {
          size = cursor.getInt(sizeIndex);
        }
      }
    }

    if (size == null) {
      return null;
    }

    final byte[] bytes = new byte[size];
    try (InputStream inputStream = contentResolver.openInputStream(uri)) {
      final DataInputStream dataInputStream = objectFactory.newDataInputStream(inputStream);
      dataInputStream.readFully(bytes);
    } catch (IOException exception) {
      Log.w(TAG, exception.getMessage());
      return null;
    }

    String uriPath;
    GeneratedFileSelectorApi.FileSelectorNativeException nativeError = null;

    try {
      uriPath = FileUtils.getPathFromCopyOfFileFromUri(activityPluginBinding.getActivity(), uri);
    } catch (IOException e) {
      // If closing the output stream fails, we cannot be sure that the
      // target file was written in full. Flushing the stream merely moves
      // the bytes into the OS, not necessarily to the file.
      uriPath = null;
    } catch (SecurityException e) {
      // Calling `ContentResolver#openInputStream()` has been reported to throw a
      // `SecurityException` on some devices in certain circumstances. Instead of crashing, we
      // return `null`.
      //
      // See https://github.com/flutter/flutter/issues/100025 for more details.
      uriPath = null;
    } catch (IllegalArgumentException e) {
      uriPath = FILE_SELECTOR_EXCEPTION_PLACEHOLDER_PATH;
      nativeError =
          new GeneratedFileSelectorApi.FileSelectorNativeException.Builder()
              .setMessage(e.getMessage() == null ? "" : e.getMessage())
              .setFileSelectorExceptionCode(
                  GeneratedFileSelectorApi.FileSelectorExceptionCode.ILLEGAL_ARGUMENT_EXCEPTION)
              .build();
    }

    return new GeneratedFileSelectorApi.FileResponse.Builder()
        .setName(name)
        .setBytes(bytes)
        .setPath(uriPath)
        .setMimeType(contentResolver.getType(uri))
        .setSize(size.longValue())
        .setFileSelectorNativeException(nativeError)
        .build();
  }
}
