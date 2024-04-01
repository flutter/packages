//
//  InstanceManagerTests.swift
//  RunnerTests
//
//  Created by Maurice Parrish on 4/1/24.
//

import Foundation
import XCTest

@testable import test_plugin

final class InstanceManagerTests: XCTestCase {
  func testAddDartCreatedInstance() {
    let instanceManager = PenguinInstanceManager(finalizerDelegate: EmptyFinalizerDelegate())
    let object = NSObject()

    instanceManager.addDartCreatedInstance(object, withIdentifier: 0)
    XCTAssertEqual(instanceManager.instance(forIdentifier: 0) as! NSObject, object)
    XCTAssertEqual(instanceManager.identifierWithStrongReference(forInstance: object), 0)
  }

  func testAddHostCreatedInstance() {
    let instanceManager = PenguinInstanceManager(finalizerDelegate: EmptyFinalizerDelegate())
    let object = NSObject()
    _ = instanceManager.addHostCreatedInstance(object)

    let identifier = instanceManager.identifierWithStrongReference(forInstance: object)
    XCTAssertNotNil(identifier)
    XCTAssertEqual(instanceManager.instance(forIdentifier: identifier!) as! NSObject, object)
  }

  func testRemoveInstance() {
    let instanceManager = PenguinInstanceManager(finalizerDelegate: EmptyFinalizerDelegate())
    let object = NSObject()

    instanceManager.addDartCreatedInstance(object, withIdentifier: 0)

    XCTAssertEqual(instanceManager.removeInstance(withIdentifier: 0) as? NSObject, object)
    XCTAssertEqual(instanceManager.strongInstanceCount, 0)
  }
  
  func testFinalizerCallsDelegateMethod() {
    let finalizerDelegate = TestFinalizerDelegate()
    
    var object: NSObject? = NSObject()
    PenguinFinalizer.attach(to: object!, identifier: 0, delegate: finalizerDelegate)
    
    object = nil
    XCTAssertEqual(finalizerDelegate.lastHandledIdentifier, 0)
  }
  
  func testRemoveAllObjects() {
    let instanceManager = PenguinInstanceManager(finalizerDelegate: EmptyFinalizerDelegate())
    let object = NSObject()

    instanceManager.addDartCreatedInstance(object, withIdentifier: 0)
    instanceManager.removeAllObjects()
    
    XCTAssertEqual(instanceManager.strongInstanceCount, 0)
    XCTAssertEqual(instanceManager.weakInstanceCount, 0)
  }
  
  func testCanAddSameObjectWithAddDartCreatedInstance() {
    let instanceManager = PenguinInstanceManager(finalizerDelegate: EmptyFinalizerDelegate())
    let object = NSObject()
    
    instanceManager.addDartCreatedInstance(object, withIdentifier: 0)
    instanceManager.addDartCreatedInstance(object, withIdentifier: 1)
    
    XCTAssertEqual(instanceManager.instance(forIdentifier: 0) as! NSObject, instanceManager.instance(forIdentifier: 1) as! NSObject)
  }

  func testObjectsAreStoredWithPointerHashcode() {
    let instanceManager = PenguinInstanceManager(finalizerDelegate: EmptyFinalizerDelegate())
    
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
}

class EmptyFinalizerDelegate: PenguinFinalizerDelegate {
  func onDeinit(identifier: Int64) { }
}

class TestFinalizerDelegate: PenguinFinalizerDelegate {
  var lastHandledIdentifier: Int64?
  
  func onDeinit(identifier: Int64) { 
    lastHandledIdentifier = identifier
  }
}
