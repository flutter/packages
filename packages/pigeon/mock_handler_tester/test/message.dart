// Autogenerated from Pigeon (v0.2.0-nullsafety.0), do not edit directly.
// See also: https://pub.dev/packages/pigeon
// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import
// @dart = 2.12
import 'dart:async';
import 'dart:typed_data' show Uint8List, Int32List, Int64List, Float64List;

import 'package:flutter/services.dart';

class SearchReply {
  String? result;
  String? error;

  Object encode() {
    final Map<Object?, Object?> pigeonMap = <Object?, Object?>{};
    pigeonMap['result'] = result;
    pigeonMap['error'] = error;
    return pigeonMap;
  }

  static SearchReply decode(Object? message) {
    if (message == null) {
      return SearchReply();
    }
    final Map<Object?, Object?> pigeonMap = message as Map<Object?, Object?>;
    return SearchReply()
      ..result = pigeonMap['result'] as String?
      ..error = pigeonMap['error'] as String?;
  }
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

  static SearchRequest decode(Object? message) {
    if (message == null) {
      return SearchRequest();
    }
    final Map<Object?, Object?> pigeonMap = message as Map<Object?, Object?>;
    return SearchRequest()
      ..query = pigeonMap['query'] as String?
      ..anInt = pigeonMap['anInt'] as int?
      ..aBool = pigeonMap['aBool'] as bool?;
  }
}

class Nested {
  SearchRequest? request;

  Object encode() {
    final Map<Object?, Object?> pigeonMap = <Object?, Object?>{};
    pigeonMap['request'] = request == null ? null : request!.encode();
    return pigeonMap;
  }

  static Nested decode(Object? message) {
    if (message == null) {
      return Nested();
    }
    final Map<Object?, Object?> pigeonMap = message as Map<Object?, Object?>;
    return Nested()
      ..request = pigeonMap['request'] != null
          ? SearchRequest.decode(pigeonMap['request']!)
          : null;
  }
}

abstract class FlutterSearchApi {
  SearchReply search(SearchRequest arg);
  static void setup(FlutterSearchApi? api) {
    {
      const BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.FlutterSearchApi.search', StandardMessageCodec());
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          final SearchRequest input = SearchRequest.decode(message);
          final SearchReply output = api.search(input);
          return output.encode();
        });
      }
    }
  }
}

class NestedApi {
  Future<SearchReply> search(Nested arg) async {
    final Object encoded = arg.encode();
    const BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.NestedApi.search', StandardMessageCodec());
    final Map<Object?, Object?>? replyMap =
        await channel.send(encoded) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object?, Object?> error =
          replyMap['error']! as Map<Object?, Object?>;
      throw PlatformException(
        code: error['code'] as String? ?? 'unknown',
        message: error['message'] as String?,
        details: error['details'],
      );
    } else {
      return SearchReply.decode(replyMap['result']!);
    }
  }
}

class Api {
  Future<void> initialize() async {
    const BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.Api.initialize', StandardMessageCodec());
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
          replyMap['error']! as Map<Object?, Object?>;
      throw PlatformException(
        code: error['code'] as String? ?? 'unknown',
        message: error['message'] as String?,
        details: error['details'],
      );
    } else {
      // noop
    }
  }

  Future<SearchReply> search(SearchRequest arg) async {
    final Object encoded = arg.encode();
    const BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.Api.search', StandardMessageCodec());
    final Map<Object?, Object?>? replyMap =
        await channel.send(encoded) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object?, Object?> error =
          replyMap['error']! as Map<Object?, Object?>;
      throw PlatformException(
        code: error['code'] as String? ?? 'unknown',
        message: error['message'] as String?,
        details: error['details'],
      );
    } else {
      return SearchReply.decode(replyMap['result']!);
    }
  }
}
