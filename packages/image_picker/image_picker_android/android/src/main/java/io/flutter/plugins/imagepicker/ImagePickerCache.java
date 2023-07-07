// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import android.content.Context;
import android.content.SharedPreferences;
import android.net.Uri;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

class ImagePickerCache {
  public enum CacheType {
    IMAGE,
    VIDEO
  }

  static final String MAP_KEY_PATH_LIST = "pathList";
  static final String MAP_KEY_MAX_WIDTH = "maxWidth";
  static final String MAP_KEY_MAX_HEIGHT = "maxHeight";
  static final String MAP_KEY_IMAGE_QUALITY = "imageQuality";
  static final String MAP_KEY_TYPE = "type";
  static final String MAP_KEY_ERROR = "error";

  private static final String MAP_TYPE_VALUE_IMAGE = "image";
  private static final String MAP_TYPE_VALUE_VIDEO = "video";

  private static final String FLUTTER_IMAGE_PICKER_IMAGE_PATH_KEY =
      "flutter_image_picker_image_path";
  private static final String SHARED_PREFERENCE_ERROR_CODE_KEY = "flutter_image_picker_error_code";
  private static final String SHARED_PREFERENCE_ERROR_MESSAGE_KEY =
      "flutter_image_picker_error_message";

  private static final String SHARED_PREFERENCE_MAX_WIDTH_KEY = "flutter_image_picker_max_width";

  private static final String SHARED_PREFERENCE_MAX_HEIGHT_KEY = "flutter_image_picker_max_height";

  private static final String SHARED_PREFERENCE_IMAGE_QUALITY_KEY =
      "flutter_image_picker_image_quality";

  private static final String SHARED_PREFERENCE_TYPE_KEY = "flutter_image_picker_type";
  private static final String SHARED_PREFERENCE_PENDING_IMAGE_URI_PATH_KEY =
      "flutter_image_picker_pending_image_uri";

  @VisibleForTesting
  static final String SHARED_PREFERENCES_NAME = "flutter_image_picker_shared_preference";

  private final @NonNull Context context;

  ImagePickerCache(final @NonNull Context context) {
    this.context = context;
  }

  void saveType(CacheType type) {
    switch (type) {
      case IMAGE:
        setType(MAP_TYPE_VALUE_IMAGE);
        break;
      case VIDEO:
        setType(MAP_TYPE_VALUE_VIDEO);
        break;
    }
  }

  private void setType(String type) {
    final SharedPreferences prefs =
        context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
    prefs.edit().putString(SHARED_PREFERENCE_TYPE_KEY, type).apply();
  }

  void saveDimensionWithOutputOptions(Messages.ImageSelectionOptions options) {
    final SharedPreferences prefs =
        context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
    SharedPreferences.Editor editor = prefs.edit();
    if (options.getMaxWidth() != null) {
      editor.putLong(
          SHARED_PREFERENCE_MAX_WIDTH_KEY, Double.doubleToRawLongBits(options.getMaxWidth()));
    }
    if (options.getMaxHeight() != null) {
      editor.putLong(
          SHARED_PREFERENCE_MAX_HEIGHT_KEY, Double.doubleToRawLongBits(options.getMaxHeight()));
    }
    editor.putInt(SHARED_PREFERENCE_IMAGE_QUALITY_KEY, options.getQuality().intValue());
    editor.apply();
  }

  void savePendingCameraMediaUriPath(Uri uri) {
    final SharedPreferences prefs =
        context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
    prefs.edit().putString(SHARED_PREFERENCE_PENDING_IMAGE_URI_PATH_KEY, uri.getPath()).apply();
  }

  String retrievePendingCameraMediaUriPath() {
    final SharedPreferences prefs =
        context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
    return prefs.getString(SHARED_PREFERENCE_PENDING_IMAGE_URI_PATH_KEY, "");
  }

  void saveResult(
      @Nullable ArrayList<String> path, @Nullable String errorCode, @Nullable String errorMessage) {
    final SharedPreferences prefs =
        context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);

    SharedPreferences.Editor editor = prefs.edit();
    if (path != null) {
      Set<String> imageSet = new HashSet<>(path);
      editor.putStringSet(FLUTTER_IMAGE_PICKER_IMAGE_PATH_KEY, imageSet);
    }
    if (errorCode != null) {
      editor.putString(SHARED_PREFERENCE_ERROR_CODE_KEY, errorCode);
    }
    if (errorMessage != null) {
      editor.putString(SHARED_PREFERENCE_ERROR_MESSAGE_KEY, errorMessage);
    }
    editor.apply();
  }

  void clear() {
    final SharedPreferences prefs =
        context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
    prefs.edit().clear().apply();
  }

  Map<String, Object> getCacheMap() {
    Map<String, Object> resultMap = new HashMap<>();
    boolean hasData = false;

    final SharedPreferences prefs =
        context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);

    if (prefs.contains(FLUTTER_IMAGE_PICKER_IMAGE_PATH_KEY)) {
      final Set<String> imagePathList =
          prefs.getStringSet(FLUTTER_IMAGE_PICKER_IMAGE_PATH_KEY, null);
      if (imagePathList != null) {
        ArrayList<String> pathList = new ArrayList<>(imagePathList);
        resultMap.put(MAP_KEY_PATH_LIST, pathList);
        hasData = true;
      }
    }

    if (prefs.contains(SHARED_PREFERENCE_ERROR_CODE_KEY)) {
      final Messages.CacheRetrievalError.Builder error = new Messages.CacheRetrievalError.Builder();
      error.setCode(prefs.getString(SHARED_PREFERENCE_ERROR_CODE_KEY, ""));
      hasData = true;
      if (prefs.contains(SHARED_PREFERENCE_ERROR_MESSAGE_KEY)) {
        error.setMessage(prefs.getString(SHARED_PREFERENCE_ERROR_MESSAGE_KEY, ""));
      }
      resultMap.put(MAP_KEY_ERROR, error.build());
    }

    if (hasData) {
      if (prefs.contains(SHARED_PREFERENCE_TYPE_KEY)) {
        final String typeValue = prefs.getString(SHARED_PREFERENCE_TYPE_KEY, "");
        resultMap.put(
            MAP_KEY_TYPE,
            typeValue.equals(MAP_TYPE_VALUE_VIDEO)
                ? Messages.CacheRetrievalType.VIDEO
                : Messages.CacheRetrievalType.IMAGE);
      }
      if (prefs.contains(SHARED_PREFERENCE_MAX_WIDTH_KEY)) {
        final long maxWidthValue = prefs.getLong(SHARED_PREFERENCE_MAX_WIDTH_KEY, 0);
        resultMap.put(MAP_KEY_MAX_WIDTH, Double.longBitsToDouble(maxWidthValue));
      }
      if (prefs.contains(SHARED_PREFERENCE_MAX_HEIGHT_KEY)) {
        final long maxHeightValue = prefs.getLong(SHARED_PREFERENCE_MAX_HEIGHT_KEY, 0);
        resultMap.put(MAP_KEY_MAX_HEIGHT, Double.longBitsToDouble(maxHeightValue));
      }
      final int imageQuality = prefs.getInt(SHARED_PREFERENCE_IMAGE_QUALITY_KEY, 100);
      resultMap.put(MAP_KEY_IMAGE_QUALITY, imageQuality);
    }
    return resultMap;
  }
}
