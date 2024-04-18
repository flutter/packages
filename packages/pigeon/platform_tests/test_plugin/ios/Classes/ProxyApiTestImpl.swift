//
//  ProxyApiTestImpl.swift
//  test_plugin
//
//  Created by Maurice Parrish on 3/27/24.
//

import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

private func wrapResult(_ result: Any?) -> [Any?] {
  return [result]
}

private func wrapError(_ error: Any) -> [Any?] {
  if let flutterError = error as? FlutterError {
    return [
      flutterError.code,
      flutterError.message,
      flutterError.details,
    ]
  }
  return [
    "\(error)",
    "\(type(of: error))",
    "Stacktrace: \(Thread.callStackSymbols)",
  ]
}

private func createConnectionError(withChannelName channelName: String) -> FlutterError {
  return FlutterError(
    code: "channel-error", message: "Unable to establish connection on channel: '\(channelName)'.",
    details: "")
}

private func isNullish(_ value: Any?) -> Bool {
  return value is NSNull || value == nil
}

private func nilOrValue<T>(_ value: Any?) -> T? {
  if value is NSNull { return nil }
  return value as! T?
}

///// Handles the callback when an object is deallocated.
//public protocol PigeonFinalizerDelegate: AnyObject {
//  /// Invoked when the strong reference of an object is deallocated in an `InstanceManager`.
//  func onDeinit(identifier: Int64)
//}
//
//// Attaches to an object to receive a callback when the object is deallocated.
//internal final class PigeonFinalizer {
//  private static let associatedObjectKey = malloc(1)!
//
//  private let identifier: Int64
//  // Reference to the delegate is weak because the callback should be ignored if the
//  // `InstanceManager` is deallocated.
//  private weak var delegate: PigeonFinalizerDelegate?
//
//  private init(identifier: Int64, delegate: PigeonFinalizerDelegate) {
//    self.identifier = identifier
//    self.delegate = delegate
//  }
//
//  internal static func attach(
//    to instance: AnyObject, identifier: Int64, delegate: PigeonFinalizerDelegate
//  ) {
//    let finalizer = PigeonFinalizer(identifier: identifier, delegate: delegate)
//    objc_setAssociatedObject(instance, associatedObjectKey, finalizer, .OBJC_ASSOCIATION_RETAIN)
//  }
//
//  static func detach(from instance: AnyObject) {
//    objc_setAssociatedObject(instance, associatedObjectKey, nil, .OBJC_ASSOCIATION_ASSIGN)
//  }
//
//  deinit {
//    delegate?.onDeinit(identifier: identifier)
//  }
//}
//
///// Maintains instances used to communicate with the corresponding objects in Dart.
/////
///// Objects stored in this container are represented by an object in Dart that is also stored in
///// an InstanceManager with the same identifier.
/////
///// When an instance is added with an identifier, either can be used to retrieve the other.
/////
///// Added instances are added as a weak reference and a strong reference. When the strong
///// reference is removed and the weak reference is deallocated,`PigeonFinalizerDelegate.onDeinit`
///// is called with the instance's identifier. However, if the strong reference is removed and then the identifier is
///// retrieved with the intention to pass the identifier to Dart (e.g. by calling `identifierWithStrongReference`),
///// the strong reference to the instance is readded. The strong reference will then need to be removed manually
///// again.
/////
///// Accessing and inserting to an InstanceManager is thread safe.
//public class PigeonInstanceManager {
//  // Identifiers are locked to a specific range to avoid collisions with objects
//  // created simultaneously from Dart.
//  // Host uses identifiers >= 2^16 and Dart is expected to use values n where,
//  // 0 <= n < 2^16.
//  private static let minHostCreatedIdentifier: Int64 = 65536
//
//  private let lockQueue = DispatchQueue(label: "PigeonInstanceManager")
//  private let identifiers: NSMapTable<AnyObject, NSNumber> = NSMapTable(
//    keyOptions: [.weakMemory, .objectPointerPersonality], valueOptions: .strongMemory)
//  private let weakInstances: NSMapTable<NSNumber, AnyObject> = NSMapTable(
//    keyOptions: .strongMemory, valueOptions: [.weakMemory, .objectPointerPersonality])
//  private let strongInstances: NSMapTable<NSNumber, AnyObject> = NSMapTable(
//    keyOptions: .strongMemory, valueOptions: [.strongMemory, .objectPointerPersonality])
//  private let finalizerDelegate: PigeonFinalizerDelegate
//  private var nextIdentifier: Int64 = minHostCreatedIdentifier
//
//  public init(finalizerDelegate: PigeonFinalizerDelegate) {
//    self.finalizerDelegate = finalizerDelegate
//  }
//
//  /// Adds a new instance that was instantiated from Dart.
//  ///
//  /// The same instance can be added multiple times, but each identifier must be unique. This allows
//  /// two objects that are equivalent (e.g. conforms to `Equatable`)  to both be added.
//  ///
//  /// - Parameters:
//  ///   - instance: the instance to be stored
//  ///   - identifier: the identifier to be paired with instance. This value must be >= 0 and unique
//  func addDartCreatedInstance(_ instance: AnyObject, withIdentifier identifier: Int64) {
//    lockQueue.async {
//      self.addInstance(instance, withIdentifier: identifier)
//    }
//  }
//
//  /// Adds a new instance that was instantiated from the host platform.
//  ///
//  /// - Parameters:
//  ///   - instance: the instance to be stored. This must be unique to all other added instances.
//  /// - Returns: the unique identifier (>= 0) stored with instance
//  func addHostCreatedInstance(_ instance: AnyObject) -> Int64 {
//    assert(!containsInstance(instance), "Instance of \(instance) has already been added.")
//    var identifier: Int64 = -1
//    lockQueue.sync {
//      identifier = nextIdentifier
//      nextIdentifier += 1
//      self.addInstance(instance, withIdentifier: identifier)
//    }
//    return identifier
//  }
//
//  /// Removes `instanceIdentifier` and its associated strongly referenced instance, if present, from the manager.
//  ///
//  /// - Parameters:
//  ///   - instanceIdentifier: the identifier paired to an instance.
//  /// - Returns: removed instance if the manager contains the given identifier, otherwise `nil` if
//  ///   the manager doesn't contain the value
//  func removeInstance<T: AnyObject>(withIdentifier instanceIdentifier: Int64) -> T? {
//    var instance: AnyObject? = nil
//    lockQueue.sync {
//      instance = strongInstances.object(forKey: NSNumber(value: instanceIdentifier))
//      strongInstances.removeObject(forKey: NSNumber(value: instanceIdentifier))
//    }
//    return instance as? T
//  }
//
//  /// Retrieves the instance associated with identifier.
//  ///
//  /// - Parameters:
//  ///   - instanceIdentifier: the identifier associated with an instance
//  /// - Returns: the instance associated with `instanceIdentifier` if the manager contains the value, otherwise
//  ///   `nil` if the manager doesn't contain the value
//  func instance<T: AnyObject>(forIdentifier instanceIdentifier: Int64) -> T? {
//    var instance: AnyObject? = nil
//    lockQueue.sync {
//      instance = weakInstances.object(forKey: NSNumber(value: instanceIdentifier))
//    }
//    return instance as? T
//  }
//
//  private func addInstance(_ instance: AnyObject, withIdentifier identifier: Int64) {
//    assert(identifier >= 0)
//    assert(
//      weakInstances.object(forKey: identifier as NSNumber) == nil,
//      "Identifier has already been added: \(identifier)")
//    identifiers.setObject(NSNumber(value: identifier), forKey: instance)
//    weakInstances.setObject(instance, forKey: NSNumber(value: identifier))
//    strongInstances.setObject(instance, forKey: NSNumber(value: identifier))
//    PigeonFinalizer.attach(to: instance, identifier: identifier, delegate: finalizerDelegate)
//  }
//
//  /// Retrieves the identifier paired with an instance.
//  ///
//  /// If the manager contains a strong reference to `instance`, it will return the identifier
//  /// associated with `instance`. If the manager contains only a weak reference to `instance`, a new
//  /// strong reference to `instance` will be added and will need to be removed again with `removeInstance`.
//  ///
//  /// If this method returns a nonnull identifier, this method also expects the Dart
//  /// `PigeonInstanceManager` to have, or recreate, a weak reference to the Dart instance the
//  /// identifier is associated with.
//  ///
//  /// - Parameters:
//  ///   - instance: an instance that may be stored in the manager
//  /// - Returns: the identifier associated with `instance` if the manager contains the value, otherwise
//  ///   `nil` if the manager doesn't contain the value
//  func identifierWithStrongReference(forInstance instance: AnyObject) -> Int64? {
//    var identifier: Int64? = nil
//    lockQueue.sync {
//      if let existingIdentifier = identifiers.object(forKey: instance)?.int64Value {
//        strongInstances.setObject(instance, forKey: NSNumber(value: existingIdentifier))
//        identifier = existingIdentifier
//      }
//    }
//    return identifier
//  }
//
//  /// Whether this manager contains the given `instance`.
//  ///
//  /// - Parameters:
//  ///   - instance: the instance whose presence in this manager is to be tested
//  /// - Returns: whether this manager contains the given `instance`
//  func containsInstance(_ instance: AnyObject) -> Bool {
//    var containsInstance = false
//    lockQueue.sync {
//      containsInstance = identifiers.object(forKey: instance) != nil
//    }
//    return containsInstance
//  }
//
//  /// Removes all of the instances from this manager.
//  ///
//  /// The manager will be empty after this call returns.
//  func removeAllObjects() {
//    lockQueue.sync {
//      identifiers.removeAllObjects()
//      weakInstances.removeAllObjects()
//      strongInstances.removeAllObjects()
//      nextIdentifier = PigeonInstanceManager.minHostCreatedIdentifier
//    }
//  }
//
//  /// The number of instances stored as a strong reference.
//  ///
//  /// For debugging and testing purposes.
//  internal var strongInstanceCount: Int {
//    var count: Int = 0
//    lockQueue.sync {
//      count = strongInstances.count
//    }
//    return count
//  }
//
//  /// The number of instances stored as a weak reference.
//  ///
//  /// For debugging and testing purposes. NSMapTables that store keys or objects as weak
//  /// reference will be reclaimed nondeterministically.
//  internal var weakInstanceCount: Int {
//    var count: Int = 0
//    lockQueue.sync {
//      count = weakInstances.count
//    }
//    return count
//  }
//}
//
//private class PigeonInstanceManagerApi {
//  /// The codec used for serializing messages.
//  static let codec = FlutterStandardMessageCodec.sharedInstance()
//
//  /// Handles sending and receiving messages with Dart.
//  unowned let binaryMessenger: FlutterBinaryMessenger
//
//  init(binaryMessenger: FlutterBinaryMessenger) {
//    self.binaryMessenger = binaryMessenger
//  }
//
//  /// Sets up an instance of `PigeonInstanceManagerApi` to handle messages through the `binaryMessenger`.
//  static func setUpMessageHandlers(
//    binaryMessenger: FlutterBinaryMessenger, instanceManager: PigeonInstanceManager?
//  ) {
//    let removeStrongReferenceChannel = FlutterBasicMessageChannel(
//      name:
//        "dev.flutter.pigeon.pigeon_integration_tests.PigeonInstanceManagerApi.removeStrongReference",
//      binaryMessenger: binaryMessenger, codec: codec)
//    if let instanceManager = instanceManager {
//      removeStrongReferenceChannel.setMessageHandler { message, reply in
//        let identifier = message is Int64 ? message as! Int64 : Int64(message as! Int32)
//        let _: AnyObject? = instanceManager.removeInstance(withIdentifier: identifier)
//        reply(wrapResult(nil))
//      }
//    } else {
//      removeStrongReferenceChannel.setMessageHandler(nil)
//    }
//    let clearChannel = FlutterBasicMessageChannel(
//      name: "dev.flutter.pigeon.pigeon_integration_tests.PigeonInstanceManagerApi.clear",
//      binaryMessenger: binaryMessenger, codec: codec)
//    if let instanceManager = instanceManager {
//      clearChannel.setMessageHandler { _, reply in
//        instanceManager.removeAllObjects()
//        reply(wrapResult(nil))
//      }
//    } else {
//      clearChannel.setMessageHandler(nil)
//    }
//  }
//
//  /// Send a messaage to the Dart `InstanceManager` to remove the strong reference of the instance associated with `identifier`.
//  func removeStrongReference(
//    withIdentifier identifier: Int64, completion: @escaping (Result<Void, FlutterError>) -> Void
//  ) {
//    let channelName: String =
//      "dev.flutter.pigeon.pigeon_integration_tests.PigeonInstanceManagerApi.removeStrongReference"
//    let channel = FlutterBasicMessageChannel(
//      name: channelName, binaryMessenger: binaryMessenger, codec: PigeonInstanceManagerApi.codec)
//    channel.sendMessage(identifier) { response in
//      guard let listResponse = response as? [Any?] else {
//        completion(.failure(createConnectionError(withChannelName: channelName)))
//        return
//      }
//      if listResponse.count > 1 {
//        let code: String = listResponse[0] as! String
//        let message: String? = nilOrValue(listResponse[1])
//        let details: String? = nilOrValue(listResponse[2])
//        completion(.failure(FlutterError(code: code, message: message, details: details)))
//      } else {
//        completion(.success(Void()))
//      }
//    }
//  }
//}

//private class PigeonProxyApiBaseCodecReaderWriter: FlutterStandardReaderWriter {
//  unowned let pigeonRegistrar: PigeonProxyApiRegistrar
//
//  private class PigeonProxyApiBaseCodecReader: FlutterStandardReader {
//    unowned let pigeonRegistrar: PigeonProxyApiRegistrar
//
//    init(data: Data, pigeonRegistrar: PigeonProxyApiRegistrar) {
//      self.pigeonRegistrar = pigeonRegistrar
//      super.init(data: data)
//    }
//
//    override func readValue(ofType type: UInt8) -> Any? {
//      switch type {
//      case 128:
//        let identifier = self.readValue()
//        let instance: AnyObject? = pigeonRegistrar.instanceManager.instance(
//          forIdentifier: identifier is Int64 ? identifier as! Int64 : Int64(identifier as! Int32))
//        return instance
//      default:
//        return super.readValue(ofType: type)
//      }
//    }
//  }
//
//  private class PigeonProxyApiBaseCodecWriter: FlutterStandardWriter {
//    unowned let pigeonRegistrar: PigeonProxyApiRegistrar
//
//    init(data: NSMutableData, pigeonRegistrar: PigeonProxyApiRegistrar) {
//      self.pigeonRegistrar = pigeonRegistrar
//      super.init(data: data)
//    }
//
//    override func writeValue(_ value: Any) {
//      if #available(iOS 15, *), value is ProxyApiTestClass {
//        pigeonRegistrar.apiDelegate.pigeonApiProxyApiTestClass(pigeonRegistrar).pigeonNewInstance(
//          pigeonInstanceArg: value as! ProxyApiTestClass
//        ) { _ in }
//      }
//
//      if let instance = value as? AnyClass,
//        pigeonRegistrar.instanceManager.containsInstance(instance)
//      {
//        super.writeByte(128)
//        super.writeValue(
//          pigeonRegistrar.instanceManager.identifierWithStrongReference(forInstance: instance)!)
//      } else {
//        super.writeValue(value)
//      }
//    }
//  }
//
//  init(pigeonRegistrar: PigeonProxyApiRegistrar) {
//    self.pigeonRegistrar = pigeonRegistrar
//  }
//
//  override func reader(with data: Data) -> FlutterStandardReader {
//    return PigeonProxyApiBaseCodecReader(data: data, pigeonRegistrar: pigeonRegistrar)
//  }
//
//  override func writer(with data: NSMutableData) -> FlutterStandardWriter {
//    return PigeonProxyApiBaseCodecWriter(data: data, pigeonRegistrar: pigeonRegistrar)
//  }
//}
//
//public protocol PigeonProxyApiRegistrarDelegate {
//  /// An implementation of [PigeonApiProxyApiTestClass] used to add a new Dart instance of
//  /// `ProxyApiTestClass` to the Dart `InstanceManager`.
//  func pigeonApiProxyApiTestClass(_ pigeonRegistrar: PigeonProxyApiRegistrar)
//    -> PigeonApiProxyApiTestClass
//}
//
//public class PigeonProxyApiRegistrar {
//  let binaryMessenger: FlutterBinaryMessenger
//  let apiDelegate: PigeonProxyApiRegistrarDelegate
//  let instanceManager: PigeonInstanceManager
//
//  private var _codec: FlutterStandardMessageCodec?
//  var codec: FlutterStandardMessageCodec {
//    if _codec == nil {
//      _codec = FlutterStandardMessageCodec(
//        readerWriter: PigeonProxyApiBaseCodecReaderWriter(pigeonRegistrar: self))
//    }
//    return _codec!
//  }
//
//  private class InstanceManagerApiFinalizerDelegate: PigeonFinalizerDelegate {
//    let api: PigeonInstanceManagerApi
//
//    init(_ api: PigeonInstanceManagerApi) {
//      self.api = api
//    }
//
//    public func onDeinit(identifier: Int64) {
//      api.removeStrongReference(withIdentifier: identifier) {
//        _ in
//      }
//    }
//  }
//
//  init(binaryMessenger: FlutterBinaryMessenger, apiDelegate: PigeonProxyApiRegistrarDelegate) {
//    self.binaryMessenger = binaryMessenger
//    self.apiDelegate = apiDelegate
//    self.instanceManager = PigeonInstanceManager(
//      finalizerDelegate: InstanceManagerApiFinalizerDelegate(
//        PigeonInstanceManagerApi(binaryMessenger: binaryMessenger)))
//  }
//
//  func setUp() {
//    PigeonInstanceManagerApi.setUpMessageHandlers(
//      binaryMessenger: binaryMessenger, instanceManager: instanceManager)
//    PigeonApiProxyApiTestClass.setUpMessageHandlers(
//      binaryMessenger: binaryMessenger, api: apiDelegate.pigeonApiProxyApiTestClass(self))
//  }
//
//  func tearDown() {
//    instanceManager.removeAllObjects()
//    PigeonInstanceManagerApi.setUpMessageHandlers(
//      binaryMessenger: binaryMessenger, instanceManager: nil)
//    PigeonApiProxyApiTestClass.setUpMessageHandlers(
//      binaryMessenger: binaryMessenger, api: nil)
//  }
//}

public class ProxyApiTestClass {}
public class ProxyApiSuperClass {}
protocol ProxyApiInterface: AnyObject {}

public protocol PigeonApiDelegateProxyApiTestClass {
  /// woij
  /// wef
  @available(iOS 15.0.0, *)
  func pigeonDefaultConstructor(_ pigeonApi: PigeonApiProxyApiTestClass) throws -> ProxyApiTestClass
  func someField(_ pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass) throws
    -> Int
  func attachedField(_ pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass)
    throws -> ProxyApiSuperClass
  func echo(_ pigeonApi: PigeonApiProxyApiTestClass, pigeonInstance: ProxyApiTestClass, aBool: Bool)
    throws -> Bool
}

public class PigeonApiProxyApiTestClass {
  unowned let pigeonRegistrar: PigeonProxyApiRegistrar
  let pigeonDelegate: PigeonApiDelegateProxyApiTestClass

  var pigeonApiProxyApiSuperClass: PigeonApiProxyApiTestClass {
    return pigeonRegistrar.apiDelegate.pigeonApiProxyApiTestClass(pigeonRegistrar)
  }

  init(pigeonRegistrar: PigeonProxyApiRegistrar, delegate: PigeonApiDelegateProxyApiTestClass) {
    self.pigeonRegistrar = pigeonRegistrar
    self.pigeonDelegate = delegate
  }

  static func setUpMessageHandlers(
    binaryMessenger: FlutterBinaryMessenger, api: PigeonApiProxyApiTestClass?
  ) {
    let codec: FlutterStandardMessageCodec =
      api != nil
      ? FlutterStandardMessageCodec(
        readerWriter: PigeonProxyApiBaseCodecReaderWriter(pigeonRegistrar: api!.pigeonRegistrar))
      : FlutterStandardMessageCodec.sharedInstance()
    let pigeonDefaultConstructorChannel = FlutterBasicMessageChannel(
      name: "dev.flutter.pigeon.pigeon_integration_tests.HostIntegrationCoreApi.echoBool",
      binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      pigeonDefaultConstructorChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let pigeonIdentifierArg = args[0] is Int64 ? args[0] as! Int64 : Int64(args[0] as! Int32)
        do {
          api.pigeonRegistrar.instanceManager.addDartCreatedInstance(
            try api.pigeonDelegate.pigeonDefaultConstructor(api),
            withIdentifier: pigeonIdentifierArg)
          reply(wrapResult(nil))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      pigeonDefaultConstructorChannel.setMessageHandler(nil)
    }
    let attachedFieldChannel = FlutterBasicMessageChannel(
      name: "dev.flutter.pigeon.pigeon_integration_tests.HostIntegrationCoreApi.echoBool",
      binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      attachedFieldChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let pigeonInstanceArg = args[0] as! ProxyApiTestClass
        let pigeonIdentifierArg = args[1] is Int64 ? args[1] as! Int64 : Int64(args[1] as! Int32)
        do {
          api.pigeonRegistrar.instanceManager.addDartCreatedInstance(
            try api.pigeonDelegate.attachedField(api, pigeonInstance: pigeonInstanceArg),
            withIdentifier: pigeonIdentifierArg)
          reply(wrapResult(nil))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      attachedFieldChannel.setMessageHandler(nil)
    }
    let echoBoolChannel = FlutterBasicMessageChannel(
      name: "dev.flutter.pigeon.pigeon_integration_tests.HostIntegrationCoreApi.echoBool",
      binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      echoBoolChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let pigeonInstanceArg = args[0] as! ProxyApiTestClass
        let aBoolArg = args[1] as! Bool
        do {
          let result = try api.pigeonDelegate.echo(
            api, pigeonInstance: pigeonInstanceArg, aBool: aBoolArg)
          reply(wrapResult(result))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      echoBoolChannel.setMessageHandler(nil)
    }
  }

  func pigeonNewInstance(
    pigeonInstanceArg: ProxyApiTestClass,
    completion: @escaping (Result<Void, FlutterError>) -> Void
  ) {
    if pigeonRegistrar.instanceManager.containsInstance(pigeonInstanceArg) {
      completion(.success(Void()))
      return
    }
    let pigeonIdentifierArg = pigeonRegistrar.instanceManager.addHostCreatedInstance(
      pigeonInstanceArg)
    let binaryMessenger = pigeonRegistrar.binaryMessenger
    let codec = pigeonRegistrar.codec

    let channelName: String =
      "dev.flutter.pigeon.pigeon_integration_tests.FlutterIntegrationCoreApi.noop"
    let channel = FlutterBasicMessageChannel(
      name: channelName, binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage([pigeonIdentifierArg] as [Any?]) { response in
      guard let listResponse = response as? [Any?] else {
        completion(.failure(createConnectionError(withChannelName: channelName)))
        return
      }
      if listResponse.count > 1 {
        let code: String = listResponse[0] as! String
        let message: String? = nilOrValue(listResponse[1])
        let details: String? = nilOrValue(listResponse[2])
        completion(.failure(FlutterError(code: code, message: message, details: details)))
      } else {
        completion(.success(Void()))
      }
    }
  }

  func echo(
    _ aBool: Bool, completion: @escaping (Result<Bool, FlutterError>) -> Void
  ) {
    let binaryMessenger = pigeonRegistrar.binaryMessenger
    let codec = pigeonRegistrar.codec

    let channelName: String =
      "dev.flutter.pigeon.pigeon_integration_tests.FlutterIntegrationCoreApi.echoAllTypes"
    let channel = FlutterBasicMessageChannel(
      name: channelName, binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage([aBool] as [Any?]) { response in
      guard let listResponse = response as? [Any?] else {
        completion(.failure(createConnectionError(withChannelName: channelName)))
        return
      }
      if listResponse.count > 1 {
        let code: String = listResponse[0] as! String
        let message: String? = nilOrValue(listResponse[1])
        let details: String? = nilOrValue(listResponse[2])
        completion(.failure(FlutterError(code: code, message: message, details: details)))
      } else if listResponse[0] == nil {
        completion(
          .failure(
            FlutterError(
              code: "null-error",
              message: "Flutter api returned null value for non-null return value.", details: "")))
      } else {
        let result = listResponse[0] as! Bool
        completion(.success(result))
      }
    }
  }
}
