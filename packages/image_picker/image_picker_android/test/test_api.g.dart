// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v22.6.2), do not edit directly.
// See also: https://pub.dev/packages/pigeon
// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, unnecessary_import, no_leading_underscores_for_local_identifiers
// ignore_for_file: avoid_relative_lib_imports
import 'dart:async';
import 'dart:typed_data' show Float64List, Int32List, Int64List, Uint8List;
import 'package:flutter/foundation.dart' show ReadBuffer, WriteBuffer;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:image_picker_android/src/messages.g.dart';

class _PigeonCodec extends StandardMessageCodec {
  const _PigeonCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is int) {
      buffer.putUint8(4);
      buffer.putInt64(value);
    } else if (value is SourceCamera) {
      buffer.putUint8(129);
      writeValue(buffer, value.index);
    } else if (value is SourceType) {
      buffer.putUint8(130);
      writeValue(buffer, value.index);
    } else if (value is CacheRetrievalType) {
      buffer.putUint8(131);
      writeValue(buffer, value.index);
    } else if (value is GeneralOptions) {
      buffer.putUint8(132);
      writeValue(buffer, value.encode());
    } else if (value is ImageSelectionOptions) {
      buffer.putUint8(133);
      writeValue(buffer, value.encode());
    } else if (value is MediaSelectionOptions) {
      buffer.putUint8(134);
      writeValue(buffer, value.encode());
    } else if (value is VideoSelectionOptions) {
      buffer.putUint8(135);
      writeValue(buffer, value.encode());
    } else if (value is SourceSpecification) {
      buffer.putUint8(136);
      writeValue(buffer, value.encode());
    } else if (value is CacheRetrievalError) {
      buffer.putUint8(137);
      writeValue(buffer, value.encode());
    } else if (value is CacheRetrievalResult) {
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
        return value == null ? null : SourceCamera.values[value];
      case 130:
        final int? value = readValue(buffer) as int?;
        return value == null ? null : SourceType.values[value];
      case 131:
        final int? value = readValue(buffer) as int?;
        return value == null ? null : CacheRetrievalType.values[value];
      case 132:
        return GeneralOptions.decode(readValue(buffer)!);
      case 133:
        return ImageSelectionOptions.decode(readValue(buffer)!);
      case 134:
        return MediaSelectionOptions.decode(readValue(buffer)!);
      case 135:
        return VideoSelectionOptions.decode(readValue(buffer)!);
      case 136:
        return SourceSpecification.decode(readValue(buffer)!);
      case 137:
        return CacheRetrievalError.decode(readValue(buffer)!);
      case 138:
        return CacheRetrievalResult.decode(readValue(buffer)!);
      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

abstract class TestHostImagePickerApi {
  static TestDefaultBinaryMessengerBinding? get _testBinaryMessengerBinding =>
      TestDefaultBinaryMessengerBinding.instance;
  static const MessageCodec<Object?> pigeonChannelCodec = _PigeonCodec();

  /// Selects images and returns their paths.
  Future<List<String>> pickImages(SourceSpecification source,
      ImageSelectionOptions options, GeneralOptions generalOptions);

  /// Selects video and returns their paths.
  Future<List<String>> pickVideos(SourceSpecification source,
      VideoSelectionOptions options, GeneralOptions generalOptions);

  /// Selects images and videos and returns their paths.
  Future<List<String>> pickMedia(MediaSelectionOptions mediaSelectionOptions,
      GeneralOptions generalOptions);

  /// Returns results from a previous app session, if any.
  CacheRetrievalResult? retrieveLostResults();

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
          'dev.flutter.pigeon.image_picker_android.ImagePickerApi.pickImages$messageChannelSuffix',
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
              'Argument for dev.flutter.pigeon.image_picker_android.ImagePickerApi.pickImages was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final SourceSpecification? arg_source =
              (args[0] as SourceSpecification?);
          assert(arg_source != null,
              'Argument for dev.flutter.pigeon.image_picker_android.ImagePickerApi.pickImages was null, expected non-null SourceSpecification.');
          final ImageSelectionOptions? arg_options =
              (args[1] as ImageSelectionOptions?);
          assert(arg_options != null,
              'Argument for dev.flutter.pigeon.image_picker_android.ImagePickerApi.pickImages was null, expected non-null ImageSelectionOptions.');
          final GeneralOptions? arg_generalOptions =
              (args[2] as GeneralOptions?);
          assert(arg_generalOptions != null,
              'Argument for dev.flutter.pigeon.image_picker_android.ImagePickerApi.pickImages was null, expected non-null GeneralOptions.');
          try {
            final List<String> output = await api.pickImages(
                arg_source!, arg_options!, arg_generalOptions!);
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
          'dev.flutter.pigeon.image_picker_android.ImagePickerApi.pickVideos$messageChannelSuffix',
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
              'Argument for dev.flutter.pigeon.image_picker_android.ImagePickerApi.pickVideos was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final SourceSpecification? arg_source =
              (args[0] as SourceSpecification?);
          assert(arg_source != null,
              'Argument for dev.flutter.pigeon.image_picker_android.ImagePickerApi.pickVideos was null, expected non-null SourceSpecification.');
          final VideoSelectionOptions? arg_options =
              (args[1] as VideoSelectionOptions?);
          assert(arg_options != null,
              'Argument for dev.flutter.pigeon.image_picker_android.ImagePickerApi.pickVideos was null, expected non-null VideoSelectionOptions.');
          final GeneralOptions? arg_generalOptions =
              (args[2] as GeneralOptions?);
          assert(arg_generalOptions != null,
              'Argument for dev.flutter.pigeon.image_picker_android.ImagePickerApi.pickVideos was null, expected non-null GeneralOptions.');
          try {
            final List<String> output = await api.pickVideos(
                arg_source!, arg_options!, arg_generalOptions!);
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
          'dev.flutter.pigeon.image_picker_android.ImagePickerApi.pickMedia$messageChannelSuffix',
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
              'Argument for dev.flutter.pigeon.image_picker_android.ImagePickerApi.pickMedia was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final MediaSelectionOptions? arg_mediaSelectionOptions =
              (args[0] as MediaSelectionOptions?);
          assert(arg_mediaSelectionOptions != null,
              'Argument for dev.flutter.pigeon.image_picker_android.ImagePickerApi.pickMedia was null, expected non-null MediaSelectionOptions.');
          final GeneralOptions? arg_generalOptions =
              (args[1] as GeneralOptions?);
          assert(arg_generalOptions != null,
              'Argument for dev.flutter.pigeon.image_picker_android.ImagePickerApi.pickMedia was null, expected non-null GeneralOptions.');
          try {
            final List<String> output = await api.pickMedia(
                arg_mediaSelectionOptions!, arg_generalOptions!);
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
          'dev.flutter.pigeon.image_picker_android.ImagePickerApi.retrieveLostResults$messageChannelSuffix',
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
            final CacheRetrievalResult? output = api.retrieveLostResults();
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
