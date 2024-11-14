// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@file:Suppress("unused")

// #docregion simple-proxy-class
package dev.flutter.pigeon_example_app

open class SimpleExampleNativeClass(val aField: String, private val aParameter: String) {
  open fun flutterMethod(aParameter: String) {}

  fun hostMethod(aParameter: String): String {
    return "aString"
  }
}
// #enddocregion simple-proxy-class

class ComplexExampleNativeClass : ExampleNativeSuperClass(), ExampleNativeInterface {
  val anAttachedField = ExampleNativeSuperClass()

  companion object {
    val aStaticField = ExampleNativeSuperClass()

    fun staticHostMethod(): String {
      return "some string"
    }
  }

  override fun inheritedInterfaceMethod() {}
}

open class ExampleNativeSuperClass {
  fun inheritedSuperClassMethod(): String {
    return "some string"
  }
}

interface ExampleNativeInterface {
  fun inheritedInterfaceMethod()
}
