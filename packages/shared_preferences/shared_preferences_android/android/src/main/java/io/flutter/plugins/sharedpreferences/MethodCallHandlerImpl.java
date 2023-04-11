// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.sharedpreferences;

import android.content.Context;
import android.content.SharedPreferences;
import androidx.annotation.NonNull;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/** Helper class to save data to `android.content.SharedPreferences` */
class MethodCallHandlerImpl {

  SharedPreferencesListEncoder listEncoder;

  private static final String SHARED_PREFERENCES_NAME = "FlutterSharedPreferences";

  // Fun fact: The following is a base64 encoding of the string "This is the prefix for a list."
  private static final String LIST_IDENTIFIER = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu";
  private static final String BIG_INTEGER_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBCaWdJbnRlZ2Vy";
  private static final String DOUBLE_PREFIX = "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu";

  private final android.content.SharedPreferences preferences;

  MethodCallHandlerImpl(Context context, SharedPreferencesListEncoder listEncoder) {
    preferences = context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
    this.listEncoder = listEncoder;
  }

  public @NonNull Boolean setBool(@NonNull String key, @NonNull Boolean value) {
    return preferences.edit().putBoolean(key, value).commit();
  }

  public @NonNull Boolean setString(@NonNull String key, @NonNull String value) {
    // TODO (tarrinneal): Move this string prefix checking logic to dart code and make it an Argument Error.
    if (value.startsWith(LIST_IDENTIFIER)
        || value.startsWith(BIG_INTEGER_PREFIX)
        || value.startsWith(DOUBLE_PREFIX)) {
      throw new RuntimeException(
          "StorageError: This string cannot be stored as it clashes with special identifier prefixes");
    }
    return preferences.edit().putString(key, value).commit();
  }

  public @NonNull Boolean setInt(@NonNull String key, @NonNull Long value) {
    return preferences.edit().putLong(key, value).commit();
  }

  public @NonNull Boolean setDouble(@NonNull String key, @NonNull Double value) {
    String doubleValueStr = Double.toString(value);
    return preferences.edit().putString(key, DOUBLE_PREFIX + doubleValueStr).commit();
  }

  public @NonNull Boolean setStringList(@NonNull String key, @NonNull List<String> value)
      throws RuntimeException {
    return preferences.edit().putString(key, LIST_IDENTIFIER + listEncoder.encode(value)).commit();
  }

  public @NonNull Map<String, Object> getAllWithPrefix(@NonNull String prefix)
      throws RuntimeException {
    return getAllPrefs(prefix);
  }

  public @NonNull Boolean remove(@NonNull String key) {
    return preferences.edit().remove(key).commit();
  }

  public @NonNull Boolean clearWithPrefix(@NonNull String prefix) throws RuntimeException {
    Map<String, ?> allPrefs = preferences.getAll();
    Map<String, Object> filteredPrefs = new HashMap<>();
    for (String key : allPrefs.keySet()) {
      if (key.startsWith(prefix)) {
        filteredPrefs.put(key, allPrefs.get(key));
      }
    }
    SharedPreferences.Editor clearEditor = preferences.edit();
    for (String key : filteredPrefs.keySet()) {
      clearEditor.remove(key);
    }
    return clearEditor.commit();
  }

  // Gets all shared preferences, filtered to only those set with the given prefix.
  @SuppressWarnings("unchecked")
  private @NonNull Map<String, Object> getAllPrefs(@NonNull String prefix) throws RuntimeException {
    Map<String, ?> allPrefs = preferences.getAll();
    Map<String, Object> filteredPrefs = new HashMap<>();
    for (String key : allPrefs.keySet()) {
      if (key.startsWith(prefix)) {
        filteredPrefs.put(key, transformPref(key, allPrefs.get(key)));
      }
    }

    return filteredPrefs;
  }

  private Object transformPref(@NonNull String key, @NonNull Object value) {
    if (value instanceof String) {
      String stringValue = (String) value;
      if (stringValue.startsWith(LIST_IDENTIFIER)) {
        return listEncoder.decode(stringValue.substring(LIST_IDENTIFIER.length()));
        // TODO (tarrinneal): Remove all BigInt code.
        // https://github.com/flutter/flutter/issues/124420
      } else if (stringValue.startsWith(BIG_INTEGER_PREFIX)) {
        String encoded = stringValue.substring(BIG_INTEGER_PREFIX.length());
        return new BigInteger(encoded, Character.MAX_RADIX);
      } else if (stringValue.startsWith(DOUBLE_PREFIX)) {
        String doubleStr = stringValue.substring(DOUBLE_PREFIX.length());
        return Double.valueOf(doubleStr);
      }
        // TODO (tarrinneal): Remove Set code.
        // https://github.com/flutter/flutter/issues/124420
    } else if (value instanceof Set) {
      // This only happens for previous usage of setStringSet. The app expects a list.
      @SuppressWarnings("unchecked")
      List<String> listValue = new ArrayList<>((Set<String>) value);
      // Let's migrate the value too while we are at it.
      preferences
          .edit()
          .remove(key)
          .putString(key, LIST_IDENTIFIER + listEncoder.encode(listValue))
          .apply();

      return listValue;
    }
    return value;
  }
}
