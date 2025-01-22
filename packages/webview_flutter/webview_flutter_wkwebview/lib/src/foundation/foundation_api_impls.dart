// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../common/instance_manager.dart';
import '../common/web_kit.g.dart';
import 'foundation.dart';

export '../common/web_kit.g.dart'
    show NSUrlCredentialPersistence, NSUrlSessionAuthChallengeDisposition;

Iterable<NSKeyValueObservingOptionsEnumData>
    _toNSKeyValueObservingOptionsEnumData(
  Iterable<NSKeyValueObservingOptions> options,
) {
  return options.map<NSKeyValueObservingOptionsEnumData>((
    NSKeyValueObservingOptions option,
  ) {
    late final NSKeyValueObservingOptionsEnum? value;
    switch (option) {
      case NSKeyValueObservingOptions.newValue:
        value = NSKeyValueObservingOptionsEnum.newValue;
      case NSKeyValueObservingOptions.oldValue:
        value = NSKeyValueObservingOptionsEnum.oldValue;
      case NSKeyValueObservingOptions.initialValue:
        value = NSKeyValueObservingOptionsEnum.initialValue;
      case NSKeyValueObservingOptions.priorNotification:
        value = NSKeyValueObservingOptionsEnum.priorNotification;
    }

    return NSKeyValueObservingOptionsEnumData(value: value);
  });
}

extension _NSKeyValueChangeKeyEnumDataConverter on NSKeyValueChangeKeyEnumData {
  NSKeyValueChangeKey toNSKeyValueChangeKey() {
    return NSKeyValueChangeKey.values.firstWhere(
      (NSKeyValueChangeKey element) => element.name == value.name,
    );
  }
}

/// Handles initialization of Flutter APIs for the Foundation library.
class FoundationFlutterApis {
  /// Constructs a [FoundationFlutterApis].
  @visibleForTesting
  FoundationFlutterApis({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  })  : _binaryMessenger = binaryMessenger,
        object = NSObjectFlutterApiImpl(instanceManager: instanceManager),
        url = NSUrlFlutterApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
        urlProtectionSpace = NSUrlProtectionSpaceFlutterApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
        urlAuthenticationChallenge = NSUrlAuthenticationChallengeFlutterApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        );

  static FoundationFlutterApis _instance = FoundationFlutterApis();

  /// Sets the global instance containing the Flutter Apis for the Foundation library.
  @visibleForTesting
  static set instance(FoundationFlutterApis instance) {
    _instance = instance;
  }

  /// Global instance containing the Flutter Apis for the Foundation library.
  static FoundationFlutterApis get instance {
    return _instance;
  }

  final BinaryMessenger? _binaryMessenger;
  bool _hasBeenSetUp = false;

  /// Flutter Api for [NSObject].
  @visibleForTesting
  final NSObjectFlutterApiImpl object;

  /// Flutter Api for [NSUrl].
  @visibleForTesting
  final NSUrlFlutterApiImpl url;

  /// Flutter Api for [NSUrlProtectionSpace].
  @visibleForTesting
  final NSUrlProtectionSpaceFlutterApiImpl urlProtectionSpace;

  /// Flutter Api for [NSUrlAuthenticationChallenge].
  @visibleForTesting
  final NSUrlAuthenticationChallengeFlutterApiImpl urlAuthenticationChallenge;

  /// Ensures all the Flutter APIs have been set up to receive calls from native code.
  void ensureSetUp() {
    if (!_hasBeenSetUp) {
      NSObjectFlutterApi.setUp(
        object,
        binaryMessenger: _binaryMessenger,
      );
      NSUrlFlutterApi.setUp(url, binaryMessenger: _binaryMessenger);
      NSUrlProtectionSpaceFlutterApi.setUp(
        urlProtectionSpace,
        binaryMessenger: _binaryMessenger,
      );
      NSUrlAuthenticationChallengeFlutterApi.setUp(
        urlAuthenticationChallenge,
        binaryMessenger: _binaryMessenger,
      );
      _hasBeenSetUp = true;
    }
  }
}

/// Host api implementation for [NSObject].
class NSObjectHostApiImpl extends NSObjectHostApi {
  /// Constructs an [NSObjectHostApiImpl].
  NSObjectHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? NSObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  /// Sends binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with Objective-C objects.
  final InstanceManager instanceManager;

  /// Calls [addObserver] with the ids of the provided object instances.
  Future<void> addObserverForInstances(
    NSObject instance,
    NSObject observer,
    String keyPath,
    Set<NSKeyValueObservingOptions> options,
  ) {
    return addObserver(
      instanceManager.getIdentifier(instance)!,
      instanceManager.getIdentifier(observer)!,
      keyPath,
      _toNSKeyValueObservingOptionsEnumData(options).toList(),
    );
  }

  /// Calls [removeObserver] with the ids of the provided object instances.
  Future<void> removeObserverForInstances(
    NSObject instance,
    NSObject observer,
    String keyPath,
  ) {
    return removeObserver(
      instanceManager.getIdentifier(instance)!,
      instanceManager.getIdentifier(observer)!,
      keyPath,
    );
  }
}

/// Flutter api implementation for [NSObject].
class NSObjectFlutterApiImpl extends NSObjectFlutterApi {
  /// Constructs a [NSObjectFlutterApiImpl].
  NSObjectFlutterApiImpl({InstanceManager? instanceManager})
      : instanceManager = instanceManager ?? NSObject.globalInstanceManager;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager instanceManager;

  NSObject _getObject(int identifier) {
    return instanceManager.getInstanceWithWeakReference(identifier)!;
  }

  @override
  void observeValue(
    int identifier,
    String keyPath,
    int objectIdentifier,
    List<NSKeyValueChangeKeyEnumData?> changeKeys,
    List<ObjectOrIdentifier?> changeValues,
  ) {
    final void Function(String, NSObject, Map<NSKeyValueChangeKey, Object?>)?
        function = _getObject(identifier).observeValue;
    function?.call(
      keyPath,
      instanceManager.getInstanceWithWeakReference(objectIdentifier)!
          as NSObject,
      Map<NSKeyValueChangeKey, Object?>.fromIterables(
        changeKeys.map<NSKeyValueChangeKey>(
          (NSKeyValueChangeKeyEnumData? data) {
            return data!.toNSKeyValueChangeKey();
          },
        ),
        changeValues.map<Object?>((ObjectOrIdentifier? value) {
          if (value != null && value.isIdentifier) {
            return instanceManager.getInstanceWithWeakReference(
              value.value! as int,
            );
          }
          return value?.value;
        }),
      ),
    );
  }

  @override
  void dispose(int identifier) {
    instanceManager.remove(identifier);
  }
}

/// Host api implementation for [NSUrl].
class NSUrlHostApiImpl extends NSUrlHostApi {
  /// Constructs an [NSUrlHostApiImpl].
  NSUrlHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? NSObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  /// Sends binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with Objective-C objects.
  final InstanceManager instanceManager;

  /// Calls [getAbsoluteString] with the ids of the provided object instances.
  Future<String?> getAbsoluteStringFromInstances(NSUrl instance) {
    return getAbsoluteString(instanceManager.getIdentifier(instance)!);
  }
}

/// Flutter API implementation for [NSUrl].
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
class NSUrlFlutterApiImpl implements NSUrlFlutterApi {
  /// Constructs a [NSUrlFlutterApiImpl].
  NSUrlFlutterApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  }) : instanceManager = instanceManager ?? NSObject.globalInstanceManager;

  /// Receives binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager instanceManager;

  @override
  void create(int identifier) {
    instanceManager.addHostCreatedInstance(
      NSUrl.detached(
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
      identifier,
    );
  }
}

/// Host api implementation for [NSUrlCredential].
class NSUrlCredentialHostApiImpl extends NSUrlCredentialHostApi {
  /// Constructs an [NSUrlCredentialHostApiImpl].
  NSUrlCredentialHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? NSObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  /// Sends binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with Objective-C objects.
  final InstanceManager instanceManager;

  /// Calls [createWithUser] with the ids of the provided object instances.
  Future<void> createWithUserFromInstances(
    NSUrlCredential instance,
    String user,
    String password,
    NSUrlCredentialPersistence persistence,
  ) {
    return createWithUser(
      instanceManager.addDartCreatedInstance(instance),
      user,
      password,
      persistence,
    );
  }
}

/// Flutter API implementation for [NSUrlProtectionSpace].
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
@protected
class NSUrlProtectionSpaceFlutterApiImpl
    implements NSUrlProtectionSpaceFlutterApi {
  /// Constructs a [NSUrlProtectionSpaceFlutterApiImpl].
  NSUrlProtectionSpaceFlutterApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  }) : instanceManager = instanceManager ?? NSObject.globalInstanceManager;

  /// Receives binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager instanceManager;

  @override
  void create(
    int identifier,
    String? host,
    String? realm,
    String? authenticationMethod,
  ) {
    instanceManager.addHostCreatedInstance(
      NSUrlProtectionSpace.detached(
        host: host,
        realm: realm,
        authenticationMethod: authenticationMethod,
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
      identifier,
    );
  }
}

/// Flutter API implementation for [NSUrlAuthenticationChallenge].
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
@protected
class NSUrlAuthenticationChallengeFlutterApiImpl
    implements NSUrlAuthenticationChallengeFlutterApi {
  /// Constructs a [NSUrlAuthenticationChallengeFlutterApiImpl].
  NSUrlAuthenticationChallengeFlutterApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  }) : instanceManager = instanceManager ?? NSObject.globalInstanceManager;

  /// Receives binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager instanceManager;

  @override
  void create(
    int identifier,
    int protectionSpaceIdentifier,
  ) {
    instanceManager.addHostCreatedInstance(
      NSUrlAuthenticationChallenge.detached(
        protectionSpace: instanceManager.getInstanceWithWeakReference(
          protectionSpaceIdentifier,
        )!,
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
      identifier,
    );
  }
}
