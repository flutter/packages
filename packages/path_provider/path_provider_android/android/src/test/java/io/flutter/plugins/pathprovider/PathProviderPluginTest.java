// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.pathprovider;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;

public class PathProviderPluginTest {
  @org.junit.Test
  public void testStorageDirectoryTypeTranslation() {
    final PathProviderPlugin plugin = new PathProviderPlugin();
    assertNull(plugin.getStorageDirectoryString(Messages.StorageDirectory.ROOT));
    assertEquals("music", plugin.getStorageDirectoryString(Messages.StorageDirectory.MUSIC));
    assertEquals("podcasts", plugin.getStorageDirectoryString(Messages.StorageDirectory.PODCASTS));
    assertEquals(
        "ringtones", plugin.getStorageDirectoryString(Messages.StorageDirectory.RINGTONES));
    assertEquals("alarms", plugin.getStorageDirectoryString(Messages.StorageDirectory.ALARMS));
    assertEquals(
        "notifications", plugin.getStorageDirectoryString(Messages.StorageDirectory.NOTIFICATIONS));
    assertEquals("pictures", plugin.getStorageDirectoryString(Messages.StorageDirectory.PICTURES));
    assertEquals("movies", plugin.getStorageDirectoryString(Messages.StorageDirectory.MOVIES));
    assertEquals(
        "downloads", plugin.getStorageDirectoryString(Messages.StorageDirectory.DOWNLOADS));
    assertEquals("dcim", plugin.getStorageDirectoryString(Messages.StorageDirectory.DCIM));
  }
}
