// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'camerax_library.g.dart' as camerax;

export 'camerax_library.g.dart' hide CameraInfo, LiveData, Observer;

/// Handles adding support for generics to the API wrapper.
///
/// APIs wrapped with the pigeon ProxyAPI system doesn't support generics, so
/// this handles using subclasses to add support.
void setUpGenerics({
  BinaryMessenger? pigeonBinaryMessenger,
  camerax.PigeonInstanceManager? pigeonInstanceManager,
}) {
  camerax.LiveData.pigeon_setUpMessageHandlers(
    pigeon_newInstance: (camerax.LiveDataSupportedType type) {
      switch (type) {
        case camerax.LiveDataSupportedType.cameraState:
          return LiveData<camerax.CameraState>.detached(
            type: type,
            pigeon_binaryMessenger: pigeonBinaryMessenger,
            pigeon_instanceManager: pigeonInstanceManager,
          );
        case camerax.LiveDataSupportedType.zoomState:
          return LiveData<camerax.ZoomState>.detached(
            type: type,
            pigeon_binaryMessenger: pigeonBinaryMessenger,
            pigeon_instanceManager: pigeonInstanceManager,
          );
      }
    },
  );

  camerax.CameraInfo.pigeon_setUpMessageHandlers(
    pigeon_newInstance: (
      int sensorRotationDegrees,
      camerax.ExposureState exposureState,
    ) {
      return CameraInfo.detached(
        sensorRotationDegrees: sensorRotationDegrees,
        exposureState: exposureState,
        pigeon_binaryMessenger: pigeonBinaryMessenger,
        pigeon_instanceManager: pigeonInstanceManager,
      );
    },
  );
}

/// Handle onto the raw buffer managed by screen compositor.
///
/// See https://developer.android.com/reference/android/view/Surface.html.
class Surface {
  /// Rotation constant to signify the natural orientation.
  ///
  /// See https://developer.android.com/reference/android/view/Surface.html#ROTATION_0.
  static const int rotation0 = 0;

  /// Rotation constant to signify a 90 degrees rotation.
  ///
  /// See https://developer.android.com/reference/android/view/Surface.html#ROTATION_90.
  static const int rotation90 = 1;

  /// Rotation constant to signify a 180 degrees rotation.
  ///
  /// See https://developer.android.com/reference/android/view/Surface.html#ROTATION_180.
  static const int rotation180 = 2;

  /// Rotation constant to signify a 270 degrees rotation.
  ///
  /// See https://developer.android.com/reference/android/view/Surface.html#ROTATION_270.
  static const int rotation270 = 3;
}

/// An interface for retrieving camera information.
///
/// See https://developer.android.com/reference/androidx/camera/core/CameraInfo.
class CameraInfo extends camerax.CameraInfo {
  /// Constructs [CameraInfo] without creating the associated native object.
  ///
  /// This should only be used by subclasses created by this library or to
  /// create copies for an [PigeonInstanceManager].
  CameraInfo.detached({
    required super.sensorRotationDegrees,
    required super.exposureState,
    // ignore: non_constant_identifier_names
    super.pigeon_binaryMessenger,
    // ignore: non_constant_identifier_names
    super.pigeon_instanceManager,
  }) : super.pigeon_detached();

  @override
  Future<LiveData<camerax.CameraState>> getCameraState() async {
    return (await super.getCameraState()) as LiveData<camerax.CameraState>;
  }

  @override
  Future<LiveData<camerax.ZoomState>> getZoomState() async {
    return (await super.getZoomState()) as LiveData<camerax.ZoomState>;
  }

  @override
  // ignore: non_constant_identifier_names
  CameraInfo pigeon_copy() {
    return CameraInfo.detached(
      sensorRotationDegrees: sensorRotationDegrees,
      exposureState: exposureState,
      pigeon_binaryMessenger: pigeon_binaryMessenger,
      pigeon_instanceManager: pigeon_instanceManager,
    );
  }
}

/// LiveData is a data holder class that can be observed within a given
/// lifecycle.
///
/// This is a wrapper around the native class to better support the generic
/// type. Java has type erasure.
///
/// See https://developer.android.com/reference/androidx/lifecycle/LiveData.
class LiveData<T> extends camerax.LiveData {
  /// Constructs [LiveData] without creating the associated native object.
  ///
  /// This should only be used by subclasses created by this library or to
  /// create copies for an [PigeonInstanceManager].
  @protected
  LiveData.detached({
    required super.type,
    // ignore: non_constant_identifier_names
    super.pigeon_binaryMessenger,
    // ignore: non_constant_identifier_names
    super.pigeon_instanceManager,
  }) : super.pigeon_detached();

  @override
  Future<void> observe(covariant Observer<T> observer) {
    return super.observe(observer);
  }

  @override
  Future<T?> getValue() async {
    return (await super.getValue()) as T?;
  }

  @override
  // ignore: non_constant_identifier_names
  LiveData<T> pigeon_copy() {
    return LiveData<T>.detached(
      type: type,
      pigeon_binaryMessenger: pigeon_binaryMessenger,
      pigeon_instanceManager: pigeon_instanceManager,
    );
  }
}

/// A simple callback that can receive from LiveData.
///
/// See https://developer.android.com/reference/androidx/lifecycle/Observer.
class Observer<T> extends camerax.Observer {
  /// Constructs an [Observer].
  Observer({
    required void Function(Observer<T> instance, T value) onChanged,
    // ignore: non_constant_identifier_names
    super.pigeon_binaryMessenger,
    // ignore: non_constant_identifier_names
    super.pigeon_instanceManager,
  }) : _genericOnChanged = onChanged,
       super(
         onChanged: (camerax.Observer instance, Object value) {
           onChanged(instance as Observer<T>, value as T);
         },
       );

  /// Constructs [Observer] without creating the associated native object.
  ///
  /// This should only be used by subclasses created by this library or to
  /// create copies for an [PigeonInstanceManager].
  Observer.detached({
    required void Function(Observer<T> instance, T value) onChanged,
    // ignore: non_constant_identifier_names
    super.pigeon_binaryMessenger,
    // ignore: non_constant_identifier_names
    super.pigeon_instanceManager,
  }) : _genericOnChanged = onChanged,
       super.pigeon_detached(
         onChanged: (camerax.Observer instance, Object value) {
           onChanged(instance as Observer<T>, value as T);
         },
       );

  final void Function(Observer<T> instance, T value) _genericOnChanged;

  @override
  // ignore: non_constant_identifier_names
  Observer<T> pigeon_copy() {
    return Observer<T>.detached(
      onChanged: _genericOnChanged,
      pigeon_binaryMessenger: pigeon_binaryMessenger,
      pigeon_instanceManager: pigeon_instanceManager,
    );
  }
}
