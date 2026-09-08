// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertNotNull;

import androidx.concurrent.futures.CallbackToFutureAdapter;
import org.junit.Test;

/**
 * Regression test for https://github.com/flutter/flutter/issues/190505.
 *
 * <p>{@code camera-core}'s compiled classes carry Jspecify {@code @NonNull} type annotations on
 * members that reference {@link CallbackToFutureAdapter}. javac needs that class on the compile
 * classpath to process those annotations, even though this plugin never calls the annotated members
 * directly. Without an explicit {@code androidx.concurrent:concurrent-futures} dependency,
 * resolution of that class can silently depend on transitive dependency behavior and fail with
 * "class file for androidx.concurrent.futures.CallbackToFutureAdapter not found" during {@code
 * compileDebugJavaWithJavac}.
 *
 * <p>The static reference to {@link CallbackToFutureAdapter} below means that if the explicit
 * dependency in {@code android/build.gradle.kts} is ever removed, this test target fails to compile
 * instead of the break only surfacing as a build error for consumers.
 */
public class ConcurrentFuturesDependencyTest {
  @Test
  public void callbackToFutureAdapter_isOnClasspath() {
    assertNotNull(CallbackToFutureAdapter.class);
  }
}
