// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.file_selector_android;

import android.app.Activity;
import android.content.ClipData;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.provider.DocumentsContract;
import android.util.Log;
import android.webkit.MimeTypeMap;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.PluginRegistry;
import java.io.DataInputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import kotlin.Result;
import kotlin.Unit;
import kotlin.jvm.functions.Function1;
import org.jetbrains.annotations.NotNull;

public class FileSelectorApiImpl implements FileSelectorApi {
  private static final String TAG = "FileSelectorApiImpl";
  // Request code for selecting a file.
  private static final int OPEN_FILE = 221;
  // Request code for selecting files.
  private static final int OPEN_FILES = 222;
  // Request code for selecting a directory.
  private static final int OPEN_DIR = 223;

  private final @NonNull NativeObjectFactory objectFactory;

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

  public FileSelectorApiImpl(@NonNull ActivityPluginBinding activityPluginBinding) {
    this(activityPluginBinding, new NativeObjectFactory());
  }

  @VisibleForTesting
  FileSelectorApiImpl(
      @NonNull ActivityPluginBinding activityPluginBinding,
      @NonNull NativeObjectFactory objectFactory) {
    this.activityPluginBinding = activityPluginBinding;
    this.objectFactory = objectFactory;
  }

  @Override
  public void openFile(
      @Nullable String initialDirectory,
      @NonNull FileTypes allowedTypes,
      @NonNull Function1<? super Result<String>, Unit> callback) {
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
                if (uri != null) {
                  ResultUtilsKt.completeWithValue(callback, uri.toString());
                } else {
                  ResultUtilsKt.completeWithError(
                      callback, new Exception("Failed to retrieve file uri."));
                }
              } else {
                ResultUtilsKt.completeWithValue(callback, null);
              }
            }
          });
    } catch (Exception exception) {
      ResultUtilsKt.completeWithError(callback, exception);
    }
  }

  @Override
  public void openFiles(
      @Nullable String initialDirectory,
      @NonNull FileTypes allowedTypes,
      @NonNull
          Function1<
                  ? super @NotNull Result<? extends @NotNull List<@NotNull String>>, @NotNull Unit>
              callback) {
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
                  ResultUtilsKt.completeWithValue(
                      callback, Collections.singletonList(uri.toString()));
                }

                // Multiple files were returned.
                final ClipData clipData = data.getClipData();
                if (clipData != null) {
                  final List<String> files = new ArrayList<>(clipData.getItemCount());
                  for (int i = 0; i < clipData.getItemCount(); i++) {
                    final ClipData.Item clipItem = clipData.getItemAt(i);
                    files.add(clipItem.getUri().toString());
                  }
                  ResultUtilsKt.completeWithValue(callback, files);
                }
              } else {
                ResultUtilsKt.completeWithValue(callback, new ArrayList<>());
              }
            }
          });
    } catch (Exception exception) {
      ResultUtilsKt.completeWithError(callback, exception);
    }
  }

  @Override
  public void getDirectoryPath(
      @Nullable String initialDirectory,
      @NonNull Function1<? super @NotNull Result<String>, @NotNull Unit> callback) {
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
                if (uri != null) {
                  ResultUtilsKt.completeWithValue(callback, uri.toString());
                } else {
                  // No data retrieved from opening directory.
                  ResultUtilsKt.completeWithError(
                      callback, new Exception("Failed to retrieve data from opening directory."));
                }
              } else {
                ResultUtilsKt.completeWithValue(callback, null);
              }
            }
          });
    } catch (Exception exception) {
      ResultUtilsKt.completeWithError(callback, exception);
    }
  }

  public void setActivityPluginBinding(@Nullable ActivityPluginBinding activityPluginBinding) {
    this.activityPluginBinding = activityPluginBinding;
  }

  // Setting the mimeType with `setType` is required when opening files. This handles setting the
  // mimeType based on the `mimeTypes` list and converts extensions to mimeTypes.
  // See https://developer.android.com/guide/components/intents-common#OpenFile
  private void setMimeTypes(@NonNull Intent intent, @NonNull FileTypes allowedTypes) {
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
}
