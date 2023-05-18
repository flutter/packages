// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.file_selector_android;

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

@SuppressWarnings("unused")
public class FileSelectorApiImpl implements GeneratedFileSelectorApi.FileSelectorApi {
  private static final String TAG = "FileSelectorApiImpl";
  // Request code for selecting a file.
  private static final int OPEN_FILE = 221;
  // Request code for selecting files.
  private static final int OPEN_FILES = 222;
  // Request code for selecting a directory.
  private static final int OPEN_DIR = 223;

  private final TestProxy testProxy;
  @Nullable private ActivityPluginBinding activityPluginBinding;

  private abstract static class OnResultListener {
    public abstract void onResult(int resultCode, @Nullable Intent data);
  }

  // Proxy for instantiating Android classes for unit tests.
  @VisibleForTesting
  static class TestProxy {
    @NonNull
    Intent newIntent(@NonNull String action) {
      return new Intent(action);
    }

    @NonNull
    DataInputStream newDataInputStream(InputStream inputStream) {
      return new DataInputStream(inputStream);
    }
  }

  public FileSelectorApiImpl(@NonNull ActivityPluginBinding activityPluginBinding) {
    this(activityPluginBinding, new TestProxy());
  }

  @VisibleForTesting
  FileSelectorApiImpl(@NonNull ActivityPluginBinding activityPluginBinding, @NonNull TestProxy testProxy) {
    this.activityPluginBinding = activityPluginBinding;
    this.testProxy = testProxy;
  }

  @Override
  public void openFile(
      @Nullable String initialDirectory,
      @NonNull List<String> mimeTypes,
      @NonNull List<String> extensions,
      @NonNull GeneratedFileSelectorApi.Result<GeneratedFileSelectorApi.FileResponse> result) {
    final Intent intent = testProxy.newIntent(Intent.ACTION_OPEN_DOCUMENT);
    intent.addCategory(Intent.CATEGORY_OPENABLE);

    setMimeTypes(intent, mimeTypes, extensions);

    try {
      if (initialDirectory != null) {
        trySetInitialDirectory(intent, initialDirectory);
      }
      tryStartActivityForResult(
          intent,
          OPEN_FILE,
          new OnResultListener() {
            @Override
            public void onResult(int resultCode, @Nullable Intent data) {
              if (resultCode == Activity.RESULT_OK && data != null) {
                final Uri uri = data.getData();
                final GeneratedFileSelectorApi.FileResponse file = toFileResponse(uri);
                if (file != null) {
                  result.success(file);
                } else {
                  result.error(new Exception(String.format("Failed to read file: %s", uri)));
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
      @NonNull List<String> mimeTypes,
      @NonNull List<String> extensions,
      @NonNull
          GeneratedFileSelectorApi.Result<List<GeneratedFileSelectorApi.FileResponse>> result) {
    final Intent intent = testProxy.newIntent(Intent.ACTION_OPEN_DOCUMENT);
    intent.addCategory(Intent.CATEGORY_OPENABLE);
    intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true);

    setMimeTypes(intent, mimeTypes, extensions);

    try {
      if (initialDirectory != null) {
        trySetInitialDirectory(intent, initialDirectory);
      }
      tryStartActivityForResult(
          intent,
          OPEN_FILES,
          new OnResultListener() {
            @Override
            public void onResult(int resultCode, @Nullable Intent data) {
              if (resultCode == Activity.RESULT_OK && data != null) {
                // Only one file was returned.
                final Uri uri = data.getData();
                if (uri != null) {
                  result.success(Collections.singletonList(toFileResponse(uri)));
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
                      result.error(new Exception(String.format("Failed to read file: %s", uri)));
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
      @Nullable String initialDirectory, @NonNull GeneratedFileSelectorApi.Result<String> result) {
    if (android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.LOLLIPOP) {
      throw new UnsupportedOperationException(
          "Selecting a directory is only supported on versions >= android.os.Build.VERSION_CODES.LOLLIPOP");
    }

    final Intent intent = testProxy.newIntent(Intent.ACTION_OPEN_DOCUMENT_TREE);
    try {
      if (initialDirectory != null) {
        trySetInitialDirectory(intent, initialDirectory);
      }
      tryStartActivityForResult(
          intent,
          OPEN_DIR,
          new OnResultListener() {
            @Override
            public void onResult(int resultCode, @Nullable Intent data) {
              if (resultCode == Activity.RESULT_OK && data != null) {
                final Uri uri = data.getData();
                result.success(uri.toString());
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
      @NonNull Intent intent, @NonNull List<String> mimeTypes, @NonNull List<String> extensions) {
    final List<String> allMimetypes = new ArrayList<>();
    allMimetypes.addAll(mimeTypes);
    allMimetypes.addAll(tryConvertExtensionsToMimetypes(extensions));

    if (allMimetypes.isEmpty()) {
      intent.setType("*/*");
    } else if (allMimetypes.size() == 1) {
      intent.setType(allMimetypes.get(0));
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
        Log.w(TAG, String.format("Extension not supported: %s", extension));
      }
    }

    return new ArrayList<>(mimeTypes);
  }

  private void trySetInitialDirectory(@NonNull Intent intent, @NonNull String initialDirectory)
      throws Exception {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, Uri.parse(initialDirectory));
    } else {
      throw new Exception(
          "Setting an initial directory requires Android version Build.VERSION_CODES.O or greater.");
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
        final DataInputStream dataInputStream = testProxy.newDataInputStream(inputStream);
        dataInputStream.readFully(bytes);
      } catch (IOException exception) {
        Log.w(TAG, exception.getMessage());
        return null;
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
