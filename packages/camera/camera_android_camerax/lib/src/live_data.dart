import 'package:simple_ast/annotations.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'observer.dart';
import 'java_object.dart';
import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';

class LiveData<T> extends JavaObject {
  LiveData.detached({this.binaryMessenger, this.instanceManager})
      : _api = _LiveDataHostApiImpl(
            binaryMessenger: binaryMessenger, instanceManager: instanceManager),
        super.detached(
            binaryMessenger: binaryMessenger, instanceManager: instanceManager);

  final _LiveDataHostApiImpl _api;

  final BinaryMessenger? binaryMessenger;
  final InstanceManager? instanceManager;

  Future<void> observe(Observer<T> observer) {
    return _api.observeFromInstances(this, observer);
  }

  Future<void> removeObservers() {
    return _api.removeObserversFromInstances(this);
  }

  // @protected
  LiveData<S> cast<S>() {
    final LiveData<S> newInstance = LiveData<S>.detached(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    _api.castFromInstances(this, newInstance);
    return newInstance;
  }
}

class _LiveDataHostApiImpl extends LiveDataHostApi {
  _LiveDataHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? JavaObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  final BinaryMessenger? binaryMessenger;

  final InstanceManager instanceManager;

  Future<void> observeFromInstances(
    LiveData instance,
    Observer observer,
  ) {
    return observe(
      instanceManager.getIdentifier(instance)!,
      instanceManager.getIdentifier(observer)!,
    );
  }

  Future<void> removeObserversFromInstances(
    LiveData instance,
  ) {
    return removeObservers(
      instanceManager.getIdentifier(instance)!,
    );
  }

  Future<void> castFromInstances<T, S>(
      LiveData<T> instance, LiveData<S> newInstance) {
    return cast(
        instanceManager.getIdentifier(instance)!,
        instanceManager.addDartCreatedInstance(newInstance,
            onCopy: (LiveData original) => LiveData.detached(
                  binaryMessenger: binaryMessenger,
                  instanceManager: instanceManager,
                )));
  }
}

/// Flutter API implementation for [LiveData].
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
@protected
class LiveDataFlutterApiImpl implements LiveDataFlutterApi {
  /// Constructs a [LiveDataFlutterApiImpl].
  LiveDataFlutterApiImpl({
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
  void create(
    int identifier,
  ) {
    instanceManager.addHostCreatedInstance(
      LiveData.detached(
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
      identifier,
      onCopy: (LiveData original) => LiveData.detached(
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
    );
  }
}
