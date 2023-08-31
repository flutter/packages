// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.utils;

import java.lang.reflect.Field;
import org.junit.Assert;

public class TestUtils {
  public static <T> void setPrivateField(T instance, String fieldName, Object newValue) {
    try {
      Field field = instance.getClass().getDeclaredField(fieldName);
      field.setAccessible(true);
      field.set(instance, newValue);
    } catch (Exception e) {
      Assert.fail("Unable to mock private field: " + fieldName);
    }
  }

  public static <T> Object getPrivateField(T instance, String fieldName) {
    try {
      Field field = instance.getClass().getDeclaredField(fieldName);
      field.setAccessible(true);
      return field.get(instance);
    } catch (Exception e) {
      Assert.fail("Unable to mock private field: " + fieldName);
      return null;
    }
  }
}
