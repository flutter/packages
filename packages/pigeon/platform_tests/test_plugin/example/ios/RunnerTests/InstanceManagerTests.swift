// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import Flutter
import XCTest

@testable import test_plugin

final class InstanceManagerTests: XCTestCase {
  func testAddDartCreatedInstance() {
    let instanceManager = PigeonInstanceManager(finalizerDelegate: EmptyFinalizerDelegate())
    let object = NSObject()

    instanceManager.addDartCreatedInstance(object, withIdentifier: 0)
    XCTAssertEqual(instanceManager.instance(forIdentifier: 0), object)
    XCTAssertEqual(instanceManager.identifierWithStrongReference(forInstance: object), 0)
  }

  func testAddHostCreatedInstance() {
    let instanceManager = PigeonInstanceManager(finalizerDelegate: EmptyFinalizerDelegate())
    let object = NSObject()
    _ = instanceManager.addHostCreatedInstance(object)

    let identifier = instanceManager.identifierWithStrongReference(forInstance: object)
    XCTAssertNotNil(identifier)
    XCTAssertEqual(instanceManager.instance(forIdentifier: identifier!), object)
  }

  func testRemoveInstance() {
    let instanceManager = PigeonInstanceManager(finalizerDelegate: EmptyFinalizerDelegate())
    let object = NSObject()

    instanceManager.addDartCreatedInstance(object, withIdentifier: 0)

    XCTAssertEqual(instanceManager.removeInstance(withIdentifier: 0), object)
    XCTAssertEqual(instanceManager.strongInstanceCount, 0)
  }

  func testFinalizerCallsDelegateMethod() {
    let finalizerDelegate = TestFinalizerDelegate()

    var object: NSObject? = NSObject()
    PigeonFinalizer.attach(to: object!, identifier: 0, delegate: finalizerDelegate)

    object = nil
    XCTAssertEqual(finalizerDelegate.lastHandledIdentifier, 0)
  }

  func testRemoveAllObjects() {
    let instanceManager = PigeonInstanceManager(finalizerDelegate: EmptyFinalizerDelegate())
    let object = NSObject()

    instanceManager.addDartCreatedInstance(object, withIdentifier: 0)
    instanceManager.removeAllObjects()

    XCTAssertEqual(instanceManager.strongInstanceCount, 0)
    XCTAssertEqual(instanceManager.weakInstanceCount, 0)
  }

  func testCanAddSameObjectWithAddDartCreatedInstance() {
    let instanceManager = PigeonInstanceManager(finalizerDelegate: EmptyFinalizerDelegate())
    let object = NSObject()

    instanceManager.addDartCreatedInstance(object, withIdentifier: 0)
    instanceManager.addDartCreatedInstance(object, withIdentifier: 1)

    let instance1: NSObject? = instanceManager.instance(forIdentifier: 0)
    let instance2: NSObject? = instanceManager.instance(forIdentifier: 1)

    XCTAssertEqual(instance1, instance2)
  }

  func testObjectsAreStoredWithPointerHashcode() {
    let instanceManager = PigeonInstanceManager(finalizerDelegate: EmptyFinalizerDelegate())

    class EquatableClass: Equatable {
      static func == (lhs: EquatableClass, rhs: EquatableClass) -> Bool {
        return true
      }
    }

    let instance1 = EquatableClass()
    let instance2 = EquatableClass()

    // Ensure instances are considered equal.
    XCTAssertTrue(instance1 == instance2)

    _ = instanceManager.addHostCreatedInstance(instance1)
    _ = instanceManager.addHostCreatedInstance(instance2)

    XCTAssertNotEqual(
      instanceManager.identifierWithStrongReference(forInstance: instance1),
      instanceManager.identifierWithStrongReference(forInstance: instance2))
  }
  
  func testInstanceManagerCanBeDeallocated() {
    let binaryMessenger = MockBinaryMessenger<String>(codec: FlutterStandardMessageCodec.sharedInstance())
    
    let instanceManager = PigeonInstanceManager(api: PigeonInstanceManagerApi(binaryMessenger: binaryMessenger))
    
    class ApiDel: PigeonApiDelegate {
      func getPiegonApiProxyApiTestClass() -> test_plugin.PigeonApiProxyApiTestClass {
        class ABC: PigeonDelegateProxyApiTestClass {
          func pigeonDefaultConstructor() throws -> test_plugin.ProxyApiTestClass {
            return nil
          }
          
          func attachedField(pigeonInstance: test_plugin.ProxyApiTestClass) throws -> test_plugin.ProxyApiSuperClass {
            return nil
          }
          
          func echo(pigeonInstance: test_plugin.ProxyApiTestClass, aBool: Bool) throws -> Bool {
            return nil
          }
        }
        return PigeonApiProxyApiTestClass(codec: nil, delegate: ABC())
      }
    }
    
    let codec = PigeonProxyApiBaseCodec(binaryMessenger: binaryMessenger, instanceManager: instanceManager, apiDelegate: nil)
  }
}

class EmptyFinalizerDelegate: PigeonFinalizerDelegate {
  func onDeinit(identifier: Int64) {}
}

class TestFinalizerDelegate: PigeonFinalizerDelegate {
  var lastHandledIdentifier: Int64?

  func onDeinit(identifier: Int64) {
    lastHandledIdentifier = identifier
  }
}
