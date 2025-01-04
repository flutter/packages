// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v22.7.2), do not edit directly.
// See also: https://pub.dev/packages/pigeon
// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, unnecessary_import, no_leading_underscores_for_local_identifiers
// ignore_for_file: avoid_relative_lib_imports
import 'dart:async';
import 'dart:typed_data' show Float64List, Int32List, Int64List, Uint8List;
import 'package:flutter/foundation.dart' show ReadBuffer, WriteBuffer;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:image_picker_macos/src/messages.g.dart';

class _PigeonCodec extends StandardMessageCodec {
  const _PigeonCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is int) {
      buffer.putUint8(4);
      buffer.putInt64(value);
    } else if (value is ImagePickerError) {
      buffer.putUint8(129);
      writeValue(buffer, value.index);
    } else if (value is GeneralOptions) {
      buffer.putUint8(130);
      writeValue(buffer, value.encode());
    } else if (value is MaxSize) {
      buffer.putUint8(131);
      writeValue(buffer, value.encode());
    } else if (value is ImageSelectionOptions) {
      buffer.putUint8(132);
      writeValue(buffer, value.encode());
    } else if (value is MediaSelectionOptions) {
      buffer.putUint8(133);
      writeValue(buffer, value.encode());
    } else if (value is ImagePickerSuccessResult) {
      buffer.putUint8(134);
      writeValue(buffer, value.encode());
    } else if (value is ImagePickerErrorResult) {
      buffer.putUint8(135);
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
        return value == null ? null : ImagePickerError.values[value];
      case 130:
        return GeneralOptions.decode(readValue(buffer)!);
      case 131:
        return MaxSize.decode(readValue(buffer)!);
      case 132:
        return ImageSelectionOptions.decode(readValue(buffer)!);
      case 133:
        return MediaSelectionOptions.decode(readValue(buffer)!);
      case 134:
        return ImagePickerSuccessResult.decode(readValue(buffer)!);
      case 135:
        return ImagePickerErrorResult.decode(readValue(buffer)!);
      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

abstract class TestHostImagePickerApi {
  static TestDefaultBinaryMessengerBinding? get _testBinaryMessengerBinding =>
      TestDefaultBinaryMessengerBinding.instance;
  static const MessageCodec<Object?> pigeonChannelCodec = _PigeonCodec();

  /// Returns whether [PHPickerViewController](https://developer.apple.com/documentation/photosui/phpickerviewcontroller)
  /// is supported on the current macOS version.
  bool supportsPHPicker();

  Future<ImagePickerResult> pickImages(
      ImageSelectionOptions options, GeneralOptions generalOptions);

  /// Currently, multi-video selection is unimplemented.
  Future<ImagePickerResult> pickVideos(GeneralOptions generalOptions);

  Future<ImagePickerResult> pickMedia(
      MediaSelectionOptions options, GeneralOptions generalOptions);

  static void setUp(
    TestHostImagePickerApi? api, {
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) {
    messageChannelSuffix =
        messageChannelSuffix.isNotEmpty ? '.$messageChannelSuffix' : '';
    {
      final BasicMessageChannel<
          Object?> pigeonVar_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.image_picker_macos.ImagePickerApi.supportsPHPicker$messageChannelSuffix',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        _testBinaryMessengerBinding!.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(pigeonVar_channel, null);
      } else {
        _testBinaryMessengerBinding!.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(pigeonVar_channel,
                (Object? message) async {
          try {
            final bool output = api.supportsPHPicker();
            return <Object?>[output];
          } on PlatformException catch (e) {
            return wrapResponse(error: e);
          } catch (e) {
            return wrapResponse(
                error: PlatformException(code: 'error', message: e.toString()));
          }
        });
      }
    }
    {
      final BasicMessageChannel<
          Object?> pigeonVar_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.image_picker_macos.ImagePickerApi.pickImages$messageChannelSuffix',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        _testBinaryMessengerBinding!.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(pigeonVar_channel, null);
      } else {
        _testBinaryMessengerBinding!.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(pigeonVar_channel,
                (Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.image_picker_macos.ImagePickerApi.pickImages was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final ImageSelectionOptions? arg_options =
              (args[0] as ImageSelectionOptions?);
          assert(arg_options != null,
              'Argument for dev.flutter.pigeon.image_picker_macos.ImagePickerApi.pickImages was null, expected non-null ImageSelectionOptions.');
          final GeneralOptions? arg_generalOptions =
              (args[1] as GeneralOptions?);
          assert(arg_generalOptions != null,
              'Argument for dev.flutter.pigeon.image_picker_macos.ImagePickerApi.pickImages was null, expected non-null GeneralOptions.');
          try {
            final ImagePickerResult output =
                await api.pickImages(arg_options!, arg_generalOptions!);
            return <Object?>[output];
          } on PlatformException catch (e) {
            return wrapResponse(error: e);
          } catch (e) {
            return wrapResponse(
                error: PlatformException(code: 'error', message: e.toString()));
          }
        });
      }
    }
    {
      final BasicMessageChannel<
          Object?> pigeonVar_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.image_picker_macos.ImagePickerApi.pickVideos$messageChannelSuffix',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        _testBinaryMessengerBinding!.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(pigeonVar_channel, null);
      } else {
        _testBinaryMessengerBinding!.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(pigeonVar_channel,
                (Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.image_picker_macos.ImagePickerApi.pickVideos was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final GeneralOptions? arg_generalOptions =
              (args[0] as GeneralOptions?);
          assert(arg_generalOptions != null,
              'Argument for dev.flutter.pigeon.image_picker_macos.ImagePickerApi.pickVideos was null, expected non-null GeneralOptions.');
          try {
            final ImagePickerResult output =
                await api.pickVideos(arg_generalOptions!);
            return <Object?>[output];
          } on PlatformException catch (e) {
            return wrapResponse(error: e);
          } catch (e) {
            return wrapResponse(
                error: PlatformException(code: 'error', message: e.toString()));
          }
        });
      }
    }
    {
      final BasicMessageChannel<
          Object?> pigeonVar_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.image_picker_macos.ImagePickerApi.pickMedia$messageChannelSuffix',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        _testBinaryMessengerBinding!.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(pigeonVar_channel, null);
      } else {
        _testBinaryMessengerBinding!.defaultBinaryMessenger
            .setMockDecodedMessageHandler<Object?>(pigeonVar_channel,
                (Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.image_picker_macos.ImagePickerApi.pickMedia was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final MediaSelectionOptions? arg_options =
              (args[0] as MediaSelectionOptions?);
          assert(arg_options != null,
              'Argument for dev.flutter.pigeon.image_picker_macos.ImagePickerApi.pickMedia was null, expected non-null MediaSelectionOptions.');
          final GeneralOptions? arg_generalOptions =
              (args[1] as GeneralOptions?);
          assert(arg_generalOptions != null,
              'Argument for dev.flutter.pigeon.image_picker_macos.ImagePickerApi.pickMedia was null, expected non-null GeneralOptions.');
          try {
            final ImagePickerResult output =
                await api.pickMedia(arg_options!, arg_generalOptions!);
            return <Object?>[output];
          } on PlatformException catch (e) {
            return wrapResponse(error: e);
          } catch (e) {
            return wrapResponse(
                error: PlatformException(code: 'error', message: e.toString()));
          }
        });
      }
    }
  }
}
