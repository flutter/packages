package dev.flutter.packages.file_selector_android;

import android.app.Activity;
import android.content.ContentUris;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.provider.OpenableColumns;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;

import java.io.File;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.List;

import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.PluginRegistry;

public class FileSelectorApiImpl implements GeneratedFileSelectorApi.FileSelectorApi {
  // Request code for selecting a file.
  private static final int OPEN_FILE = 221;

  @VisibleForTesting
  static abstract class OnResultListener {
    public abstract void onResult(int resultCode, @Nullable Intent data);
  }

  @Nullable
  private ActivityPluginBinding activityPluginBinding;

  public FileSelectorApiImpl(@NonNull ActivityPluginBinding activityPluginBinding) {
    this.activityPluginBinding = activityPluginBinding;
  }

  @Override
  public void openFile(@Nullable String initialDirectory, @Nullable List<String> mimeTypes, @NonNull GeneratedFileSelectorApi.Result<GeneratedFileSelectorApi.FileResponse> result) {
    final Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
    intent.addCategory(Intent.CATEGORY_OPENABLE);

    trySetMimeTypes(intent, mimeTypes);

    try {
      trySetInitialDirectory(intent, initialDirectory);
      tryStartActivityForResult(intent, OPEN_FILE, new OnResultListener() {
        @Override
        public void onResult(int resultCode, @Nullable Intent data) {
          if (resultCode == Activity.RESULT_OK && data != null) {
            String path = "";
            final Uri uri = data.getData();
            Log.d("APPLE", "" + uri.toString());
            Cursor cursor = null;
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
              cursor = activityPluginBinding.getActivity().getContentResolver().query(uri, new String[]{OpenableColumns.DISPLAY_NAME}, null, null, null);
              try {
                if (cursor != null && cursor.moveToFirst()) {
                  //MediaStore.Images.Media.DATA;
                  path = cursor.getString(cursor.getColumnIndexOrThrow(OpenableColumns.DISPLAY_NAME));
                }
              } finally {
                cursor.close();
              }
            }
            Log.d("APPLE", "" + path);
            result.success("document/Image_created_with_a_mobile_phone.png");
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
  public void openFiles(@Nullable String initialDirectory, @Nullable List<String> mimeTypes, @NonNull GeneratedFileSelectorApi.Result<List<GeneratedFileSelectorApi.FileResponse>> result) {

  }

  @Override
  public void getDirectoryPath(@Nullable String initialDirectory, @NonNull GeneratedFileSelectorApi.Result<String> result) {

  }

  @Override
  public void getDirectoryPaths(@Nullable String initialDirectory, @NonNull GeneratedFileSelectorApi.Result<List<String>> result) {

  }

  public void setActivityPluginBinding(@Nullable ActivityPluginBinding activityPluginBinding) {
    this.activityPluginBinding = activityPluginBinding;
  }

  private void trySetMimeTypes(@NonNull Intent intent, @Nullable List<String> mimeTypes) {
    // Setting the mimeType with `setType` is required. This handles setting the mimeType based on
    // the `mimeTypes` list.
    // See https://developer.android.com/guide/components/intents-common#OpenFile
    if (mimeTypes == null) {
      intent.setType("*/*");
    } else if (mimeTypes.isEmpty()) {
      intent.setType("*/*");
    } else if (mimeTypes.size() == 1) {
      intent.setType(mimeTypes.get(0));
    } else {
      intent.setType("*/*");
      intent.putExtra(Intent.EXTRA_MIME_TYPES, mimeTypes.toArray(new String[0]));
    }
  }

  private void trySetInitialDirectory(@NonNull Intent intent, @Nullable String initialDirectory) throws Exception {
    if (initialDirectory != null) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, Uri.parse(initialDirectory));
      } else {
        throw new Exception("Setting an initial directory requires Android version Build.VERSION_CODES.O or greater.");
      }
    }
  }

  private void tryStartActivityForResult(@NonNull Intent intent, int newRequestCode, @NonNull OnResultListener resultListener) throws Exception {
    if (activityPluginBinding == null) {
      throw new Exception("No activity is available.");
    } else {
      activityPluginBinding.addActivityResultListener(new PluginRegistry.ActivityResultListener() {
        @Override
        public boolean onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
          if (requestCode == newRequestCode) {
            resultListener.onResult(resultCode, data);
            activityPluginBinding.removeActivityResultListener(this);
            return true;
          }

          return false;
        }
      });
      activityPluginBinding.getActivity().startActivityForResult(intent, newRequestCode);
    }
  }

  public static String getDataColumn(Context context, Uri uri, String selection,
                                     String[] selectionArgs) {
    Cursor cursor = null;
    String result = null;
    final String column = "_data";
    final String[] projection = { OpenableColumns.DISPLAY_NAME };
    try {
      cursor = context.getContentResolver().query(uri, projection, selection, selectionArgs,
          null);
      if (cursor != null && cursor.moveToFirst()) {
        final int index = cursor.getColumnIndexOrThrow(column);
        result = cursor.getString(index);
      }
    } catch (Exception ex) {
      ex.printStackTrace();
      return null;
    } finally {
      if (cursor != null)
        cursor.close();
    }
    return result;
  }
}
