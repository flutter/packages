// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show WidgetsFlutterBinding;

import 'camerax_library.g.dart';
import 'instance_manager.dart';

/// Root of the Java class hierarchy.
///
/// See https://docs.oracle.com/javase/8/docs/api/java/lang/Object.html.
@immutable
class JavaObject {
  /// Constructs a [JavaObject] without creating the associated Java object.
  ///
  /// This should only be used by subclasses created by this library or to
  /// create copies.
  JavaObject.detached({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  }) : _api = JavaObjectHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        );

  /// Global instance of [InstanceManager].
  static final InstanceManager globalInstanceManager = _initInstanceManager();

  static InstanceManager _initInstanceManager() {
    WidgetsFlutterBinding.ensureInitialized();
    // Clears the native `InstanceManager` on initial use of the Dart one.
    InstanceManagerHostApi().clear();
    return InstanceManager(
      onWeakReferenceRemoved: (int identifier) {
        JavaObjectHostApiImpl().dispose(identifier);
      },
    );
  }

  /// Release the weak reference to the [instance].
  static void dispose(JavaObject instance) {
    instance._api.instanceManager.removeWeakReference(instance);
  }

  // ignore: unused_field
  final JavaObjectHostApiImpl _api;
}

/// Handles methods calls to the native Java Object class.
class JavaObjectHostApiImpl extends JavaObjectHostApi {
  /// Constructs a [JavaObjectHostApiImpl].
  JavaObjectHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? JavaObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  /// Receives binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager instanceManager;
}

/// Handles callbacks methods for the native Java Object class.
class JavaObjectFlutterApiImpl implements JavaObjectFlutterApi {
  /// Constructs a [JavaObjectFlutterApiImpl].
  JavaObjectFlutterApiImpl({InstanceManager? instanceManager})
      : instanceManager = instanceManager ?? JavaObject.globalInstanceManager;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager instanceManager;

  @override
  void dispose(int identifier) {
    instanceManager.remove(identifier);
  }
}
