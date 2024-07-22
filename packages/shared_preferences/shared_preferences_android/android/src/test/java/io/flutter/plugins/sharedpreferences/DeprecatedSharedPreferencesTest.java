// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.sharedpreferences;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNull;
import static org.mockito.Mockito.anyInt;
import static org.mockito.Mockito.anyString;

import android.content.Context;
import android.content.SharedPreferences;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.Mockito;

public class LegacySharedPreferencesTest {

  LegacySharedPreferencesPlugin plugin;

  @Mock BinaryMessenger mockMessenger;
  @Mock FlutterPlugin.FlutterPluginBinding flutterPluginBinding;

  @Before
  public void before() {
    Context context = Mockito.mock(Context.class);
    SharedPreferences sharedPrefs = new FakeSharedPreferences();

    flutterPluginBinding = Mockito.mock(FlutterPlugin.FlutterPluginBinding.class);

    Mockito.when(flutterPluginBinding.getBinaryMessenger()).thenReturn(mockMessenger);
    Mockito.when(flutterPluginBinding.getApplicationContext()).thenReturn(context);
    Mockito.when(context.getSharedPreferences(anyString(), anyInt())).thenReturn(sharedPrefs);

    plugin = new LegacySharedPreferencesPlugin(new ListEncoder());
    plugin.onAttachedToEngine(flutterPluginBinding);
  }

  private static final Map<String, Object> data = new HashMap<>();

  static {
    data.put("Language", "Java");
    data.put("Counter", 0L);
    data.put("Pie", 3.14);
    data.put("Names", Arrays.asList("Flutter", "Dart"));
    data.put("NewToFlutter", false);
    data.put("flutter.Language", "Java");
    data.put("flutter.Counter", 0L);
    data.put("flutter.Pie", 3.14);
    data.put("flutter.Names", Arrays.asList("Flutter", "Dart"));
    data.put("flutter.NewToFlutter", false);
    data.put("prefix.Language", "Java");
    data.put("prefix.Counter", 0L);
    data.put("prefix.Pie", 3.14);
    data.put("prefix.Names", Arrays.asList("Flutter", "Dart"));
    data.put("prefix.NewToFlutter", false);
  }

  @Test
  public void getAll() {
    assertEquals(plugin.getAll("", null).size(), 0);

    addData();

    Map<String, Object> flutterData = plugin.getAll("flutter.", null);

    assertEquals(flutterData.size(), 5);
    assertEquals(flutterData.get("flutter.Language"), "Java");
    assertEquals(flutterData.get("flutter.Counter"), 0L);
    assertEquals(flutterData.get("flutter.Pie"), 3.14);
    assertEquals(flutterData.get("flutter.Names"), Arrays.asList("Flutter", "Dart"));
    assertEquals(flutterData.get("flutter.NewToFlutter"), false);

    Map<String, Object> allData = plugin.getAll("", null);

    assertEquals(allData, data);
  }

  @Test
  public void allowList() {
    assertEquals(plugin.getAll("", null).size(), 0);

    addData();

    final List<String> allowList = Collections.singletonList("flutter.Language");

    Map<String, Object> allData = plugin.getAll("flutter.", allowList);

    assertEquals(allData.size(), 1);
    assertEquals(allData.get("flutter.Language"), "Java");
    assertNull(allData.get("flutter.Counter"));

    allData = plugin.getAll("", allowList);

    assertEquals(allData.size(), 1);
    assertEquals(allData.get("flutter.Language"), "Java");
    assertNull(allData.get("flutter.Counter"));

    allData = plugin.getAll("prefix.", allowList);

    assertEquals(allData.size(), 0);
    assertNull(allData.get("flutter.Language"));
  }

  @Test
  public void setString() {
    final String key = "language";
    final String value = "Java";
    plugin.setString(key, value);
    Map<String, Object> flutterData = plugin.getAll("", null);
    assertEquals(flutterData.get(key), value);
  }

  @Test
  public void setInt() {
    final String key = "Counter";
    final Long value = 0L;
    plugin.setInt(key, value);
    Map<String, Object> flutterData = plugin.getAll("", null);
    assertEquals(flutterData.get(key), value);
  }

  @Test
  public void setDouble() {
    final String key = "Pie";
    final double value = 3.14;
    plugin.setDouble(key, value);
    Map<String, Object> flutterData = plugin.getAll("", null);
    assertEquals(flutterData.get(key), value);
  }

  @Test
  public void setStringList() {
    final String key = "Names";
    final List<String> value = Arrays.asList("Flutter", "Dart");
    plugin.setStringList(key, value);
    Map<String, Object> flutterData = plugin.getAll("", null);
    assertEquals(flutterData.get(key), value);
  }

  @Test
  public void setBool() {
    final String key = "NewToFlutter";
    final boolean value = false;
    plugin.setBool(key, value);
    Map<String, Object> flutterData = plugin.getAll("", null);
    assertEquals(flutterData.get(key), value);
  }

  @Test
  public void clearWithNoAllowList() {
    addData();

    assertEquals(plugin.getAll("", null).size(), 15);

    plugin.clear("flutter.", null);

    assertEquals(plugin.getAll("", null).size(), 10);
  }

  @Test
  public void clearWithAllowList() {
    addData();

    assertEquals(plugin.getAll("", null).size(), 15);

    plugin.clear("flutter.", Collections.singletonList("flutter.Language"));

    assertEquals(plugin.getAll("", null).size(), 14);
  }

  @Test
  public void clearAll() {
    addData();

    assertEquals(plugin.getAll("", null).size(), 15);

    plugin.clear("", null);

    assertEquals(plugin.getAll("", null).size(), 0);
  }

  @Test
  public void testRemove() {
    final String key = "NewToFlutter";
    final boolean value = true;
    plugin.setBool(key, value);
    assert (plugin.getAll("", null).containsKey(key));
    plugin.remove(key);
    assertFalse(plugin.getAll("", null).containsKey(key));
  }

  private void addData() {
    plugin.setString("Language", "Java");
    plugin.setInt("Counter", 0L);
    plugin.setDouble("Pie", 3.14);
    plugin.setStringList("Names", Arrays.asList("Flutter", "Dart"));
    plugin.setBool("NewToFlutter", false);
    plugin.setString("flutter.Language", "Java");
    plugin.setInt("flutter.Counter", 0L);
    plugin.setDouble("flutter.Pie", 3.14);
    plugin.setStringList("flutter.Names", Arrays.asList("Flutter", "Dart"));
    plugin.setBool("flutter.NewToFlutter", false);
    plugin.setString("prefix.Language", "Java");
    plugin.setInt("prefix.Counter", 0L);
    plugin.setDouble("prefix.Pie", 3.14);
    plugin.setStringList("prefix.Names", Arrays.asList("Flutter", "Dart"));
    plugin.setBool("prefix.NewToFlutter", false);
  }

  /** A dummy implementation for tests for use with FakeSharedPreferences */
  public static class FakeSharedPreferencesEditor implements SharedPreferences.Editor {
    private final Map<String, Object> sharedPrefData;

    FakeSharedPreferencesEditor(@NonNull Map<String, Object> data) {
      sharedPrefData = data;
    }

    @Override
    public @NonNull SharedPreferences.Editor putString(@NonNull String key, @NonNull String value) {
      sharedPrefData.put(key, value);
      return this;
    }

    @Override
    public @NonNull SharedPreferences.Editor putStringSet(
        @NonNull String key, @NonNull Set<String> values) {
      sharedPrefData.put(key, values);
      return this;
    }

    @Override
    public @NonNull SharedPreferences.Editor putBoolean(@NonNull String key, boolean value) {
      sharedPrefData.put(key, value);
      return this;
    }

    @Override
    public @NonNull SharedPreferences.Editor putInt(@NonNull String key, int value) {
      sharedPrefData.put(key, value);
      return this;
    }

    @Override
    public @NonNull SharedPreferences.Editor putLong(@NonNull String key, long value) {
      sharedPrefData.put(key, value);
      return this;
    }

    @Override
    public @NonNull SharedPreferences.Editor putFloat(@NonNull String key, float value) {
      sharedPrefData.put(key, value);
      return this;
    }

    @Override
    public @NonNull SharedPreferences.Editor remove(@NonNull String key) {
      sharedPrefData.remove(key);
      return this;
    }

    @Override
    public boolean commit() {
      return true;
    }

    @Override
    public void apply() {
      throw new UnsupportedOperationException("This method is not implemented for testing");
    }

    @Override
    public @NonNull SharedPreferences.Editor clear() {
      throw new UnsupportedOperationException("This method is not implemented for testing");
    }
  }

  /** A dummy implementation of SharedPreferences for tests that store values in memory. */
  private static class FakeSharedPreferences implements SharedPreferences {

    Map<String, Object> sharedPrefData = new HashMap<>();

    @Override
    public @NonNull Map<String, ?> getAll() {
      return sharedPrefData;
    }

    @Override
    public @NonNull SharedPreferences.Editor edit() {
      return new FakeSharedPreferencesEditor(sharedPrefData);
    }

    // All methods below are not implemented.
    @Override
    public boolean contains(@NonNull String key) {
      throw new UnsupportedOperationException("This method is not implemented for testing");
    }

    @Override
    public boolean getBoolean(@NonNull String key, boolean defValue) {
      throw new UnsupportedOperationException("This method is not implemented for testing");
    }

    @Override
    public float getFloat(@NonNull String key, float defValue) {
      throw new UnsupportedOperationException("This method is not implemented for testing");
    }

    @Override
    public int getInt(@NonNull String key, int defValue) {
      throw new UnsupportedOperationException("This method is not implemented for testing");
    }

    @Override
    public long getLong(@NonNull String key, long defValue) {
      throw new UnsupportedOperationException("This method is not implemented for testing");
    }

    @Override
    public @NonNull String getString(@NonNull String key, @NonNull String defValue) {
      throw new UnsupportedOperationException("This method is not implemented for testing");
    }

    @Override
    public @NonNull Set<String> getStringSet(@NonNull String key, @NonNull Set<String> defValues) {
      throw new UnsupportedOperationException("This method is not implemented for testing");
    }

    @Override
    public void registerOnSharedPreferenceChangeListener(
        @NonNull SharedPreferences.OnSharedPreferenceChangeListener listener) {
      throw new UnsupportedOperationException("This method is not implemented for testing");
    }

    @Override
    public void unregisterOnSharedPreferenceChangeListener(
        @NonNull SharedPreferences.OnSharedPreferenceChangeListener listener) {
      throw new UnsupportedOperationException("This method is not implemented for testing");
    }
  }

  /** A dummy implementation of SharedPreferencesListEncoder for tests that store List<String>. */
  static class ListEncoder implements SharedPreferencesListEncoder {
    @Override
    public @NonNull String encode(@NonNull List<String> list) {
      return String.join(";-;", list);
    }

    @Override
    public @NonNull List<String> decode(@NonNull String listString) {
      return Arrays.asList(listString.split(";-;"));
    }
  }
}
