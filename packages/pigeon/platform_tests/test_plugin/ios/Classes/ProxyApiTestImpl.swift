//
//  ProxyApiTestImpl.swift
//  test_plugin
//
//  Created by Maurice Parrish on 3/27/24.
//

import Foundation

typealias PenguinOnDeallocCallback = (Int64) -> Void

// Only classes can have a weak reference, so the callback is wrapped here.
// TODO: better name or combine?
final class PenguinCallbackHolder {
  let callback: PenguinOnDeallocCallback
  
  init(callback: @escaping PenguinOnDeallocCallback) {
    self.callback = callback
  }
}

// Attaches to an object to receive a callback when the object is deallocated.
final class PenguinFinalizer {
  private static let associatedObjectKey = malloc(1)!
  
  private let identifier: Int64
  private weak var callbackHolder: PenguinCallbackHolder?
  
  init(identifier: Int64, callbackHolder: PenguinCallbackHolder) {
    self.identifier = identifier
    self.callbackHolder = callbackHolder
  }
  
  static func attach(to instance: AnyObject, identifier: Int64, callbackHolder: PenguinCallbackHolder) {
    let finalizer = PenguinFinalizer(identifier: identifier, callbackHolder: callbackHolder)
    objc_setAssociatedObject(instance, associatedObjectKey, finalizer, .OBJC_ASSOCIATION_RETAIN)
  }

  static func detach(from instance: AnyObject) {
    objc_setAssociatedObject(instance, associatedObjectKey, nil, .OBJC_ASSOCIATION_ASSIGN)
  }

  deinit {
    callbackHolder?.callback(identifier)
  }
}

class PenguinInstanceManager {
  private static let FWFMinHostCreatedIdentifier: Int64 = 65536

  private let lockQueue = DispatchQueue(label: "FWFInstanceManager")
  private let identifiers: NSMapTable<AnyObject, NSNumber> = NSMapTable(
    keyOptions: [.weakMemory, .objectPointerPersonality], valueOptions: .strongMemory)
  private let weakInstances: NSMapTable<NSNumber, AnyObject> = NSMapTable(
    keyOptions: .strongMemory, valueOptions: [.weakMemory, .objectPointerPersonality])
  private let strongInstances: NSMapTable<NSNumber, AnyObject> = NSMapTable(
    keyOptions: .strongMemory, valueOptions: [.strongMemory, .objectPointerPersonality])
  private let deallocCallbackHolder: PenguinCallbackHolder  // Provide a default implementation
  private var nextIdentifier: Int64 = FWFMinHostCreatedIdentifier

  init(deallocCallbackHolder: PenguinCallbackHolder) {
    self.deallocCallbackHolder = deallocCallbackHolder
  }

  func addDartCreatedInstance(_ instance: AnyObject, withIdentifier identifier: Int64) {
    assert(identifier >= 0)
    lockQueue.async {
      self.addInstance(instance, withIdentifier: identifier)
    }
  }

  func addHostCreatedInstance(_ instance: AnyObject) -> Int64 {
    var identifier: Int64 = -1
    lockQueue.sync {
      identifier = nextIdentifier
      nextIdentifier += 1
      self.addInstance(instance, withIdentifier: identifier)
    }
    return identifier
  }

  func removeInstance(withIdentifier instanceIdentifier: Int64) -> AnyObject? {
    var instance: AnyObject? = nil
    lockQueue.sync {
      instance = strongInstances.object(forKey: NSNumber(value: instanceIdentifier))
      strongInstances.removeObject(forKey: NSNumber(value: instanceIdentifier))
    }
    return instance
  }

  func instance(forIdentifier instanceIdentifier: Int64) -> AnyObject? {
    var instance: AnyObject? = nil
    lockQueue.sync {
      instance = weakInstances.object(forKey: NSNumber(value: instanceIdentifier))
    }
    return instance
  }

  private func addInstance(_ instance: AnyObject, withIdentifier identifier: Int64) {
    identifiers.setObject(NSNumber(value: identifier), forKey: instance)
    weakInstances.setObject(instance, forKey: NSNumber(value: identifier))
    strongInstances.setObject(instance, forKey: NSNumber(value: identifier))
    PenguinFinalizer.attach(to: instance, identifier: identifier, callbackHolder: deallocCallbackHolder)
  }

  func identifierWithStrongReference(forInstance instance: AnyObject) -> Int64 {
    var identifier: Int64 = Int64(NSNotFound)
    lockQueue.sync {
      if let existingIdentifier = identifiers.object(forKey: instance)?.int64Value {
        strongInstances.setObject(instance, forKey: NSNumber(value: existingIdentifier))
        identifier = existingIdentifier
      }
    }
    return identifier
  }

  func containsInstance(_ instance: AnyObject) -> Bool {
    var containsInstance = false
    lockQueue.sync {
      containsInstance = identifiers.object(forKey: instance) != nil
    }
    return containsInstance
  }
  
  var strongInstanceCount: Int {
    var count: Int = 0
    lockQueue.sync {
      count = strongInstances.count
    }
    return count
  }

  var weakInstanceCount: Int {
    var count: Int = 0
    lockQueue.sync {
      count = weakInstances.count
    }
    return count
  }
}
