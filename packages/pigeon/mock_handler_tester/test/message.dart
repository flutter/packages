// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Autogenerated from Pigeon (v0.3.0), do not edit directly.
// See also: https://pub.dev/packages/pigeon
// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, prefer_null_aware_operators, omit_local_variable_types, unused_shown_name
// @dart = 2.12
import 'dart:async';
import 'dart:typed_data' show Uint8List, Int32List, Int64List, Float64List;

import 'package:flutter/foundation.dart' show WriteBuffer, ReadBuffer;
import 'package:flutter/services.dart';

enum RequestState {
  pending,
  success,
  failure,
}

class SearchRequest {
  String? query;
  int? anInt;
  bool? aBool;

  Object encode() {
    final Map<Object?, Object?> pigeonMap = <Object?, Object?>{};
    pigeonMap['query'] = query;
    pigeonMap['anInt'] = anInt;
    pigeonMap['aBool'] = aBool;
    return pigeonMap;
  }

  static SearchRequest decode(Object message) {
    final Map<Object?, Object?> pigeonMap = message as Map<Object?, Object?>;
    return SearchRequest()
      ..query = pigeonMap['query'] as String?
      ..anInt = pigeonMap['anInt'] as int?
      ..aBool = pigeonMap['aBool'] as bool?;
  }
}

class SearchReply {
  String? result;
  String? error;
  RequestState? state;

  Object encode() {
    final Map<Object?, Object?> pigeonMap = <Object?, Object?>{};
    pigeonMap['result'] = result;
    pigeonMap['error'] = error;
    pigeonMap['state'] = state == null ? null : state!.index;
    return pigeonMap;
  }

  static SearchReply decode(Object message) {
    final Map<Object?, Object?> pigeonMap = message as Map<Object?, Object?>;
    return SearchReply()
      ..result = pigeonMap['result'] as String?
      ..error = pigeonMap['error'] as String?
      ..state = pigeonMap['state'] != null
          ? RequestState.values[pigeonMap['state']! as int]
          : null;
  }
}

class Nested {
  SearchRequest? request;

  Object encode() {
    final Map<Object?, Object?> pigeonMap = <Object?, Object?>{};
    pigeonMap['request'] = request == null ? null : request!.encode();
    return pigeonMap;
  }

  static Nested decode(Object message) {
    final Map<Object?, Object?> pigeonMap = message as Map<Object?, Object?>;
    return Nested()
      ..request = pigeonMap['request'] != null
          ? SearchRequest.decode(pigeonMap['request']!)
          : null;
  }
}

class _ApiCodec extends StandardMessageCodec {
  const _ApiCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is SearchReply) {
      buffer.putUint8(128);
      writeValue(buffer, value.encode());
    } else if (value is SearchRequest) {
      buffer.putUint8(129);
      writeValue(buffer, value.encode());
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 128:
        return SearchReply.decode(readValue(buffer)!);

      case 129:
        return SearchRequest.decode(readValue(buffer)!);

      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

class Api {
  /// Constructor for [Api].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  Api({BinaryMessenger? binaryMessenger}) : _binaryMessenger = binaryMessenger;

  final BinaryMessenger? _binaryMessenger;

  static const MessageCodec<Object?> codec = _ApiCodec();

  Future<void> initialize() async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.Api.initialize', codec,
        binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(null) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object?, Object?> error =
          (replyMap['error'] as Map<Object?, Object?>?)!;
      throw PlatformException(
        code: (error['code'] as String?)!,
        message: error['message'] as String?,
        details: error['details'],
      );
    } else {
      return;
    }
  }

  Future<SearchReply> search(SearchRequest request) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.Api.search', codec,
        binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(<Object>[request]) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object?, Object?> error =
          (replyMap['error'] as Map<Object?, Object?>?)!;
      throw PlatformException(
        code: (error['code'] as String?)!,
        message: error['message'] as String?,
        details: error['details'],
      );
    } else {
      return (replyMap['result'] as SearchReply?)!;
    }
  }
}

class _NestedApiCodec extends StandardMessageCodec {
  const _NestedApiCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is Nested) {
      buffer.putUint8(128);
      writeValue(buffer, value.encode());
    } else if (value is SearchReply) {
      buffer.putUint8(129);
      writeValue(buffer, value.encode());
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 128:
        return Nested.decode(readValue(buffer)!);

      case 129:
        return SearchReply.decode(readValue(buffer)!);

      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

class NestedApi {
  /// Constructor for [NestedApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  NestedApi({BinaryMessenger? binaryMessenger})
      : _binaryMessenger = binaryMessenger;

  final BinaryMessenger? _binaryMessenger;

  static const MessageCodec<Object?> codec = _NestedApiCodec();

  Future<SearchReply> search(Nested nested) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.NestedApi.search', codec,
        binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(<Object>[nested]) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object?, Object?> error =
          (replyMap['error'] as Map<Object?, Object?>?)!;
      throw PlatformException(
        code: (error['code'] as String?)!,
        message: error['message'] as String?,
        details: error['details'],
      );
    } else {
      return (replyMap['result'] as SearchReply?)!;
    }
  }
}

class _FlutterSearchApiCodec extends StandardMessageCodec {
  const _FlutterSearchApiCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is SearchReply) {
      buffer.putUint8(128);
      writeValue(buffer, value.encode());
    } else if (value is SearchRequest) {
      buffer.putUint8(129);
      writeValue(buffer, value.encode());
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 128:
        return SearchReply.decode(readValue(buffer)!);

      case 129:
        return SearchRequest.decode(readValue(buffer)!);

      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

abstract class FlutterSearchApi {
  static const MessageCodec<Object?> codec = _FlutterSearchApiCodec();

  SearchReply search(SearchRequest request);
  static void setup(FlutterSearchApi? api) {
    {
      const BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.FlutterSearchApi.search', codec);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.FlutterSearchApi.search was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final SearchRequest? arg_request = args[0] as SearchRequest?;
          assert(arg_request != null,
              'Argument for dev.flutter.pigeon.FlutterSearchApi.search was null, expected non-null SearchRequest.');
          final SearchReply output = api.search(arg_request!);
          return output;
        });
      }
    }
  }
}
