// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin;

import static org.junit.Assert.assertNull;

import org.junit.Test;

/**
 * Proves that Java callers can omit the trailing {@code name} argument of generated native
 * interop registrar methods.
 *
 * <p>A Kotlin default parameter does not produce a Java-callable overload on its own; without
 * {@code @JvmOverloads} on the Kotlin side, this test's call would fail to compile.
 */
public class JvmOverloadsTest {
  private static final long NO_KEY = Long.MIN_VALUE;

  @Test
  public void pigeonResolveInstanceCanBeCalledWithoutName() {
    assertNull(NativeInteropReservedNamesHostApiRegistrar.pigeonResolveInstance(NO_KEY, NO_KEY));
  }
}
