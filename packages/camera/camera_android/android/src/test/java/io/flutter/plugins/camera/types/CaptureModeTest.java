// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.types;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

public class CaptureModeTest {
  @Test
  public void getValueForString_returnsCorrectValues() {
    assertEquals(
        "Returns CaptureMode.image for 'photo'",
        CaptureMode.getValueForString("photo"),
        CaptureMode.photo);
    assertEquals(
        "Returns CaptureMode.video for 'video'",
        CaptureMode.getValueForString("video"),
        CaptureMode.video);
  }

  @Test
  public void getValueForString_returnsNullForNonexistantValue() {
    assertEquals(
        "Returns null for 'nonexistant'", CaptureMode.getValueForString("nonexistant"), null);
  }

  @Test
  public void toString_returnsCorrectValue() {
    assertEquals("Returns 'image' for CaptureMode.photo", CaptureMode.photo.toString(), "photo");
    assertEquals("Returns 'video' for CaptureMode.video", CaptureMode.video.toString(), "video");
  }
}
