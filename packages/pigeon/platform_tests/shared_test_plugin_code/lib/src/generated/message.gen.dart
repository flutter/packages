// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Autogenerated from Pigeon, do not edit directly.
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

/// This comment is to test enum documentation comments.
///
/// This comment also tests multiple line comments.
///
/// ////////////////////////
/// This comment also tests comments that start with '/'
/// ////////////////////////
enum MessageRequestState {
  pending,
  success,
  failure,
}

/// This comment is to test class documentation comments.
///
/// This comment also tests multiple line comments.
class MessageSearchRequest {
  MessageSearchRequest({
    this.query,
    this.anInt,
    this.aBool,
  });

  /// This comment is to test field documentation comments.
  String? query;

  /// This comment is to test field documentation comments.
  int? anInt;

  /// This comment is to test field documentation comments.
  bool? aBool;

  List<Object?> _toList() {
    return <Object?>[
      query,
      anInt,
      aBool,
    ];
  }

  Object encode() {
    return _toList();
  }

  static MessageSearchRequest decode(Object result) {
    result as List<Object?>;
    return MessageSearchRequest(
      query: result[0] as String?,
      anInt: result[1] as int?,
      aBool: result[2] as bool?,
    );
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) {
    if (other is! MessageSearchRequest || other.runtimeType != runtimeType) {
      return false;
    }
    if (identical(this, other)) {
      return true;
    }
    return query == other.query && anInt == other.anInt && aBool == other.aBool;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => Object.hashAll(_toList());
}

/// This comment is to test class documentation comments.
class MessageSearchReply {
  MessageSearchReply({
    this.result,
    this.error,
    this.state,
  });

  /// This comment is to test field documentation comments.
  ///
  /// This comment also tests multiple line comments.
  String? result;

  /// This comment is to test field documentation comments.
  String? error;

  /// This comment is to test field documentation comments.
  MessageRequestState? state;

  List<Object?> _toList() {
    return <Object?>[
      result,
      error,
      state,
    ];
  }

  Object encode() {
    return _toList();
  }

  static MessageSearchReply decode(Object result) {
    result as List<Object?>;
    return MessageSearchReply(
      result: result[0] as String?,
      error: result[1] as String?,
      state: result[2] as MessageRequestState?,
    );
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) {
    if (other is! MessageSearchReply || other.runtimeType != runtimeType) {
      return false;
    }
    if (identical(this, other)) {
      return true;
    }
    return result == other.result &&
        error == other.error &&
        state == other.state;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => Object.hashAll(_toList());
}

/// This comment is to test class documentation comments.
class MessageNested {
  MessageNested({
    this.request,
  });

  /// This comment is to test field documentation comments.
  MessageSearchRequest? request;

  List<Object?> _toList() {
    return <Object?>[
      request,
    ];
  }

  Object encode() {
    return _toList();
  }

  static MessageNested decode(Object result) {
    result as List<Object?>;
    return MessageNested(
      request: result[0] as MessageSearchRequest?,
    );
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) {
    if (other is! MessageNested || other.runtimeType != runtimeType) {
      return false;
    }
    if (identical(this, other)) {
      return true;
    }
    return request == other.request;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => Object.hashAll(_toList());
}

class _PigeonCodec extends StandardMessageCodec {
  const _PigeonCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is int) {
      buffer.putUint8(4);
      buffer.putInt64(value);
    } else if (value is MessageRequestState) {
      buffer.putUint8(129);
      writeValue(buffer, value.index);
    } else if (value is MessageSearchRequest) {
      buffer.putUint8(130);
      writeValue(buffer, value.encode());
    } else if (value is MessageSearchReply) {
      buffer.putUint8(131);
      writeValue(buffer, value.encode());
    } else if (value is MessageNested) {
      buffer.putUint8(132);
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
        return value == null ? null : MessageRequestState.values[value];
      case 130:
        return MessageSearchRequest.decode(readValue(buffer)!);
      case 131:
        return MessageSearchReply.decode(readValue(buffer)!);
      case 132:
        return MessageNested.decode(readValue(buffer)!);
      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

/// This comment is to test api documentation comments.
///
/// This comment also tests multiple line comments.
class MessageApi {
  /// Constructor for [MessageApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  MessageApi(
      {BinaryMessenger? binaryMessenger, String messageChannelSuffix = ''})
      : pigeonVar_binaryMessenger = binaryMessenger,
        pigeonVar_messageChannelSuffix =
            messageChannelSuffix.isNotEmpty ? '.$messageChannelSuffix' : '';
  final BinaryMessenger? pigeonVar_binaryMessenger;

  static const MessageCodec<Object?> pigeonChannelCodec = _PigeonCodec();

  final String pigeonVar_messageChannelSuffix;

  /// This comment is to test documentation comments.
  ///
  /// This comment also tests multiple line comments.
  Future<void> initialize() async {
    final String pigeonVar_channelName =
        'dev.flutter.pigeon.pigeon_integration_tests.MessageApi.initialize$pigeonVar_messageChannelSuffix';
    final BasicMessageChannel<Object?> pigeonVar_channel =
        BasicMessageChannel<Object?>(
      pigeonVar_channelName,
      pigeonChannelCodec,
      binaryMessenger: pigeonVar_binaryMessenger,
    );
    final Future<Object?> pigeonVar_sendFuture = pigeonVar_channel.send(null);
    final List<Object?>? pigeonVar_replyList =
        await pigeonVar_sendFuture as List<Object?>?;
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

  /// This comment is to test method documentation comments.
  Future<MessageSearchReply> search(MessageSearchRequest request) async {
    final String pigeonVar_channelName =
        'dev.flutter.pigeon.pigeon_integration_tests.MessageApi.search$pigeonVar_messageChannelSuffix';
    final BasicMessageChannel<Object?> pigeonVar_channel =
        BasicMessageChannel<Object?>(
      pigeonVar_channelName,
      pigeonChannelCodec,
      binaryMessenger: pigeonVar_binaryMessenger,
    );
    final Future<Object?> pigeonVar_sendFuture =
        pigeonVar_channel.send(<Object?>[request]);
    final List<Object?>? pigeonVar_replyList =
        await pigeonVar_sendFuture as List<Object?>?;
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
      return (pigeonVar_replyList[0] as MessageSearchReply?)!;
    }
  }
}

/// This comment is to test api documentation comments.
class MessageNestedApi {
  /// Constructor for [MessageNestedApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  MessageNestedApi(
      {BinaryMessenger? binaryMessenger, String messageChannelSuffix = ''})
      : pigeonVar_binaryMessenger = binaryMessenger,
        pigeonVar_messageChannelSuffix =
            messageChannelSuffix.isNotEmpty ? '.$messageChannelSuffix' : '';
  final BinaryMessenger? pigeonVar_binaryMessenger;

  static const MessageCodec<Object?> pigeonChannelCodec = _PigeonCodec();

  final String pigeonVar_messageChannelSuffix;

  /// This comment is to test method documentation comments.
  ///
  /// This comment also tests multiple line comments.
  Future<MessageSearchReply> search(MessageNested nested) async {
    final String pigeonVar_channelName =
        'dev.flutter.pigeon.pigeon_integration_tests.MessageNestedApi.search$pigeonVar_messageChannelSuffix';
    final BasicMessageChannel<Object?> pigeonVar_channel =
        BasicMessageChannel<Object?>(
      pigeonVar_channelName,
      pigeonChannelCodec,
      binaryMessenger: pigeonVar_binaryMessenger,
    );
    final Future<Object?> pigeonVar_sendFuture =
        pigeonVar_channel.send(<Object?>[nested]);
    final List<Object?>? pigeonVar_replyList =
        await pigeonVar_sendFuture as List<Object?>?;
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
      return (pigeonVar_replyList[0] as MessageSearchReply?)!;
    }
  }
}

/// This comment is to test api documentation comments.
abstract class MessageFlutterSearchApi {
  static const MessageCodec<Object?> pigeonChannelCodec = _PigeonCodec();

  /// This comment is to test method documentation comments.
  MessageSearchReply search(MessageSearchRequest request);

  static void setUp(
    MessageFlutterSearchApi? api, {
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) {
    messageChannelSuffix =
        messageChannelSuffix.isNotEmpty ? '.$messageChannelSuffix' : '';
    {
      final BasicMessageChannel<
          Object?> pigeonVar_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.pigeon_integration_tests.MessageFlutterSearchApi.search$messageChannelSuffix',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        pigeonVar_channel.setMessageHandler(null);
      } else {
        pigeonVar_channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.pigeon_integration_tests.MessageFlutterSearchApi.search was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final MessageSearchRequest? arg_request =
              (args[0] as MessageSearchRequest?);
          assert(arg_request != null,
              'Argument for dev.flutter.pigeon.pigeon_integration_tests.MessageFlutterSearchApi.search was null, expected non-null MessageSearchRequest.');
          try {
            final MessageSearchReply output = api.search(arg_request!);
            return wrapResponse(result: output);
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
