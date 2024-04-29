// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v18.0.1), do not edit directly.
// See also: https://pub.dev/packages/pigeon
// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, prefer_null_aware_operators, omit_local_variable_types, unused_shown_name, unnecessary_import, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:typed_data' show Float64List, Int32List, Int64List, Uint8List;

import 'package:flutter/foundation.dart' show ReadBuffer, WriteBuffer;
import 'package:flutter/services.dart';

PlatformException _createConnectionError(String channelName) {
  return PlatformException(
    code: 'channel-error',
    message: 'Unable to establish connection on channel: "$channelName".',
  );
}

/// Pigeon version of pltaform interface's ResolutionPreset.
enum PlatformResolutionPreset {
  low,
  medium,
  high,
  veryHigh,
  ultraHigh,
  max,
}

class PlatformMediaSettings {
  PlatformMediaSettings({
    required this.resolutionPreset,
    this.framesPerSecond,
    this.videoBitrate,
    this.audioBitrate,
    required this.enableAudio,
  });

  PlatformResolutionPreset resolutionPreset;

  int? framesPerSecond;

  int? videoBitrate;

  int? audioBitrate;

  bool enableAudio;

  Object encode() {
    return <Object?>[
      resolutionPreset.index,
      framesPerSecond,
      videoBitrate,
      audioBitrate,
      enableAudio,
    ];
  }

  static PlatformMediaSettings decode(Object result) {
    result as List<Object?>;
    return PlatformMediaSettings(
      resolutionPreset: PlatformResolutionPreset.values[result[0]! as int],
      framesPerSecond: result[1] as int?,
      videoBitrate: result[2] as int?,
      audioBitrate: result[3] as int?,
      enableAudio: result[4]! as bool,
    );
  }
}

/// A representation of a size from the native camera APIs.
class PlatformSize {
  PlatformSize({
    required this.width,
    required this.height,
  });

  double width;

  double height;

  Object encode() {
    return <Object?>[
      width,
      height,
    ];
  }

  static PlatformSize decode(Object result) {
    result as List<Object?>;
    return PlatformSize(
      width: result[0]! as double,
      height: result[1]! as double,
    );
  }
}

class PlatformVideoCaptureOptions {
  PlatformVideoCaptureOptions({
    required this.maxDurationMilliseconds,
  });

  int maxDurationMilliseconds;

  Object encode() {
    return <Object?>[
      maxDurationMilliseconds,
    ];
  }

  static PlatformVideoCaptureOptions decode(Object result) {
    result as List<Object?>;
    return PlatformVideoCaptureOptions(
      maxDurationMilliseconds: result[0]! as int,
    );
  }
}

class _CameraApiCodec extends StandardMessageCodec {
  const _CameraApiCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is PlatformMediaSettings) {
      buffer.putUint8(128);
      writeValue(buffer, value.encode());
    } else if (value is PlatformSize) {
      buffer.putUint8(129);
      writeValue(buffer, value.encode());
    } else if (value is PlatformVideoCaptureOptions) {
      buffer.putUint8(130);
      writeValue(buffer, value.encode());
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 128:
        return PlatformMediaSettings.decode(readValue(buffer)!);
      case 129:
        return PlatformSize.decode(readValue(buffer)!);
      case 130:
        return PlatformVideoCaptureOptions.decode(readValue(buffer)!);
      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

class CameraApi {
  /// Constructor for [CameraApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  CameraApi(
      {BinaryMessenger? binaryMessenger, String messageChannelSuffix = ''})
      : __pigeon_binaryMessenger = binaryMessenger,
        __pigeon_messageChannelSuffix =
            messageChannelSuffix.isNotEmpty ? '.$messageChannelSuffix' : '';
  final BinaryMessenger? __pigeon_binaryMessenger;

  static const MessageCodec<Object?> pigeonChannelCodec = _CameraApiCodec();

  final String __pigeon_messageChannelSuffix;

  /// Returns the names of all of the available capture devices.
  Future<List<String?>> availableCameras() async {
    final String __pigeon_channelName =
        'dev.flutter.pigeon.camera_windows.CameraApi.availableCameras$__pigeon_messageChannelSuffix';
    final BasicMessageChannel<Object?> __pigeon_channel =
        BasicMessageChannel<Object?>(
      __pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: __pigeon_binaryMessenger,
    );
    final List<Object?>? __pigeon_replyList =
        await __pigeon_channel.send(null) as List<Object?>?;
    if (__pigeon_replyList == null) {
      throw _createConnectionError(__pigeon_channelName);
    } else if (__pigeon_replyList.length > 1) {
      throw PlatformException(
        code: __pigeon_replyList[0]! as String,
        message: __pigeon_replyList[1] as String?,
        details: __pigeon_replyList[2],
      );
    } else if (__pigeon_replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (__pigeon_replyList[0] as List<Object?>?)!.cast<String?>();
    }
  }

  /// Creates a camera instance for the given device name and settings.
  Future<String> create(
      String cameraName, PlatformMediaSettings settings) async {
    final String __pigeon_channelName =
        'dev.flutter.pigeon.camera_windows.CameraApi.create$__pigeon_messageChannelSuffix';
    final BasicMessageChannel<Object?> __pigeon_channel =
        BasicMessageChannel<Object?>(
      __pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: __pigeon_binaryMessenger,
    );
    final List<Object?>? __pigeon_replyList = await __pigeon_channel
        .send(<Object?>[cameraName, settings]) as List<Object?>?;
    if (__pigeon_replyList == null) {
      throw _createConnectionError(__pigeon_channelName);
    } else if (__pigeon_replyList.length > 1) {
      throw PlatformException(
        code: __pigeon_replyList[0]! as String,
        message: __pigeon_replyList[1] as String?,
        details: __pigeon_replyList[2],
      );
    } else if (__pigeon_replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (__pigeon_replyList[0] as String?)!;
    }
  }

  /// Initializes a camera, and returns the size of its preview.
  Future<PlatformSize> initialize(int cameraId) async {
    final String __pigeon_channelName =
        'dev.flutter.pigeon.camera_windows.CameraApi.initialize$__pigeon_messageChannelSuffix';
    final BasicMessageChannel<Object?> __pigeon_channel =
        BasicMessageChannel<Object?>(
      __pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: __pigeon_binaryMessenger,
    );
    final List<Object?>? __pigeon_replyList =
        await __pigeon_channel.send(<Object?>[cameraId]) as List<Object?>?;
    if (__pigeon_replyList == null) {
      throw _createConnectionError(__pigeon_channelName);
    } else if (__pigeon_replyList.length > 1) {
      throw PlatformException(
        code: __pigeon_replyList[0]! as String,
        message: __pigeon_replyList[1] as String?,
        details: __pigeon_replyList[2],
      );
    } else if (__pigeon_replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (__pigeon_replyList[0] as PlatformSize?)!;
    }
  }

  /// Disposes a camera that is no longer in use.
  Future<void> dispose(int cameraId) async {
    final String __pigeon_channelName =
        'dev.flutter.pigeon.camera_windows.CameraApi.dispose$__pigeon_messageChannelSuffix';
    final BasicMessageChannel<Object?> __pigeon_channel =
        BasicMessageChannel<Object?>(
      __pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: __pigeon_binaryMessenger,
    );
    final List<Object?>? __pigeon_replyList =
        await __pigeon_channel.send(<Object?>[cameraId]) as List<Object?>?;
    if (__pigeon_replyList == null) {
      throw _createConnectionError(__pigeon_channelName);
    } else if (__pigeon_replyList.length > 1) {
      throw PlatformException(
        code: __pigeon_replyList[0]! as String,
        message: __pigeon_replyList[1] as String?,
        details: __pigeon_replyList[2],
      );
    } else {
      return;
    }
  }

  /// Takes a picture with the given camera, and returns the path to the
  /// resulting file.
  Future<String> takePicture(int cameraId) async {
    final String __pigeon_channelName =
        'dev.flutter.pigeon.camera_windows.CameraApi.takePicture$__pigeon_messageChannelSuffix';
    final BasicMessageChannel<Object?> __pigeon_channel =
        BasicMessageChannel<Object?>(
      __pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: __pigeon_binaryMessenger,
    );
    final List<Object?>? __pigeon_replyList =
        await __pigeon_channel.send(<Object?>[cameraId]) as List<Object?>?;
    if (__pigeon_replyList == null) {
      throw _createConnectionError(__pigeon_channelName);
    } else if (__pigeon_replyList.length > 1) {
      throw PlatformException(
        code: __pigeon_replyList[0]! as String,
        message: __pigeon_replyList[1] as String?,
        details: __pigeon_replyList[2],
      );
    } else if (__pigeon_replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (__pigeon_replyList[0] as String?)!;
    }
  }

  /// Starts recording video with the given camera.
  Future<void> startVideoRecording(
      int cameraId, PlatformVideoCaptureOptions options) async {
    final String __pigeon_channelName =
        'dev.flutter.pigeon.camera_windows.CameraApi.startVideoRecording$__pigeon_messageChannelSuffix';
    final BasicMessageChannel<Object?> __pigeon_channel =
        BasicMessageChannel<Object?>(
      __pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: __pigeon_binaryMessenger,
    );
    final List<Object?>? __pigeon_replyList = await __pigeon_channel
        .send(<Object?>[cameraId, options]) as List<Object?>?;
    if (__pigeon_replyList == null) {
      throw _createConnectionError(__pigeon_channelName);
    } else if (__pigeon_replyList.length > 1) {
      throw PlatformException(
        code: __pigeon_replyList[0]! as String,
        message: __pigeon_replyList[1] as String?,
        details: __pigeon_replyList[2],
      );
    } else {
      return;
    }
  }

  /// Finishes recording video with the given camera, and returns the path to
  /// the resulting file.
  Future<String> stopVideoRecording(int cameraId) async {
    final String __pigeon_channelName =
        'dev.flutter.pigeon.camera_windows.CameraApi.stopVideoRecording$__pigeon_messageChannelSuffix';
    final BasicMessageChannel<Object?> __pigeon_channel =
        BasicMessageChannel<Object?>(
      __pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: __pigeon_binaryMessenger,
    );
    final List<Object?>? __pigeon_replyList =
        await __pigeon_channel.send(<Object?>[cameraId]) as List<Object?>?;
    if (__pigeon_replyList == null) {
      throw _createConnectionError(__pigeon_channelName);
    } else if (__pigeon_replyList.length > 1) {
      throw PlatformException(
        code: __pigeon_replyList[0]! as String,
        message: __pigeon_replyList[1] as String?,
        details: __pigeon_replyList[2],
      );
    } else if (__pigeon_replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (__pigeon_replyList[0] as String?)!;
    }
  }

  /// Starts the preview stream for the given camera.
  Future<void> pausePreview(int cameraId) async {
    final String __pigeon_channelName =
        'dev.flutter.pigeon.camera_windows.CameraApi.pausePreview$__pigeon_messageChannelSuffix';
    final BasicMessageChannel<Object?> __pigeon_channel =
        BasicMessageChannel<Object?>(
      __pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: __pigeon_binaryMessenger,
    );
    final List<Object?>? __pigeon_replyList =
        await __pigeon_channel.send(<Object?>[cameraId]) as List<Object?>?;
    if (__pigeon_replyList == null) {
      throw _createConnectionError(__pigeon_channelName);
    } else if (__pigeon_replyList.length > 1) {
      throw PlatformException(
        code: __pigeon_replyList[0]! as String,
        message: __pigeon_replyList[1] as String?,
        details: __pigeon_replyList[2],
      );
    } else {
      return;
    }
  }

  /// Resumes the preview stream for the given camera.
  Future<void> resumePreview(int cameraId) async {
    final String __pigeon_channelName =
        'dev.flutter.pigeon.camera_windows.CameraApi.resumePreview$__pigeon_messageChannelSuffix';
    final BasicMessageChannel<Object?> __pigeon_channel =
        BasicMessageChannel<Object?>(
      __pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: __pigeon_binaryMessenger,
    );
    final List<Object?>? __pigeon_replyList =
        await __pigeon_channel.send(<Object?>[cameraId]) as List<Object?>?;
    if (__pigeon_replyList == null) {
      throw _createConnectionError(__pigeon_channelName);
    } else if (__pigeon_replyList.length > 1) {
      throw PlatformException(
        code: __pigeon_replyList[0]! as String,
        message: __pigeon_replyList[1] as String?,
        details: __pigeon_replyList[2],
      );
    } else {
      return;
    }
  }
}
