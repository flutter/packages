// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// FFI bindings for src/camera_linux.h.
//
// The asset id of this library (package:camera_linux/src/bindings.dart) is
// what hook/build.dart registers libcamera_linux.so under, so the `@Native`
// symbols below resolve without a DynamicLibrary.open().

import 'dart:ffi';

import 'package:ffi/ffi.dart';

/// Value of `CAMERA_LINUX_RUNNING`.
const int cameraLinuxRunning = 1;

/// Value of `CAMERA_LINUX_FAILED`.
const int cameraLinuxFailed = -1;

/// `camera_linux_list_devices`.
@Native<Pointer<Utf8> Function()>(symbol: 'camera_linux_list_devices')
external Pointer<Utf8> cameraLinuxListDevices();

/// `camera_linux_open`.
@Native<Pointer<Void> Function(Pointer<Utf8>, Int32, Int32, Int32, Pointer<Pointer<Utf8>>)>(
  symbol: 'camera_linux_open',
)
external Pointer<Void> cameraLinuxOpen(
  Pointer<Utf8> device,
  int width,
  int height,
  int jpegQuality,
  Pointer<Pointer<Utf8>> error,
);

/// `camera_linux_close`.
@Native<Void Function(Pointer<Void>)>(symbol: 'camera_linux_close')
external void cameraLinuxClose(Pointer<Void> session);

/// `camera_linux_status`.
@Native<Int32 Function(Pointer<Void>)>(symbol: 'camera_linux_status')
external int cameraLinuxStatus(Pointer<Void> session);

/// `camera_linux_read_jpeg`.
@Native<Pointer<Uint8> Function(Pointer<Void>, Pointer<Int32>)>(symbol: 'camera_linux_read_jpeg')
external Pointer<Uint8> cameraLinuxReadJpeg(Pointer<Void> session, Pointer<Int32> length);

/// `camera_linux_take_error`.
@Native<Pointer<Utf8> Function(Pointer<Void>)>(symbol: 'camera_linux_take_error')
external Pointer<Utf8> cameraLinuxTakeError(Pointer<Void> session);

/// `camera_linux_frame_size`.
@Native<Void Function(Pointer<Void>, Pointer<Int32>, Pointer<Int32>)>(
  symbol: 'camera_linux_frame_size',
)
external void cameraLinuxFrameSize(
  Pointer<Void> session,
  Pointer<Int32> width,
  Pointer<Int32> height,
);

/// `camera_linux_device_path`.
@Native<Pointer<Utf8> Function(Pointer<Void>)>(symbol: 'camera_linux_device_path')
external Pointer<Utf8> cameraLinuxDevicePath(Pointer<Void> session);

/// `camera_linux_free`.
@Native<Void Function(Pointer<Void>)>(symbol: 'camera_linux_free')
external void cameraLinuxFree(Pointer<Void> ptr);
