// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.pigeon_example_app

import MessagesPigeonProxyApiRegistrar
import PigeonApiComplexExampleNativeClass
import PigeonApiExampleNativeSuperClass
import PigeonApiSimpleExampleNativeClass
import io.flutter.plugin.common.BinaryMessenger

// #docregion simple-proxy-api
class SimpleExampleNativeClassProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiSimpleExampleNativeClass(pigeonRegistrar) {

  internal class SimpleExampleNativeClassImpl(
      val api: SimpleExampleNativeClassProxyApi,
      aField: String,
      aParameter: String
  ) : SimpleExampleNativeClass(aField, aParameter) {
    override fun flutterMethod(aParameter: String) {
      api.flutterMethod(this, aParameter) {}
    }
  }

  override fun pigeon_defaultConstructor(
      aField: String,
      aParameter: String
  ): SimpleExampleNativeClass {
    return SimpleExampleNativeClassImpl(this, aParameter, aField)
  }

  override fun aField(pigeon_instance: SimpleExampleNativeClass): String {
    return pigeon_instance.aField
  }

  override fun hostMethod(pigeon_instance: SimpleExampleNativeClass, aParameter: String): String {
    return pigeon_instance.hostMethod(aParameter)
  }
}
// #enddocregion simple-proxy-api

class ComplexExampleNativeClassProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiComplexExampleNativeClass(pigeonRegistrar) {
  override fun aStaticField(): ExampleNativeSuperClass {
    return ComplexExampleNativeClass.aStaticField
  }

  override fun anAttachedField(
      pigeon_instance: ComplexExampleNativeClass
  ): ExampleNativeSuperClass {
    return pigeon_instance.anAttachedField
  }

  override fun staticHostMethod(): String {
    return ComplexExampleNativeClass.staticHostMethod()
  }
}

class ExampleNativeSuperClassProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiExampleNativeSuperClass(pigeonRegistrar) {
  override fun inheritedSuperClassMethod(pigeon_instance: ExampleNativeSuperClass): String {
    return pigeon_instance.inheritedSuperClassMethod()
  }
}

// #docregion simple-proxy-registrar
open class ProxyApiRegistrar(binaryMessenger: BinaryMessenger) :
    MessagesPigeonProxyApiRegistrar(binaryMessenger) {
  override fun getPigeonApiSimpleExampleNativeClass(): PigeonApiSimpleExampleNativeClass {
    return SimpleExampleNativeClassProxyApi(this)
  }
  // #enddocregion simple-proxy-registrar

  override fun getPigeonApiComplexExampleNativeClass(): PigeonApiComplexExampleNativeClass {
    return ComplexExampleNativeClassProxyApi(this)
  }

  override fun getPigeonApiExampleNativeSuperClass(): PigeonApiExampleNativeSuperClass {
    return ExampleNativeSuperClassProxyApi(this)
  }
  // #docregion simple-proxy-registrar
}
// #enddocregion simple-proxy-registrar
