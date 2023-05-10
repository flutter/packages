// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camera.dart';
import 'camera_info.dart';
import 'camera_selector.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';
import 'use_case.dart';

/// Provides an object to manage the camera.
///
/// See https://developer.android.com/reference/androidx/camera/lifecycle/ProcessCameraProvider.
class ProcessCameraProvider extends JavaObject {
  /// Creates a detached [ProcessCameraProvider].
  ProcessCameraProvider.detached(
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    _api = ProcessCameraProviderHostApiImpl(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  late final ProcessCameraProviderHostApiImpl _api;

  /// Gets an instance of [ProcessCameraProvider].
  static Future<ProcessCameraProvider> getInstance(
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager}) {
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
    final ProcessCameraProviderHostApiImpl api =
        ProcessCameraProviderHostApiImpl(
            binaryMessenger: binaryMessenger, instanceManager: instanceManager);

    return api.getInstancefromInstances();
  }

  /// Retrieves the cameras available to the device.
  Future<List<CameraInfo>> getAvailableCameraInfos() {
    return _api.getAvailableCameraInfosFromInstances(this);
  }

  /// Binds the specified [UseCase]s to the lifecycle of the camera that it
  /// returns.
  Future<Camera> bindToLifecycle(
      CameraSelector cameraSelector, List<UseCase> useCases) {
    return _api.bindToLifecycleFromInstances(this, cameraSelector, useCases);
  }

  /// Returns whether or not the specified [UseCase] has been bound to the
  /// lifecycle of the camera that this instance tracks.
  Future<bool> isBound(UseCase useCase) {
    return _api.isBoundFromInstances(this, useCase);
  }

  /// Unbinds specified [UseCase]s from the lifecycle of the camera that this
  /// instance tracks.
  void unbind(List<UseCase> useCases) {
    _api.unbindFromInstances(this, useCases);
  }

  /// Unbinds all previously bound [UseCase]s from the lifecycle of the camera
  /// that this tracks.
  void unbindAll() {
    _api.unbindAllFromInstances(this);
  }
}

/// Host API implementation of [ProcessCameraProvider].
class ProcessCameraProviderHostApiImpl extends ProcessCameraProviderHostApi {
  /// Constructs an [ProcessCameraProviderHostApiImpl].
  ///
  /// If [binaryMessenger] is null, the default [BinaryMessenger] will be used,
  /// which routes to the host platform.
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created. If left null, it
  /// will default to the global instance defined in [JavaObject].
  ProcessCameraProviderHostApiImpl(
      {this.binaryMessenger, InstanceManager? instanceManager})
      : super(binaryMessenger: binaryMessenger) {
    this.instanceManager = instanceManager ?? JavaObject.globalInstanceManager;
  }

  /// Receives binary data across the Flutter platform barrier.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  late final InstanceManager instanceManager;

  /// Retrieves an instance of a ProcessCameraProvider from the context of
  /// the FlutterActivity.
  Future<ProcessCameraProvider> getInstancefromInstances() async {
    return instanceManager.getInstanceWithWeakReference<ProcessCameraProvider>(
        await getInstance())!;
  }

  /// Gets identifier that the [instanceManager] has set for
  /// the [ProcessCameraProvider] instance.
  int getProcessCameraProviderIdentifier(ProcessCameraProvider instance) {
    final int? identifier = instanceManager.getIdentifier(instance);
    return identifier!;
  }

  /// Retrives the list of CameraInfos corresponding to the available cameras.
  Future<List<CameraInfo>> getAvailableCameraInfosFromInstances(
      ProcessCameraProvider instance) async {
    final int identifier = getProcessCameraProviderIdentifier(instance);
    final List<int?> cameraInfos = await getAvailableCameraInfos(identifier);
    return cameraInfos
        .map<CameraInfo>((int? id) =>
            instanceManager.getInstanceWithWeakReference<CameraInfo>(id!)!)
        .toList();
  }

  /// Binds the specified [UseCase]s to the lifecycle of the camera which
  /// the provided [ProcessCameraProvider] instance tracks.
  ///
  /// The instance of the camera whose lifecycle the [UseCase]s are bound to
  /// is returned.
  Future<Camera> bindToLifecycleFromInstances(
    ProcessCameraProvider instance,
    CameraSelector cameraSelector,
    List<UseCase> useCases,
  ) async {
    final int identifier = getProcessCameraProviderIdentifier(instance);
    final List<int> useCaseIds = useCases
        .map<int>((UseCase useCase) => instanceManager.getIdentifier(useCase)!)
        .toList();

    final int cameraIdentifier = await bindToLifecycle(
      identifier,
      instanceManager.getIdentifier(cameraSelector)!,
      useCaseIds,
    );
    return instanceManager
        .getInstanceWithWeakReference<Camera>(cameraIdentifier)!;
  }

  /// Returns whether or not the specified [UseCase] has been bound to the
  /// lifecycle of the camera that this instance tracks.
  Future<bool> isBoundFromInstances(
    ProcessCameraProvider instance,
    UseCase useCase,
  ) async {
    final int identifier = getProcessCameraProviderIdentifier(instance);
    final int? useCaseId = instanceManager.getIdentifier(useCase);

    assert(useCaseId != null,
        'UseCase must have been created in order for this check to be valid.');

    final bool useCaseIsBound = await isBound(identifier, useCaseId!);
    return useCaseIsBound;
  }

  /// Unbinds specified [UseCase]s from the lifecycle of the camera which the
  /// provided [ProcessCameraProvider] instance tracks.
  void unbindFromInstances(
    ProcessCameraProvider instance,
    List<UseCase> useCases,
  ) {
    final int identifier = getProcessCameraProviderIdentifier(instance);
    final List<int> useCaseIds = useCases
        .map<int>((UseCase useCase) => instanceManager.getIdentifier(useCase)!)
        .toList();

    unbind(identifier, useCaseIds);
  }

  /// Unbinds all previously bound [UseCase]s from the lifecycle of the camera
  /// which the provided [ProcessCameraProvider] instance tracks.
  void unbindAllFromInstances(ProcessCameraProvider instance) {
    final int identifier = getProcessCameraProviderIdentifier(instance);
    unbindAll(identifier);
  }
}

/// Flutter API Implementation of [ProcessCameraProvider].
class ProcessCameraProviderFlutterApiImpl
    implements ProcessCameraProviderFlutterApi {
  /// Constructs an [ProcessCameraProviderFlutterApiImpl].
  ///
  /// If [binaryMessenger] is null, the default [BinaryMessenger] will be used,
  /// which routes to the host platform.
  ///
  /// An [instanceManager] is typically passed when a copy of an instance
  /// contained by an [InstanceManager] is being created. If left null, it
  /// will default to the global instance defined in [JavaObject].
  ProcessCameraProviderFlutterApiImpl({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  })  : _binaryMessenger = binaryMessenger,
        _instanceManager = instanceManager ?? JavaObject.globalInstanceManager;

  /// Receives binary data across the Flutter platform barrier.
  final BinaryMessenger? _binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager _instanceManager;

  @override
  void create(int identifier) {
    _instanceManager.addHostCreatedInstance(
      ProcessCameraProvider.detached(
          binaryMessenger: _binaryMessenger, instanceManager: _instanceManager),
      identifier,
      onCopy: (ProcessCameraProvider original) {
        return ProcessCameraProvider.detached(
            binaryMessenger: _binaryMessenger,
            instanceManager: _instanceManager);
      },
    );
  }
}
