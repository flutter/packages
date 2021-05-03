// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Autogenerated from Pigeon (v0.2.0), do not edit directly.
// See also: https://pub.dev/packages/pigeon
// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, prefer_null_aware_operators, omit_local_variable_types
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

  static SearchReply decode(Object message) {
    final Map<Object?, Object?> pigeonMap = message as Map<Object?, Object?>;
    return SearchReply()
      ..result = pigeonMap['result'] as String?
      ..error = pigeonMap['error'] as String?;
  }
}

class SearchRequest {
  String? query;

  Object encode() {
    final Map<Object?, Object?> pigeonMap = <Object?, Object?>{};
    pigeonMap['query'] = query;
    return pigeonMap;
  }

  static SearchRequest decode(Object message) {
    final Map<Object?, Object?> pigeonMap = message as Map<Object?, Object?>;
    return SearchRequest()..query = pigeonMap['query'] as String?;
  }
}

class SearchReplies {
  List<Object?>? replies;

  Object encode() {
    final Map<Object?, Object?> pigeonMap = <Object?, Object?>{};
    pigeonMap['replies'] = replies;
    return pigeonMap;
  }

  static SearchReplies decode(Object message) {
    final Map<Object?, Object?> pigeonMap = message as Map<Object?, Object?>;
    return SearchReplies()..replies = pigeonMap['replies'] as List<Object?>?;
  }
}

class SearchRequests {
  List<Object?>? requests;

  Object encode() {
    final Map<Object?, Object?> pigeonMap = <Object?, Object?>{};
    pigeonMap['requests'] = requests;
    return pigeonMap;
  }

  static SearchRequests decode(Object message) {
    final Map<Object?, Object?> pigeonMap = message as Map<Object?, Object?>;
    return SearchRequests()..requests = pigeonMap['requests'] as List<Object?>?;
  }
}

class Api {
  /// Constructor for [Api].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  Api({BinaryMessenger? binaryMessenger}) : _binaryMessenger = binaryMessenger;

  final BinaryMessenger? _binaryMessenger;

  Future<SearchReply> search(SearchRequest arg) async {
    final Object encoded = arg.encode();
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.Api.search', const StandardMessageCodec(),
        binaryMessenger: _binaryMessenger);
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
          (replyMap['error'] as Map<Object?, Object?>?)!;
      throw PlatformException(
        code: (error['code'] as String?)!,
        message: error['message'] as String?,
        details: error['details'],
      );
    } else {
      return SearchReply.decode(replyMap['result']!);
    }
  }

  Future<SearchReplies> doSearches(SearchRequests arg) async {
    final Object encoded = arg.encode();
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.Api.doSearches', const StandardMessageCodec(),
        binaryMessenger: _binaryMessenger);
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
          (replyMap['error'] as Map<Object?, Object?>?)!;
      throw PlatformException(
        code: (error['code'] as String?)!,
        message: error['message'] as String?,
        details: error['details'],
      );
    } else {
      return SearchReplies.decode(replyMap['result']!);
    }
  }
}
