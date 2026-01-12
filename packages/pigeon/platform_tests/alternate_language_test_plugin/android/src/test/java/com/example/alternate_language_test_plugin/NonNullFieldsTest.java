// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.alternate_language_test_plugin;

import static org.junit.Assert.*;

import com.example.alternate_language_test_plugin.NonNullFields.NonNullFieldSearchRequest;
import java.lang.IllegalStateException;
import org.junit.Test;

public class NonNullFieldsTest {
  @Test
  public void builder() {
    NonNullFieldSearchRequest request =
        new NonNullFieldSearchRequest.Builder().setQuery("hello").build();
    assertEquals(request.getQuery(), "hello");
  }

  @Test(expected = IllegalStateException.class)
  public void builderThrowsIfNull() {
    NonNullFieldSearchRequest request = new NonNullFieldSearchRequest.Builder().build();
  }
}
