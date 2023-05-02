// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import static io.flutter.plugins.imagepicker.ImagePickerCache.SHARED_PREFERENCES_NAME;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.core.IsEqual.equalTo;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import java.util.HashMap;
import java.util.Map;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

public class ImagePickerCacheTest {
  @Mock Activity mockActivity;
  @Mock SharedPreferences mockPreference;
  @Mock SharedPreferences.Editor mockEditor;

  static Map<String, Object> preferenceStorage;

  AutoCloseable mockCloseable;

  @Before
  public void setUp() {
    mockCloseable = MockitoAnnotations.openMocks(this);

    preferenceStorage = new HashMap<String, Object>();
    when(mockActivity.getPackageName()).thenReturn("com.example.test");
    when(mockActivity.getPackageManager()).thenReturn(mock(PackageManager.class));
    when(mockActivity.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE))
        .thenReturn(mockPreference);
    when(mockPreference.edit()).thenReturn(mockEditor);
    when(mockEditor.putInt(any(String.class), any(int.class)))
        .then(
            i -> {
              preferenceStorage.put(i.getArgument(0), i.getArgument(1));
              return mockEditor;
            });
    when(mockEditor.putLong(any(String.class), any(long.class)))
        .then(
            i -> {
              preferenceStorage.put(i.getArgument(0), i.getArgument(1));
              return mockEditor;
            });
    when(mockEditor.putString(any(String.class), any(String.class)))
        .then(
            i -> {
              preferenceStorage.put(i.getArgument(0), i.getArgument(1));
              return mockEditor;
            });

    when(mockPreference.getInt(any(String.class), any(int.class)))
        .then(
            i -> {
              int result =
                  (int)
                      ((preferenceStorage.get(i.getArgument(0)) != null)
                          ? preferenceStorage.get(i.getArgument(0))
                          : i.getArgument(1));
              return result;
            });
    when(mockPreference.getLong(any(String.class), any(long.class)))
        .then(
            i -> {
              long result =
                  (long)
                      ((preferenceStorage.get(i.getArgument(0)) != null)
                          ? preferenceStorage.get(i.getArgument(0))
                          : i.getArgument(1));
              return result;
            });
    when(mockPreference.getString(any(String.class), any(String.class)))
        .then(
            i -> {
              String result =
                  (String)
                      ((preferenceStorage.get(i.getArgument(0)) != null)
                          ? preferenceStorage.get(i.getArgument(0))
                          : i.getArgument(1));
              return result;
            });

    when(mockPreference.contains(any(String.class))).thenReturn(true);
  }

  @After
  public void tearDown() throws Exception {
    mockCloseable.close();
  }

  @Test
  public void imageCache_shouldBeAbleToSetAndGetQuality() {
    final int quality = 90;
    ImagePickerCache cache = new ImagePickerCache(mockActivity);
    cache.saveDimensionWithOutputOptions(
        new Messages.ImageSelectionOptions.Builder().setQuality((long) quality).build());
    Map<String, Object> resultMap = cache.getCacheMap();
    int imageQuality = (int) resultMap.get(ImagePickerCache.MAP_KEY_IMAGE_QUALITY);
    assertThat(imageQuality, equalTo(quality));

    cache.saveDimensionWithOutputOptions(
        new Messages.ImageSelectionOptions.Builder().setQuality((long) 100).build());
    Map<String, Object> resultMapWithDefaultQuality = cache.getCacheMap();
    int defaultImageQuality =
        (int) resultMapWithDefaultQuality.get(ImagePickerCache.MAP_KEY_IMAGE_QUALITY);
    assertThat(defaultImageQuality, equalTo(100));
  }

  @Test
  public void imageCache_shouldNotThrowIfPathIsNullInSaveResult() {
    final ImagePickerCache cache = new ImagePickerCache(mockActivity);
    cache.saveResult(null, "errorCode", "errorMessage");
    assertTrue(
        "No exception thrown when ImagePickerCache.saveResult() was passed a null path", true);
  }
}
