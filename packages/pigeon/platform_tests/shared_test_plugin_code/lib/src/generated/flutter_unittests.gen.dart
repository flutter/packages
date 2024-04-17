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

class FlutterSearchRequest {
  FlutterSearchRequest({
    this.query,
  });

  String? query;

  Object encode() {
    return <Object?>[
      query,
    ];
  }

  static FlutterSearchRequest decode(Object result) {
    result as List<Object?>;
    return FlutterSearchRequest(
      query: result[0] as String?,
    );
  }
}

class FlutterSearchReply {
  FlutterSearchReply({
    this.result,
    this.error,
  });

  String? result;

  String? error;

  Object encode() {
    return <Object?>[
      result,
      error,
    ];
  }

  static FlutterSearchReply decode(Object result) {
    result as List<Object?>;
    return FlutterSearchReply(
      result: result[0] as String?,
      error: result[1] as String?,
    );
  }
}

class FlutterSearchRequests {
  FlutterSearchRequests({
    this.requests,
  });

  List<Object?>? requests;

  Object encode() {
    return <Object?>[
      requests,
    ];
  }

  static FlutterSearchRequests decode(Object result) {
    result as List<Object?>;
    return FlutterSearchRequests(
      requests: result[0] as List<Object?>?,
    );
  }
}

class FlutterSearchReplies {
  FlutterSearchReplies({
    this.replies,
  });

  List<Object?>? replies;

  Object encode() {
    return <Object?>[
      replies,
    ];
  }

  static FlutterSearchReplies decode(Object result) {
    result as List<Object?>;
    return FlutterSearchReplies(
      replies: result[0] as List<Object?>?,
    );
  }
}

class _ApiCodec extends StandardMessageCodec {
  const _ApiCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is FlutterSearchReplies) {
      buffer.putUint8(128);
      writeValue(buffer, value.encode());
    } else if (value is FlutterSearchReply) {
      buffer.putUint8(129);
      writeValue(buffer, value.encode());
    } else if (value is FlutterSearchRequest) {
      buffer.putUint8(130);
      writeValue(buffer, value.encode());
    } else if (value is FlutterSearchRequests) {
      buffer.putUint8(131);
      writeValue(buffer, value.encode());
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 128:
        return FlutterSearchReplies.decode(readValue(buffer)!);
      case 129:
        return FlutterSearchReply.decode(readValue(buffer)!);
      case 130:
        return FlutterSearchRequest.decode(readValue(buffer)!);
      case 131:
        return FlutterSearchRequests.decode(readValue(buffer)!);
      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

class Api {
  /// Constructor for [Api].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  Api({BinaryMessenger? binaryMessenger, String messageChannelSuffix = ''})
      : __pigeon_binaryMessenger = binaryMessenger,
        __pigeon_messageChannelSuffix =
            messageChannelSuffix.isNotEmpty ? '.$messageChannelSuffix' : '';
  final BinaryMessenger? __pigeon_binaryMessenger;

  static const MessageCodec<Object?> pigeonChannelCodec = _ApiCodec();

  final String __pigeon_messageChannelSuffix;

  Future<FlutterSearchReply> search(FlutterSearchRequest request) async {
    final String __pigeon_channelName =
        'dev.flutter.pigeon.pigeon_integration_tests.Api.search$__pigeon_messageChannelSuffix';
    final BasicMessageChannel<Object?> __pigeon_channel =
        BasicMessageChannel<Object?>(
      __pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: __pigeon_binaryMessenger,
    );
    final List<Object?>? __pigeon_replyList =
        await __pigeon_channel.send(<Object?>[request]) as List<Object?>?;
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
      return (__pigeon_replyList[0] as FlutterSearchReply?)!;
    }
  }

  Future<FlutterSearchReplies> doSearches(FlutterSearchRequests request) async {
    final String __pigeon_channelName =
        'dev.flutter.pigeon.pigeon_integration_tests.Api.doSearches$__pigeon_messageChannelSuffix';
    final BasicMessageChannel<Object?> __pigeon_channel =
        BasicMessageChannel<Object?>(
      __pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: __pigeon_binaryMessenger,
    );
    final List<Object?>? __pigeon_replyList =
        await __pigeon_channel.send(<Object?>[request]) as List<Object?>?;
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
      return (__pigeon_replyList[0] as FlutterSearchReplies?)!;
    }
  }

  Future<FlutterSearchRequests> echo(FlutterSearchRequests requests) async {
    final String __pigeon_channelName =
        'dev.flutter.pigeon.pigeon_integration_tests.Api.echo$__pigeon_messageChannelSuffix';
    final BasicMessageChannel<Object?> __pigeon_channel =
        BasicMessageChannel<Object?>(
      __pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: __pigeon_binaryMessenger,
    );
    final List<Object?>? __pigeon_replyList =
        await __pigeon_channel.send(<Object?>[requests]) as List<Object?>?;
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
      return (__pigeon_replyList[0] as FlutterSearchRequests?)!;
    }
  }

  Future<int> anInt(int value) async {
    final String __pigeon_channelName =
        'dev.flutter.pigeon.pigeon_integration_tests.Api.anInt$__pigeon_messageChannelSuffix';
    final BasicMessageChannel<Object?> __pigeon_channel =
        BasicMessageChannel<Object?>(
      __pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: __pigeon_binaryMessenger,
    );
    final List<Object?>? __pigeon_replyList =
        await __pigeon_channel.send(<Object?>[value]) as List<Object?>?;
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
      return (__pigeon_replyList[0] as int?)!;
    }
  }
}
