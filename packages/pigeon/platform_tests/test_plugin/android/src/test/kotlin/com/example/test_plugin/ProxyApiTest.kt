// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin

import io.flutter.plugin.common.StandardMessageCodec
import junit.framework.TestCase.assertEquals
import org.junit.Test

class ProxyApiTest {
  @Test
  fun callsToDartFailIfTheInstanceIsNotInTheInstanceManager() {
    val testObject = ProxyApiTestClass()

    val api = ProxyApiTestClassApi(TestProxyApiRegistrar())
    api.pigeonRegistrar.instanceManager.addHostCreatedInstance(testObject)
    api.pigeonRegistrar.instanceManager.clear()

    var b: Throwable? = null
    api.flutterNoop(testObject) { b = it.exceptionOrNull() }

    assertEquals(
        b?.message,
        "Callback to `ProxyApiTestClass.flutterNoop` failed because native instance was not in the instance manager.")
  }
}

/** Test implementation of `ProxyApiRegistrar` that provides a test binary messenger. */
class TestProxyApiRegistrar : ProxyApiRegistrar(EchoBinaryMessenger(StandardMessageCodec()))
