// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v20.0.1), do not edit directly.
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

List<Object?> wrapResponse(
    {Object? result, PlatformException? error, bool empty = false}) {
  if (empty) {
    return <Object?>[];
  }
  if (error == null) {
    return <Object?>[result];
  }
  return <Object?>[error.code, error.message, error.details];
}

/// Home screen quick-action shortcut item.
class ShortcutItemMessage {
  ShortcutItemMessage({
    required this.type,
    required this.localizedTitle,
    this.localizedSubtitle,
    this.icon,
  });

  /// The identifier of this item; should be unique within the app.
  String type;

  /// Localized title of the item.
  String localizedTitle;

  /// Localized subtitle of the item.
  String? localizedSubtitle;

  /// Name of native resource to be displayed as the icon for this item.
  String? icon;

  Object encode() {
    return <Object?>[
      type,
      localizedTitle,
      localizedSubtitle,
      icon,
    ];
  }

  static ShortcutItemMessage decode(Object result) {
    result as List<Object?>;
    return ShortcutItemMessage(
      type: result[0]! as String,
      localizedTitle: result[1]! as String,
      localizedSubtitle: result[2] as String?,
      icon: result[3] as String?,
    );
  }
}

class _PigeonCodec extends StandardMessageCodec {
  const _PigeonCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is ShortcutItemMessage) {
      buffer.putUint8(129);
      writeValue(buffer, value.encode());
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 129:
        return ShortcutItemMessage.decode(readValue(buffer)!);
      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

class IOSQuickActionsApi {
  /// Constructor for [IOSQuickActionsApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  IOSQuickActionsApi(
      {BinaryMessenger? binaryMessenger, String messageChannelSuffix = ''})
      : __pigeon_binaryMessenger = binaryMessenger,
        __pigeon_messageChannelSuffix =
            messageChannelSuffix.isNotEmpty ? '.$messageChannelSuffix' : '';
  final BinaryMessenger? __pigeon_binaryMessenger;

  static const MessageCodec<Object?> pigeonChannelCodec = _PigeonCodec();

  final String __pigeon_messageChannelSuffix;

  /// Sets the dynamic shortcuts for the app.
  Future<void> setShortcutItems(List<ShortcutItemMessage?> itemsList) async {
    final String __pigeon_channelName =
        'dev.flutter.pigeon.quick_actions_ios.IOSQuickActionsApi.setShortcutItems$__pigeon_messageChannelSuffix';
    final BasicMessageChannel<Object?> __pigeon_channel =
        BasicMessageChannel<Object?>(
      __pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: __pigeon_binaryMessenger,
    );
    final List<Object?>? __pigeon_replyList =
        await __pigeon_channel.send(<Object?>[itemsList]) as List<Object?>?;
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

  /// Removes all dynamic shortcuts.
  Future<void> clearShortcutItems() async {
    final String __pigeon_channelName =
        'dev.flutter.pigeon.quick_actions_ios.IOSQuickActionsApi.clearShortcutItems$__pigeon_messageChannelSuffix';
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
    } else {
      return;
    }
  }
}

abstract class IOSQuickActionsFlutterApi {
  static const MessageCodec<Object?> pigeonChannelCodec = _PigeonCodec();

  /// Sends a string representing a shortcut from the native platform to the app.
  void launchAction(String action);

  static void setUp(
    IOSQuickActionsFlutterApi? api, {
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) {
    messageChannelSuffix =
        messageChannelSuffix.isNotEmpty ? '.$messageChannelSuffix' : '';
    {
      final BasicMessageChannel<Object?> __pigeon_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.quick_actions_ios.IOSQuickActionsFlutterApi.launchAction$messageChannelSuffix',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        __pigeon_channel.setMessageHandler(null);
      } else {
        __pigeon_channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.quick_actions_ios.IOSQuickActionsFlutterApi.launchAction was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final String? arg_action = (args[0] as String?);
          assert(arg_action != null,
              'Argument for dev.flutter.pigeon.quick_actions_ios.IOSQuickActionsFlutterApi.launchAction was null, expected non-null String.');
          try {
            api.launchAction(arg_action!);
            return wrapResponse(empty: true);
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
