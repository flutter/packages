// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.fail;

import org.junit.Test;

/**
 * Regression test for https://github.com/flutter/flutter/issues/190505.
 *
 * <p>{@code camera-core}'s compiled classes carry jspecify {@code @NonNull} type annotations on
 * members that reference {@code androidx.concurrent.futures.CallbackToFutureAdapter}. javac needs
 * that class on the compile classpath to process those annotations, even though this plugin never
 * calls the annotated members directly. Without an explicit {@code
 * androidx.concurrent:concurrent-futures} dependency, resolution of that class can silently depend
 * on transitive dependency behavior and fail with "class file for
 * androidx.concurrent.futures.CallbackToFutureAdapter not found" during {@code
 * compileDebugJavaWithJavac}.
 *
 * <p>This test asserts the class is present on the test classpath, so if the explicit dependency
 * in {@code android/build.gradle.kts} is ever removed, this test fails instead of the break only
 * surfacing as a build error for consumers.
 */
public class ConcurrentFuturesDependencyTest {
  @Test
  public void callbackToFutureAdapter_isOnClasspath() {
    try {
      Class.forName("androidx.concurrent.futures.CallbackToFutureAdapter");
    } catch (ClassNotFoundException e) {
      fail(
          "androidx.concurrent.futures.CallbackToFutureAdapter is not on the classpath. "
              + "This means the explicit androidx.concurrent:concurrent-futures dependency in "
              + "android/build.gradle.kts was removed or is no longer being resolved, which will "
              + "cause compileDebugJavaWithJavac to fail for consumers of this plugin. "
              + "See https://github.com/flutter/flutter/issues/190505.");
    }
  }
}
