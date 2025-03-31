// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// Implementation of `NSObject` that calls to Dart in callback methods.
class NSObjectImpl: NSObject {
  let api: PigeonApiProtocolNSObject
  unowned let registrar: ProxyAPIRegistrar

  init(api: PigeonApiProtocolNSObject, registrar: ProxyAPIRegistrar) {
    self.api = api
    self.registrar = registrar
  }

  static func handleObserveValue(
    withApi api: PigeonApiProtocolNSObject, registrar: ProxyAPIRegistrar, instance: NSObject,
    forKeyPath keyPath: String?,
    of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?
  ) {
    let wrapperKeys: [KeyValueChangeKey: Any]?
    if change != nil {
      let keyValueTuples = change!.map { key, value in
        let newKey: KeyValueChangeKey
        switch key {
        case .kindKey:
          newKey = .kind
        case .indexesKey:
          newKey = .indexes
        case .newKey:
          newKey = .newValue
        case .oldKey:
          newKey = .oldValue
        case .notificationIsPriorKey:
          newKey = .notificationIsPrior
        default:
          newKey = .unknown
        }

        return (newKey, value)
      }

      wrapperKeys = Dictionary(uniqueKeysWithValues: keyValueTuples)
    } else {
      wrapperKeys = nil
    }

    registrar.dispatchOnMainThread { onFailure in
      api.observeValue(
        pigeonInstance: instance, keyPath: keyPath, object: object as? NSObject, change: wrapperKeys
      ) { result in
        if case .failure(let error) = result {
          onFailure("NSObject.observeValue", error)
        }
      }
    }
  }

  override func observeValue(
    forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?,
    context: UnsafeMutableRawPointer?
  ) {
    NSObjectImpl.handleObserveValue(
      withApi: api, registrar: registrar, instance: self as NSObject, forKeyPath: keyPath,
      of: object, change: change,
      context: context)
  }
}

/// ProxyApi implementation for `NSObject`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class NSObjectProxyAPIDelegate: PigeonApiDelegateNSObject {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiNSObject) throws -> NSObject {
    return NSObjectImpl(api: pigeonApi, registrar: pigeonApi.pigeonRegistrar as! ProxyAPIRegistrar)
  }

  func addObserver(
    pigeonApi: PigeonApiNSObject, pigeonInstance: NSObject, observer: NSObject, keyPath: String,
    options: [KeyValueObservingOptions]
  ) throws {
    var nativeOptions: NSKeyValueObservingOptions = []

    for option in options {
      switch option {
      case .newValue:
        nativeOptions.insert(.new)
      case .oldValue:
        nativeOptions.insert(.old)
      case .initialValue:
        nativeOptions.insert(.initial)
      case .priorNotification:
        nativeOptions.insert(.prior)
      }
    }

    pigeonInstance.addObserver(observer, forKeyPath: keyPath, options: nativeOptions, context: nil)
  }

  func removeObserver(
    pigeonApi: PigeonApiNSObject, pigeonInstance: NSObject, observer: NSObject, keyPath: String
  ) throws {
    pigeonInstance.removeObserver(observer, forKeyPath: keyPath)
  }
}
