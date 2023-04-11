import 'package:simple_ast/annotations.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'observer.dart';
import 'java_object.dart';
import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';

class CameraStateError<T> extends JavaObject {
  CameraStateError.detached(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      required this.code,
      required this.description})
      : super.detached(
            binaryMessenger: binaryMessenger, instanceManager: instanceManager);

  final int code;

  final String description;
}

/// Flutter API implementation for [CameraStateError].
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
@protected
class CameraStateErrorFlutterApiImpl implements CameraStateErrorFlutterApi {
  /// Constructs a [CameraStateErrorFlutterApiImpl].
  CameraStateErrorFlutterApiImpl({
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
    int code,
    String description,
  ) {
    instanceManager.addHostCreatedInstance(
      CameraStateError.detached(
        code: code,
        description: description,
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
      identifier,
      onCopy: (CameraStateError original) => CameraStateError.detached(
        code: original.code,
        description: original.description,
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
    );
  }
}
