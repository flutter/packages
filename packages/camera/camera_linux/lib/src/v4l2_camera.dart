// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:ffi/ffi.dart';

import 'bindings.dart' as bindings;

/// A V4L2 video capture device that [V4l2Camera.open] can stream from.
class V4l2Device {
  /// Creates a device description.
  const V4l2Device({required this.path, required this.name, required this.pixelFormat});

  /// Device node, such as `/dev/video0`.
  final String path;

  /// The driver's card name, such as `Depstech webcam`.
  final String name;

  /// FourCC of the pixel format that would be used, such as `YUYV` or `MJPG`.
  final String pixelFormat;

  @override
  String toString() => '$path ($name, $pixelFormat)';
}

/// An open capture device that hands out JPEG frames.
///
/// This is the seam between [V4l2Camera], which is backed by the native
/// library, and the fakes used in unit tests.
abstract interface class CaptureSession {
  /// Path of the device node in use.
  String get devicePath;

  /// Negotiated frame width in pixels.
  int get width;

  /// Negotiated frame height in pixels.
  int get height;

  /// Returns the newest frame as JPEG bytes, or null when no frame has arrived
  /// since the previous call. Throws a [CameraException] when the capture has
  /// failed, for example because the camera was unplugged, or a frame could
  /// not be converted.
  Uint8List? readJpeg();

  /// Stops capturing and releases the device. Safe to call more than once.
  void close();
}

/// Streams frames from a V4L2 webcam through the native library built by
/// `hook/build.dart`.
class V4l2Camera implements CaptureSession, Finalizable {
  V4l2Camera._(this._session, this.devicePath, this.width, this.height) {
    _finalizer.attach(this, _session, detach: this);
  }

  /// Opens [devicePath], or the first usable device when it is null (the
  /// `CAMERA_LINUX_DEVICE` environment variable takes precedence), requesting
  /// [width] by [height]. The driver may pick another size; see [width] and
  /// [height] on the result. Throws a [CameraException] when no camera can be
  /// opened.
  static V4l2Camera open({
    String? devicePath,
    int width = 640,
    int height = 480,
    int jpegQuality = 85,
  }) {
    final Pointer<Utf8> device = devicePath == null ? nullptr : devicePath.toNativeUtf8();
    final Pointer<Pointer<Utf8>> error = calloc<Pointer<Utf8>>();
    try {
      final Pointer<Void> session = bindings.cameraLinuxOpen(
        device,
        width,
        height,
        jpegQuality,
        error,
      );
      if (session == nullptr) {
        throw CameraException('camera_error', _takeString(error.value) ?? 'failed to open camera');
      }
      final Pointer<Int32> w = calloc<Int32>();
      final Pointer<Int32> h = calloc<Int32>();
      try {
        bindings.cameraLinuxFrameSize(session, w, h);
        final String path = _takeString(bindings.cameraLinuxDevicePath(session)) ?? '';
        return V4l2Camera._(session, path, w.value, h.value);
      } finally {
        calloc.free(w);
        calloc.free(h);
      }
    } finally {
      if (device != nullptr) {
        malloc.free(device);
      }
      calloc.free(error);
    }
  }

  /// Lists the devices [open] can use, in the order it would try them.
  static List<V4l2Device> availableDevices() {
    final String? text = _takeString(bindings.cameraLinuxListDevices());
    if (text == null) {
      return const <V4l2Device>[];
    }
    return <V4l2Device>[
      for (final String line in const LineSplitter().convert(text))
        if (line.split('\t') case [final String path, final String name, final String fourcc])
          V4l2Device(path: path, name: name, pixelFormat: fourcc),
    ];
  }

  static final NativeFinalizer _finalizer = NativeFinalizer(
    Native.addressOf<NativeFunction<Void Function(Pointer<Void>)>>(
      bindings.cameraLinuxClose,
    ).cast(),
  );

  Pointer<Void> _session;

  @override
  final String devicePath;

  @override
  final int width;

  @override
  final int height;

  /// Whether the device is open and its capture thread is running.
  bool get isRunning =>
      _session != nullptr && bindings.cameraLinuxStatus(_session) == bindings.cameraLinuxRunning;

  @override
  Uint8List? readJpeg() {
    if (_session == nullptr) {
      throw CameraException('camera_error', 'camera is closed');
    }
    final Pointer<Int32> length = calloc<Int32>();
    try {
      final Pointer<Uint8> ptr = bindings.cameraLinuxReadJpeg(_session, length);
      if (ptr == nullptr) {
        // A frame that could not be converted, or a capture thread that
        // died, leaves an error behind; no frame yet leaves none.
        final String? error = _takeString(bindings.cameraLinuxTakeError(_session));
        if (error != null) {
          throw CameraException('camera_error', error);
        }
        if (bindings.cameraLinuxStatus(_session) == bindings.cameraLinuxFailed) {
          throw CameraException('camera_error', 'capture stopped');
        }
        return null;
      }
      try {
        return Uint8List.fromList(ptr.asTypedList(length.value));
      } finally {
        bindings.cameraLinuxFree(ptr.cast());
      }
    } finally {
      calloc.free(length);
    }
  }

  @override
  void close() {
    if (_session == nullptr) {
      return;
    }
    _finalizer.detach(this);
    bindings.cameraLinuxClose(_session);
    _session = nullptr;
  }

  /// Copies a malloc()ed string from the native side and frees it.
  static String? _takeString(Pointer<Utf8> ptr) {
    if (ptr == nullptr) {
      return null;
    }
    try {
      return ptr.toDartString();
    } finally {
      bindings.cameraLinuxFree(ptr.cast());
    }
  }
}
