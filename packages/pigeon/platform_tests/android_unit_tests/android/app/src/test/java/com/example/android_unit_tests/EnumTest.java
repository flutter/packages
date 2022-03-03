// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.android_unit_tests;

import static org.junit.Assert.*;

import java.util.Map;
import org.junit.Test;

public class EnumTest {
  @Test
  public void nullValue() {
    Enum.DataWithEnum value = new Enum.DataWithEnum();
    value.setState(null);
    Map<String, Object> map = value.toMap();
    Enum.DataWithEnum readValue = Enum.DataWithEnum.fromMap(map);
    assertEquals(value.getState(), readValue.getState());
  }
}
