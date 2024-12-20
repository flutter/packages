// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package dev.flutter.plugins

/*
 * Annotation to aid repository tooling in determining if a test is
 * a native java unit test or a java class with a dart integration.
 *
 * See: https://github.com/flutter/flutter/blob/master/docs/ecosystem/testing/Plugin-Tests.md#enabling-android-ui-tests
 * for more information.
 */
@Retention(AnnotationRetention.RUNTIME)
@Target(AnnotationTarget.CLASS)
annotation class DartIntegrationTest
