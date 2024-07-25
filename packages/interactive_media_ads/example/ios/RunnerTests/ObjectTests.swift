// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import interactive_media_ads

final class ObjectsTests: XCTestCase {
  func testAddObserver() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiNSObject(registrar)

    let instance = TestObject()

    try? api.pigeonDelegate.addObserver(
      pigeonApi: api, pigeonInstance: instance, observer: instance, keyPath: "keyPath",
      options: KeyValueObservingOptions.initialValue)

    XCTAssertEqual(instance.addObserverArgs![0] as! TestObject, instance)
    XCTAssertEqual(instance.addObserverArgs![1] as! String, "keyPath")
    XCTAssertEqual(
      instance.addObserverArgs![2] as! NSKeyValueObservingOptions,
      NSKeyValueObservingOptions.initial)
  }

  func testRemoveObserver() {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiNSObject(registrar)

    let instance = TestObject()

    try? api.pigeonDelegate.removeObserver(
      pigeonApi: api, pigeonInstance: instance, observer: instance, keyPath: "keyPath")

    XCTAssertEqual(instance.removeObserverArgs, [instance, "keyPath"])
  }

  func testObserveValue() {
    let api = TestObjectsApi()
    let instance = ObjectImpl(api: api)

    instance.observeValue(
      forKeyPath: "keyPath", of: instance, change: [NSKeyValueChangeKey.newKey: "hello"],
      context: nil)

    XCTAssertEqual(api.observeValueArgs![0] as! String, "keyPath")
    XCTAssertEqual(api.observeValueArgs![1] as! NSObject, instance)
    XCTAssertEqual(
      api.observeValueArgs![2] as! [KeyValueChangeKey: String],
      [KeyValueChangeKey.newValue: "hello"])
  }
}

class TestObjectsApi: PigeonApiProtocolNSObject {
  var observeValueArgs: [Any?]? = nil

  func observeValue(
    pigeonInstance pigeonInstanceArg: NSObject, keyPath keyPathArg: String?,
    object objectArg: NSObject?, changeKeys changeKeysArg: [KeyValueChangeKey: Any]?,
    completion: @escaping (Result<Void, PigeonError>) -> Void
  ) {
    observeValueArgs = [keyPathArg, objectArg, changeKeysArg]
  }
}

class TestObject: NSObject {
  var addObserverArgs: [Any?]? = nil
  var removeObserverArgs: [AnyHashable?]? = nil

  override func addObserver(
    _ observer: NSObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions = [],
    context: UnsafeMutableRawPointer?
  ) {
    addObserverArgs = [observer, keyPath, options]
  }

  override func removeObserver(_ observer: NSObject, forKeyPath keyPath: String) {
    removeObserverArgs = [observer, keyPath]
  }
}
