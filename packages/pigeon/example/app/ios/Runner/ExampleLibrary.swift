// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// #docregion simple-proxy-class
class SimpleExampleNativeClass {
  let aField: String

  init(aField: String, aParameter: String) {
    self.aField = aField
  }

  open func flutterMethod(aParameter: String) {}

  func hostMethod(aParamter: String) -> String {
    return "some string"
  }
}
// #enddocregion simple-proxy-class

class ComplexExampleNativeClass: ExampleNativeSuperClass, ExampleNativeInterface {
  static let aStaticField = ExampleNativeSuperClass()
  let anAttachedField = ExampleNativeSuperClass()

  static func staticHostMethod() -> String {
    return "some string"
  }

  func inheritedInterfaceMethod() {}
}

class ExampleNativeSuperClass {
  func inheritedSuperClassMethod() -> String {
    return "some string"
  }
}

protocol ExampleNativeInterface {
  func inheritedInterfaceMethod()
}
