// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v22.7.2), do not edit directly.
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

List<Object?> wrapResponse({Object? result, PlatformException? error, bool empty = false}) {
  if (empty) {
    return <Object?>[];
  }
  if (error == null) {
    return <Object?>[result];
  }
  return <Object?>[error.code, error.message, error.details];
}

class CreationOptions {
  CreationOptions({
    this.asset,
    this.uri,
    this.packageName,
    this.formatHint,
    required this.httpHeaders,
  });

  String? asset;

  String? uri;

  String? packageName;

  String? formatHint;

  Map<String, String> httpHeaders;

  Object encode() {
    return <Object?>[
      asset,
      uri,
      packageName,
      formatHint,
      httpHeaders,
    ];
  }

  static CreationOptions decode(Object result) {
    result as List<Object?>;
    return CreationOptions(
      asset: result[0] as String?,
      uri: result[1] as String?,
      packageName: result[2] as String?,
      formatHint: result[3] as String?,
      httpHeaders: (result[4] as Map<Object?, Object?>?)!.cast<String, String>(),
    );
  }
}

class AutomaticallyStartsPictureInPictureMessage {
  AutomaticallyStartsPictureInPictureMessage({
    required this.textureId,
    required this.enableStartPictureInPictureAutomaticallyFromInline,
  });

  int textureId;

  bool enableStartPictureInPictureAutomaticallyFromInline;

  Object encode() {
    return <Object?>[
      textureId,
      enableStartPictureInPictureAutomaticallyFromInline,
    ];
  }

  static AutomaticallyStartsPictureInPictureMessage decode(Object result) {
    result as List<Object?>;
    return AutomaticallyStartsPictureInPictureMessage(
      textureId: result[0]! as int,
      enableStartPictureInPictureAutomaticallyFromInline: result[1]! as bool,
    );
  }
}

class SetPictureInPictureOverlaySettingsMessage {
  SetPictureInPictureOverlaySettingsMessage({
    required this.textureId,
    this.settings,
  });

  int textureId;

  PictureInPictureOverlaySettingsMessage? settings;

  Object encode() {
    return <Object?>[
      textureId,
      settings,
    ];
  }

  static SetPictureInPictureOverlaySettingsMessage decode(Object result) {
    result as List<Object?>;
    return SetPictureInPictureOverlaySettingsMessage(
      textureId: result[0]! as int,
      settings: result[1] as PictureInPictureOverlaySettingsMessage?,
    );
  }
}

class PictureInPictureOverlaySettingsMessage {
  PictureInPictureOverlaySettingsMessage({
    required this.top,
    required this.left,
    required this.width,
    required this.height,
  });

  double top;

  double left;

  double width;

  double height;

  Object encode() {
    return <Object?>[
      top,
      left,
      width,
      height,
    ];
  }

  static PictureInPictureOverlaySettingsMessage decode(Object result) {
    result as List<Object?>;
    return PictureInPictureOverlaySettingsMessage(
      top: result[0]! as double,
      left: result[1]! as double,
      width: result[2]! as double,
      height: result[3]! as double,
    );
  }
}

class StartPictureInPictureMessage {
  StartPictureInPictureMessage({
    required this.textureId,
  });

  int textureId;

  Object encode() {
    return <Object?>[
      textureId,
    ];
  }

  static StartPictureInPictureMessage decode(Object result) {
    result as List<Object?>;
    return StartPictureInPictureMessage(
      textureId: result[0]! as int,
    );
  }
}

class StopPictureInPictureMessage {
  StopPictureInPictureMessage({
    required this.textureId,
  });

  int textureId;

  Object encode() {
    return <Object?>[
      textureId,
    ];
  }

  static StopPictureInPictureMessage decode(Object result) {
    result as List<Object?>;
    return StopPictureInPictureMessage(
      textureId: result[0]! as int,
    );
  }
}


class _PigeonCodec extends StandardMessageCodec {
  const _PigeonCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is int) {
      buffer.putUint8(4);
      buffer.putInt64(value);
    }    else if (value is CreationOptions) {
      buffer.putUint8(129);
      writeValue(buffer, value.encode());
    }    else if (value is AutomaticallyStartsPictureInPictureMessage) {
      buffer.putUint8(130);
      writeValue(buffer, value.encode());
    }    else if (value is SetPictureInPictureOverlaySettingsMessage) {
      buffer.putUint8(131);
      writeValue(buffer, value.encode());
    }    else if (value is PictureInPictureOverlaySettingsMessage) {
      buffer.putUint8(132);
      writeValue(buffer, value.encode());
    }    else if (value is StartPictureInPictureMessage) {
      buffer.putUint8(133);
      writeValue(buffer, value.encode());
    }    else if (value is StopPictureInPictureMessage) {
      buffer.putUint8(134);
      writeValue(buffer, value.encode());
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 129: 
        return CreationOptions.decode(readValue(buffer)!);
      case 130: 
        return AutomaticallyStartsPictureInPictureMessage.decode(readValue(buffer)!);
      case 131: 
        return SetPictureInPictureOverlaySettingsMessage.decode(readValue(buffer)!);
      case 132: 
        return PictureInPictureOverlaySettingsMessage.decode(readValue(buffer)!);
      case 133: 
        return StartPictureInPictureMessage.decode(readValue(buffer)!);
      case 134: 
        return StopPictureInPictureMessage.decode(readValue(buffer)!);
      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

class AVFoundationVideoPlayerApi {
  /// Constructor for [AVFoundationVideoPlayerApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  AVFoundationVideoPlayerApi({BinaryMessenger? binaryMessenger, String messageChannelSuffix = ''})
      : pigeonVar_binaryMessenger = binaryMessenger,
        pigeonVar_messageChannelSuffix = messageChannelSuffix.isNotEmpty ? '.$messageChannelSuffix' : '';
  final BinaryMessenger? pigeonVar_binaryMessenger;

  static const MessageCodec<Object?> pigeonChannelCodec = _PigeonCodec();

  final String pigeonVar_messageChannelSuffix;

  Future<void> initialize() async {
    final String pigeonVar_channelName = 'dev.flutter.pigeon.video_player_avfoundation.AVFoundationVideoPlayerApi.initialize$pigeonVar_messageChannelSuffix';
    final BasicMessageChannel<Object?> pigeonVar_channel = BasicMessageChannel<Object?>(
      pigeonVar_channelName,
      pigeonChannelCodec,
      binaryMessenger: pigeonVar_binaryMessenger,
    );
    final List<Object?>? pigeonVar_replyList =
        await pigeonVar_channel.send(null) as List<Object?>?;
    if (pigeonVar_replyList == null) {
      throw _createConnectionError(pigeonVar_channelName);
    } else if (pigeonVar_replyList.length > 1) {
      throw PlatformException(
        code: pigeonVar_replyList[0]! as String,
        message: pigeonVar_replyList[1] as String?,
        details: pigeonVar_replyList[2],
      );
    } else {
      return;
    }
  }

  Future<int> create(CreationOptions creationOptions) async {
    final String pigeonVar_channelName = 'dev.flutter.pigeon.video_player_avfoundation.AVFoundationVideoPlayerApi.create$pigeonVar_messageChannelSuffix';
    final BasicMessageChannel<Object?> pigeonVar_channel = BasicMessageChannel<Object?>(
      pigeonVar_channelName,
      pigeonChannelCodec,
      binaryMessenger: pigeonVar_binaryMessenger,
    );
    final List<Object?>? pigeonVar_replyList =
        await pigeonVar_channel.send(<Object?>[creationOptions]) as List<Object?>?;
    if (pigeonVar_replyList == null) {
      throw _createConnectionError(pigeonVar_channelName);
    } else if (pigeonVar_replyList.length > 1) {
      throw PlatformException(
        code: pigeonVar_replyList[0]! as String,
        message: pigeonVar_replyList[1] as String?,
        details: pigeonVar_replyList[2],
      );
    } else if (pigeonVar_replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (pigeonVar_replyList[0] as int?)!;
    }
  }

  Future<void> dispose(int textureId) async {
    final String pigeonVar_channelName = 'dev.flutter.pigeon.video_player_avfoundation.AVFoundationVideoPlayerApi.dispose$pigeonVar_messageChannelSuffix';
    final BasicMessageChannel<Object?> pigeonVar_channel = BasicMessageChannel<Object?>(
      pigeonVar_channelName,
      pigeonChannelCodec,
      binaryMessenger: pigeonVar_binaryMessenger,
    );
    final List<Object?>? pigeonVar_replyList =
        await pigeonVar_channel.send(<Object?>[textureId]) as List<Object?>?;
    if (pigeonVar_replyList == null) {
      throw _createConnectionError(pigeonVar_channelName);
    } else if (pigeonVar_replyList.length > 1) {
      throw PlatformException(
        code: pigeonVar_replyList[0]! as String,
        message: pigeonVar_replyList[1] as String?,
        details: pigeonVar_replyList[2],
      );
    } else {
      return;
    }
  }

  Future<void> setLooping(bool isLooping, int textureId) async {
    final String pigeonVar_channelName = 'dev.flutter.pigeon.video_player_avfoundation.AVFoundationVideoPlayerApi.setLooping$pigeonVar_messageChannelSuffix';
    final BasicMessageChannel<Object?> pigeonVar_channel = BasicMessageChannel<Object?>(
      pigeonVar_channelName,
      pigeonChannelCodec,
      binaryMessenger: pigeonVar_binaryMessenger,
    );
    final List<Object?>? pigeonVar_replyList =
        await pigeonVar_channel.send(<Object?>[isLooping, textureId]) as List<Object?>?;
    if (pigeonVar_replyList == null) {
      throw _createConnectionError(pigeonVar_channelName);
    } else if (pigeonVar_replyList.length > 1) {
      throw PlatformException(
        code: pigeonVar_replyList[0]! as String,
        message: pigeonVar_replyList[1] as String?,
        details: pigeonVar_replyList[2],
      );
    } else {
      return;
    }
  }

  Future<void> setVolume(double volume, int textureId) async {
    final String pigeonVar_channelName = 'dev.flutter.pigeon.video_player_avfoundation.AVFoundationVideoPlayerApi.setVolume$pigeonVar_messageChannelSuffix';
    final BasicMessageChannel<Object?> pigeonVar_channel = BasicMessageChannel<Object?>(
      pigeonVar_channelName,
      pigeonChannelCodec,
      binaryMessenger: pigeonVar_binaryMessenger,
    );
    final List<Object?>? pigeonVar_replyList =
        await pigeonVar_channel.send(<Object?>[volume, textureId]) as List<Object?>?;
    if (pigeonVar_replyList == null) {
      throw _createConnectionError(pigeonVar_channelName);
    } else if (pigeonVar_replyList.length > 1) {
      throw PlatformException(
        code: pigeonVar_replyList[0]! as String,
        message: pigeonVar_replyList[1] as String?,
        details: pigeonVar_replyList[2],
      );
    } else {
      return;
    }
  }

  Future<void> setPlaybackSpeed(double speed, int textureId) async {
    final String pigeonVar_channelName = 'dev.flutter.pigeon.video_player_avfoundation.AVFoundationVideoPlayerApi.setPlaybackSpeed$pigeonVar_messageChannelSuffix';
    final BasicMessageChannel<Object?> pigeonVar_channel = BasicMessageChannel<Object?>(
      pigeonVar_channelName,
      pigeonChannelCodec,
      binaryMessenger: pigeonVar_binaryMessenger,
    );
    final List<Object?>? pigeonVar_replyList =
        await pigeonVar_channel.send(<Object?>[speed, textureId]) as List<Object?>?;
    if (pigeonVar_replyList == null) {
      throw _createConnectionError(pigeonVar_channelName);
    } else if (pigeonVar_replyList.length > 1) {
      throw PlatformException(
        code: pigeonVar_replyList[0]! as String,
        message: pigeonVar_replyList[1] as String?,
        details: pigeonVar_replyList[2],
      );
    } else {
      return;
    }
  }

  Future<void> play(int textureId) async {
    final String pigeonVar_channelName = 'dev.flutter.pigeon.video_player_avfoundation.AVFoundationVideoPlayerApi.play$pigeonVar_messageChannelSuffix';
    final BasicMessageChannel<Object?> pigeonVar_channel = BasicMessageChannel<Object?>(
      pigeonVar_channelName,
      pigeonChannelCodec,
      binaryMessenger: pigeonVar_binaryMessenger,
    );
    final List<Object?>? pigeonVar_replyList =
        await pigeonVar_channel.send(<Object?>[textureId]) as List<Object?>?;
    if (pigeonVar_replyList == null) {
      throw _createConnectionError(pigeonVar_channelName);
    } else if (pigeonVar_replyList.length > 1) {
      throw PlatformException(
        code: pigeonVar_replyList[0]! as String,
        message: pigeonVar_replyList[1] as String?,
        details: pigeonVar_replyList[2],
      );
    } else {
      return;
    }
  }

  Future<int> getPosition(int textureId) async {
    final String pigeonVar_channelName = 'dev.flutter.pigeon.video_player_avfoundation.AVFoundationVideoPlayerApi.getPosition$pigeonVar_messageChannelSuffix';
    final BasicMessageChannel<Object?> pigeonVar_channel = BasicMessageChannel<Object?>(
      pigeonVar_channelName,
      pigeonChannelCodec,
      binaryMessenger: pigeonVar_binaryMessenger,
    );
    final List<Object?>? pigeonVar_replyList =
        await pigeonVar_channel.send(<Object?>[textureId]) as List<Object?>?;
    if (pigeonVar_replyList == null) {
      throw _createConnectionError(pigeonVar_channelName);
    } else if (pigeonVar_replyList.length > 1) {
      throw PlatformException(
        code: pigeonVar_replyList[0]! as String,
        message: pigeonVar_replyList[1] as String?,
        details: pigeonVar_replyList[2],
      );
    } else if (pigeonVar_replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (pigeonVar_replyList[0] as int?)!;
    }
  }

  Future<void> seekTo(int position, int textureId) async {
    final String pigeonVar_channelName = 'dev.flutter.pigeon.video_player_avfoundation.AVFoundationVideoPlayerApi.seekTo$pigeonVar_messageChannelSuffix';
    final BasicMessageChannel<Object?> pigeonVar_channel = BasicMessageChannel<Object?>(
      pigeonVar_channelName,
      pigeonChannelCodec,
      binaryMessenger: pigeonVar_binaryMessenger,
    );
    final List<Object?>? pigeonVar_replyList =
        await pigeonVar_channel.send(<Object?>[position, textureId]) as List<Object?>?;
    if (pigeonVar_replyList == null) {
      throw _createConnectionError(pigeonVar_channelName);
    } else if (pigeonVar_replyList.length > 1) {
      throw PlatformException(
        code: pigeonVar_replyList[0]! as String,
        message: pigeonVar_replyList[1] as String?,
        details: pigeonVar_replyList[2],
      );
    } else {
      return;
    }
  }

  Future<void> pause(int textureId) async {
    final String pigeonVar_channelName = 'dev.flutter.pigeon.video_player_avfoundation.AVFoundationVideoPlayerApi.pause$pigeonVar_messageChannelSuffix';
    final BasicMessageChannel<Object?> pigeonVar_channel = BasicMessageChannel<Object?>(
      pigeonVar_channelName,
      pigeonChannelCodec,
      binaryMessenger: pigeonVar_binaryMessenger,
    );
    final List<Object?>? pigeonVar_replyList =
        await pigeonVar_channel.send(<Object?>[textureId]) as List<Object?>?;
    if (pigeonVar_replyList == null) {
      throw _createConnectionError(pigeonVar_channelName);
    } else if (pigeonVar_replyList.length > 1) {
      throw PlatformException(
        code: pigeonVar_replyList[0]! as String,
        message: pigeonVar_replyList[1] as String?,
        details: pigeonVar_replyList[2],
      );
    } else {
      return;
    }
  }

  Future<void> setMixWithOthers(bool mixWithOthers) async {
    final String pigeonVar_channelName = 'dev.flutter.pigeon.video_player_avfoundation.AVFoundationVideoPlayerApi.setMixWithOthers$pigeonVar_messageChannelSuffix';
    final BasicMessageChannel<Object?> pigeonVar_channel = BasicMessageChannel<Object?>(
      pigeonVar_channelName,
      pigeonChannelCodec,
      binaryMessenger: pigeonVar_binaryMessenger,
    );
    final List<Object?>? pigeonVar_replyList =
        await pigeonVar_channel.send(<Object?>[mixWithOthers]) as List<Object?>?;
    if (pigeonVar_replyList == null) {
      throw _createConnectionError(pigeonVar_channelName);
    } else if (pigeonVar_replyList.length > 1) {
      throw PlatformException(
        code: pigeonVar_replyList[0]! as String,
        message: pigeonVar_replyList[1] as String?,
        details: pigeonVar_replyList[2],
      );
    } else {
      return;
    }
  }

  Future<bool> isPictureInPictureSupported() async {
    final String pigeonVar_channelName = 'dev.flutter.pigeon.video_player_avfoundation.AVFoundationVideoPlayerApi.isPictureInPictureSupported$pigeonVar_messageChannelSuffix';
    final BasicMessageChannel<Object?> pigeonVar_channel = BasicMessageChannel<Object?>(
      pigeonVar_channelName,
      pigeonChannelCodec,
      binaryMessenger: pigeonVar_binaryMessenger,
    );
    final List<Object?>? pigeonVar_replyList =
        await pigeonVar_channel.send(null) as List<Object?>?;
    if (pigeonVar_replyList == null) {
      throw _createConnectionError(pigeonVar_channelName);
    } else if (pigeonVar_replyList.length > 1) {
      throw PlatformException(
        code: pigeonVar_replyList[0]! as String,
        message: pigeonVar_replyList[1] as String?,
        details: pigeonVar_replyList[2],
      );
    } else if (pigeonVar_replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (pigeonVar_replyList[0] as bool?)!;
    }
  }

  Future<void> setPictureInPictureOverlaySettings(SetPictureInPictureOverlaySettingsMessage msg) async {
    final String pigeonVar_channelName = 'dev.flutter.pigeon.video_player_avfoundation.AVFoundationVideoPlayerApi.setPictureInPictureOverlaySettings$pigeonVar_messageChannelSuffix';
    final BasicMessageChannel<Object?> pigeonVar_channel = BasicMessageChannel<Object?>(
      pigeonVar_channelName,
      pigeonChannelCodec,
      binaryMessenger: pigeonVar_binaryMessenger,
    );
    final List<Object?>? pigeonVar_replyList =
        await pigeonVar_channel.send(<Object?>[msg]) as List<Object?>?;
    if (pigeonVar_replyList == null) {
      throw _createConnectionError(pigeonVar_channelName);
    } else if (pigeonVar_replyList.length > 1) {
      throw PlatformException(
        code: pigeonVar_replyList[0]! as String,
        message: pigeonVar_replyList[1] as String?,
        details: pigeonVar_replyList[2],
      );
    } else {
      return;
    }
  }

  Future<void> setAutomaticallyStartsPictureInPicture(AutomaticallyStartsPictureInPictureMessage msg) async {
    final String pigeonVar_channelName = 'dev.flutter.pigeon.video_player_avfoundation.AVFoundationVideoPlayerApi.setAutomaticallyStartsPictureInPicture$pigeonVar_messageChannelSuffix';
    final BasicMessageChannel<Object?> pigeonVar_channel = BasicMessageChannel<Object?>(
      pigeonVar_channelName,
      pigeonChannelCodec,
      binaryMessenger: pigeonVar_binaryMessenger,
    );
    final List<Object?>? pigeonVar_replyList =
        await pigeonVar_channel.send(<Object?>[msg]) as List<Object?>?;
    if (pigeonVar_replyList == null) {
      throw _createConnectionError(pigeonVar_channelName);
    } else if (pigeonVar_replyList.length > 1) {
      throw PlatformException(
        code: pigeonVar_replyList[0]! as String,
        message: pigeonVar_replyList[1] as String?,
        details: pigeonVar_replyList[2],
      );
    } else {
      return;
    }
  }

  Future<void> startPictureInPicture(StartPictureInPictureMessage msg) async {
    final String pigeonVar_channelName = 'dev.flutter.pigeon.video_player_avfoundation.AVFoundationVideoPlayerApi.startPictureInPicture$pigeonVar_messageChannelSuffix';
    final BasicMessageChannel<Object?> pigeonVar_channel = BasicMessageChannel<Object?>(
      pigeonVar_channelName,
      pigeonChannelCodec,
      binaryMessenger: pigeonVar_binaryMessenger,
    );
    final List<Object?>? pigeonVar_replyList =
        await pigeonVar_channel.send(<Object?>[msg]) as List<Object?>?;
    if (pigeonVar_replyList == null) {
      throw _createConnectionError(pigeonVar_channelName);
    } else if (pigeonVar_replyList.length > 1) {
      throw PlatformException(
        code: pigeonVar_replyList[0]! as String,
        message: pigeonVar_replyList[1] as String?,
        details: pigeonVar_replyList[2],
      );
    } else {
      return;
    }
  }

  Future<void> stopPictureInPicture(StopPictureInPictureMessage msg) async {
    final String pigeonVar_channelName = 'dev.flutter.pigeon.video_player_avfoundation.AVFoundationVideoPlayerApi.stopPictureInPicture$pigeonVar_messageChannelSuffix';
    final BasicMessageChannel<Object?> pigeonVar_channel = BasicMessageChannel<Object?>(
      pigeonVar_channelName,
      pigeonChannelCodec,
      binaryMessenger: pigeonVar_binaryMessenger,
    );
    final List<Object?>? pigeonVar_replyList =
        await pigeonVar_channel.send(<Object?>[msg]) as List<Object?>?;
    if (pigeonVar_replyList == null) {
      throw _createConnectionError(pigeonVar_channelName);
    } else if (pigeonVar_replyList.length > 1) {
      throw PlatformException(
        code: pigeonVar_replyList[0]! as String,
        message: pigeonVar_replyList[1] as String?,
        details: pigeonVar_replyList[2],
      );
    } else {
      return;
    }
  }
}
