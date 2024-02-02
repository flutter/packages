// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Autogenerated from Pigeon, do not edit directly.
// See also: https://pub.dev/packages/pigeon
// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, prefer_null_aware_operators, omit_local_variable_types, unused_shown_name, unnecessary_import, no_leading_underscores_for_local_identifiers, camel_case_types

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

class PrimitiveHostApi {
  /// Constructor for [PrimitiveHostApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  PrimitiveHostApi({BinaryMessenger? binaryMessenger})
      : __pigeon_binaryMessenger = binaryMessenger;
  final BinaryMessenger? __pigeon_binaryMessenger;

  static const MessageCodec<Object?> pigeonChannelCodec =
      StandardMessageCodec();

  Future<int> anInt(int value) async {
    const String __pigeon_channelName =
        'dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.anInt';
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

  Future<bool> aBool(bool value) async {
    const String __pigeon_channelName =
        'dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aBool';
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
      return (__pigeon_replyList[0] as bool?)!;
    }
  }

  Future<String> aString(String value) async {
    const String __pigeon_channelName =
        'dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aString';
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
      return (__pigeon_replyList[0] as String?)!;
    }
  }

  Future<double> aDouble(double value) async {
    const String __pigeon_channelName =
        'dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aDouble';
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
      return (__pigeon_replyList[0] as double?)!;
    }
  }

  Future<Map<Object?, Object?>> aMap(Map<Object?, Object?> value) async {
    const String __pigeon_channelName =
        'dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aMap';
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
      return (__pigeon_replyList[0] as Map<Object?, Object?>?)!;
    }
  }

  Future<List<Object?>> aList(List<Object?> value) async {
    const String __pigeon_channelName =
        'dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aList';
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
      return (__pigeon_replyList[0] as List<Object?>?)!;
    }
  }

  Future<Int32List> anInt32List(Int32List value) async {
    const String __pigeon_channelName =
        'dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.anInt32List';
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
      return (__pigeon_replyList[0] as Int32List?)!;
    }
  }

  Future<List<bool?>> aBoolList(List<bool?> value) async {
    const String __pigeon_channelName =
        'dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aBoolList';
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
      return (__pigeon_replyList[0] as List<Object?>?)!.cast<bool?>();
    }
  }

  Future<Map<String?, int?>> aStringIntMap(Map<String?, int?> value) async {
    const String __pigeon_channelName =
        'dev.flutter.pigeon.pigeon_integration_tests.PrimitiveHostApi.aStringIntMap';
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
      return (__pigeon_replyList[0] as Map<Object?, Object?>?)!
          .cast<String?, int?>();
    }
  }
}

abstract class PrimitiveFlutterApi {
  static const MessageCodec<Object?> pigeonChannelCodec =
      StandardMessageCodec();

  int anInt(int value);

  bool aBool(bool value);

  String aString(String value);

  double aDouble(double value);

  Map<Object?, Object?> aMap(Map<Object?, Object?> value);

  List<Object?> aList(List<Object?> value);

  Int32List anInt32List(Int32List value);

  List<bool?> aBoolList(List<bool?> value);

  Map<String?, int?> aStringIntMap(Map<String?, int?> value);

  static void setup(PrimitiveFlutterApi? api,
      {BinaryMessenger? binaryMessenger}) {
    {
      final BasicMessageChannel<Object?> __pigeon_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.pigeon_integration_tests.PrimitiveFlutterApi.anInt',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        __pigeon_channel.setMessageHandler(null);
      } else {
        __pigeon_channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.pigeon_integration_tests.PrimitiveFlutterApi.anInt was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final int? arg_value = (args[0] as int?);
          assert(arg_value != null,
              'Argument for dev.flutter.pigeon.pigeon_integration_tests.PrimitiveFlutterApi.anInt was null, expected non-null int.');
          try {
            final int output = api.anInt(arg_value!);
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
    {
      final BasicMessageChannel<Object?> __pigeon_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.pigeon_integration_tests.PrimitiveFlutterApi.aBool',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        __pigeon_channel.setMessageHandler(null);
      } else {
        __pigeon_channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.pigeon_integration_tests.PrimitiveFlutterApi.aBool was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final bool? arg_value = (args[0] as bool?);
          assert(arg_value != null,
              'Argument for dev.flutter.pigeon.pigeon_integration_tests.PrimitiveFlutterApi.aBool was null, expected non-null bool.');
          try {
            final bool output = api.aBool(arg_value!);
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
    {
      final BasicMessageChannel<Object?> __pigeon_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.pigeon_integration_tests.PrimitiveFlutterApi.aString',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        __pigeon_channel.setMessageHandler(null);
      } else {
        __pigeon_channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.pigeon_integration_tests.PrimitiveFlutterApi.aString was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final String? arg_value = (args[0] as String?);
          assert(arg_value != null,
              'Argument for dev.flutter.pigeon.pigeon_integration_tests.PrimitiveFlutterApi.aString was null, expected non-null String.');
          try {
            final String output = api.aString(arg_value!);
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
    {
      final BasicMessageChannel<Object?> __pigeon_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.pigeon_integration_tests.PrimitiveFlutterApi.aDouble',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        __pigeon_channel.setMessageHandler(null);
      } else {
        __pigeon_channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.pigeon_integration_tests.PrimitiveFlutterApi.aDouble was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final double? arg_value = (args[0] as double?);
          assert(arg_value != null,
              'Argument for dev.flutter.pigeon.pigeon_integration_tests.PrimitiveFlutterApi.aDouble was null, expected non-null double.');
          try {
            final double output = api.aDouble(arg_value!);
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
    {
      final BasicMessageChannel<Object?> __pigeon_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.pigeon_integration_tests.PrimitiveFlutterApi.aMap',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        __pigeon_channel.setMessageHandler(null);
      } else {
        __pigeon_channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.pigeon_integration_tests.PrimitiveFlutterApi.aMap was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final Map<Object?, Object?>? arg_value =
              (args[0] as Map<Object?, Object?>?);
          assert(arg_value != null,
              'Argument for dev.flutter.pigeon.pigeon_integration_tests.PrimitiveFlutterApi.aMap was null, expected non-null Map<Object?, Object?>.');
          try {
            final Map<Object?, Object?> output = api.aMap(arg_value!);
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
    {
      final BasicMessageChannel<Object?> __pigeon_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.pigeon_integration_tests.PrimitiveFlutterApi.aList',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        __pigeon_channel.setMessageHandler(null);
      } else {
        __pigeon_channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.pigeon_integration_tests.PrimitiveFlutterApi.aList was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final List<Object?>? arg_value = (args[0] as List<Object?>?);
          assert(arg_value != null,
              'Argument for dev.flutter.pigeon.pigeon_integration_tests.PrimitiveFlutterApi.aList was null, expected non-null List<Object?>.');
          try {
            final List<Object?> output = api.aList(arg_value!);
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
    {
      final BasicMessageChannel<Object?> __pigeon_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.pigeon_integration_tests.PrimitiveFlutterApi.anInt32List',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        __pigeon_channel.setMessageHandler(null);
      } else {
        __pigeon_channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.pigeon_integration_tests.PrimitiveFlutterApi.anInt32List was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final Int32List? arg_value = (args[0] as Int32List?);
          assert(arg_value != null,
              'Argument for dev.flutter.pigeon.pigeon_integration_tests.PrimitiveFlutterApi.anInt32List was null, expected non-null Int32List.');
          try {
            final Int32List output = api.anInt32List(arg_value!);
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
    {
      final BasicMessageChannel<Object?> __pigeon_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.pigeon_integration_tests.PrimitiveFlutterApi.aBoolList',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        __pigeon_channel.setMessageHandler(null);
      } else {
        __pigeon_channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.pigeon_integration_tests.PrimitiveFlutterApi.aBoolList was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final List<bool?>? arg_value =
              (args[0] as List<Object?>?)?.cast<bool?>();
          assert(arg_value != null,
              'Argument for dev.flutter.pigeon.pigeon_integration_tests.PrimitiveFlutterApi.aBoolList was null, expected non-null List<bool?>.');
          try {
            final List<bool?> output = api.aBoolList(arg_value!);
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
    {
      final BasicMessageChannel<Object?> __pigeon_channel = BasicMessageChannel<
              Object?>(
          'dev.flutter.pigeon.pigeon_integration_tests.PrimitiveFlutterApi.aStringIntMap',
          pigeonChannelCodec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        __pigeon_channel.setMessageHandler(null);
      } else {
        __pigeon_channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.pigeon_integration_tests.PrimitiveFlutterApi.aStringIntMap was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final Map<String?, int?>? arg_value =
              (args[0] as Map<Object?, Object?>?)?.cast<String?, int?>();
          assert(arg_value != null,
              'Argument for dev.flutter.pigeon.pigeon_integration_tests.PrimitiveFlutterApi.aStringIntMap was null, expected non-null Map<String?, int?>.');
          try {
            final Map<String?, int?> output = api.aStringIntMap(arg_value!);
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
