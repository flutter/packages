import 'camera_state_error.dart';
import 'package:simple_ast/annotations.dart';
import 'package:meta/meta.dart';
import 'package:flutter/services.dart';

import 'observer.dart';
import 'java_object.dart';
import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';

class CameraState extends JavaObject {
  CameraState.detached(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      required this.type,
      this.error})
      : super.detached(
            binaryMessenger: binaryMessenger, instanceManager: instanceManager);

  final CameraStateType type;

  final CameraStateError? error;
}

/// Flutter API implementation for [CameraState].
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
@protected
class CameraStateFlutterApiImpl implements CameraStateFlutterApi {
  /// Constructs a [CameraStateFlutterApiImpl].
  CameraStateFlutterApiImpl({
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
    CameraStateTypeData type,
    int? errorIdentifier,
  ) {
    instanceManager.addHostCreatedInstance(
      CameraState.detached(
        type: type.value,
        error: errorIdentifier == null
            ? null
            : instanceManager.getInstanceWithWeakReference(
                errorIdentifier,
              ),
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
      identifier,
      onCopy: (CameraState original) => CameraState.detached(
        type: original.type,
        error: original.error,
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
    );
  }
}
