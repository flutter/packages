// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.test_plugin

import io.flutter.plugin.common.BinaryMessenger

class ProxyApiTestClass : ProxyApiSuperClass(), ProxyApiInterface

open class ProxyApiSuperClass

interface ProxyApiInterface

class ProxyApiCodec(binaryMessenger: BinaryMessenger, instanceManager: PigeonInstanceManager) :
    PigeonProxyApiBaseCodec(binaryMessenger, instanceManager) {
  override fun getPigeonApiProxyApiTestClass(): PigeonApiProxyApiTestClass {
    return ProxyApiTestClassApi(this)
  }

  override fun getPigeonApiProxyApiSuperClass(): PigeonApiProxyApiSuperClass {
    return ProxyApiSuperClassApi(this)
  }

  override fun getPigeonApiProxyApiInterface(): PigeonApiProxyApiInterface {
    return ProxyApiInterfaceApi(this)
  }
}

class ProxyApiTestClassApi(codec: PigeonProxyApiBaseCodec) : PigeonApiProxyApiTestClass(codec)

class ProxyApiSuperClassApi(codec: PigeonProxyApiBaseCodec) : PigeonApiProxyApiSuperClass(codec)

class ProxyApiInterfaceApi(codec: PigeonProxyApiBaseCodec) : PigeonApiProxyApiInterface(codec)
