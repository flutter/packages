// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';
import 'live_data.dart';

/// Callback that can receive from [LiveData].
///
/// See https://developer.android.com/reference/androidx/lifecycle/Observer.
class Observer<T> extends JavaObject {
  /// Constructor for [Observer].
  Observer(
      {super.binaryMessenger,
      super.instanceManager,
      required void Function(Object value) onChanged})
      : _api = _ObserverHostApiImpl(
            binaryMessenger: binaryMessenger, instanceManager: instanceManager),
        super.detached() {
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
    this.onChanged = (Object value) {
      assert(value is T);
      onChanged(value);
    };
    _api.createFromInstances(this);
  }

  /// Constructs a [Observer] that is not automatically attached to a native object.
  Observer.detached(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      required void Function(Object value) onChanged})
      : _api = _ObserverHostApiImpl(
            binaryMessenger: binaryMessenger, instanceManager: instanceManager),
        super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    this.onChanged = (Object value) {
      assert(value is T);
      onChanged(value);
    };
  }

  final _ObserverHostApiImpl _api;

  /// Callback used when the observed data is changed to a new value.
  ///
  /// The callback parameter cannot take type [T] directly due to the issue
  /// described in https://github.com/dart-lang/sdk/issues/51461.
  late final void Function(Object value) onChanged;
}

class _ObserverHostApiImpl extends ObserverHostApi {
  _ObserverHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? JavaObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  final BinaryMessenger? binaryMessenger;

  final InstanceManager instanceManager;

  /// Adds specified [Observer] instance to instance manager and makes call
  /// to native side to create the instance.
  Future<void> createFromInstances<T>(
    Observer<T> instance,
  ) {
    return create(
      instanceManager.addDartCreatedInstance(
        instance,
        onCopy: (Observer<T> original) => Observer<T>.detached(
          onChanged: original.onChanged,
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
      ),
    );
  }
}

/// Flutter API implementation for [Observer].
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
@protected
class ObserverFlutterApiImpl implements ObserverFlutterApi {
  /// Constructs a [ObserverFlutterApiImpl].
  ObserverFlutterApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  }) : instanceManager = instanceManager ?? JavaObject.globalInstanceManager;

  /// Receives binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager instanceManager;

  @override
  void onChanged(
    int identifier,
    int valueIdentifier,
  ) {
    final Observer<dynamic> instance =
        instanceManager.getInstanceWithWeakReference(identifier)!;

    // ignore: avoid_dynamic_calls, void_checks
    instance.onChanged(
      instanceManager.getInstanceWithWeakReference<Object>(valueIdentifier)!,
    );
  }
}
