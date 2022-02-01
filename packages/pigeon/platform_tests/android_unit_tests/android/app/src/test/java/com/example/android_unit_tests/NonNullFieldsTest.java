// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.android_unit_tests;

import static org.junit.Assert.*;

import com.example.android_unit_tests.NonNullFields.SearchRequest;
import java.lang.IllegalStateException;
import org.junit.Test;

public class NonNullFieldsTest {
  @Test
  public void builder() {
    SearchRequest request = new SearchRequest.Builder().setQuery("hello").build();
    assertEquals(request.getQuery(), "hello");
  }

  @Test(expected = IllegalStateException.class)
  public void builderThrowsIfNull() {
    SearchRequest request = new SearchRequest.Builder().build();
  }
}
