// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Autogenerated from Pigeon (v3.1.4), do not edit directly.
// See also: https://pub.dev/packages/pigeon
// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, prefer_null_aware_operators, omit_local_variable_types, unused_shown_name
// @dart = 2.12
import 'dart:async';
import 'dart:typed_data' show Uint8List, Int32List, Int64List, Float64List;

import 'package:flutter/foundation.dart' show WriteBuffer, ReadBuffer;
import 'package:flutter/services.dart';

class _NullableReturnHostApiCodec extends StandardMessageCodec {
  const _NullableReturnHostApiCodec();
}

class NullableReturnHostApi {
  /// Constructor for [NullableReturnHostApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  NullableReturnHostApi({BinaryMessenger? binaryMessenger})
      : _binaryMessenger = binaryMessenger;

  final BinaryMessenger? _binaryMessenger;

  static const MessageCodec<Object?> codec = _NullableReturnHostApiCodec();

  Future<int?> doit() async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.NullableReturnHostApi.doit', codec,
        binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(null) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
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
      return (replyMap['result'] as int?);
    }
  }
}

class _NullableReturnFlutterApiCodec extends StandardMessageCodec {
  const _NullableReturnFlutterApiCodec();
}

abstract class NullableReturnFlutterApi {
  static const MessageCodec<Object?> codec = _NullableReturnFlutterApiCodec();

  int? doit();
  static void setup(NullableReturnFlutterApi? api,
      {BinaryMessenger? binaryMessenger}) {
    {
      final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.NullableReturnFlutterApi.doit', codec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          // ignore message
          final int? output = api.doit();
          return output;
        });
      }
    }
  }
}

class _NullableArgHostApiCodec extends StandardMessageCodec {
  const _NullableArgHostApiCodec();
}

class NullableArgHostApi {
  /// Constructor for [NullableArgHostApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  NullableArgHostApi({BinaryMessenger? binaryMessenger})
      : _binaryMessenger = binaryMessenger;

  final BinaryMessenger? _binaryMessenger;

  static const MessageCodec<Object?> codec = _NullableArgHostApiCodec();

  Future<int> doit(int? arg_x) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.NullableArgHostApi.doit', codec,
        binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(<Object?>[arg_x]) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyMap['error'] != null) {
      final Map<Object?, Object?> error =
          (replyMap['error'] as Map<Object?, Object?>?)!;
      throw PlatformException(
        code: (error['code'] as String?)!,
        message: error['message'] as String?,
        details: error['details'],
      );
    } else if (replyMap['result'] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (replyMap['result'] as int?)!;
    }
  }
}

class _NullableArgFlutterApiCodec extends StandardMessageCodec {
  const _NullableArgFlutterApiCodec();
}

abstract class NullableArgFlutterApi {
  static const MessageCodec<Object?> codec = _NullableArgFlutterApiCodec();

  int doit(int? x);
  static void setup(NullableArgFlutterApi? api,
      {BinaryMessenger? binaryMessenger}) {
    {
      final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.NullableArgFlutterApi.doit', codec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.NullableArgFlutterApi.doit was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final int? arg_x = (args[0] as int?);
          final int output = api.doit(arg_x);
          return output;
        });
      }
    }
  }
}

class _NullableCollectionReturnHostApiCodec extends StandardMessageCodec {
  const _NullableCollectionReturnHostApiCodec();
}

class NullableCollectionReturnHostApi {
  /// Constructor for [NullableCollectionReturnHostApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  NullableCollectionReturnHostApi({BinaryMessenger? binaryMessenger})
      : _binaryMessenger = binaryMessenger;

  final BinaryMessenger? _binaryMessenger;

  static const MessageCodec<Object?> codec =
      _NullableCollectionReturnHostApiCodec();

  Future<List<String?>?> doit() async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.NullableCollectionReturnHostApi.doit', codec,
        binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(null) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
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
      return (replyMap['result'] as List<Object?>?)?.cast<String?>();
    }
  }
}

class _NullableCollectionReturnFlutterApiCodec extends StandardMessageCodec {
  const _NullableCollectionReturnFlutterApiCodec();
}

abstract class NullableCollectionReturnFlutterApi {
  static const MessageCodec<Object?> codec =
      _NullableCollectionReturnFlutterApiCodec();

  List<String?>? doit();
  static void setup(NullableCollectionReturnFlutterApi? api,
      {BinaryMessenger? binaryMessenger}) {
    {
      final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.NullableCollectionReturnFlutterApi.doit', codec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          // ignore message
          final List<String?>? output = api.doit();
          return output;
        });
      }
    }
  }
}

class _NullableCollectionArgHostApiCodec extends StandardMessageCodec {
  const _NullableCollectionArgHostApiCodec();
}

class NullableCollectionArgHostApi {
  /// Constructor for [NullableCollectionArgHostApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  NullableCollectionArgHostApi({BinaryMessenger? binaryMessenger})
      : _binaryMessenger = binaryMessenger;

  final BinaryMessenger? _binaryMessenger;

  static const MessageCodec<Object?> codec =
      _NullableCollectionArgHostApiCodec();

  Future<List<String?>> doit(List<String?>? arg_x) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.NullableCollectionArgHostApi.doit', codec,
        binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(<Object?>[arg_x]) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyMap['error'] != null) {
      final Map<Object?, Object?> error =
          (replyMap['error'] as Map<Object?, Object?>?)!;
      throw PlatformException(
        code: (error['code'] as String?)!,
        message: error['message'] as String?,
        details: error['details'],
      );
    } else if (replyMap['result'] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (replyMap['result'] as List<Object?>?)!.cast<String?>();
    }
  }
}

class _NullableCollectionArgFlutterApiCodec extends StandardMessageCodec {
  const _NullableCollectionArgFlutterApiCodec();
}

abstract class NullableCollectionArgFlutterApi {
  static const MessageCodec<Object?> codec =
      _NullableCollectionArgFlutterApiCodec();

  List<String?> doit(List<String?>? x);
  static void setup(NullableCollectionArgFlutterApi? api,
      {BinaryMessenger? binaryMessenger}) {
    {
      final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.NullableCollectionArgFlutterApi.doit', codec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.NullableCollectionArgFlutterApi.doit was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final List<String?>? arg_x =
              (args[0] as List<Object?>?)?.cast<String?>();
          final List<String?> output = api.doit(arg_x);
          return output;
        });
      }
    }
  }
}
