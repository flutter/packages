import 'package:flutter/services.dart';

import 'camerax_library2.g.dart' as camerax;

export 'camerax_library2.g.dart' hide CameraInfo, LiveData, Observer;

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

  camerax.CameraInfo.pigeon_setUpMessageHandlers(pigeon_newInstance: (
    int sensorRotationDegrees,
    camerax.ExposureState exposureState,
  ) {
    return CameraInfo.detached(
      sensorRotationDegrees: sensorRotationDegrees,
      exposureState: exposureState,
      pigeon_binaryMessenger: pigeonBinaryMessenger,
      pigeon_instanceManager: pigeonInstanceManager,
    );
  });
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

class CameraInfo extends camerax.CameraInfo {
  CameraInfo.detached({
    required super.sensorRotationDegrees,
    required super.exposureState,
    super.pigeon_binaryMessenger,
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
  CameraInfo pigeon_copy() {
    return CameraInfo.detached(
      sensorRotationDegrees: sensorRotationDegrees,
      exposureState: exposureState,
      pigeon_binaryMessenger: pigeon_binaryMessenger,
      pigeon_instanceManager: pigeon_instanceManager,
    );
  }
}

class LiveData<T> extends camerax.LiveData {
  LiveData.detached({
    required super.type,
    super.pigeon_binaryMessenger,
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
  LiveData<T> pigeon_copy() {
    return LiveData<T>.detached(
      type: type,
      pigeon_binaryMessenger: pigeon_binaryMessenger,
      pigeon_instanceManager: pigeon_instanceManager,
    );
  }
}

class Observer<T> extends camerax.Observer {
  Observer({
    required void Function(Observer<T> instance, T value) onChanged,
    super.pigeon_binaryMessenger,
    super.pigeon_instanceManager,
  })  : _genericOnChanged = onChanged,
        super(
          onChanged: (
            camerax.Observer instance,
            Object value,
          ) {
            onChanged(instance as Observer<T>, value as T);
          },
        );

  Observer.detached({
    required void Function(Observer<T> instance, T value) onChanged,
    super.pigeon_binaryMessenger,
    super.pigeon_instanceManager,
  })  : _genericOnChanged = onChanged,
        super.pigeon_detached(
          onChanged: (
            camerax.Observer instance,
            Object value,
          ) {
            onChanged(instance as Observer<T>, value as T);
          },
        );

  final void Function(Observer<T> instance, T value) _genericOnChanged;

  @override
  Observer<T> pigeon_copy() {
    return Observer<T>.detached(
      onChanged: _genericOnChanged,
      pigeon_binaryMessenger: pigeon_binaryMessenger,
      pigeon_instanceManager: pigeon_instanceManager,
    );
  }
}
