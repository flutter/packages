// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../ast.dart';
import '../generator_tools.dart';

/// Name of delegate that handles the callback when an object is deallocated
/// in an `InstanceManager`.
const String instanceManagerFinalizerDelegateName =
    '${_instanceManagerFinalizerName}Delegate';

/// The name of the registrar containing all the ProxyApi implementations.
const String proxyApiRegistrarName = '${classNamePrefix}ProxyApiRegistrar';

/// The name of the `ReaderWriter` that handles ProxyApis.
const String proxyApiReaderWriterName =
    '${classNamePrefix}ProxyApiCodecReaderWriter';

/// Template for delegate with callback when an object is deallocated.
const String instanceManagerFinalizerDelegateTemplate = '''
/// Handles the callback when an object is deallocated.
public protocol $instanceManagerFinalizerDelegateName: AnyObject {
  /// Invoked when the strong reference of an object is deallocated in an `InstanceManager`.
  func onDeinit(identifier: Int64)
}
''';

/// Template for an object that tracks when an object is deallocated.
const String instanceManagerFinalizerTemplate = '''
// Attaches to an object to receive a callback when the object is deallocated.
internal final class $_instanceManagerFinalizerName {
  private static let associatedObjectKey = malloc(1)!

  private let identifier: Int64
  // Reference to the delegate is weak because the callback should be ignored if the
  // `InstanceManager` is deallocated.
  private weak var delegate: $instanceManagerFinalizerDelegateName?

  private init(identifier: Int64, delegate: $instanceManagerFinalizerDelegateName) {
    self.identifier = identifier
    self.delegate = delegate
  }

  internal static func attach(
    to instance: AnyObject, identifier: Int64, delegate: $instanceManagerFinalizerDelegateName
  ) {
    let finalizer = $_instanceManagerFinalizerName(identifier: identifier, delegate: delegate)
    objc_setAssociatedObject(instance, associatedObjectKey, finalizer, .OBJC_ASSOCIATION_RETAIN)
  }

  static func detach(from instance: AnyObject) {
    objc_setAssociatedObject(instance, associatedObjectKey, nil, .OBJC_ASSOCIATION_ASSIGN)
  }

  deinit {
    delegate?.onDeinit(identifier: identifier)
  }
}
''';

/// The Swift `InstanceManager`.
const String instanceManagerTemplate = '''
/// Maintains instances used to communicate with the corresponding objects in Dart.
///
/// Objects stored in this container are represented by an object in Dart that is also stored in
/// an InstanceManager with the same identifier.
///
/// When an instance is added with an identifier, either can be used to retrieve the other.
///
/// Added instances are added as a weak reference and a strong reference. When the strong
/// reference is removed and the weak reference is deallocated,`$instanceManagerFinalizerDelegateName.onDeinit`
/// is called with the instance's identifier. However, if the strong reference is removed and then the identifier is
/// retrieved with the intention to pass the identifier to Dart (e.g. by calling `identifierWithStrongReference`),
/// the strong reference to the instance is re-added. The strong reference will then need to be removed manually
/// again.
///
/// Accessing and inserting to an InstanceManager is thread safe.
public class $instanceManagerClassName {
  // Identifiers are locked to a specific range to avoid collisions with objects
  // created simultaneously from Dart.
  // Host uses identifiers >= 2^16 and Dart is expected to use values n where,
  // 0 <= n < 2^16.
  private static let minHostCreatedIdentifier: Int64 = 65536

  private let lockQueue = DispatchQueue(label: "$instanceManagerClassName")
  private let identifiers: NSMapTable<AnyObject, NSNumber> = NSMapTable(
    keyOptions: [.weakMemory, .objectPointerPersonality], valueOptions: .strongMemory)
  private let weakInstances: NSMapTable<NSNumber, AnyObject> = NSMapTable(
    keyOptions: .strongMemory, valueOptions: [.weakMemory, .objectPointerPersonality])
  private let strongInstances: NSMapTable<NSNumber, AnyObject> = NSMapTable(
    keyOptions: .strongMemory, valueOptions: [.strongMemory, .objectPointerPersonality])
  private let finalizerDelegate: $instanceManagerFinalizerDelegateName
  private var nextIdentifier: Int64 = minHostCreatedIdentifier

  public init(finalizerDelegate: $instanceManagerFinalizerDelegateName) {
    self.finalizerDelegate = finalizerDelegate
  }

  /// Adds a new instance that was instantiated from Dart.
  ///
  /// The same instance can be added multiple times, but each identifier must be unique. This allows
  /// two objects that are equivalent (e.g. conforms to `Equatable`)  to both be added.
  ///
  /// - Parameters:
  ///   - instance: the instance to be stored
  ///   - identifier: the identifier to be paired with instance. This value must be >= 0 and unique
  func addDartCreatedInstance(_ instance: AnyObject, withIdentifier identifier: Int64) {
    lockQueue.async {
      self.addInstance(instance, withIdentifier: identifier)
    }
  }

  /// Adds a new instance that was instantiated from the host platform.
  ///
  /// - Parameters:
  ///   - instance: the instance to be stored. This must be unique to all other added instances.
  /// - Returns: the unique identifier (>= 0) stored with instance
  func addHostCreatedInstance(_ instance: AnyObject) -> Int64 {
    assert(!containsInstance(instance), "Instance of \\(instance) has already been added.")
    var identifier: Int64 = -1
    lockQueue.sync {
      identifier = nextIdentifier
      nextIdentifier += 1
      self.addInstance(instance, withIdentifier: identifier)
    }
    return identifier
  }

  /// Removes `instanceIdentifier` and its associated strongly referenced instance, if present, from the manager.
  ///
  /// - Parameters:
  ///   - instanceIdentifier: the identifier paired to an instance.
  /// - Returns: removed instance if the manager contains the given identifier, otherwise `nil` if
  ///   the manager doesn't contain the value
  func removeInstance<T: AnyObject>(withIdentifier instanceIdentifier: Int64) -> T? {
    var instance: AnyObject? = nil
    lockQueue.sync {
      instance = strongInstances.object(forKey: NSNumber(value: instanceIdentifier))
      strongInstances.removeObject(forKey: NSNumber(value: instanceIdentifier))
    }
    return instance as? T
  }

  /// Retrieves the instance associated with identifier.
  ///
  /// - Parameters:
  ///   - instanceIdentifier: the identifier associated with an instance
  /// - Returns: the instance associated with `instanceIdentifier` if the manager contains the value, otherwise
  ///   `nil` if the manager doesn't contain the value
  func instance<T: AnyObject>(forIdentifier instanceIdentifier: Int64) -> T? {
    var instance: AnyObject? = nil
    lockQueue.sync {
      instance = weakInstances.object(forKey: NSNumber(value: instanceIdentifier))
    }
    return instance as? T
  }

  private func addInstance(_ instance: AnyObject, withIdentifier identifier: Int64) {
    assert(identifier >= 0)
    assert(
      weakInstances.object(forKey: identifier as NSNumber) == nil,
      "Identifier has already been added: \\(identifier)")
    identifiers.setObject(NSNumber(value: identifier), forKey: instance)
    weakInstances.setObject(instance, forKey: NSNumber(value: identifier))
    strongInstances.setObject(instance, forKey: NSNumber(value: identifier))
    $_instanceManagerFinalizerName.attach(to: instance, identifier: identifier, delegate: finalizerDelegate)
  }

  /// Retrieves the identifier paired with an instance.
  ///
  /// If the manager contains a strong reference to `instance`, it will return the identifier
  /// associated with `instance`. If the manager contains only a weak reference to `instance`, a new
  /// strong reference to `instance` will be added and will need to be removed again with `removeInstance`.
  ///
  /// If this method returns a nonnull identifier, this method also expects the Dart
  /// `$instanceManagerClassName` to have, or recreate, a weak reference to the Dart instance the
  /// identifier is associated with.
  ///
  /// - Parameters:
  ///   - instance: an instance that may be stored in the manager
  /// - Returns: the identifier associated with `instance` if the manager contains the value, otherwise
  ///   `nil` if the manager doesn't contain the value
  func identifierWithStrongReference(forInstance instance: AnyObject) -> Int64? {
    var identifier: Int64? = nil
    lockQueue.sync {
      if let existingIdentifier = identifiers.object(forKey: instance)?.int64Value {
        strongInstances.setObject(instance, forKey: NSNumber(value: existingIdentifier))
        identifier = existingIdentifier
      }
    }
    return identifier
  }

  /// Whether this manager contains the given `instance`.
  ///
  /// - Parameters:
  ///   - instance: the instance whose presence in this manager is to be tested
  /// - Returns: whether this manager contains the given `instance`
  func containsInstance(_ instance: AnyObject) -> Bool {
    var containsInstance = false
    lockQueue.sync {
      containsInstance = identifiers.object(forKey: instance) != nil
    }
    return containsInstance
  }

  /// Removes all of the instances from this manager.
  ///
  /// The manager will be empty after this call returns.
  func removeAllObjects() {
    lockQueue.sync {
      identifiers.removeAllObjects()
      weakInstances.removeAllObjects()
      strongInstances.removeAllObjects()
      nextIdentifier = $instanceManagerClassName.minHostCreatedIdentifier
    }
  }

  /// The number of instances stored as a strong reference.
  ///
  /// For debugging and testing purposes.
  internal var strongInstanceCount: Int {
    var count: Int = 0
    lockQueue.sync {
      count = strongInstances.count
    }
    return count
  }

  /// The number of instances stored as a weak reference.
  ///
  /// For debugging and testing purposes. NSMapTables that store keys or objects as weak
  /// reference will be reclaimed non-deterministically.
  internal var weakInstanceCount: Int {
    var count: Int = 0
    lockQueue.sync {
      count = weakInstances.count
    }
    return count
  }
}
''';

/// Creates the `InstanceManagerApi` with the passed string values.
String instanceManagerApiTemplate({required String dartPackageName}) {
  final String removeStrongReferenceName = makeChannelNameWithStrings(
    apiName: _instanceManagerApiName,
    methodName: 'removeStrongReference',
    dartPackageName: dartPackageName,
  );
  final String clearName = makeChannelNameWithStrings(
    apiName: _instanceManagerApiName,
    methodName: 'clear',
    dartPackageName: dartPackageName,
  );
  return '''
private class $_instanceManagerApiName {
  /// The codec used for serializing messages.
  static let codec = FlutterStandardMessageCodec.sharedInstance()

  /// Handles sending and receiving messages with Dart.
  unowned let binaryMessenger: FlutterBinaryMessenger

  init(binaryMessenger: FlutterBinaryMessenger) {
    self.binaryMessenger = binaryMessenger
  }

  /// Sets up an instance of `$_instanceManagerApiName` to handle messages through the `binaryMessenger`.
  static func setUpMessageHandlers(
    binaryMessenger: FlutterBinaryMessenger, instanceManager: $instanceManagerClassName?
  ) {
    let removeStrongReferenceChannel = FlutterBasicMessageChannel(
      name:
        "$removeStrongReferenceName",
      binaryMessenger: binaryMessenger, codec: codec)
    if let instanceManager = instanceManager {
      removeStrongReferenceChannel.setMessageHandler { message, reply in
        let identifier = message is Int64 ? message as! Int64 : Int64(message as! Int32)
        let _: AnyObject? = instanceManager.removeInstance(withIdentifier: identifier)
        reply(wrapResult(nil))
      }
    } else {
      removeStrongReferenceChannel.setMessageHandler(nil)
    }
    let clearChannel = FlutterBasicMessageChannel(
      name: "$clearName",
      binaryMessenger: binaryMessenger, codec: codec)
    if let instanceManager = instanceManager {
      clearChannel.setMessageHandler { _, reply in
        instanceManager.removeAllObjects()
        reply(wrapResult(nil))
      }
    } else {
      clearChannel.setMessageHandler(nil)
    }
  }

  /// Send a messaage to the Dart `InstanceManager` to remove the strong reference of the instance associated with `identifier`.
  func removeStrongReference(
    withIdentifier identifier: Int64, completion: @escaping (Result<Void, FlutterError>) -> Void
  ) {
    let channelName: String =
      "$removeStrongReferenceName"
    let channel = FlutterBasicMessageChannel(
      name: channelName, binaryMessenger: binaryMessenger, codec: $_instanceManagerApiName.codec)
    channel.sendMessage(identifier) { response in
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
}
''';
}

/// Creates the Swift `ReaderWriter` for handling ProxyApis.
String proxyApiReaderWriterTemplate({
  required Iterable<AstProxyApi> allProxyApis,
}) {
  final String classChecker = allProxyApis.map<String>((AstProxyApi api) {
    final String className = api.swiftOptions?.name ?? api.name;
    String versionCheck = '';
    if (api.swiftOptions?.minIosApi != null) {
      versionCheck = '#available(iOS ${api.swiftOptions!.minIosApi!}, *), ';
    }
    return '''
      if ${versionCheck}value is $className {
        pigeonRegistrar.apiDelegate.pigeonApi${api.name}(pigeonRegistrar).pigeonNewInstance(
          pigeonInstance: value as! $className
        ) { _ in }
      }
    ''';
  }).join(' else ');

  return '''
private class $proxyApiReaderWriterName: FlutterStandardReaderWriter {
  unowned let pigeonRegistrar: $proxyApiRegistrarName
  
  private class ${classNamePrefix}ProxyApiCodecReader: FlutterStandardReader {
    unowned let pigeonRegistrar: $proxyApiRegistrarName

    init(data: Data, pigeonRegistrar: $proxyApiRegistrarName) {
      self.pigeonRegistrar = pigeonRegistrar
      super.init(data: data)
    }

    override func readValue(ofType type: UInt8) -> Any? {
      switch type {
      case 128:
        let identifier = self.readValue()
        let instance: AnyObject? = pigeonRegistrar.instanceManager.instance(
          forIdentifier: identifier is Int64 ? identifier as! Int64 : Int64(identifier as! Int32))
        return instance
      default:
        return super.readValue(ofType: type)
      }
    }
  }
  
  private class ${classNamePrefix}ProxyApiCodecWriter: FlutterStandardWriter {
    unowned let pigeonRegistrar: $proxyApiRegistrarName

    init(data: NSMutableData, pigeonRegistrar: $proxyApiRegistrarName) {
      self.pigeonRegistrar = pigeonRegistrar
      super.init(data: data)
    }

    override func writeValue(_ value: Any) {
      $classChecker

      if let instance = value as? AnyClass, pigeonRegistrar.instanceManager.containsInstance(instance)
      {
        super.writeByte(128)
        super.writeValue(
          pigeonRegistrar.instanceManager.identifierWithStrongReference(forInstance: instance)!)
      } else {
        super.writeValue(value)
      }
    }
  }

  init(pigeonRegistrar: $proxyApiRegistrarName) {
    self.pigeonRegistrar = pigeonRegistrar
  }

  override func reader(with data: Data) -> FlutterStandardReader {
    return PigeonProxyApiCodecReader(data: data, pigeonRegistrar: pigeonRegistrar)
  }

  override func writer(with data: NSMutableData) -> FlutterStandardWriter {
    return PigeonProxyApiCodecWriter(data: data, pigeonRegistrar: pigeonRegistrar)
  }
}  
''';
}

const String _instanceManagerApiName = '${instanceManagerClassName}Api';

const String _instanceManagerFinalizerName = '${classNamePrefix}Finalizer';
