// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import webview_flutter_wkwebview

class ObjectProxyAPITests: XCTestCase {
  func testPigeonDefaultConstructor() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiNSObject(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api)
    XCTAssertNotNil(instance)
  }

  func testAddObserver() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiNSObject(registrar)

    let instance = TestObject()
    let observer = NSObject()
    let keyPath = "myString"
    let options: [KeyValueObservingOptions] = [.newValue]
    try? api.pigeonDelegate.addObserver(
      pigeonApi: api, pigeonInstance: instance, observer: observer, keyPath: keyPath,
      options: options)

    var nativeOptions: NSKeyValueObservingOptions = []
    nativeOptions.insert(.new)

    XCTAssertEqual(instance.addObserverArgs, [observer, keyPath, nativeOptions.rawValue])
  }

  func testRemoveObserver() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiNSObject(registrar)

    let instance = TestObject()
    let object = NSObject()
    let keyPath = "myString"
    try? api.pigeonDelegate.removeObserver(
      pigeonApi: api, pigeonInstance: instance, observer: object, keyPath: keyPath)

    XCTAssertEqual(instance.removeObserverArgs, [object, keyPath])
  }

  func testObserveValue() {
    let api = TestObjectApi()

    let registrar = TestProxyApiRegistrar()
    let instance = NSObjectImpl(api: api, registrar: registrar)
    let keyPath = "myString"
    let object = NSObject()
    let change = [NSKeyValueChangeKey.indexesKey: -1]
    instance.observeValue(forKeyPath: keyPath, of: object, change: change, context: nil)

    XCTAssertEqual(api.observeValueArgs, [keyPath, object, [KeyValueChangeKey.indexes: -1]])
  }
}

class TestObject: NSObject {
  var addObserverArgs: [AnyHashable?]? = nil
  var removeObserverArgs: [AnyHashable?]? = nil

  override func addObserver(
    _ observer: NSObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions = [],
    context: UnsafeMutableRawPointer?
  ) {
    addObserverArgs = [observer, keyPath, options.rawValue]
  }

  override func removeObserver(_ observer: NSObject, forKeyPath keyPath: String) {
    removeObserverArgs = [observer, keyPath]
  }
}

class TestObjectApi: PigeonApiProtocolNSObject {
  var observeValueArgs: [AnyHashable?]? = nil

  func observeValue(
    pigeonInstance pigeonInstanceArg: NSObject, keyPath keyPathArg: String?,
    object objectArg: NSObject?, change changeArg: [KeyValueChangeKey: Any?]?,
    completion: @escaping (Result<Void, PigeonError>) -> Void
  ) {
    observeValueArgs = [keyPathArg, objectArg, changeArg! as! [KeyValueChangeKey: Int]]
  }
}
