// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.sharedpreferences;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import org.junit.Test;

public class SharedPreferencesTest {

  SharedPreferencesPlugin plugin;

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
  public void initPluginDoesNotThrow() {
    plugin = new SharedPreferencesPlugin();
  }

  @Test
  public void getAllWithPrefix() {
    plugin.clearWithPrefix("");

    assertEquals(plugin.getAllWithPrefix("").size(), 0);

    addData();

    Map<String, Object> flutterData = plugin.getAllWithPrefix("flutter.");

    assertEquals(flutterData.size(), 5);
    assertEquals(flutterData.get("flutter.Language"), "Java");
    assertEquals(flutterData.get("flutter.Counter"), 0);
    assertEquals(flutterData.get("flutter.Pie"), 3.14);
    assertEquals(flutterData.get("flutter.Names"), Arrays.asList("Flutter", "Dart"));
    assertEquals(flutterData.get("flutter.NewToFlutter"), false);

    Map<String, Object> allData = plugin.getAllWithPrefix("");

    assertEquals(allData, data);
  }

  @Test
  public void clearWithPrefix() {
    plugin.clearWithPrefix("");

    addData();

    assertEquals(plugin.getAllWithPrefix("").size(), 15);

    plugin.clearWithPrefix("flutter.");

    assertEquals(plugin.getAllWithPrefix("").size(), 10);
  }

  @Test
  public void testRemove() {
    plugin.clearWithPrefix("");

    plugin.setBool("isJava", true);
    assert (plugin.getAllWithPrefix("").containsKey("isJava"));
    plugin.remove("isJava");
    assertFalse(plugin.getAllWithPrefix("").containsKey("isJava"));
  }

  public void addData() {
    plugin.setString("Language", "Java");
    plugin.setInt("Counter", 0);
    plugin.setDouble("Pie", 3.14);
    plugin.setStringList("Names", Arrays.asList("Flutter", "Dart"));
    plugin.setBool("NewToFlutter", false);
    plugin.setString("flutter.Language", "Java");
    plugin.setInt("flutter.Counter", 0);
    plugin.setDouble("flutter.Pie", 3.14);
    plugin.setStringList("flutter.Names", Arrays.asList("Flutter", "Dart"));
    plugin.setBool("flutter.NewToFlutter", false);
    plugin.setString("prefix.Language", "Java");
    plugin.setInt("prefix.Counter", 0);
    plugin.setDouble("prefix.Pie", 3.14);
    plugin.setStringList("prefix.Names", Arrays.asList("Flutter", "Dart"));
    plugin.setBool("prefix.NewToFlutter", false);
  }
}
