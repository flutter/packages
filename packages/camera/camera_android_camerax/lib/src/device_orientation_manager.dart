// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart'
    show DeviceOrientationChangedEvent;
import 'package:flutter/services.dart';

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';

// Ignoring lint indicating this class only contains static members
// as this class is a wrapper for various Android system services.
// ignore_for_file: avoid_classes_with_only_static_members

/// Utility class that offers access to Android system services needed for
/// camera usage and other informational streams.
class DeviceOrientationManager {
  /// Stream that emits the device orientation whenever it is changed.
  ///
  /// Values may start being added to the stream once
  /// `startListeningForDeviceOrientationChange(...)` is called.
  static final StreamController<DeviceOrientationChangedEvent>
      deviceOrientationChangedStreamController =
      StreamController<DeviceOrientationChangedEvent>.broadcast();

  /// Requests that [deviceOrientationChangedStreamController] start
  /// emitting values for any change in device orientation.
  static void startListeningForDeviceOrientationChange(
      bool isFrontFacing, int sensorOrientation,
      {BinaryMessenger? binaryMessenger}) {
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
    final DeviceOrientationManagerHostApi api =
        DeviceOrientationManagerHostApi(binaryMessenger: binaryMessenger);

    api.startListeningForDeviceOrientationChange(
        isFrontFacing, sensorOrientation);
  }

  /// Stops the [deviceOrientationChangedStreamController] from emitting values
  /// for changes in device orientation.
  static void stopListeningForDeviceOrientationChange(
      {BinaryMessenger? binaryMessenger}) {
    final DeviceOrientationManagerHostApi api =
        DeviceOrientationManagerHostApi(binaryMessenger: binaryMessenger);

    api.stopListeningForDeviceOrientationChange();
  }

  /// Retrieves the default rotation that CameraX uses for [UseCase]s in terms
  /// of one of the [Surface] rotation constants.
  ///
  /// The default rotation that CameraX uses is the rotation of the default
  /// display at the time of binding a particular [UseCase], but the default
  /// display does not change in the plugin, so this default value is
  /// display-agnostic.
  ///
  /// [startListeningForDeviceOrientationChange] must be called before calling
  /// this method.
  static Future<int> getDefaultDisplayRotation(
      {BinaryMessenger? binaryMessenger}) async {
    final DeviceOrientationManagerHostApi api =
        DeviceOrientationManagerHostApi(binaryMessenger: binaryMessenger);

    return api.getDefaultDisplayRotation();
  }

  /// Retrieves the current UI orientation based on the current device
  /// orientation and screen rotation.
  static Future<DeviceOrientation> getUiOrientation(
      {BinaryMessenger? binaryMessenger}) async {
    final DeviceOrientationManagerHostApi api =
        DeviceOrientationManagerHostApi(binaryMessenger: binaryMessenger);

    return deserializeDeviceOrientation(await api.getUiOrientation());
  }

  /// Serializes [DeviceOrientation] into a [String].
  static String serializeDeviceOrientation(DeviceOrientation orientation) {
    switch (orientation) {
      case DeviceOrientation.landscapeLeft:
        return 'LANDSCAPE_LEFT';
      case DeviceOrientation.landscapeRight:
        return 'LANDSCAPE_RIGHT';
      case DeviceOrientation.portraitDown:
        return 'PORTRAIT_DOWN';
      case DeviceOrientation.portraitUp:
        return 'PORTRAIT_UP';
    }
  }

  /// Deserializes device orientation in [String] format into a
  /// [DeviceOrientation].
  static DeviceOrientation deserializeDeviceOrientation(String orientation) {
    switch (orientation) {
      case 'LANDSCAPE_LEFT':
        return DeviceOrientation.landscapeLeft;
      case 'LANDSCAPE_RIGHT':
        return DeviceOrientation.landscapeRight;
      case 'PORTRAIT_DOWN':
        return DeviceOrientation.portraitDown;
      case 'PORTRAIT_UP':
        return DeviceOrientation.portraitUp;
      default:
        throw ArgumentError(
            '"$orientation" is not a valid DeviceOrientation value');
    }
  }
}

/// Flutter API implementation of [DeviceOrientationManager].
class DeviceOrientationManagerFlutterApiImpl
    implements DeviceOrientationManagerFlutterApi {
  /// Constructs an [DeviceOrientationManagerFlutterApiImpl].
  DeviceOrientationManagerFlutterApiImpl();

  /// Callback method for any changes in device orientation.
  ///
  /// Will only be called if
  /// `DeviceOrientationManager.startListeningForDeviceOrientationChange(...)` was called
  /// to start listening for device orientation updates.
  @override
  void onDeviceOrientationChanged(String orientation) {
    final DeviceOrientation deviceOrientation =
        DeviceOrientationManager.deserializeDeviceOrientation(orientation);
    DeviceOrientationManager.deviceOrientationChangedStreamController
        .add(DeviceOrientationChangedEvent(deviceOrientation));
  }
}
