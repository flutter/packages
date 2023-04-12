import 'package:simple_ast/annotations.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'observer.dart';
import 'java_object.dart';
import 'android_camera_camerax_flutter_api_impls.dart';
import 'camera_state.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';

@SimpleClassAnnotation()
class Observer<T> extends JavaObject {
  Observer(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      required this.onChanged})
      : _api = _ObserverHostApiImpl(
            binaryMessenger: binaryMessenger, instanceManager: instanceManager),
        super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
    _api.createFromInstances(this);
  }

  Observer.detached(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      required this.onChanged})
      : _api = _ObserverHostApiImpl(
            binaryMessenger: binaryMessenger, instanceManager: instanceManager),
        super.detached(
            binaryMessenger: binaryMessenger, instanceManager: instanceManager);

  final _ObserverHostApiImpl _api;

  final void Function(T value) onChanged;
}

// TODO(bparrishMines): Move these classes or desired methods into `observer.dart`

class _ObserverHostApiImpl extends ObserverHostApi {
  _ObserverHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? JavaObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  final BinaryMessenger? binaryMessenger;

  final InstanceManager instanceManager;

  Future<void> createFromInstances(
    Observer instance,
  ) {
    return create(
      instanceManager.addDartCreatedInstance(
        instance,
        onCopy: (Observer original) => Observer.detached(
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
    final dynamic instance =
        instanceManager.getInstanceWithWeakReference(identifier)!;

    // ignore: avoid_dynamic_calls, void_checks
    return instance.onChanged(
      instanceManager.getInstanceWithWeakReference(valueIdentifier)!,
    );
  }
}
