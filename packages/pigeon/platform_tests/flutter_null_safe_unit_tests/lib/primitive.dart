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

class _PrimitiveHostApiCodec extends StandardMessageCodec {
  const _PrimitiveHostApiCodec();
}

class PrimitiveHostApi {
  /// Constructor for [PrimitiveHostApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  PrimitiveHostApi({BinaryMessenger? binaryMessenger})
      : _binaryMessenger = binaryMessenger;

  final BinaryMessenger? _binaryMessenger;

  static const MessageCodec<Object?> codec = _PrimitiveHostApiCodec();

  Future<int> anInt(int value) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.PrimitiveHostApi.anInt', codec,
        binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(<Object>[value]) as Map<Object?, Object?>?;
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
      return (replyMap['result'] as int?)!;
    }
  }

  Future<bool> aBool(bool value) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.PrimitiveHostApi.aBool', codec,
        binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(<Object>[value]) as Map<Object?, Object?>?;
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
      return (replyMap['result'] as bool?)!;
    }
  }

  Future<String> aString(String value) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.PrimitiveHostApi.aString', codec,
        binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(<Object>[value]) as Map<Object?, Object?>?;
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
      return (replyMap['result'] as String?)!;
    }
  }

  Future<double> aDouble(double value) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.PrimitiveHostApi.aDouble', codec,
        binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(<Object>[value]) as Map<Object?, Object?>?;
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
      return (replyMap['result'] as double?)!;
    }
  }

  Future<Map<Object?, Object?>> aMap(Map<Object?, Object?> value) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.PrimitiveHostApi.aMap', codec,
        binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(<Object>[value]) as Map<Object?, Object?>?;
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
      return (replyMap['result'] as Map<Object?, Object?>?)!;
    }
  }

  Future<List<Object?>> aList(List<Object?> value) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.PrimitiveHostApi.aList', codec,
        binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(<Object>[value]) as Map<Object?, Object?>?;
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
      return (replyMap['result'] as List<Object?>?)!;
    }
  }

  Future<Int32List> anInt32List(Int32List value) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.PrimitiveHostApi.anInt32List', codec,
        binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(<Object>[value]) as Map<Object?, Object?>?;
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
      return (replyMap['result'] as Int32List?)!;
    }
  }

  Future<List<bool?>> aBoolList(List<bool?> value) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.PrimitiveHostApi.aBoolList', codec,
        binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(<Object>[value]) as Map<Object?, Object?>?;
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
      return (replyMap['result'] as List<Object?>?)!.cast<bool?>();
    }
  }

  Future<Map<String?, int?>> aStringIntMap(Map<String?, int?> value) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.PrimitiveHostApi.aStringIntMap', codec,
        binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(<Object>[value]) as Map<Object?, Object?>?;
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
      return (replyMap['result'] as Map<Object?, Object?>?)!
          .cast<String?, int?>();
    }
  }
}

class _PrimitiveFlutterApiCodec extends StandardMessageCodec {
  const _PrimitiveFlutterApiCodec();
}

abstract class PrimitiveFlutterApi {
  static const MessageCodec<Object?> codec = _PrimitiveFlutterApiCodec();

  int anInt(int value);
  bool aBool(bool value);
  String aString(String value);
  double aDouble(double value);
  Map<Object?, Object?> aMap(Map<Object?, Object?> value);
  List<Object?> aList(List<Object?> value);
  Int32List anInt32List(Int32List value);
  List<bool?> aBoolList(List<bool?> value);
  Map<String?, int?> aStringIntMap(Map<String?, int?> value);
  static void setup(PrimitiveFlutterApi? api) {
    {
      const BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.PrimitiveFlutterApi.anInt', codec);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.PrimitiveFlutterApi.anInt was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final int? arg0 = args[0] as int?;
          assert(arg0 != null,
              'Argument for dev.flutter.pigeon.PrimitiveFlutterApi.anInt was null. Expected int.');
          final int output = api.anInt(arg0!);
          return output;
        });
      }
    }
    {
      const BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.PrimitiveFlutterApi.aBool', codec);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.PrimitiveFlutterApi.aBool was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final bool? arg0 = args[0] as bool?;
          assert(arg0 != null,
              'Argument for dev.flutter.pigeon.PrimitiveFlutterApi.aBool was null. Expected bool.');
          final bool output = api.aBool(arg0!);
          return output;
        });
      }
    }
    {
      const BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.PrimitiveFlutterApi.aString', codec);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.PrimitiveFlutterApi.aString was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final String? arg0 = args[0] as String?;
          assert(arg0 != null,
              'Argument for dev.flutter.pigeon.PrimitiveFlutterApi.aString was null. Expected String.');
          final String output = api.aString(arg0!);
          return output;
        });
      }
    }
    {
      const BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.PrimitiveFlutterApi.aDouble', codec);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.PrimitiveFlutterApi.aDouble was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final double? arg0 = args[0] as double?;
          assert(arg0 != null,
              'Argument for dev.flutter.pigeon.PrimitiveFlutterApi.aDouble was null. Expected double.');
          final double output = api.aDouble(arg0!);
          return output;
        });
      }
    }
    {
      const BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.PrimitiveFlutterApi.aMap', codec);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.PrimitiveFlutterApi.aMap was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final Map<Object?, Object?>? arg0 = args[0] as Map<Object?, Object?>?;
          assert(arg0 != null,
              'Argument for dev.flutter.pigeon.PrimitiveFlutterApi.aMap was null. Expected Map<Object?, Object?>.');
          final Map<Object?, Object?> output = api.aMap(arg0!);
          return output;
        });
      }
    }
    {
      const BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.PrimitiveFlutterApi.aList', codec);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.PrimitiveFlutterApi.aList was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final List<Object?>? arg0 = args[0] as List<Object?>?;
          assert(arg0 != null,
              'Argument for dev.flutter.pigeon.PrimitiveFlutterApi.aList was null. Expected List<Object?>.');
          final List<Object?> output = api.aList(arg0!);
          return output;
        });
      }
    }
    {
      const BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.PrimitiveFlutterApi.anInt32List', codec);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.PrimitiveFlutterApi.anInt32List was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final Int32List? arg0 = args[0] as Int32List?;
          assert(arg0 != null,
              'Argument for dev.flutter.pigeon.PrimitiveFlutterApi.anInt32List was null. Expected Int32List.');
          final Int32List output = api.anInt32List(arg0!);
          return output;
        });
      }
    }
    {
      const BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.PrimitiveFlutterApi.aBoolList', codec);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.PrimitiveFlutterApi.aBoolList was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final List<bool?>? arg0 = args[0] as List<bool?>?;
          assert(arg0 != null,
              'Argument for dev.flutter.pigeon.PrimitiveFlutterApi.aBoolList was null. Expected List<bool?>.');
          final List<bool?> output = api.aBoolList(arg0!);
          return output;
        });
      }
    }
    {
      const BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.PrimitiveFlutterApi.aStringIntMap', codec);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.PrimitiveFlutterApi.aStringIntMap was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final Map<String?, int?>? arg0 = args[0] as Map<String?, int?>?;
          assert(arg0 != null,
              'Argument for dev.flutter.pigeon.PrimitiveFlutterApi.aStringIntMap was null. Expected Map<String?, int?>.');
          final Map<String?, int?> output = api.aStringIntMap(arg0!);
          return output;
        });
      }
    }
  }
}
