// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v22.7.0), do not edit directly.
// See also: https://pub.dev/packages/pigeon
// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, unnecessary_import, no_leading_underscores_for_local_identifiers
// ignore_for_file: avoid_relative_lib_imports
import 'dart:async';
import 'dart:typed_data' show Float64List, Int32List, Int64List, Uint8List;
import 'package:flutter/foundation.dart' show ReadBuffer, WriteBuffer;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camera_android_camerax/src/camerax_library2.g.dart';


class _PigeonCodec extends StandardMessageCodec {
  const _PigeonCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is int) {
      buffer.putUint8(4);
      buffer.putInt64(value);
    }    else if (value is CameraStateType) {
      buffer.putUint8(129);
      writeValue(buffer, value.index);
    }    else if (value is LiveDataSupportedType) {
      buffer.putUint8(130);
      writeValue(buffer, value.index);
    }    else if (value is VideoQuality) {
      buffer.putUint8(131);
      writeValue(buffer, value.index);
    }    else if (value is MeteringMode) {
      buffer.putUint8(132);
      writeValue(buffer, value.index);
    }    else if (value is LensFacing) {
      buffer.putUint8(133);
      writeValue(buffer, value.index);
    }    else if (value is FlashMode) {
      buffer.putUint8(134);
      writeValue(buffer, value.index);
    }    else if (value is ResolutionStrategyFallbackRule) {
      buffer.putUint8(135);
      writeValue(buffer, value.index);
    }    else if (value is AspectRatioStrategyFallbackRule) {
      buffer.putUint8(136);
      writeValue(buffer, value.index);
    }    else if (value is CameraStateErrorCode) {
      buffer.putUint8(137);
      writeValue(buffer, value.index);
    }    else if (value is CameraPermissionsErrorData) {
      buffer.putUint8(138);
      writeValue(buffer, value.encode());
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 129: 
        final int? value = readValue(buffer) as int?;
        return value == null ? null : CameraStateType.values[value];
      case 130: 
        final int? value = readValue(buffer) as int?;
        return value == null ? null : LiveDataSupportedType.values[value];
      case 131: 
        final int? value = readValue(buffer) as int?;
        return value == null ? null : VideoQuality.values[value];
      case 132: 
        final int? value = readValue(buffer) as int?;
        return value == null ? null : MeteringMode.values[value];
      case 133: 
        final int? value = readValue(buffer) as int?;
        return value == null ? null : LensFacing.values[value];
      case 134: 
        final int? value = readValue(buffer) as int?;
        return value == null ? null : FlashMode.values[value];
      case 135: 
        final int? value = readValue(buffer) as int?;
        return value == null ? null : ResolutionStrategyFallbackRule.values[value];
      case 136: 
        final int? value = readValue(buffer) as int?;
        return value == null ? null : AspectRatioStrategyFallbackRule.values[value];
      case 137: 
        final int? value = readValue(buffer) as int?;
        return value == null ? null : CameraStateErrorCode.values[value];
      case 138: 
        return CameraPermissionsErrorData.decode(readValue(buffer)!);
      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

abstract class TestSystemServicesHostApi {
  static TestDefaultBinaryMessengerBinding? get _testBinaryMessengerBinding => TestDefaultBinaryMessengerBinding.instance;
  static const MessageCodec<Object?> pigeonChannelCodec = _PigeonCodec();

  Future<CameraPermissionsErrorData?> requestCameraPermissions(bool enableAudio);

  String getTempFilePath(String prefix, String suffix);

  bool isPreviewPreTransformed();

  static void setUp(TestSystemServicesHostApi? api, {BinaryMessenger? binaryMessenger, String messageChannelSuffix = '',}) {
    messageChannelSuffix = messageChannelSuffix.isNotEmpty ? '.$messageChannelSuffix' : '';
    {
      final BasicMessageChannel<Object?> pigeonVar_channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.camera_android_camerax.SystemServicesHostApi.requestCameraPermissions$messageChannelSuffix', pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        _testBinaryMessengerBinding!.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(pigeonVar_channel, null);
      } else {
        _testBinaryMessengerBinding!.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(pigeonVar_channel, (Object? message) async {
          assert(message != null,
          'Argument for dev.flutter.pigeon.camera_android_camerax.SystemServicesHostApi.requestCameraPermissions was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final bool? arg_enableAudio = (args[0] as bool?);
          assert(arg_enableAudio != null,
              'Argument for dev.flutter.pigeon.camera_android_camerax.SystemServicesHostApi.requestCameraPermissions was null, expected non-null bool.');
          try {
            final CameraPermissionsErrorData? output = await api.requestCameraPermissions(arg_enableAudio!);
            return <Object?>[output];
          } on PlatformException catch (e) {
            return wrapResponse(error: e);
          }          catch (e) {
            return wrapResponse(error: PlatformException(code: 'error', message: e.toString()));
          }
        });
      }
    }
    {
      final BasicMessageChannel<Object?> pigeonVar_channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.camera_android_camerax.SystemServicesHostApi.getTempFilePath$messageChannelSuffix', pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        _testBinaryMessengerBinding!.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(pigeonVar_channel, null);
      } else {
        _testBinaryMessengerBinding!.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(pigeonVar_channel, (Object? message) async {
          assert(message != null,
          'Argument for dev.flutter.pigeon.camera_android_camerax.SystemServicesHostApi.getTempFilePath was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final String? arg_prefix = (args[0] as String?);
          assert(arg_prefix != null,
              'Argument for dev.flutter.pigeon.camera_android_camerax.SystemServicesHostApi.getTempFilePath was null, expected non-null String.');
          final String? arg_suffix = (args[1] as String?);
          assert(arg_suffix != null,
              'Argument for dev.flutter.pigeon.camera_android_camerax.SystemServicesHostApi.getTempFilePath was null, expected non-null String.');
          try {
            final String output = api.getTempFilePath(arg_prefix!, arg_suffix!);
            return <Object?>[output];
          } on PlatformException catch (e) {
            return wrapResponse(error: e);
          }          catch (e) {
            return wrapResponse(error: PlatformException(code: 'error', message: e.toString()));
          }
        });
      }
    }
    {
      final BasicMessageChannel<Object?> pigeonVar_channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.camera_android_camerax.SystemServicesHostApi.isPreviewPreTransformed$messageChannelSuffix', pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        _testBinaryMessengerBinding!.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(pigeonVar_channel, null);
      } else {
        _testBinaryMessengerBinding!.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(pigeonVar_channel, (Object? message) async {
          try {
            final bool output = api.isPreviewPreTransformed();
            return <Object?>[output];
          } on PlatformException catch (e) {
            return wrapResponse(error: e);
          }          catch (e) {
            return wrapResponse(error: PlatformException(code: 'error', message: e.toString()));
          }
        });
      }
    }
  }
}

abstract class TestDeviceOrientationManagerHostApi {
  static TestDefaultBinaryMessengerBinding? get _testBinaryMessengerBinding => TestDefaultBinaryMessengerBinding.instance;
  static const MessageCodec<Object?> pigeonChannelCodec = _PigeonCodec();

  void startListeningForDeviceOrientationChange(bool isFrontFacing, int sensorOrientation);

  void stopListeningForDeviceOrientationChange();

  int getDefaultDisplayRotation();

  String getUiOrientation();

  static void setUp(TestDeviceOrientationManagerHostApi? api, {BinaryMessenger? binaryMessenger, String messageChannelSuffix = '',}) {
    messageChannelSuffix = messageChannelSuffix.isNotEmpty ? '.$messageChannelSuffix' : '';
    {
      final BasicMessageChannel<Object?> pigeonVar_channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.camera_android_camerax.DeviceOrientationManagerHostApi.startListeningForDeviceOrientationChange$messageChannelSuffix', pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        _testBinaryMessengerBinding!.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(pigeonVar_channel, null);
      } else {
        _testBinaryMessengerBinding!.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(pigeonVar_channel, (Object? message) async {
          assert(message != null,
          'Argument for dev.flutter.pigeon.camera_android_camerax.DeviceOrientationManagerHostApi.startListeningForDeviceOrientationChange was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final bool? arg_isFrontFacing = (args[0] as bool?);
          assert(arg_isFrontFacing != null,
              'Argument for dev.flutter.pigeon.camera_android_camerax.DeviceOrientationManagerHostApi.startListeningForDeviceOrientationChange was null, expected non-null bool.');
          final int? arg_sensorOrientation = (args[1] as int?);
          assert(arg_sensorOrientation != null,
              'Argument for dev.flutter.pigeon.camera_android_camerax.DeviceOrientationManagerHostApi.startListeningForDeviceOrientationChange was null, expected non-null int.');
          try {
            api.startListeningForDeviceOrientationChange(arg_isFrontFacing!, arg_sensorOrientation!);
            return wrapResponse(empty: true);
          } on PlatformException catch (e) {
            return wrapResponse(error: e);
          }          catch (e) {
            return wrapResponse(error: PlatformException(code: 'error', message: e.toString()));
          }
        });
      }
    }
    {
      final BasicMessageChannel<Object?> pigeonVar_channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.camera_android_camerax.DeviceOrientationManagerHostApi.stopListeningForDeviceOrientationChange$messageChannelSuffix', pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        _testBinaryMessengerBinding!.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(pigeonVar_channel, null);
      } else {
        _testBinaryMessengerBinding!.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(pigeonVar_channel, (Object? message) async {
          try {
            api.stopListeningForDeviceOrientationChange();
            return wrapResponse(empty: true);
          } on PlatformException catch (e) {
            return wrapResponse(error: e);
          }          catch (e) {
            return wrapResponse(error: PlatformException(code: 'error', message: e.toString()));
          }
        });
      }
    }
    {
      final BasicMessageChannel<Object?> pigeonVar_channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.camera_android_camerax.DeviceOrientationManagerHostApi.getDefaultDisplayRotation$messageChannelSuffix', pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        _testBinaryMessengerBinding!.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(pigeonVar_channel, null);
      } else {
        _testBinaryMessengerBinding!.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(pigeonVar_channel, (Object? message) async {
          try {
            final int output = api.getDefaultDisplayRotation();
            return <Object?>[output];
          } on PlatformException catch (e) {
            return wrapResponse(error: e);
          }          catch (e) {
            return wrapResponse(error: PlatformException(code: 'error', message: e.toString()));
          }
        });
      }
    }
    {
      final BasicMessageChannel<Object?> pigeonVar_channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.camera_android_camerax.DeviceOrientationManagerHostApi.getUiOrientation$messageChannelSuffix', pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        _testBinaryMessengerBinding!.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(pigeonVar_channel, null);
      } else {
        _testBinaryMessengerBinding!.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(pigeonVar_channel, (Object? message) async {
          try {
            final String output = api.getUiOrientation();
            return <Object?>[output];
          } on PlatformException catch (e) {
            return wrapResponse(error: e);
          }          catch (e) {
            return wrapResponse(error: PlatformException(code: 'error', message: e.toString()));
          }
        });
      }
    }
  }
}
