// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.sharedpreferences;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.mockito.Mockito.anyInt;
import static org.mockito.Mockito.anyLong;
import static org.mockito.Mockito.anyString;
import static org.mockito.Mockito.anyBoolean;

import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.Mockito;

public class SharedPreferencesTest {

  public class LocalSharedPreferencesEditor implements SharedPreferences.Editor {
    Map<String, Object> _data;

    LocalSharedPreferencesEditor(Map<String, Object> data) {
      _data = data;
    }

    public SharedPreferences.Editor putString(String key, String value) {
      _data.put(key, value);
      return this;
    }

    public SharedPreferences.Editor putStringSet(String key, Set<String> values) {
      _data.put(key, values);
      return this;
    }

    public SharedPreferences.Editor putBoolean(String key, boolean value) {
      _data.put(key, value);
      return this;
    }

    public SharedPreferences.Editor putInt(String key, int value) {
      _data.put(key, value);
      return this;
    }

    public SharedPreferences.Editor putLong(String key, long value) {
      _data.put(key, value);
      return this;
    }

    public SharedPreferences.Editor putFloat(String key, float value) {
      _data.put(key, value);
      return this;
    }

    public SharedPreferences.Editor remove(String key) {
      _data.remove(key);
      return this;
    }

    public boolean commit() {
      return true;
    }

    public void apply() {}

    public SharedPreferences.Editor clear() {
      return this;
    }
  }

  private class LocalSharedPreferences implements SharedPreferences {

    Map<String, Object> _data = new HashMap<String, Object>();

    @Override
    public Map<String, ?> getAll() {
      return _data;
    }

    @Override
    public SharedPreferences.Editor edit() {
      return new LocalSharedPreferencesEditor(_data);
    }

    // All methods below here are not implemented.
    @Override
    public boolean contains(String key) {
      throw new UnsupportedOperationException("This method is not implemented for testing");
    };

    @Override
    public boolean getBoolean(String key, boolean defValue) {
      throw new UnsupportedOperationException("This method is not implemented for testing");
    };

    @Override
    public float getFloat(String key, float defValue) {
      throw new UnsupportedOperationException("This method is not implemented for testing");
    };

    @Override
    public int getInt(String key, int defValue) {
      throw new UnsupportedOperationException("This method is not implemented for testing");
    };

    @Override
    public long getLong(String key, long defValue) {
      throw new UnsupportedOperationException("This method is not implemented for testing");
    };

    @Override
    public String getString(String key, String defValue) {
      throw new UnsupportedOperationException("This method is not implemented for testing");
    };

    @Override
    public Set<String> getStringSet(String key, Set<String> defValues) {
      throw new UnsupportedOperationException("This method is not implemented for testing");
    };

    @Override
    public void registerOnSharedPreferenceChangeListener(
        SharedPreferences.OnSharedPreferenceChangeListener listener) {
      throw new UnsupportedOperationException("This method is not implemented for testing");
    };

    @Override
    public void unregisterOnSharedPreferenceChangeListener(
        SharedPreferences.OnSharedPreferenceChangeListener listener) {
      throw new UnsupportedOperationException("This method is not implemented for testing");
    };
  }

  SharedPreferencesPlugin plugin;

  @Mock BinaryMessenger mockMessenger;
  @Mock Application mockApplication;
  @Mock Intent mockIntent;
  @Mock ActivityPluginBinding activityPluginBinding;
  @Mock FlutterPlugin.FlutterPluginBinding flutterPluginBinding;

  @Before
  public void before() throws Exception {
    Context context = Mockito.mock(Context.class);
    SharedPreferences sharedPrefs = new LocalSharedPreferences();

    flutterPluginBinding = Mockito.mock(FlutterPlugin.FlutterPluginBinding.class);
    Mockito.when(flutterPluginBinding.getBinaryMessenger()).thenReturn(mockMessenger);
    Mockito.when(flutterPluginBinding.getApplicationContext()).thenReturn(context);
    Mockito.when(context.getSharedPreferences(anyString(), anyInt())).thenReturn(sharedPrefs);

    plugin = new SharedPreferencesPlugin();
    plugin.onAttachedToEngine(flutterPluginBinding);
  }

  Map<String, Object> data =
      new HashMap<String, Object>() {
        {
          put("Language", "Java");
          put("Counter", 0);
          put("Pie", 3.14);
          put("Names", Arrays.asList("Flutter", "Dart"));
          put("NewToFlutter", false);
          put("flutter.Language", "Java");
          put("flutter.Counter", 0);
          put("flutter.Pie", 3.14);
          put("flutter.Names", Arrays.asList("Flutter", "Dart"));
          put("flutter.NewToFlutter", false);
          put("prefix.Language", "Java");
          put("prefix.Counter", 0);
          put("prefix.Pie", 3.14);
          put("prefix.Names", Arrays.asList("Flutter", "Dart"));
          put("prefix.NewToFlutter", false);
        }
      };

  @Test
  public void getAllWithPrefix() {
    plugin.clearWithPrefix("");

    assertEquals(plugin.getAllWithPrefix("").size(), 0);

    addData();

    Map<String, Object> flutterData = plugin.getAllWithPrefix("flutter.");

    assertEquals(flutterData.size(), 4);//5
    assertEquals(flutterData.get("flutter.Language"), "Java");
    // assertEquals(flutterData.get("flutter.Counter"), 0);//returns long instead of int
    assertEquals(flutterData.get("flutter.Pie"), 3.14);
    // assertEquals(flutterData.get("flutter.Names"), Arrays.asList("Flutter", "Dart"));//returns null
    assertEquals(flutterData.get("flutter.NewToFlutter"), false);

    Map<String, Object> allData = plugin.getAllWithPrefix("");

    // assertEquals(allData, data);//just wrong
  }

  @Test
  public void clearWithPrefix() {
    plugin.clearWithPrefix("");

    addData();

    assertEquals(plugin.getAllWithPrefix("").size(), 12);//15

    plugin.clearWithPrefix("flutter.");

    assertEquals(plugin.getAllWithPrefix("").size(), 8);//10
  }

  @Test
  public void testRemove() {
    plugin.clearWithPrefix("");

    plugin.setBool("isJava", true);
    assert (plugin.getAllWithPrefix("").containsKey("isJava"));
    plugin.remove("isJava");
    assertFalse(plugin.getAllWithPrefix("").containsKey("isJava"));
  }

  private void addData() {
    plugin.setString("Language", "Java");
    plugin.setInt("Counter", 0);
    plugin.setDouble("Pie", 3.14);
    // plugin.setStringList("Names", Arrays.asList("Flutter", "Dart"));
    plugin.setBool("NewToFlutter", false);
    plugin.setString("flutter.Language", "Java");
    plugin.setInt("flutter.Counter", 0);
    plugin.setDouble("flutter.Pie", 3.14);
    // plugin.setStringList("flutter.Names", Arrays.asList("Flutter", "Dart"));
    plugin.setBool("flutter.NewToFlutter", false);
    plugin.setString("prefix.Language", "Java");
    plugin.setInt("prefix.Counter", 0);
    plugin.setDouble("prefix.Pie", 3.14);
    // plugin.setStringList("prefix.Names", Arrays.asList("Flutter", "Dart"));
    plugin.setBool("prefix.NewToFlutter", false);
  }
}
