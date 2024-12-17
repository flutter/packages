// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.pathprovider;

import android.content.Context;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.pathprovider.Messages.PathProviderApi;
import io.flutter.util.PathUtils;
import java.io.File;
import java.util.ArrayList;
import java.util.List;

public class PathProviderPlugin implements FlutterPlugin, PathProviderApi {
  static final String TAG = "PathProviderPlugin";
  private Context context;

  public PathProviderPlugin() {}

  private void setUp(BinaryMessenger messenger, Context context) {
    try {
      PathProviderApi.setUp(messenger, this);
    } catch (Exception ex) {
      Log.e(TAG, "Received exception while setting up PathProviderPlugin", ex);
    }

    this.context = context;
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    setUp(binding.getBinaryMessenger(), binding.getApplicationContext());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    PathProviderApi.setUp(binding.getBinaryMessenger(), null);
  }

  @Override
  public @Nullable String getTemporaryPath() {
    return context.getCacheDir().getPath();
  }

  @Override
  public @Nullable String getApplicationSupportPath() {
    return PathUtils.getFilesDir(context);
  }

  @Override
  public @Nullable String getApplicationDocumentsPath() {
    return PathUtils.getDataDirectory(context);
  }

  @Override
  public @Nullable String getApplicationCachePath() {
    return context.getCacheDir().getPath();
  }

  @Override
  public @Nullable String getExternalStoragePath() {
    final File dir = context.getExternalFilesDir(null);
    if (dir == null) {
      return null;
    }
    return dir.getAbsolutePath();
  }

  @Override
  public @NonNull List<String> getExternalCachePaths() {
    final List<String> paths = new ArrayList<>();
    for (File dir : context.getExternalCacheDirs()) {
      if (dir != null) {
        paths.add(dir.getAbsolutePath());
      }
    }
    return paths;
  }

  @Override
  public @NonNull List<String> getExternalStoragePaths(
      @NonNull Messages.StorageDirectory directory) {
    final List<String> paths = new ArrayList<>();
    for (File dir : context.getExternalFilesDirs(getStorageDirectoryString(directory))) {
      if (dir != null) {
        paths.add(dir.getAbsolutePath());
      }
    }
    return paths;
  }

  @VisibleForTesting
  String getStorageDirectoryString(@NonNull Messages.StorageDirectory directory) {
    switch (directory) {
      case ROOT:
        return null;
      case MUSIC:
        return "music";
      case PODCASTS:
        return "podcasts";
      case RINGTONES:
        return "ringtones";
      case ALARMS:
        return "alarms";
      case NOTIFICATIONS:
        return "notifications";
      case PICTURES:
        return "pictures";
      case MOVIES:
        return "movies";
      case DOWNLOADS:
        return "downloads";
      case DCIM:
        return "dcim";
      case DOCUMENTS:
        return "documents";
      default:
        throw new RuntimeException("Unrecognized directory: " + directory);
    }
  }
}
