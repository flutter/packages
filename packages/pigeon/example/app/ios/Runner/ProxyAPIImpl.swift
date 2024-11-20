// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// #docregion simple-proxy-api
class SimpleExampleNativeClassImpl: SimpleExampleNativeClass {
  let api: PigeonApiSimpleExampleNativeClass

  init(api: PigeonApiSimpleExampleNativeClass, aField: String, aParameter: String) {
    self.api = api
    super.init(aField: aField, aParameter: aField)
  }

  override func flutterMethod(aParameter: String) {
    api.flutterMethod(pigeonInstance: self, aParameter: aParameter) { _ in }
  }
}

class SimpleExampleNativeClassAPIDelegate: PigeonApiDelegateSimpleExampleNativeClass {
  func pigeonDefaultConstructor(
    pigeonApi: PigeonApiSimpleExampleNativeClass, aField: String, aParameter: String
  ) throws -> SimpleExampleNativeClass {
    return SimpleExampleNativeClassImpl(api: pigeonApi, aField: aField, aParameter: aParameter)
  }

  func aField(
    pigeonApi: PigeonApiSimpleExampleNativeClass, pigeonInstance: SimpleExampleNativeClass
  ) throws -> String {
    return pigeonInstance.aField
  }

  func hostMethod(
    pigeonApi: PigeonApiSimpleExampleNativeClass, pigeonInstance: SimpleExampleNativeClass,
    aParameter: String
  ) throws -> String {
    return pigeonInstance.hostMethod(aParamter: aParameter)
  }
}
// #enddocregion simple-proxy-api

class ComplexExampleNativeClassAPIDelegate: PigeonApiDelegateComplexExampleNativeClass {
  func aStaticField(pigeonApi: PigeonApiComplexExampleNativeClass) throws -> ExampleNativeSuperClass
  {
    return ComplexExampleNativeClass.aStaticField
  }

  func anAttachedField(
    pigeonApi: PigeonApiComplexExampleNativeClass, pigeonInstance: ComplexExampleNativeClass
  ) throws -> ExampleNativeSuperClass {
    return pigeonInstance.anAttachedField
  }

  func staticHostMethod(pigeonApi: PigeonApiComplexExampleNativeClass) throws -> String {
    return ComplexExampleNativeClass.staticHostMethod()
  }
}

class ExampleNativeSuperClassAPIDelegate: PigeonApiDelegateExampleNativeSuperClass {
  func inheritedSuperClassMethod(
    pigeonApi: PigeonApiExampleNativeSuperClass, pigeonInstance: ExampleNativeSuperClass
  ) throws -> String {
    return pigeonInstance.inheritedSuperClassMethod()
  }
}

// #docregion simple-proxy-registrar
open class ProxyAPIDelegate: MessagesPigeonProxyApiDelegate {
  func pigeonApiSimpleExampleNativeClass(_ registrar: MessagesPigeonProxyApiRegistrar)
    -> PigeonApiSimpleExampleNativeClass
  {
    return PigeonApiSimpleExampleNativeClass(
      pigeonRegistrar: registrar, delegate: SimpleExampleNativeClassAPIDelegate())
  }
  // #enddocregion simple-proxy-registrar

  func pigeonApiComplexExampleNativeClass(_ registrar: MessagesPigeonProxyApiRegistrar)
    -> PigeonApiComplexExampleNativeClass
  {
    return PigeonApiComplexExampleNativeClass(
      pigeonRegistrar: registrar, delegate: ComplexExampleNativeClassAPIDelegate())
  }

  func pigeonApiExampleNativeSuperClass(_ registrar: MessagesPigeonProxyApiRegistrar)
    -> PigeonApiExampleNativeSuperClass
  {
    return PigeonApiExampleNativeSuperClass(
      pigeonRegistrar: registrar, delegate: ExampleNativeSuperClassAPIDelegate())
  }
  // #docregion simple-proxy-registrar
}
// #enddocregion simple-proxy-registrar
